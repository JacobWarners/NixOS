#!/usr/bin/env bash

# --- Configuration ---
WALLPAPER_DIR="/home/jake/nixos-config/home/wallpaper"
THUMBNAIL_DIR="$HOME/.cache/rofi-wallpaper-thumbnails"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROFI_THEME_PATH="/home/jake/nixos-config/home/rofi-themes/wallpaper.rasi"

mkdir -p "$THUMBNAIL_DIR"

# --- STEP 1: Ask for the theme mode ---
# Create a menu of options for Rofi
MODE_OPTIONS="Dark\nLight\nSoft-Light"
# Show the menu and capture the user's choice
CHOSEN_MODE=$(echo -e "$MODE_OPTIONS" | rofi -dmenu -i -p "Select Theme Mode")

# Exit if the user pressed escape
if [ -z "$CHOSEN_MODE" ]; then
    exit 0
fi

# Convert the user-friendly choice into the command-line flag for wallust
case $CHOSEN_MODE in
    "Dark")       PALETTE="dark" ;;
    "Light")      PALETTE="light" ;;
    "Soft-Light") PALETTE="softlight" ;;
    *)            exit 1 ;;
esac

# --- STEP 2: Show the wallpaper picker ---
generate_rofi_list() {
    # (This function is the same as before)
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

SELECTED_BASENAME=$(generate_rofi_list | rofi -dmenu -i -p "Select Wallpaper" -show-icons -theme "$ROFI_THEME_PATH")

if [ -z "$SELECTED_BASENAME" ]; then
    exit 0
fi

SELECTED_FULL_PATH="$WALLPAPER_DIR/$SELECTED_BASENAME"

# --- STEP 3: Call the update script with BOTH arguments ---
"$SCRIPT_DIR/update-theme.sh" "$SELECTED_FULL_PATH" "$PALETTE"
