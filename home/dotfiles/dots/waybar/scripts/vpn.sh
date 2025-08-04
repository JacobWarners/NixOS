#!/usr/bin/env bash

VPN_CONNECT_CMD="mullvad connect"
VPN_DISCONNECT_CMD="mullvad disconnect"


# Function to check VPN status
check_status() {
    if ip addr show "$VPN_INTERFACE" &> /dev/null; then
        echo "connected"
    else
        echo "disconnected"
    fi
}

# Main logic: handle 'cycle' argument or print Waybar JSON
case "$1" in
    cycle)
        # Toggle connection
        if [[ "$(check_status)" == "connected" ]]; then
            $VPN_DISCONNECT_CMD
        else
            $VPN_CONNECT_CMD
        fi
        ;;
    *)
        # Output JSON for Waybar
        status=$(check_status)
        if [[ "$status" == "connected" ]]; then
            printf '{"text": "", "class": "connected", "tooltip": "VPN: Connected"}'
        else
            printf '{"text": "", "class": "disconnected", "tooltip": "VPN: Disconnected"}'
        fi
        ;;
esac

