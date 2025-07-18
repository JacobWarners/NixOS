#!/usr/bin/env bash
# This script only SETS the governor. It will be called BY sudo.

CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

if [ "$CURRENT_GOV" == "performance" ]; then
  /run/current-system/sw/bin/cpupower frequency-set -g powersave
else
  /run/current-system/sw/bin/cpupower frequency-set -g performance
fi
