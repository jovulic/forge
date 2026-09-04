#!/usr/bin/env bash

# Quiet formatting variables.
BOLD="\e[1m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

echo -e "${BOLD}${CYAN}====================================================${RESET}"
echo -e "${BOLD}${CYAN}            VR STREAMING DIAGNOSTIC REPORT         ${RESET}"
echo -e "${BOLD}${CYAN}====================================================${RESET}"
echo ""

# -----------------------------------------------------------------------------
# HOST STATUS
# -----------------------------------------------------------------------------
echo -e "${BOLD}[1/5] Host PC Process Status${RESET}"

HOST_WIVRN_PID=$(pgrep -f "wivrn-server" | head -n 1)
HOST_WAYVR_PID=$(pgrep -x "wayvr" | head -n 1)

if [ -n "$HOST_WIVRN_PID" ]; then
  echo -e "  - wivrn-server: ${GREEN}RUNNING${RESET} (PID: $HOST_WIVRN_PID)"
else
  echo -e "  - wivrn-server: ${RED}NOT RUNNING${RESET}"
fi

if [ -n "$HOST_WAYVR_PID" ]; then
  echo -e "  - wayvr:        ${GREEN}RUNNING${RESET} (PID: $HOST_WAYVR_PID)"
else
  echo -e "  - wayvr:        ${RED}NOT RUNNING${RESET}"
fi

# -----------------------------------------------------------------------------
# ENCODER CONFIGURATION CHECK
# -----------------------------------------------------------------------------
echo ""
echo -e "${BOLD}[2/5] Host WiVRn Encoder Configuration${RESET}"

CONFIG_PATH="/home/me/.config/wivrn/config.json"

if [ -f "$CONFIG_PATH" ]; then
  echo -e "  - Config Path:  $CONFIG_PATH"

  ENCODER=$(jq -r '.encoder // "Not Specified"' "$CONFIG_PATH" 2>/dev/null)
  BITRATE=$(jq -r '.bitrate // "Not Specified"' "$CONFIG_PATH" 2>/dev/null)
  CODEC=$(jq -r '.encoders[0].codec // "Not Specified"' "$CONFIG_PATH" 2>/dev/null)
  SUB_ENCODER=$(jq -r '.encoders[0].encoder // "Not Specified"' "$CONFIG_PATH" 2>/dev/null)
  SCALE_W=$(jq -r '.scale[0] // "Not Specified"' "$CONFIG_PATH" 2>/dev/null)
  SCALE_H=$(jq -r '.scale[1] // "Not Specified"' "$CONFIG_PATH" 2>/dev/null)

  # Check for potential bottlenecks
  if [ "$SUB_ENCODER" = "x264" ]; then
    echo -e "  - Encoder:      ${RED}WARNING: CPU SOFTWARE ENCODING (${SUB_ENCODER})${RESET}"
  elif [ "$SUB_ENCODER" = "vaapi" ] || [ "$ENCODER" = "vaapi" ]; then
    echo -e "  - Encoder:      ${GREEN}VA-API (GPU Hardware Accelerated)${RESET}"
  elif [ "$SUB_ENCODER" = "vulkan" ] || [ "$ENCODER" = "vulkan" ]; then
    echo -e "  - Encoder:      ${GREEN}Vulkan Video (GPU Hardware Accelerated)${RESET}"
  elif [ "$SUB_ENCODER" = "nvenc" ] || [ "$ENCODER" = "nvenc" ]; then
    echo -e "  - Encoder:      ${GREEN}NVIDIA NVENC (GPU Hardware Accelerated)${RESET}"
  else
    echo -e "  - Encoder:      $ENCODER ($SUB_ENCODER)"
  fi

  if [ "$CODEC" = "h264" ]; then
    echo -e "  - Codec:        ${YELLOW}H.264${RESET} (${YELLOW}NOTE:${RESET} H.265/HEVC is recommended to prevent streaming stutters)"
  elif [ "$CODEC" = "h265" ] || [ "$CODEC" = "hevc" ]; then
    echo -e "  - Codec:        ${GREEN}H.265 (HEVC)${RESET} (${GREEN}OPTIMAL${RESET})"
  else
    echo -e "  - Codec:        $CODEC"
  fi

  if [ "$BITRATE" != "Not Specified" ]; then
    MBPS=$((BITRATE / 1000000))
    echo -e "  - Bitrate:      ${CYAN}$MBPS Mbps${RESET} ($BITRATE bps)"
  else
    echo -e "  - Bitrate:      $BITRATE"
  fi

  echo -e "  - Resolution:   Scale ${CYAN}${SCALE_W}x${SCALE_H}${RESET}"
