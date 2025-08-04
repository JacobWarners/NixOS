#!/usr/bin/env bash

# --- Configuration with FULL PATHS ---
# NixOS path for Mullvad
MULLVAD_CMD="/run/current-system/sw/bin/mullvad"

# Standard paths for other tools (run 'which grep' and 'which head' to confirm)
GREP_CMD="/run/current-system/sw/bin/grep"
HEAD_CMD="/run/current-system/sw/bin/head"


# --- Logic ---
check_status() {
    # Use full paths for every command in the pipeline
    if "$MULLVAD_CMD" status | "$GREP_CMD" -q "Connected to"; then
        echo "connected"
    else
        echo "disconnected"
    fi
}


# --- Main ---
case "$1" in
    cycle)
        # The toggle commands now use the full path variable
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
            tooltip_text=$("$MULLVAD_CMD" status | "$HEAD_CMD" -n 1)
            printf '{"text": "", "class": "connected", "tooltip": "%s"}' "$tooltip_text"
        else
            printf '{"text": "", "class": "disconnected", "tooltip": "Mullvad: Disconnected"}'
        fi
        ;;
esac
