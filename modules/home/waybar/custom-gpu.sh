#!/usr/bin/env bash

set -euo pipefail

# Fetch GPU metrics (clocks, activity, hotspot temperature, socket power).
data=$(rocm-smi --showmetrics --json | jq -cr '.card0')
temperature=$(jq -cr '."temperature_hotspot (C)"' <<<"$data")
activity=$(jq -cr '."average_gfx_activity (%)"' <<<"$data")
power=$(jq -cr '."average_socket_power (W)"' <<<"$data")
clock=$(jq -cr '."average_gfxclk_frequency (MHz)"' <<<"$data")

# Fetch GPU VRAM usage.
vram_data=$(rocm-smi --showmeminfo vram --json | jq -cr '.card0')
vram_total_b=$(jq -cr '."VRAM Total Memory (B)" | tonumber' <<<"$vram_data")
vram_used_b=$(jq -cr '."VRAM Total Used Memory (B)" | tonumber' <<<"$vram_data")
vram_str=$(awk -v total="$vram_total_b" -v used="$vram_used_b" 'BEGIN { printf "%.1f/%.0fGB", used / 1073741824, total / 1073741824 }')

# Fetch System RAM (CPU memory) usage.
ram_str=$(awk '
  /MemTotal:/ {total=$2}
  /MemAvailable:/ {avail=$2}
  END {
    used = total - avail;
    printf "%.1f/%.0fGB", used / 1048576, total / 1048576
  }
' /proc/meminfo)

# Fetch graphics driver and hardware information safely.
if deviceinfo_raw=$(glxinfo -B 2>/dev/null); then
  deviceinfo=$(grep 'Device:' <<<"$deviceinfo_raw" | sed 's/^.*: //')
  driverinfo=$(grep "OpenGL version" <<<"$deviceinfo_raw")
else
  deviceinfo="AMD Radeon RX 6800"
  driverinfo="ROCm driver"
fi

# Print JSON output for Waybar custom-gpu widget.
printf '{"text": "%sMhz | %s%% | %s°C | %sW | VRAM: %s | RAM: %s", "class": "custom-gpu", "tooltip": "<b>%s</b>\\n%s"}' \
  "$clock" "$activity" "$temperature" "$power" "$vram_str" "$ram_str" "$deviceinfo" "$driverinfo"
