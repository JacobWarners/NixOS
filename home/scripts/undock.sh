#!/bin/sh
# This script runs as the user to safely prepare for eGPU undocking.
set -e

HELPER_SCRIPT="$HOME/.config/hypr/scripts/undock-helper.sh"

notify-send "eGPU Undock" "Preparing to undock..." -u normal

# Run user-level commands first (these may now be redundant but are harmless)
hyprctl keyword monitor "DP-11,disable"
hyprctl keyword monitor "HDMI-A-1,disable"
sleep 1

# Call the helper script with sudo to run the privileged kernel commands.
if sudo "$HELPER_SCRIPT"; then
    notify-send "eGPU Undock" "SUCCESS: It is now safe to unplug the Thunderbolt cable." -u critical -t 10000
else
    notify-send "eGPU Undock" "ERROR: Failed to run privileged undock commands. Check sudo config." -u critical
fi
