#!/usr/bin/env bash
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wallust"
WALLPAPER_IMAGE="$1"

# --- Main Script ---
if [ -z "$WALLPAPER_IMAGE" ]; then
  echo "Usage: $0 /path/to/your/wallpaper.jpg"
  exit 1
fi

echo "Setting new wallpaper with swww..."
swww img "$WALLPAPER_IMAGE" --transition-type any

echo "Running wallust to generate all color palettes..."
WALLUST_OUTPUT=$(wallust run "$WALLPAPER_IMAGE" 2>&1)
echo "$WALLUST_OUTPUT"

JSON_PATH=$(echo "$WALLUST_OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep 'Using cache' | awk '{print $5}')
if [ -z "$JSON_PATH" ]; then
  echo "Existing wallpaper not found in cache log, finding newest file..."
  sleep 0.1
  JSON_PATH=$(ls -t "$CACHE_DIR"/*.json | head -n 1)
fi
if [ -z "$JSON_PATH" ]; then
  echo "Error: Could not determine JSON palette file path."
  exit 1
fi
echo "Using JSON file: $JSON_PATH"

# --- Generate Theme Files ---
CSS_OUTPUT_FILE="$CACHE_DIR/colors.css"
echo "Generating colors.css for Waybar..."
sed 's/}.*$/}/' "$JSON_PATH" | jq -r 'to_entries[] | "@define-color \(.key) \(.value);"' > "$CSS_OUTPUT_FILE"

KITTY_OUTPUT_FILE="$CACHE_DIR/colors-kitty.conf"
echo "Generating colors-kitty.conf for Kitty..."
jq -r 'to_entries[] | "\(.key) \(.value)"' "$JSON_PATH" > "$KITTY_OUTPUT_FILE"

# --- Apply GTK Theme ---
echo "Applying theme to GTK applications..."
WALLUST_GTK3_CSS="$CACHE_DIR/gtk.css"
mkdir -p "$HOME/.config/gtk-3.0"
if [ -f "$WALLUST_GTK3_CSS" ]; then cp "$WALLUST_GTK3_CSS" "$HOME/.config/gtk-3.0/gtk.css"; fi
echo "GTK theme colors updated."

# --- NEW: Apply theme to Firefox ---
echo "Applying theme to Firefox..."
# Find the generated userChrome.css from wallust's cache
WALLUST_CHROME_CSS="$CACHE_DIR/userChrome.css"
# Find the default Firefox profile directory
FIREFOX_PROFILE_DIR=$(find "$HOME/.mozilla/firefox/" -maxdepth 1 -type d -name "*.default-release")

if [ -f "$WALLUST_CHROME_CSS" ] && [ -d "$FIREFOX_PROFILE_DIR" ]; then
    # Ensure the 'chrome' subdirectory exists
    mkdir -p "$FIREFOX_PROFILE_DIR/chrome"
    # Copy the theme to where Firefox will find it
    cp "$WALLUST_CHROME_CSS" "$FIREFOX_PROFILE_DIR/chrome/userChrome.css"
    echo "Firefox theme updated. You may need to restart Firefox to see changes."
else
    echo "Warning: Firefox profile or wallust's userChrome.css not found. Skipping."
fi

# --- Reload Components ---
echo "Sending reload signal to Waybar..."
pkill -SIGUSR2 waybar
echo "Sending reload signal to Kitty..."
pkill -SIGUSR-I kitty || true

echo "Desktop theme fully updated."
