#!/usr/bin/env bash
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wallust"
WALLPAPER_IMAGE="$1"
# Accept a second argument for the palette, default to 'dark' if not provided
PALETTE=${2:-dark}

# --- Main Script ---
if [ -z "$WALLPAPER_IMAGE" ]; then
  echo "Usage: $0 /path/to/wallpaper.jpg [palette]"
  exit 1
fi

echo "Setting new wallpaper with swww..."
swww img "$WALLPAPER_IMAGE" --transition-type any

echo "Running wallust with '$PALETTE' palette..."
# Pass the --palette argument to wallust
WALLUST_OUTPUT=$(wallust run --palette "$PALETTE" "$WALLPAPER_IMAGE" 2>&1)
echo "$WALLUST_OUTPUT"

# --- The rest of the script is the same ---
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

CSS_OUTPUT_FILE="$CACHE_DIR/colors.css"
echo "Generating colors.css for Waybar..."
sed 's/}.*$/}/' "$JSON_PATH" | jq -r 'to_entries[] | "@define-color \(.key) \(.value);"' > "$CSS_OUTPUT_FILE"

KITTY_OUTPUT_FILE="$CACHE_DIR/colors-kitty.conf"
echo "Generating colors-kitty.conf for Kitty..."
jq -r 'to_entries[] | "\(.key) \(.value)"' "$JSON_PATH" > "$KITTY_OUTPUT_FILE"

echo "Applying theme to GTK applications..."
WALLUST_GTK3_CSS="$CACHE_DIR/gtk.css"
mkdir -p "$HOME/.config/gtk-3.0"
if [ -f "$WALLUST_GTK3_CSS" ]; then cp "$WALLUST_GTK3_CSS" "$HOME/.config/gtk-3.0/gtk.css"; fi
echo "GTK theme colors updated."

echo "Sending reload signal to Waybar..."
pkill -SIGUSR2 waybar
echo "Sending reload signal to Kitty..."
pkill -SIGUSR1 kitty || true

echo "Desktop theme fully updated."
