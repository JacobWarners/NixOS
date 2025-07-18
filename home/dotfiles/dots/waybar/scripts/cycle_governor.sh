#!/usr/bin/env bash

# This script now contains NO sudo commands.
# Sudo will be handled by the Waybar on-click command.

if [ "$1" == "cycle" ]; then
  CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

  case $CURRENT_GOV in
    "schedutil" | "ondemand")
      /run/current-system/sw/bin/cpupower frequency-set -g performance
      ;;
    "performance")
      /run/current-system/sw/bin/cpupower frequency-set -g powersave
      ;;
    "powersave")
      # This fixes the "Error setting new values" by checking first.
      if [ "$CURRENT_GOV" != "schedutil" ]; then
        /run/current-system/sw/bin/cpupower frequency-set -g schedutil
      fi
      ;;
  esac
fi

# Always print the current governor for Waybar
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
