#!/bin/sh
#
# This script runs as the user to safely prepare for eGPU undocking.

set -e

# Path to the root helper script.
# Note: Adjust this path if you place the helper script elsewhere.
HELPER_SCRIPT="$HOME/.config/hypr/scripts/undock-helper.sh"

notify-send "eGPU Undock" "Preparing to undock... Moving windows and disabling displays." -u normal

# 1. Run user-level commands as 'jake'.
hyprctl keyword monitor "DP-11,disable"
hyprctl keyword monitor "HDMI-A-1,disable"
sleep 2

# 2. Call the helper script with sudo to run the privileged commands.
#    Our system's sudoers config will allow this without a password.
if sudo "$HELPER_SCRIPT"; then
    # 3. Only show the success message if the sudo command finished without errors.
    notify-send "eGPU Undock" "SUCCESS: It is now safe to unplug the Thunderbolt cable." -u critical -t 10000
else
    notify-send "eGPU Undock" "ERROR: Failed to run privileged undock commands. Check sudoers config." -u critical
fi
