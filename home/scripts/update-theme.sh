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

echo "Running wallust to generate color palette..."
wallust run "$WALLPAPER_IMAGE"

echo "Finding the latest color palette JSON file..."
LATEST_JSON=$(ls -t "$CACHE_DIR"/*.json | head -n 1)

if [ -z "$LATEST_JSON" ]; then
  echo "Error: No JSON palette file found in $CACHE_DIR"
  exit 1
fi

echo "Generating colors.css from $LATEST_JSON..."
sed 's/}.*$/}/' "$LATEST_JSON" | jq -r 'to_entries[] | "@define-color \(.key) \(.value);"' > "$CSS_OUTPUT_FILE"
echo "Successfully created $CSS_OUTPUT_FILE!"

# --- THE FINAL FIX: Force a full restart of Waybar ---
echo "Performing a full restart of Waybar to apply new theme..."

# The '|| true' prevents the script from exiting if waybar isn't running
# The '-w' flag waits for the process to die before continuing.
killall -w waybar || true

# Give it a moment to die completely before restarting
sleep 0.2

# Restart waybar in the background
waybar &

echo "Theme updated and Waybar restarted for hot-reloading."