else
  echo -e "  - Config Path:  ${RED}NOT FOUND${RESET} (using default system config)"
fi

# -----------------------------------------------------------------------------
# ADB & HEADSET SYSTEM CHECK
# -----------------------------------------------------------------------------
echo ""
echo -e "${BOLD}[3/5] ADB & Headset General Status${RESET}"

ADB_DEVICE=$(adb devices 2>/dev/null | grep -v "List" | grep "device" | awk '{print $1}' | head -n 1)

if [ -z "$ADB_DEVICE" ]; then
  echo -e "  - ADB Connection: ${RED}NO DEVICE DETECTED / UNAUTHORIZED${RESET}"
  echo "    Please verify that Developer Mode is enabled and you allowed USB debugging in the headset."
  echo -e "${BOLD}${CYAN}====================================================${RESET}"
  exit 0
else
  echo -e "  - ADB Connection: ${GREEN}CONNECTED${RESET} (Serial: $ADB_DEVICE)"
fi

MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
BATTERY=$(adb shell dumpsys battery 2>/dev/null | grep "level:" | awk '{print $2}' | tr -d '\r')
AC_POWER=$(adb shell dumpsys battery 2>/dev/null | grep "AC powered:" | awk '{print $3}' | tr -d '\r')

echo -e "  - Device Model:   ${CYAN}$MODEL${RESET}"
echo -e "  - Battery Level:  ${CYAN}$BATTERY%${RESET} (AC Powered: $AC_POWER)"

# -----------------------------------------------------------------------------
# WIRELESS TELEMETRY (HEADSET SIDE)
# -----------------------------------------------------------------------------
echo ""
echo -e "${BOLD}[4/5] Wireless & Telemetry Statistics${RESET}"

# Find Headset IP
HEADSET_IP=$(ss -tupn 2>/dev/null | grep -E 'wivrn-server|wivrn' | awk '{print $6}' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

if [ -z "$HEADSET_IP" ]; then
  # Fallback: Query wlan0 IP from the headset.
  HEADSET_IP=$(adb shell "ip addr show wlan0" 2>/dev/null | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}' | head -n 1)
fi

if [ -n "$HEADSET_IP" ]; then
  echo -e "  - Headset IP:     $HEADSET_IP"
else
  echo -e "  - Headset IP:     ${RED}NOT FOUND${RESET}"
fi

WIFI_DUMP=$(adb shell "dumpsys wifi" 2>/dev/null)
mWifiInfoLine=$(echo "$WIFI_DUMP" | grep -E "^mWifiInfo SSID:" | head -n 1)

if [ -n "$mWifiInfoLine" ]; then
  SSID=$(echo "$mWifiInfoLine" | grep -oE 'SSID: [^,]+' | head -n 1 | cut -d: -f2- | tr -d ' "')
  FREQ=$(echo "$mWifiInfoLine" | grep -oE 'Frequency: [0-9]+' | head -n 1 | awk '{print $2}')
  RSSI=$(echo "$mWifiInfoLine" | grep -oE 'RSSI: -?[0-9]+' | head -n 1 | awk '{print $2}')
  LS=$(echo "$mWifiInfoLine" | grep -oE 'Link speed: [0-9]+' | head -n 1 | awk '{print $3}')
  WIFI_STD=$(echo "$mWifiInfoLine" | grep -oE 'Wi-Fi standard: [0-9]+' | head -n 1 | awk '{print $3}')
else
  # Fallback queries.
  SSID=$(echo "$WIFI_DUMP" | grep -oE 'SSID="[^"]+"' | head -n 1 | cut -d'"' -f2)
  FREQ=$(echo "$WIFI_DUMP" | grep -oE 'freq [0-9]+' | head -n 1 | awk '{print $2}')
  RSSI=$(echo "$WIFI_DUMP" | grep -oE 'rssi -?[0-9]+' | head -n 1 | awk '{print $2}')
  LS=$(echo "$WIFI_DUMP" | grep -oE 'link_speed_mbps=[0-9]+' | head -n 1 | cut -d= -f2)
  WIFI_STD=$(echo "$WIFI_DUMP" | grep -oE 'mWifiStandard=[0-9]+' | head -n 1 | cut -d= -f2)
fi

# Clean units.
FREQ=${FREQ//MHz/}
RSSI=${RSSI//dBm/}
LS=${LS//Mbps/}

# Convert Wi-Fi Standard number to names.
case "$WIFI_STD" in
4) WIFI_STD_NAME="Wi-Fi 4 (802.11n)" ;;
5) WIFI_STD_NAME="Wi-Fi 5 (802.11ac)" ;;
6) WIFI_STD_NAME="Wi-Fi 6 (802.11ax)" ;;
7) WIFI_STD_NAME="Wi-Fi 7 (802.11be)" ;;
*) WIFI_STD_NAME="Unknown ($WIFI_STD)" ;;
esac

