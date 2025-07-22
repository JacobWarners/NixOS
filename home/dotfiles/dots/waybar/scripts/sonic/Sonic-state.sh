#!/bin/sh
#
# toggle_waybar_state.sh
#
# This script checks the current state in the Waybar status file
# and toggles it to the other state.

# --- Configuration ---
# The two class names you want to toggle between.
STATE_A="flashing"
STATE_B="super-charge-flash"

# The file that stores the current state.
STATE_FILE="/tmp/waybar_status.txt"

# --- Logic ---
# Check if the state file exists and read the current state.
if [ -f "$STATE_FILE" ]; then
    current_state=$(cat "$STATE_FILE")
else
    # If the file doesn't exist, set a default state.
    current_state=""
fi

# Decide which state to switch to.
if [ "$current_state" = "$STATE_B" ]; then
    # If the current state is B, switch to A.
    next_state="$STATE_A"
else
    # For any other case (including state A or an empty file), switch to B.
    next_state="$STATE_B"
fi

# Write the new state to the file.
echo "$next_state" > "$STATE_FILE"

# --- Refresh Waybar ---
# Send a signal to the Waybar process to tell it to update its modules.
# This makes the change appear instantly.
pkill -RTMIN+8 waybar

# Optional: Print the change to the terminal so you know what happened.
echo "Waybar state toggled to: $next_state"

