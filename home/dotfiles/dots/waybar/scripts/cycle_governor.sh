#!/usr/bin/env bash

# This script handles both changing the governor and displaying the state.

# If called with "cycle", perform the toggle logic.
if [ "$1" == "cycle" ]; then
  CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

  if [ "$CURRENT_GOV" == "performance" ]; then
    # If in performance, switch to powersave
    NEXT_GOV="powersave"
  else
    # Otherwise, switch to performance
    NEXT_GOV="performance"
  fi

  # Execute the change using sudo. This works because the command is authorized in Nix.
  sudo /run/current-system/sw/bin/cpupower frequency-set -g "$NEXT_GOV" > /dev/null
fi

# Finally, always print the CURRENT state cleanly for Waybar to use.
# This ensures the icon is always correct.
CURRENT_STATE=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
echo -n "$CURRENT_STATE"
