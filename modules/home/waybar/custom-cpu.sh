#!/usr/bin/env bash

set -euo pipefail

clock_mhz=$(awk '/cpu MHz/ {sum += $4; count++} END {printf "%.0f\n", sum/count}' /proc/cpuinfo)
usage_percent=$(top -bn1 | awk '/^%Cpu/ {usage=100 - $8; printf "%.0f\n", usage}')
temperature_celcius=$(sensors | awk '/^Tctl:/ {printf "%.0f\n", $2}' | tr -d '+°C' | head -n 1)

# Safely run sensors to avoid crashing under set -e if zenpower is unavailable
# or fails.
if raw_output=$(sensors "zenpower-*" 2>/dev/null); then
  # Extract the SVI2_P_Core value (Power Core).
  # Format typically: SVI2_P_Core:  24.52 W
  power_watt=$(echo "$raw_output" | awk '/SVI2_P_Core/ {print $2}' | cut -d. -f1)
  if [ -z "$power_watt" ]; then
    power_watt="?"
  fi
else
  power_watt="?"
fi

governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

printf '{"text": "%sMhz | %s%% | %s°C | %sW", "class": "custom-cpu", "tooltip": "<b>Governor</b>: %s"}' "$clock_mhz" "$usage_percent" "$temperature_celcius" "$power_watt" "$governor"
