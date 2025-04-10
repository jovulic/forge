#!/usr/bin/env bash

clock=$(cat /sys/class/drm/card0/device/pp_dpm_sclk | grep -E -o '[0-9]{0,4}Mhz \W' | sed "s/Mhz \*//")
raw_temp=$(cat /sys/class/hwmon/hwmon7/temp1_input)
temperature=$((raw_temp / 1000))
busypercent=$(cat /sys/class/hwmon/hwmon7/device/gpu_busy_percent)
deviceinfo=$(glxinfo -B | grep 'Device:' | sed 's/^.*: //')
driverinfo=$(glxinfo -B | grep "OpenGL version")

printf '{"text": "'"$clock"'MHz | '"$busypercent"'% | '"$temperature"'°C", "class": "custom-gpu", "tooltip": "<b>'"$deviceinfo"'</b>\n'"$driverinfo"'"}'
