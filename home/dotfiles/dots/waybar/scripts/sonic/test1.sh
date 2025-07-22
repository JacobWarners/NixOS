#!/usr/bin/env sh

#
# update_counter.sh
#
# This script increases or decreases the counter's value.
# Usage: ./update_counter.sh inc
#        ./update_counter.sh dec

# The file that stores the current count.
COUNTER_FILE="/tmp/waybar_counter.txt"

# Check if the counter file exists. If not, start at 0.
if [ -f "$COUNTER_FILE" ]; then
    current_count=$(cat "$COUNTER_FILE")
else
    current_count=0
fi

# Check the first argument to decide whether to increment or decrement.
if [ "$1" = "inc" ]; then
    # Increment the count by 1.
    next_count=$((current_count + 1))
elif [ "$1" = "dec" ]; then
    # Decrement the count by 1.
    next_count=$((current_count - 1))
else
    echo "Usage: $0 [inc|dec]"
    exit 1
fi

# Write the new count back to the file.
echo "$next_count" > "$COUNTER_FILE"

# Refresh Waybar to show the change instantly.
pkill -RTMIN+8 waybar

echo "Counter updated to: $next_count"

