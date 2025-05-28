#!/usr/bin/env bash

set -euo pipefail

clock_mhz=$(awk '/cpu MHz/ {sum += $4; count++} END {printf "%.0f\n", sum/count}' /proc/cpuinfo)
usage_percent=$(top -bn1 | awk '/^%Cpu/ {usage=100 - $8; printf "%.0f\n", usage}')

data=$(head -n 40 /tmp/ryzen_monitor_export | grep 'name=Core')
temperature_celcius=$(echo "$data" | awk -F'[ =,]' '
{
  for (i=1; i<=NF; i++) if ($i == "core_temperature") temp = $(i+1)
  if (temp) { sum += temp; count++ }
}
END {
  printf "%.0f\n", sum/count
}')
power_watt=$(echo "$data" | awk -F'[ =,]' '
{
  for (i=1; i<=NF; i++) if ($i == "core_power") power = $(i+1)
  if (power) { sum += power }
}
END {
  printf "%.0f\n", sum
}')

governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

printf '{"text": "%sMhz | %s%% | %s°C | %sW", "class": "custom-cpu", "tooltip": "<b>Governor</b>: %s"}' "$clock_mhz" "$usage_percent" "$temperature_celcius" "$power_watt" "$governor"
