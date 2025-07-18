#!/usr/bin/env bash
# This script will be CALLED BY sudo.

CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

if [ "$CURRENT_GOV" == "performance" ]; then
  /run/current-system/sw/bin/cpupower frequency-set -g powersave
else
  /run/current-system/sw/bin/cpupower frequency-set -g performance
fi
