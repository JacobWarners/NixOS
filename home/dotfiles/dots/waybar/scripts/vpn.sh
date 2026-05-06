#!/usr/bin/env bash

# Tri-state VPN toggle for Waybar.
#   left-click  (cycle)     -> toggle Mullvad   (tears Apartment down first)
#   right-click (apartment) -> toggle Apartment (disconnects Mullvad first)
#   middle-click            -> handled in waybar config (vpn-gui.sh)
#
# States surfaced via JSON class:
#   disconnected | mullvad | apartment

MULLVAD_CMD="/run/current-system/sw/bin/mullvad"
HEAD_CMD="/run/current-system/sw/bin/head"
SED_CMD="/run/current-system/sw/bin/sed"
NOTIFY_CMD="/run/current-system/sw/bin/notify-send"
SYSTEMCTL_CMD="/run/current-system/sw/bin/systemctl"

APARTMENT_UNIT="wg-quick-apartment.service"

mullvad_connected() {
    local first_line
    first_line=$("$MULLVAD_CMD" status 2>/dev/null | "$HEAD_CMD" -n 1)
    [[ "$first_line" == "Connected" ]]
}

apartment_active() {
    "$SYSTEMCTL_CMD" is-active --quiet "$APARTMENT_UNIT"
}

current_state() {
    if apartment_active; then
        echo "apartment"
    elif mullvad_connected; then
        echo "mullvad"
    else
        echo "disconnected"
    fi
}

print_json() {
    local state tooltip
    state=$(current_state)
    case "$state" in
        mullvad)
            tooltip=$("$MULLVAD_CMD" status 2>/dev/null | "$SED_CMD" -z 's/\n/\\n/g')
            printf '{"text": "", "class": "mullvad", "tooltip": "%s"}' "$tooltip"
            ;;
        apartment)
            tooltip="Apartment WireGuard: connected\\nInterface: apartment"
            printf '{"text": "", "class": "apartment", "tooltip": "%s"}' "$tooltip"
            ;;
        *)
            printf '{"text": "", "class": "disconnected", "tooltip": "VPN: Disconnected"}'
            ;;
    esac
}

stop_apartment() {
    if apartment_active; then
        "$SYSTEMCTL_CMD" stop "$APARTMENT_UNIT" >/dev/null 2>&1
    fi
}

start_apartment() {
    "$SYSTEMCTL_CMD" start "$APARTMENT_UNIT" >/dev/null 2>&1
}

stop_mullvad() {
    if mullvad_connected; then
        "$MULLVAD_CMD" disconnect >/dev/null 2>&1
    fi
}

start_mullvad() {
    "$MULLVAD_CMD" connect >/dev/null 2>&1
}

case "$1" in
    cycle)
        # Mullvad toggle
        if mullvad_connected; then
            stop_mullvad
            "$NOTIFY_CMD" -a "VPN" -u normal "Mullvad Disconnected"
        else
            stop_apartment
            start_mullvad
            "$NOTIFY_CMD" -a "VPN" -u normal "Mullvad Connected"
        fi
        sleep 1
        print_json
        ;;
    apartment)
        # Apartment WG toggle
        if apartment_active; then
            stop_apartment
            "$NOTIFY_CMD" -a "VPN" -u normal "Apartment WG Disconnected"
        else
            stop_mullvad
            start_apartment
            if apartment_active; then
                "$NOTIFY_CMD" -a "VPN" -u normal "Apartment WG Connected"
            else
                "$NOTIFY_CMD" -a "VPN" -u critical "Apartment WG failed to start (check logs)"
            fi
        fi
        sleep 1
        print_json
        ;;
    *)
        print_json
        ;;
esac
