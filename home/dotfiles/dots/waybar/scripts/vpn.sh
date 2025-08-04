#!/usr/bin/env bash

# --- Configuration with FULL PATHS ---
# Your correct NixOS path for Mullvad
MULLVAD_CMD="/run/current-system/sw/bin/mullvad"

# Standard path for the 'head' command (confirm with 'which head' if needed)
HEAD_CMD="/run/current-system/sw/bin/head"


# --- Logic ---
######################################
## THIS IS THE CORRECTED LOGIC ##
######################################
check_status() {
    # Get the very first line of the status output
    local first_line
    first_line=$("$MULLVAD_CMD" status | "$HEAD_CMD" -n 1)

    # Check if that line is exactly the word "Connected"
    if [[ "$first_line" == "Connected" ]]; then
        echo "connected"
    else
        echo "disconnected"
    fi
}


# --- Main ---
case "$1" in
    cycle)
        # This toggle logic will now work correctly
        if [[ "$(check_status)" == "connected" ]]; then
            "$MULLVAD_CMD" disconnect
        else
            "$MULLVAD_CMD" connect
        fi
        ;;
    *)
        # Output JSON for Waybar
        status=$(check_status)
        if [[ "$status" == "connected" ]]; then
            # THIS IS THE IMPROVED TOOLTIP
            # It grabs the FULL status output for more detail
            tooltip_text=$("$MULLVAD_CMD" status)
            printf '{"text": "", "class": "connected", "tooltip": "%s"}' "$tooltip_text"
        else
            printf '{"text": "", "class": "disconnected", "tooltip": "Mullvad: Disconnected"}'
        fi
        ;;
esac
