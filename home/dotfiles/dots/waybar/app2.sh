#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bc procps

# This script finds the top CPU-consuming process over a 10-second interval
# and outputs the result as plain text for Waybar.

# --- Configuration ---
# Duration of the polling interval in seconds.
POLL_DURATION=10
# The icon to display next to the output.
ICON="🔥"

# --- Main Logic ---
# Use an associative array to store the cumulative CPU usage for each command.
declare -A cpu_usage

# Get the start time for the polling interval.
start_time=$(date +%s)

# Poll for the specified duration. The loop now runs for a fixed period and then exits.
while [ $(( $(date +%s) - start_time )) -lt $POLL_DURATION ]; do
    # Get a list of all processes with their CPU usage and command name.
    # 'ps -eo %cpu,comm' outputs the CPU usage and command for each process.
    # The 'tail -n +2' command is used to skip the header line from the ps output.
    processes=$(ps -eo %cpu,comm --sort=-%cpu | tail -n +2)

    # Read each line of the process list using a here-string to avoid a subshell.
    while read -r cpu comm; do
        # Check if the command name is not empty and is not 'ps' itself.
        if [ -n "$comm" ] && [ "$comm" != "ps" ]; then
            # Add the current CPU usage to the cumulative total for that command.
            cpu_usage["$comm"]=$(echo "${cpu_usage[$comm]:-0} + $cpu" | bc)
        fi
    done <<< "$processes"
    
    # Sleep for a short interval to avoid overwhelming the system with 'ps' commands.
    sleep 1
done

# Find the command with the highest cumulative CPU usage.
top_process=""
max_cpu=0

# Iterate over the keys (command names) of the associative array.
for comm in "${!cpu_usage[@]}"; do
    # Compare the current command's CPU usage with the maximum found so far.
    if (( $(echo "${cpu_usage[$comm]} > $max_cpu" | bc -l) )); then
        max_cpu=${cpu_usage[$comm]}
        top_process=$comm
    fi
done

# --- Output for Waybar ---
# Check if a top process was identified.
if [ -n "$top_process" ]; then
    # Calculate the average CPU usage over the polling interval, rounded to one decimal place.
    avg_cpu=$(echo "scale=1; ($max_cpu / $POLL_DURATION) / 1" | bc)

    # Output the result as a simple text string.
    echo "$ICON $top_process - $avg_cpu% CPU"
else
    # Show a fallback message.
    echo "$ICON No process found"
fi
