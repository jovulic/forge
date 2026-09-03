#!/usr/bin/env bash
# shellcheck shell=bash

FILE_PATH="${1:-}"

if [[ -z "$FILE_PATH" ]]; then
  echo "Error: No file provided" >&2
  exit 1
fi

if [[ ! -f "$FILE_PATH" ]]; then
  echo "Error: File does not exist: $FILE_PATH" >&2
  exit 1
fi

# Determine mime-type.
mime=$(file --mime-type -b "$FILE_PATH")

# Common optimized options for Kitty video output rendering:
# - vo=kitty: render using modern kitty graphics protocol.
# - profile=sw-fast: fast, low-overhead software scaling and decoding.
# - vo-kitty-use-shm=yes: use POSIX shared memory instead of writing escape streams to stdout.
# - hwdec=auto-safe: GPU-accelerated decoding to offload CPU.
# - really-quiet: prevent any text stdout logging from corrupting/lagging the graphics stream.
# - vo-kitty-width/height: force rendering at 1080p canvas and let terminal scale down to avoid pixelation.
MPV_KITTY_OPTS=(
  "--vo=kitty"
  "--profile=sw-fast"
  "--vo-kitty-use-shm=yes"
  "--hwdec=auto-safe"
  "--really-quiet"
  "--vo-kitty-width=1920"
  "--vo-kitty-height=1080"
  "--keep-open=yes"
  "--loop-file=inf"
)

if [[ "$mime" =~ ^video/ ]]; then
  mpv "${MPV_KITTY_OPTS[@]}" "$FILE_PATH"
elif [[ "$mime" =~ ^audio/ ]]; then
  mpv --vo=null "$FILE_PATH"
elif [[ "$mime" =~ ^image/ ]]; then
  mpv "${MPV_KITTY_OPTS[@]}" "$FILE_PATH"
else
  xdg-open "$FILE_PATH"
fi
