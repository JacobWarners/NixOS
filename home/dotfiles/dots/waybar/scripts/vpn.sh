#!/usr/bin/env bash

# --- Configuration with FULL PATHS ---
# Your correct NixOS paths
MULLVAD_CMD="/run/current-system/sw/bin/mullvad"
HEAD_CMD="/run/current-system/sw/bin/head"
# Add the path to sed you found with 'which sed'
SED_CMD="/run/current-system/sw/bin/sed"


# --- Logic ---
check_status() {
    local first_line
    first_line=$("$MULLVAD_CMD" status | "$HEAD_CMD" -n 1)
    if [[ "$first_line" == "Connected" ]]; then
        echo "connected"
    else
        echo "disconnected"
    fi
}


# --- Main ---
case "$1" in
    cycle)
        if [[ "$(check_status)" == "connected" ]]; then
            "$MULLVAD_CMD" disconnect
        else
            "$MULLVAD_CMD" connect
        fi
        ;;
    *)
        status=$(check_status)
        if [[ "$status" == "connected" ]]; then
            #########################################################
            # THIS IS THE FIX:
            # We pipe the status to 'sed' to escape newlines for JSON
            #########################################################
            tooltip_text=$("$MULLVAD_CMD" status | "$SED_CMD" -z 's/\n/\\n/g')
            printf '{"text": "", "class": "connected", "tooltip": "%s"}' "$tooltip_text"
        else
            printf '{"text": "", "class": "disconnected", "tooltip": "Mullvad: Disconnected"}'
        fi
        ;;
esac
