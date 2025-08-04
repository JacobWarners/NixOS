#!/usr/bin/env bash

# --- Configuration ---
WALLPAPER_DIR="/home/jake/nixos-config/home/wallpaper"
THUMBNAIL_DIR="$HOME/.cache/rofi-wallpaper-thumbnails"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROFI_THEME_PATH="/home/jake/nixos-config/home/rofi-themes/wallpaper.rasi"

# Create the thumbnail directory if it doesn't exist
mkdir -p "$THUMBNAIL_DIR"

# --- Main Script ---
generate_rofi_list() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | while read -r F_PATH
    do
        THUMBNAIL_FNAME="$(echo -n "$F_PATH" | md5sum | cut -d' ' -f1).png"
        THUMBNAIL_PATH="$THUMBNAIL_DIR/$THUMBNAIL_FNAME"

        if [ ! -f "$THUMBNAIL_PATH" ]; then
            magick "$F_PATH" -thumbnail '200x200^' -gravity center -extent 200x200 "$THUMBNAIL_PATH"
        fi
        
        echo -en "$(basename "$F_PATH")\0icon\x1f$THUMBNAIL_PATH\n"
    done
}

# Run Rofi only ONCE
SELECTED_BASENAME=$(generate_rofi_list | rofi -dmenu -i -p "Select Wallpaper" -show-icons -theme "$ROFI_THEME_PATH")

# Exit if the user pressed escape
if [ -z "$SELECTED_BASENAME" ]; then
    exit 0
fi

# Reconstruct the full path from the basename
SELECTED_FULL_PATH="$WALLPAPER_DIR/$SELECTED_BASENAME"

# Call the update script with the full path
"$SCRIPT_DIR/update-theme.sh" "$SELECTED_FULL_PATH"
