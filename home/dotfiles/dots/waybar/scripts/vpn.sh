#!/usr/bin/env bash

# --- Configuration with FULL PATHS ---
# Your correct NixOS paths
MULLVAD_CMD="/run/current-system/sw/bin/mullvad"
HEAD_CMD="/run/current-system/sw/bin/head"
SED_CMD="/run/current-system/sw/bin/sed"
# Add the path to notify-send you found with 'which'
NOTIFY_CMD="/run/current-system/sw/bin/notify-send"


# --- Logic ---
check_status() {
    local first_line
    first_line=$("$MULLVAD_CMD" status 2> /dev/null | "$HEAD_CMD" -n 1)
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
            # Send Disconnected Notification
            "$NOTIFY_CMD" -a "VPN Status" -u normal "Mullvad Disconnected"
        else
            "$MULLVAD_CMD" connect
            # Send Connected Notification
            "$NOTIFY_CMD" -a "VPN Status" -u normal "Mullvad Connected"
        fi
        ;;
    *)
        status=$(check_status)
        if [[ "$status" == "connected" ]]; then
            tooltip_text=$("$MULLVAD_CMD" status 2> /dev/null | "$SED_CMD" -z 's/\n/\\n/g')
            printf '{"text": "", "class": "connected", "tooltip": "%s"}' "$tooltip_text"
        else
            printf '{"text": "", "class": "disconnected", "tooltip": "Mullvad: Disconnected"}'
        fi
        ;;
esac
