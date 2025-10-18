#!/bin/sh

# This script toggles Hyprland F-key bindings for gaming.

LOCK_FILE="/tmp/hypr_fkeys_disabled.lock"

if [ -f "$LOCK_FILE" ]; then
    # F-keys are disabled, so re-enable them
    notify-send "Hyprland" "F-Keys ENABLED for workspaces" -u normal
    hyprctl keyword source ~/.config/hypr/fkeys.conf
    rm "$LOCK_FILE"
else
    # F-keys are enabled, so disable them (for gaming)
    notify-send "Hyprland" "F-Keys DISABLED for gaming" -u normal
    
    # Loop to unbind F1 through F10
    for i in $(seq 1 10); do
        hyprctl keyword unbind ",F$i"
    done
    
    touch "$LOCK_FILE"
fi
