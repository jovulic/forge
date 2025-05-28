#!/usr/bin/env bash

set -euo pipefail

clock_mhz=$(awk '/cpu MHz/ {sum += $4; count++} END {printf "%.0f\n", sum/count}' /proc/cpuinfo)
usage_percent=$(top -bn1 | awk '/^%Cpu/ {usage=100 - $8; printf "%.0f\n", usage}')
temperature_celcius=$(sensors | awk '/^Tctl:/ {printf "%.0f\n", $2}' | tr -d '+°C')
if [ -p "/tmp/ryzen_monitor_export" ]; then
  power_watt=$(head -n 40 /tmp/ryzen_monitor_export | grep 'name=Core' | awk -F'[ =,]' '
  {
    for (i=1; i<=NF; i++) if ($i == "core_power") power = $(i+1)
    if (power) { sum += power }
  }
  END {
    printf "%.0f\n", sum
  }')
else
  power_watt="?"
fi
governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

printf '{"text": "%sMhz | %s%% | %s°C | %sW", "class": "custom-cpu", "tooltip": "<b>Governor</b>: %s"}' "$clock_mhz" "$usage_percent" "$temperature_celcius" "$power_watt" "$governor"
