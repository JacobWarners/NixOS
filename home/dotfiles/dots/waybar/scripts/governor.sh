#!/usr/bin/env bash
LOCK_FILE="/tmp/governor.lock"
# Exit if another instance of the script is running.
if [ -e "$LOCK_FILE" ]; then
    exit 0
fi
touch "$LOCK_FILE"
# Ensure the lock file is removed when the script exits.
trap 'rm -f "$LOCK_FILE"' EXIT


# If called with "cycle", change the governor.
if [ "$1" == "cycle" ]; then
  CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

  if [ "$CURRENT_GOV" == "performance" ]; then
    NEXT_GOV="powersave"
  else
    NEXT_GOV="performance"
  fi

  # Execute the change using sudo. This is now doubly authorized.
  sudo /run/current-system/sw/bin/cpupower frequency-set -g "$NEXT_GOV" > /dev/null
fi


# Always output the current state cleanly for Waybar's icon.
CURRENT_STATE=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
echo -n "$CURRENT_STATE"
