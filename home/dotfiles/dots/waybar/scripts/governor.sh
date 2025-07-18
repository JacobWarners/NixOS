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

# Get current governor
CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

# Generate JSON output based on governor
if [ "$CURRENT_GOV" == "performance" ]; then
  # Note the "class": "performance"
  echo '{"text": "󱐋", "tooltip": "Performance Mode", "class": "performance"}'
else
  # Note the "class": "powersave"
  echo '{"text": "󰌪", "tooltip": "Power Save Mode", "class": "powersave"}'
fi
