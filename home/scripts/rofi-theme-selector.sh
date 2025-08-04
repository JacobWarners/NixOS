#!/usr/bin/env bash

# The directory where you store your wallpapers
# CORRECTED to 'wallpaper' (singular)
WALLPAPER_DIR="/home/jake/nixos-config/home/wallpaper"

# This line gets the directory where the current script is located.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Check if the directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  notify-send "Wallpaper Picker Error" "Directory not found: $WALLPAPER_DIR"
  exit 1
fi

# Use 'find' to get a list of all image files and pipe it into rofi
SELECTED_FILE=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | rofi -dmenu -i -p "Select Wallpaper")

# Exit if the user pressed escape or didn't select anything
if [ -z "$SELECTED_FILE" ]; then
    exit 0
fi

# It uses the SCRIPT_DIR variable to reliably find update-theme.sh
"$SCRIPT_DIR/update-theme.sh" "$SELECTED_FILE"

