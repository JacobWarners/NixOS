#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wallust"
CSS_OUTPUT_FILE="$CACHE_DIR/colors.css"
WALLPAPER_IMAGE="$1"

# --- Main Script ---

# Check if a wallpaper image was provided
if [ -z "$WALLPAPER_IMAGE" ]; then
  echo "Usage: $0 /path/to/your/wallpaper.jpg"
  exit 1
fi

echo "Running wallust and capturing its output..."
WALLUST_OUTPUT=$(wallust run "$WALLPAPER_IMAGE" 2>&1)
echo "$WALLUST_OUTPUT"

# --- THE BULLETPROOF FIX ---
# 1. Use `sed` to strip out all ANSI color escape codes.
# 2. Pipe the now-clean text to `grep`.
# 3. Pipe the result to `awk` to get the 5th field (the path).
JSON_PATH=$(echo "$WALLUST_OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep 'cache: Using cache' | awk '{print $5}')

# Check if we successfully found the path
if [ -z "$JSON_PATH" ]; then
  echo "Error: Could not determine the JSON palette file path from wallust's output."
  exit 1
fi

echo "Found correct JSON file: $JSON_PATH"
echo "Generating colors.css..."

# Use the guaranteed-correct path to generate the CSS
sed 's/}.*$/}/' "$JSON_PATH" | jq -r 'to_entries[] | "@define-color \(.key) \(.value);"' > "$CSS_OUTPUT_FILE"
echo "Successfully created $CSS_OUTPUT_FILE!"

# --- Perform a full restart of Waybar to apply the theme ---
echo "Performing a full restart of Waybar..."
killall -w waybar || true
sleep 0.2
waybar &

echo "Theme updated and Waybar restarted for hot-reloading."
