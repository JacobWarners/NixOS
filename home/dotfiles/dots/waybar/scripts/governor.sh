#!/usr/bin/env bash

# This script is called by sudo and handles all logic.

# If called with "cycle", change the governor.
if [ "$1" == "cycle" ]; then
  CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

  if [ "$CURRENT_GOV" == "performance" ]; then
   sudo /run/current-system/sw/bin/cpupower frequency-set -g powersave
  else
   sudo /run/current-system/sw/bin/cpupower frequency-set -g performance
  fi
fi

# ALWAYS output the current state cleanly for Waybar's icon.
echo -n "$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
