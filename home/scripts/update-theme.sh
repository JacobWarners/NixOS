#!/usr/bin/env bash
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wallust"
CSS_OUTPUT_FILE="$CACHE_DIR/colors.css"
WALLPAPER_IMAGE="$1"

# --- Main Script ---
if [ -z "$WALLPAPER_IMAGE" ]; then
  echo "Usage: $0 /path/to/your/wallpaper.jpg"
  exit 1
fi

# --- NEW PART: Set the wallpaper using swww ---
# This assumes swww is initialized. The '--transition-type any' provides a nice effect.
echo "Setting new wallpaper with swww..."
swww img "$WALLPAPER_IMAGE" --transition-type any

# --- The rest of the script is the same ---
echo "Running wallust and capturing its output..."
WALLUST_OUTPUT=$(wallust run "$WALLPAPER_IMAGE" 2>&1)
echo "$WALLUST_OUTPUT"

JSON_PATH=$(echo "$WALLUST_OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep 'cache: Using cache' | awk '{print $5}')
if [ -z "$JSON_PATH" ]; then
  echo "Error: Could not determine the JSON palette file path from wallust's output."
  exit 1
fi

echo "Found correct JSON file: $JSON_PATH"
echo "Generating colors.css..."
sed 's/}.*$/}/' "$JSON_PATH" | jq -r 'to_entries[] | "@define-color \(.key) \(.value);"' > "$CSS_OUTPUT_FILE"
echo "Successfully created $CSS_OUTPUT_FILE!"

echo "Performing a full restart of Waybar..."
pkill -SIGUSR2 waybar

echo "Theme updated and Waybar restarted for hot-reloading."
