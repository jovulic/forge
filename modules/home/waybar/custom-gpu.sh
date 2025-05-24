#!/usr/bin/env bash

set -euo pipefail

data=$(rocm-smi --showmetrics --json | jq -cr '.card0')
temperature=$(jq -cr '."temperature_hotspot (C)"' <<<"$data")
activity=$(jq -cr '."average_gfx_activity (%)"' <<<"$data")
power=$(jq -cr '."average_socket_power (W)"' <<<"$data")
clock=$(jq -cr '."average_gfxclk_frequency (MHz)"' <<<"$data")
deviceinfo=$(glxinfo -B | grep 'Device:' | sed 's/^.*: //')
driverinfo=$(glxinfo -B | grep "OpenGL version")

printf '{"text": "%sMhz | %s%% | %s°C | %sW", "class": "custom-gpu", "tooltip": "<b>%s</b>\\n%s"}' "$clock" "$activity" "$temperature" "$power" "$deviceinfo" "$driverinfo"
