#!/usr/bin/env bash
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wallust"
WALLPAPER_IMAGE="$1"
PALETTE=${2:-dark}

# --- Main Script ---
if [ -z "$WALLPAPER_IMAGE" ]; then
  echo "Usage: $0 /path/to/wallpaper.jpg [palette]"
  exit 1
fi

echo "Setting new wallpaper with awww..."
awww img "$WALLPAPER_IMAGE" --transition-type any

# wallust writes every target in [templates] of ~/.config/wallust/wallust.toml
# (colors.css, colors-kitty.conf, gtk.css, userChrome.css) directly into
# $CACHE_DIR. -w (--overwrite-cache) forces a fresh render even when the
# wallpaper is already cached, so the colors actually change every run.
echo "Running wallust with '$PALETTE' palette..."
wallust run -w --palette "$PALETTE" "$WALLPAPER_IMAGE"

# --- Apply GTK theme ---
echo "Applying GTK theme..."
mkdir -p "$HOME/.config/gtk-3.0"
cp "$CACHE_DIR/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"

# --- Apply Firefox theme (uncomment + set profile to enable) ---
# FIREFOX_PROFILE_DIR="/home/jake/.mozilla/firefox/hv5gsrjf.default"
# if [ -d "$FIREFOX_PROFILE_DIR" ]; then
#     mkdir -p "$FIREFOX_PROFILE_DIR/chrome"
#     cp "$CACHE_DIR/userChrome.css" "$FIREFOX_PROFILE_DIR/chrome/userChrome.css"
#     echo "Firefox theme updated. Restart Firefox to see changes."
# fi

# --- Reload Components ---
echo "Sending reload signal to Waybar..."
pkill -SIGUSR2 waybar || true
echo "Sending reload signal to Kitty..."
pkill -SIGUSR1 kitty || true

echo "Desktop theme fully updated."
