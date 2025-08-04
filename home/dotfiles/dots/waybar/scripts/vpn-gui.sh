#!/usr/bin/env bash


# 1. Launch the Mullvad GUI and wait for the user to close it.
/run/current-system/sw/bin/mullvad-vpn

# 2. After the GUI is closed, run our main script to output the
#    final status, instantly updating Waybar.
/home/jake/.config/waybar/scripts/vpn.sh
