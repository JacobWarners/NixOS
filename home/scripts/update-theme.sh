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
# We run wallust without capturing output, its messages will show in the terminal
wallust run "$WALLPAPER_IMAGE"
sleep 0.1 # Give filesystem a moment to update

# Find the latest JSON palette file
LATEST_JSON=$(ls -t "$CACHE_DIR"/*.json | head -n 1)
if [ -z "$LATEST_JSON" ]; then
  echo "Error: No JSON palette file found after running wallust."
  exit 1
fi

# --- Generate Waybar CSS ---
echo "Generating colors.css for Waybar..."
sed 's/}.*$/}/' "$LATEST_JSON" | jq -r 'to_entries[] | "@define-color \(.key) \(.value);"' > "$CSS_OUTPUT_FILE"

# --- NEW: Apply theme to GTK applications ---
echo "Applying theme to GTK applications..."
# wallust generates gtk.css and gtk-4.0.css in its cache
WALLUST_GTK3_CSS="$CACHE_DIR/gtk.css"
WALLUST_GTK4_CSS="$CACHE_DIR/gtk-4.0.css"

# Ensure the target directories exist
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-4.0"

# Copy the colors to where GTK will find them
if [ -f "$WALLUST_GTK3_CSS" ]; then
    cp "$WALLUST_GTK3_CSS" "$HOME/.config/gtk-3.0/gtk.css"
fi
if [ -f "$WALLUST_GTK4_CSS" ]; then
    cp "$WALLUST_GTK4_CSS" "$HOME/.config/gtk-4.0/gtk.css"
fi
echo "GTK theme colors updated."

# --- Reload Components ---
echo "Sending reload signal to Waybar..."
pkill -SIGUSR2 waybar

echo "Sending reload signal to Kitty..."
pkill -SIGUSR1 kitty || true

echo "Desktop theme fully updated."
