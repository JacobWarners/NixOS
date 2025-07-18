#!/usr/bin/env bash

# This script now only does two things:
# 1. If clicked, it cycles the CPU governor.
# 2. It prints the name of the current governor to be used as a CSS class.

# Check if the script was clicked
if [ "$1" == "cycle" ]; then
  CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
  case $CURRENT_GOV in
    "schedutil" | "ondemand")
        cpupower frequency-set -g performance
      ;;
    "performance")
        cpupower frequency-set -g powersave
      ;;
    "powersave")
        cpupower frequency-set -g schedutil
      ;;
  esac
fi

# Always print the current governor name. Waybar will use this as a class.
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
