#!/usr/bin/env sh

#
# show_counter.sh
#
# This script reads a number from a state file and displays it on Waybar.

# The file that stores the current count.
COUNTER_FILE="/tmp/waybar_counter.txt"

# Check if the counter file exists. If not, the count is 0.
if [ -f "$COUNTER_FILE" ]; then
    count=$(cat "$COUNTER_FILE")
else
    count=0
fi

# --- Output JSON for Waybar ---
# We'll add a diamond icon for flair. You can change it to any icon or text.
# The tooltip will show a helpful message when you hover over it.
printf '{"text": "💎 %s", "tooltip": "Current Score: %s", "class": "counter"}\n' "$count" "$count"

