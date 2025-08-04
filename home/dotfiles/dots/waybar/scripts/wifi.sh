#!/usr/bin/env bash

# A simple rofi-based wifi menu using nmcli
# Icons from Nerd Fonts:  (secure),  (open),  (wifi)

# Notify function using hyprctl
notify() {
    hyprctl notify 5 2500 "rgb(d3c6aa)" "  $1"
}

main() {
    # Get a list of available wifi networks and format for Rofi
    # --terse provides a more script-friendly output
    # --rescan tells nmcli to scan for new networks before listing
    local networks=$(nmcli --terse --fields "SSID,SECURITY" device wifi list --rescan yes | awk -F: '{if ($2 ~ /WPA|WEP|802.1X/) print " " $1; else if ($1 != "") print " " $1}')

    # Present the networks in a Rofi menu
    local selected_ssid_with_icon=$(echo -e "$networks" | rofi -dmenu -p "Select Wi-Fi" -i -l 10)

    # Exit if the user cancelled
    if [ -z "$selected_ssid_with_icon" ]; then
        exit 0
    fi

    # Extract the pure SSID without the icon
    local selected_ssid=$(echo "$selected_ssid_with_icon" | sed 's/^..//')

    # Check if a connection for this SSID already exists
    if nmcli connection show | grep -q "^${selected_ssid}\s"; then
        # If it exists, just bring it up
        if nmcli connection up "$selected_ssid"; then
            notify "Connected to $selected_ssid."
        else
            notify "Failed to connect to $selected_ssid."
        fi
    else
        # If it's a new network, check its security
        if echo "$selected_ssid_with_icon" | grep -q ""; then
            # Prompt for a password for a secure network
            local password=$(rofi -dmenu -password -p "Password for $selected_ssid")
            if [ -n "$password" ]; then
                if nmcli device wifi connect "$selected_ssid" password "$password"; then
                    notify "Successfully connected to $selected_ssid."
                else
                    notify "Failed to connect. Check password."
                fi
            fi
        else
            # Connect to an open network without a password
            if nmcli device wifi connect "$selected_ssid"; then
                notify "Successfully connected to $selected_ssid."
            else
                notify "Failed to connect to open network."
            fi
        fi
    fi
}

main
