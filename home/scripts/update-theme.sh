#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wallust"
CSS_OUTPUT_FILE="$CACHE_DIR/colors.css"
WALLPAPER_IMAGE="$1"

# --- Main Script ---

# Check if a wallpaper image was provided
if [ -z "$WALLPAPER_IMAGE" ];
then
  echo "Usage: $0 /path/to/your/wallpaper.jpg"
  exit 1
fi

echo "Running wallust to generate color palette..."
wallust run "$WALLPAPER_IMAGE"

echo "Finding the latest color palette JSON file..."
# Find the most recently modified .json file in the cache
LATEST_JSON=$(ls -t "$CACHE_DIR"/*.json | head -n 1)

if [ -z "$LATEST_JSON" ];
then
  echo "Error: No JSON palette file found in $CACHE_DIR"
  exit 1
fi

echo "Generating colors.css from $LATEST_JSON..."

# --- THIS IS THE FINAL CORRECTED COMMAND (NO QUOTES) ---
sed 's/}.*$/}/' "$LATEST_JSON" | jq -r 'to_entries[] | "@define-color \(.key) \(.value);"' > "$CSS_OUTPUT_FILE"

echo "Successfully created $CSS_OUTPUT_FILE!"
echo "You can now use it in your waybar style.css."
