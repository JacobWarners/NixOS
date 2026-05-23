#!/usr/bin/env bash
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wallust"
TEMPLATE_DIR="$HOME/.config/wallust/templates"
WALLPAPER_IMAGE="$1"
PALETTE=${2:-dark}

# --- Main Script ---
if [ -z "$WALLPAPER_IMAGE" ]; then
  echo "Usage: $0 /path/to/wallpaper.jpg [palette]"
  exit 1
fi

echo "Setting new wallpaper with swww..."
swww img "$WALLPAPER_IMAGE" --transition-type any

echo "Running wallust with '$PALETTE' palette..."
WALLUST_OUTPUT=$(wallust run --palette "$PALETTE" "$WALLPAPER_IMAGE" 2>&1)
echo "$WALLUST_OUTPUT"

# wallust 3.4 layout: ~/.cache/wallust/<imghash>_1.7/FastResize_Lch_auto_<Palette>
case "$PALETTE" in
    dark)      PAL_CAP="Dark" ;;
    light)     PAL_CAP="Light" ;;
    softlight) PAL_CAP="SoftLight" ;;
    *)         PAL_CAP="${PALETTE^}" ;;
esac

JSON_PATH=$(ls -t "$CACHE_DIR"/*_1.7/FastResize_*_"$PAL_CAP" 2>/dev/null | head -n 1)
if [ -z "$JSON_PATH" ]; then
  echo "Error: no wallust 3.4 cache file found for palette '$PAL_CAP'."
  exit 1
fi
echo "Using JSON file: $JSON_PATH"

# --- Generate ALL Theme Files from Templates ---
echo "Generating all theme files from your templates..."
declare -A colors
while IFS= read -r key && IFS= read -r value; do
    colors["$key"]="$value"
done < <(jq -r 'to_entries[] | .key, .value' "$JSON_PATH")

for TPL_FILE in "$TEMPLATE_DIR"/*.tpl; do
    tpl_basename=$(basename "$TPL_FILE")
    dest_filename=${tpl_basename%.tpl}
    dest_path="$CACHE_DIR/$dest_filename"
    if [ -f "$TPL_FILE" ]; then
        echo "Processing: $tpl_basename -> $dest_filename"
        temp_file=$(mktemp)
        cp "$TPL_FILE" "$temp_file"
        for key in "${!colors[@]}"; do
            sed -i "s|{${key}}|${colors[$key]}|g" "$temp_file"
        done
        mv "$temp_file" "$dest_path"
    fi
done

# --- Apply GTK and Firefox themes ---
echo "Applying GTK & Firefox themes..."
mkdir -p "$HOME/.config/gtk-3.0"
cp "$CACHE_DIR/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"

# --- THIS IS THE CORRECTED PART ---
# Use the exact Firefox profile path you provided
# FIREFOX_PROFILE_DIR="/home/jake/.mozilla/firefox/hv5gsrjf.default"
# if [ -d "$FIREFOX_PROFILE_DIR" ]; then
#     mkdir -p "$FIREFOX_PROFILE_DIR/chrome"
#     cp "$CACHE_DIR/userChrome.css" "$FIREFOX_PROFILE_DIR/chrome/userChrome.css"
#     echo "Firefox theme updated. Restart Firefox to see changes."
# else
#     echo "Warning: Specific Firefox profile not found at $FIREFOX_PROFILE_DIR"
# fi
# 
# --- Reload Components ---
echo "Sending reload signal to Waybar..."
pkill -SIGUSR2 waybar
echo "Sending reload signal to Kitty..."
pkill -SIGUSR1 kitty || true

echo "Desktop theme fully updated."
