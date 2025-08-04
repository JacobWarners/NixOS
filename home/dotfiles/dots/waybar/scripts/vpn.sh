#!/usr/bin/env bash

# --- Configuration with FULL PATHS ---
MULLVAD_CMD="/run/current-system/sw/bin/mullvad"
HEAD_CMD="/run/current-system/sw/bin/head"
SED_CMD="/run/current-system/sw/bin/sed"
NOTIFY_CMD="/run/current-system/sw/bin/notify-send"


# --- Logic Functions ---

# Function to check the current VPN status
check_status() {
    # Add '2> /dev/null' to suppress the harmless "Broken pipe" error
    local first_line
    first_line=$("$MULLVAD_CMD" status 2> /dev/null | "$HEAD_CMD" -n 1)

    if [[ "$first_line" == "Connected" ]]; then
        echo "connected"
    else
        echo "disconnected"
    fi
}

# Function to print the JSON output for Waybar
print_json() {
    local status
    status=$(check_status)

    if [[ "$status" == "connected" ]]; then
        # Get the full status and escape newlines for the JSON tooltip
        tooltip_text=$("$MULLVAD_CMD" status 2> /dev/null | "$SED_CMD" -z 's/\n/\\n/g')
        printf '{"text": "", "class": "connected", "tooltip": "%s"}' "$tooltip_text"
    else
        printf '{"text": "", "class": "disconnected", "tooltip": "Mullvad: Disconnected"}'
    fi
}


# --- Main ---
case "$1" in
    cycle)
        # This block handles the on-click action
        if [[ "$(check_status)" == "connected" ]]; then
            "$MULLVAD_CMD" disconnect
            "$NOTIFY_CMD" -a "VPN Status" -u normal "Mullvad Disconnected"
        else
            "$MULLVAD_CMD" connect
            "$NOTIFY_CMD" -a "VPN Status" -u normal "Mullvad Connected"
        fi

        # IMPORTANT: Wait a second for the state to settle...
        sleep 1
        # ...then print the new status to instantly update Waybar's icon
        print_json
        ;;
    *)
        # This block handles the default 'exec' based on the interval
        print_json
        ;;
esac
