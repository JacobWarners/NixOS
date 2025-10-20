#!/usr/bin/env bash

# An improved rofi-based wifi menu using nmcli
# Icons:  (connected),  (secure),  (open)

# Notify function using hyprctl
notify() {
    hyprctl notify 5 2500 "rgb(d3c6aa)" "  $1"
}

main() {
    # Get a list of available wifi networks and show the active one
    local networks=$(nmcli --terse --fields "ACTIVE,SSID,SECURITY" device wifi list --rescan yes | awk -F: '{
        if ($2 != "") {
            active_icon = ($1 == "yes") ? "" : " ";
            security_icon = ($3 ~ /WPA|WEP|802.1X/) ? "" : "";
            print active_icon " " security_icon " " $2;
        }
    }')

    # Present the networks in a Rofi menu
    local selected_ssid_with_icons=$(echo -e "$networks" | rofi -dmenu -p "Select Wi-Fi" -i -l 10)

    # Exit if the user cancelled
    if [ -z "$selected_ssid_with_icons" ]; then
        exit 0
    fi

    # Extract the pure SSID using a more robust method
    local selected_ssid=$(echo "$selected_ssid_with_icons" | sed 's/^..//;s/^..//')

    # Check if we are already connected to the selected network
    if echo "$selected_ssid_with_icons" | grep -q ""; then
        notify "Already connected to $selected_ssid."
        exit 0
    fi

    # Check if a connection profile for this SSID already exists
    if nmcli connection show | grep -q "^${selected_ssid}\s"; then
        # Use the smarter "device wifi connect" command which handles switching automatically
        if pkexec nmcli device wifi connect "$selected_ssid"; then
            notify "Switched to $selected_ssid."
        else
            notify "Failed to switch to $selected_ssid."
        fi
    else
        # If it's a new network, check its security
        if echo "$selected_ssid_with_icons" | grep -q ""; then
            local password=$(rofi -dmenu -password -p "Password for $selected_ssid")
            if [ -n "$password" ]; then
                if pkexec nmcli device wifi connect "$selected_ssid" password "$password"; then
                    notify "Successfully connected to $selected_ssid."
                else
                    notify "Failed to connect. Check password."
                fi
            fi
        else
            # Connect to an open network
            if pkexec nmcli device wifi connect "$selected_ssid"; then
                notify "Successfully connected to $selected_ssid."
            else
                notify "Failed to connect to open network."
            fi
        fi
    fi
}

main
