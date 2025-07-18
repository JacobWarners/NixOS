#!/usr/bin/env bash

# This script will be CALLED BY sudo. It contains NO sudo commands itself.

# If called with "cycle", change the governor
if [ "$1" == "cycle" ]; then
  CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

  if [ "$CURRENT_GOV" == "performance" ]; then
    /run/current-system/sw/bin/cpupower frequency-set -g powersave
  else
    /run/current-system/sw/bin/cpupower frequency-set -g performance
  fi
fi

# After any potential change, always read the final state and print it for Waybar.
# This read is now done with sudo's privileges because the whole script is.
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
