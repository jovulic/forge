#!/usr/bin/env bash
# shellcheck shell=bash

set -euo pipefail
IFS=$'\n'

FILE_PATH=""
OFFSET=0

while [[ $# -gt 0 ]]; do
  case "$1" in
  --path)
    shift
    FILE_PATH="${1:-}"
    ;;
  --offset)
    shift
    OFFSET="${1:-0}"
    ;;
  --topw | --toph | --width | --height) shift ;; # ignore if passed
  esac
  shift || true
done

[[ -z "${FILE_PATH}" || ! -f "${FILE_PATH}" ]] && {
  echo "No such file: ${FILE_PATH}"
  exit 0
}

have() { command -v "$1" >/dev/null 2>&1; }
emit_image() { echo "__preview__image__path__ $1"; }

hash_str() {
  printf "%s" "$1" | (md5sum 2>/dev/null || shasum 2>/dev/null || sha1sum 2>/dev/null) | awk '{print $1}'
}

# Get video duration dynamically using ffprobe or mediainfo
get_duration() {
  if have ffprobe; then
    ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -- "$1" 2>/dev/null
  elif have mediainfo; then
    local ms
    ms=$(mediainfo --Inform="General;%Duration%" -- "$1" 2>/dev/null)
    if [[ -n "$ms" ]]; then
      echo "$((ms / 1000))"
    fi
  fi
}

DUR_FLOAT=$(get_duration "$FILE_PATH" || echo "")
# convert float to integer (e.g. 12.34 -> 12)
DUR=${DUR_FLOAT%.*}
DUR=${DUR:-0}

# --- TIMELINE SETTINGS ---
if ((DUR > 8)); then
  # For videos longer than 8s, sample across the entire timeline.
  BASE_SECS=$((DUR / 8))
  STEP_SECS=$(((DUR - BASE_SECS) / 8))
  # Avoid 0 step size
  if ((STEP_SECS == 0)); then
    STEP_SECS=1
  fi
else
  # For very short videos (or if duration is undetected), sample closely
  # frame-by-frame.
  BASE_SECS=0
  STEP_SECS=1
fi

# --- THUMB SETTINGS ---
# Set high-resolution dimensions (standard 16:9).
OUT_W=1600
OUT_H=900

cache_key() {
  local st
  if st="$(stat -Lc '%n|%Y|%s' -- "$FILE_PATH" 2>/dev/null)"; then
    :
  else
    st="$(stat -f '%N|%m|%z' -- "$FILE_PATH")"
  fi

  local settings="base=${BASE_SECS}|step=${STEP_SECS}|w=${OUT_W}|h=${OUT_H}|crop=16:9"
  hash_str "${st}|${settings}"
}

TMPDIR="${TMPDIR:-/tmp}"
CACHEDIR="${TMPDIR%/}/yazi-video-timeline"
mkdir -p "$CACHEDIR"

OFFSET=$((OFFSET % 8))
((OFFSET < 0)) && OFFSET=0

# If the video is short (under 8s), loop the offsets within the actual video
# duration. This creates a infinite loop of the video's actual frames and
# prevents displaying duplicate frames at the end of the video.
if ((DUR > 0 && DUR < 8)); then
  OFFSET=$((OFFSET % DUR))
fi

KEY="$(cache_key)"
IMG="${CACHEDIR}/${KEY}.${OFFSET}.jpg"
INFO="${CACHEDIR}/${KEY}.info"

TS=$((BASE_SECS + OFFSET * STEP_SECS))
# Clamping to ensure we don't seek beyond video duration.
if ((DUR > 0 && TS >= DUR)); then
  TS=$((DUR - 1))
fi

# Generate thumbnail if missing.
if [[ ! -s "$IMG" ]]; then
  if have ffmpeg; then
    VF="scale=${OUT_W}:${OUT_H}:force_original_aspect_ratio=increase,crop=${OUT_W}:${OUT_H}"
    LC_NUMERIC=C ffmpeg -hide_banner -loglevel error -y \
      -ss "$TS" -i "$FILE_PATH" \
      -vf "$VF" -frames:v 1 -q:v 3 \
      "$IMG" >/dev/null 2>&1 || true
  elif have ffmpegthumbnailer; then
    LC_NUMERIC=C ffmpegthumbnailer \
      -q 7 -c jpeg -i "$FILE_PATH" -o "$IMG" -t "$TS" -s "$OUT_W" \
      >/dev/null 2>&1 || true
  else
    echo "Missing dependency: ffmpeg (preferred) or ffmpegthumbnailer"
  fi
fi

[[ -s "$IMG" ]] && emit_image "$IMG"

# Metadata (cached once per file version + settings).
if [[ ! -s "$INFO" ]]; then
  if have mediainfo; then
    mediainfo "$FILE_PATH" >"$INFO" 2>/dev/null || true
  elif have ffprobe; then
    ffprobe -v error -show_format -show_streams -- "$FILE_PATH" >"$INFO" 2>/dev/null || true
  else
    echo "Install mediainfo (recommended) or ffmpeg (ffprobe) for metadata." >"$INFO"
  fi
fi

cat "$INFO" 2>/dev/null || true
