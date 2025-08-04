#!/usr/bin/env bash

# --- Configuration with FULL PATHS ---
MULLVAD_CMD="/run/current-system/sw/bin/mullvad"
HEAD_CMD="/run/current-system/sw/bin/head"
SED_CMD="/run/current-system/sw/bin/sed"


# --- Logic ---
check_status() {
    local first_line
    # Add '2> /dev/null' to suppress the "Broken pipe" error from mullvad
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
        # The cycle commands don't produce long output, so no redirection is needed here
        if [[ "$(check_status)" == "connected" ]]; then
            "$MULLVAD_CMD" disconnect
        else
            "$MULLVAD_CMD" connect
        fi
        ;;
    *)
        status=$(check_status)
        if [[ "$status" == "connected" ]]; then
            # Also add '2> /dev/null' here for the tooltip generation
            tooltip_text=$("$MULLVAD_CMD" status 2> /dev/null | "$SED_CMD" -z 's/\n/\\n/g')
            printf '{"text": "", "class": "connected", "tooltip": "%s"}' "$tooltip_text"
        else
            printf '{"text": "", "class": "disconnected", "tooltip": "Mullvad: Disconnected"}'
        fi
        ;;
esac
