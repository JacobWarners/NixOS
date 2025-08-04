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

echo "Setting new wallpaper with swww..."
swww img "$WALLPAPER_IMAGE" --transition-type any

echo "Running wallust to generate all color palettes..."
WALLUST_OUTPUT=$(wallust run "$WALLPAPER_IMAGE" 2>&1)
echo "$WALLUST_OUTPUT"

# --- THE CORRECT LOGIC FOR FINDING THE JSON FILE ---
# First, try to find the path for an EXISTING wallpaper in the log
JSON_PATH=$(echo "$WALLUST_OUTPUT" | sed 's/\x1b\[[0-9;]*m//g' | grep 'Using cache' | awk '{print $5}')

# If that fails, it must be a NEW wallpaper, so find the newest file in the cache
if [ -z "$JSON_PATH" ]; then
  echo "Existing wallpaper not found in cache log, finding newest file for new wallpaper..."
  sleep 0.1 # Give filesystem a moment
  JSON_PATH=$(ls -t "$CACHE_DIR"/*.json | head -n 1)
fi

# Final check to ensure we have a path
if [ -z "$JSON_PATH" ]; then
  echo "Error: Could not determine JSON palette file path."
  exit 1
fi

echo "Using JSON file: $JSON_PATH"
# --- END OF LOGIC FIX ---

# --- Generate Waybar CSS ---
echo "Generating colors.css for Waybar..."
sed 's/}.*$/}/' "$JSON_PATH" | jq -r 'to_entries[] | "@define-color \(.key) \(.value);"' > "$CSS_OUTPUT_FILE"

# --- Apply theme to GTK applications ---
echo "Applying theme to GTK applications..."
WALLUST_GTK3_CSS="$CACHE_DIR/gtk.css"
WALLUST_GTK4_CSS="$CACHE_DIR/gtk-4.0.css"
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-4.0"
if [ -f "$WALLUST_GTK3_CSS" ]; then cp "$WALLUST_GTK3_CSS" "$HOME/.config/gtk-3.0/gtk.css"; fi
if [ -f "$WALLUST_GTK4_CSS" ]; then cp "$WALLUST_GTK4_CSS" "$HOME/.config/gtk-4.0/gtk.css"; fi
echo "GTK theme colors updated."

# --- Reload Components ---
echo "Sending reload signal to Waybar..."
pkill -SIGUSR2 waybar

echo "Sending reload signal to Kitty..."
pkill -SIGUSR1 kitty || true

echo "Desktop theme fully updated."