echo -e "  - Active SSID:    ${CYAN}$SSID${RESET}"
echo -e "  - Standard:       $WIFI_STD_NAME"

if [ -n "$FREQ" ] && [ "$FREQ" -eq "$FREQ" ] 2>/dev/null; then
  BAND="Unknown"
  if [ "$FREQ" -ge 2400 ] && [ "$FREQ" -le 2500 ]; then BAND="2.4 GHz"; fi
  if [ "$FREQ" -ge 5000 ] && [ "$FREQ" -le 5900 ]; then BAND="5 GHz"; fi
  if [ "$FREQ" -ge 5925 ] && [ "$FREQ" -le 7125 ]; then BAND="6 GHz"; fi
  echo -e "  - Frequency/Band: $FREQ MHz (${CYAN}$BAND${RESET})"
fi

# Print RSSI with visual health indicator.
if [ -n "$RSSI" ] && [ "$RSSI" -eq "$RSSI" ] 2>/dev/null; then
  if [ "$RSSI" -ge -55 ]; then
    echo -e "  - Signal (RSSI):  ${GREEN}$RSSI dBm (EXCELLENT)${RESET}"
  elif [ "$RSSI" -ge -65 ]; then
    echo -e "  - Signal (RSSI):  ${GREEN}$RSSI dBm (GOOD)${RESET}"
  elif [ "$RSSI" -ge -72 ]; then
    echo -e "  - Signal (RSSI):  ${YELLOW}$RSSI dBm (FAIR - LINK DOWNSHIFTING POSSIBLE)${RESET}"
  else
    echo -e "  - Signal (RSSI):  ${RED}$RSSI dBm (WEAK - PRONE TO STUTTERING)${RESET}"
  fi
fi

if [ -n "$LS" ]; then
  echo -e "  - Current Link:   ${CYAN}$LS Mbps${RESET}"
fi

# Parse hardware TX retries to compute retransmission percentage.
POLL_BLOCKS=$(echo "$WIFI_DUMP" | grep -E 'total_tx_success=[0-9]+' | tail -n 2)
POLL_LATEST=$(echo "$POLL_BLOCKS" | tail -n 1)

if [ -n "$POLL_LATEST" ]; then
  TX_SUCCESS=$(echo "$POLL_LATEST" | grep -oE "total_tx_success=[0-9]+" | cut -d= -f2)
  TX_RETRIES=$(echo "$POLL_LATEST" | grep -oE "total_tx_retries=[0-9]+" | cut -d= -f2)

  if [ -n "$TX_SUCCESS" ] && [ -n "$TX_RETRIES" ] && [ "$TX_SUCCESS" -gt 0 ]; then
    # Float math using awk
    RETRY_RATE=$(awk "BEGIN {printf \"%.2f\", ($TX_RETRIES * 100) / ($TX_SUCCESS + $TX_RETRIES)}")

    if (($(echo "$RETRY_RATE < 5.0" | bc -l))); then
      echo -e "  - Hardware Retry: ${GREEN}$RETRY_RATE% (EXCELLENT STABILITY)${RESET}"
    elif (($(echo "$RETRY_RATE < 12.0" | bc -l))); then
      echo -e "  - Hardware Retry: ${YELLOW}$RETRY_RATE% (MODERATE INTERFERENCE)${RESET}"
    else
      echo -e "  - Hardware Retry: ${RED}WARNING: $RETRY_RATE% RETRIES (HIGH INTERFERENCE)${RESET}"
    fi
  fi
fi

