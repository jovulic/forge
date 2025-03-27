#!/usr/bin/env bash

set -veuo pipefail

clock_mhz_raw=$(lscpu -J -e=MHZ | jq -r '.cpus[0].mhz')
clock_mhz=$(printf %.0f "$clock_mhz_raw")
temperature_degree_raw=$(cat /sys/class/hwmon/hwmon2/temp1_input)
temperature_degree=$((temperature_degree_raw / 1000))
usage_percent=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

echo '{"text": "'"$clock_mhz"'MHz | '"$usage_percent"'% | '"$temperature_degree"'°C", "class": "custom-cpu", "tooltip": "<b>Governor</b>:' "$governor"'"}'
