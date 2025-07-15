#!/usr/bin/env sh

# Terminate already running bar instances
killall -q waybar

# Wait until the processes have been shut down
while pgrep -x waybar >/dev/null; do sleep 1; done

# Define the monitor names
DOCKED_MONITOR="DP-7"
LAPTOP_MONITOR="eDP-1" # Make sure this matches your laptop screen

# Check if the docked monitor is connected
if hyprctl monitors | grep -q "$DOCKED_MONITOR"; then
    # If docked, launch on the docked monitor
    waybar -o "$DOCKED_MONITOR" &
else
    # If not docked, launch on the laptop monitor
    waybar -o "$LAPTOP_MONITOR" &
fi