# Ping Test Execution.
if [ -n "$HEADSET_IP" ]; then
  echo ""
  echo "  - Running 10 rapid ping packets to measure real-time latency..."
  PING_OUT=$(ping -c 10 -i 0.2 "$HEADSET_IP" 2>&1)

  LOSS=$(echo "$PING_OUT" | grep -oE '[0-9]+% packet loss' | cut -d% -f1)
  RTT_STATS=$(echo "$PING_OUT" | tail -n 1 | cut -d= -f2 | awk -F'/' '{print $1 "/" $2 "/" $3 "/" $4}')

  if [ -n "$LOSS" ]; then
    if [ "$LOSS" -eq 0 ]; then
      echo -e "    - Packet Loss:  ${GREEN}0% (PERFECT CONNECTION)${RESET}"
    else
      echo -e "    - Packet Loss:  ${RED}WARNING: $LOSS% PACKET LOSS (DROPPING FRAMES)${RESET}"
    fi
  fi

  if [ -n "$RTT_STATS" ]; then
    IFS='/' read -r rtt_min rtt_avg rtt_max rtt_mdev <<<"$RTT_STATS"

    # Strip spaces and units.
    rtt_min=$(echo "$rtt_min" | tr -d ' ms')
    rtt_avg=$(echo "$rtt_avg" | tr -d ' ms')
    rtt_max=$(echo "$rtt_max" | tr -d ' ms')
    rtt_mdev=$(echo "$rtt_mdev" | tr -d ' ms')

    # Assess jitter/latency stability.
    if (($(echo "$rtt_avg < 10.0" | bc -l))); then
      echo -e "    - Latency (RTT): Min: ${rtt_min}ms / ${GREEN}Avg: ${rtt_avg}ms${RESET} / Max: ${rtt_max}ms (Jitter: ${rtt_mdev}ms) (${GREEN}OPTIMAL${RESET})"
    elif (($(echo "$rtt_avg < 25.0" | bc -l))); then
      echo -e "    - Latency (RTT): Min: ${rtt_min}ms / ${YELLOW}Avg: ${rtt_avg}ms${RESET} / Max: ${rtt_max}ms (Jitter: ${rtt_mdev}ms) (${YELLOW}MODERATE JITTER${RESET})"
    else
      echo -e "    - Latency (RTT): Min: ${rtt_min}ms / ${RED}Avg: ${rtt_avg}ms${RESET} / Max: ${rtt_max}ms (Jitter: ${rtt_mdev}ms) (${RED}SEVERE LAG SPIKES${RESET})"
    fi
  fi
fi

# -----------------------------------------------------------------------------
# VRAPI PERFORMANCE STATS (CLIENT COMPOSITOR)
# -----------------------------------------------------------------------------
echo ""
echo -e "${BOLD}[5/5] Real-Time Headset Rendering (VrApi)${RESET}"

VRAPI_LINE=$(adb logcat -d 2>/dev/null | grep -E "VrApi\s*:" | tail -n 1)

if [ -n "$VRAPI_LINE" ]; then
  # Extract metrics safely using sed / awk.
  FPS=$(echo "$VRAPI_LINE" | grep -oE "FPS=[0-9]+/[0-9]+" | cut -d= -f2)
  STALE=$(echo "$VRAPI_LINE" | grep -oE "Stale=[0-9]+" | cut -d= -f2)
  TEMP=$(echo "$VRAPI_LINE" | grep -oE "Temp=[0-9.]+C" | cut -d= -f2)
  APP=$(echo "$VRAPI_LINE" | grep -oE "App=[0-9.]+ms" | cut -d= -f2)
  LAT=$(echo "$VRAPI_LINE" | grep -oE "Lat=[-0-9]+" | cut -d= -f2)

  if [ -n "$FPS" ]; then
    CURR_FPS=$(echo "$FPS" | cut -d/ -f1)
    TARGET_FPS=$(echo "$FPS" | cut -d/ -f2)
    if [ "$CURR_FPS" -eq "$TARGET_FPS" ]; then
      echo -e "  - Frame Rate:     ${GREEN}$FPS FPS (LOCKED)${RESET}"
    else
      echo -e "  - Frame Rate:     ${YELLOW}$FPS FPS (PERFORMANCE DROP)${RESET}"
    fi
  fi

  if [ -n "$STALE" ]; then
    if [ "$STALE" -eq 0 ]; then
      echo -e "  - Dropped Frames: ${GREEN}0 (PERFECT SCREEN PACING)${RESET}"
    else
      echo -e "  - Dropped Frames: ${RED}WARNING: $STALE STALE FRAMES (VISIBLE STUTTERS)${RESET}"
    fi
  fi

  [ -n "$APP" ] && echo -e "  - App Frame Time: $APP"
  [ -n "$TEMP" ] && echo -e "  - Headset Temp:   $TEMP"
  [ -n "$LAT" ] && echo -e "  - Frame Latency:  $LAT ms"
else
  echo -e "  - Telemetry:      ${YELLOW}Compositor stats are currently offline.${RESET}"
  echo "    Start streaming a game/room inside the headset to activate real-time telemetry."
fi

echo ""
echo -e "${BOLD}${CYAN}====================================================${RESET}"
