#!/usr/bin/env bash
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wallust"
TEMPLATE_DIR="$HOME/.config/wallust/templates"
WALLPAPER_IMAGE="$1"

# --- Main Script ---
if [ -z "$WALLPAPER_IMAGE" ]; then
  echo "Usage: $0 /path/to/your/wallpaper.jpg"
  exit 1
fi

echo "Setting new wallpaper with swww..."
swww img "$WALLPAPER_IMAGE" --transition-type any

echo "Running wallust to generate color palette..."
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

# --- NEW: ROBUSTLY GENERATE ALL THEME FILES FROM TEMPLATES ---
echo "Generating all theme files from your templates..."

# Read all key-value pairs from the JSON into a bash associative array
declare -A colors
while IFS= read -r key && IFS= read -r value; do
    colors["$key"]="$value"
done < <(jq -r 'to_entries[] | .key, .value' "$JSON_PATH")

# Process each template file that exists in your template directory
for TPL_FILE in "$TEMPLATE_DIR"/*.tpl; do
    # Get just the filename, e.g., 'colors.css.tpl'
    tpl_basename=$(basename "$TPL_FILE")
    # Get the output filename by removing '.tpl', e.g., 'colors.css'
    dest_filename=${tpl_basename%.tpl}
    dest_path="$CACHE_DIR/$dest_filename"

    echo "Processing: $tpl_basename -> $dest_filename"
    
    # Start with a fresh copy of the template
    temp_file=$(mktemp)
    cp "$TPL_FILE" "$temp_file"

    # Loop through our associative array of colors and replace placeholders
    for key in "${!colors[@]}"; do
        # sed -i "s|{placeholder}|value|g" file
        sed -i "s|{${key}}|${colors[$key]}|g" "$temp_file"
    done
    
    # Move the finished, themed file into the cache
    mv "$temp_file" "$dest_path"
done

# --- Apply GTK and Firefox themes by copying them to their final destinations ---
echo "Applying GTK & Firefox themes..."
mkdir -p "$HOME/.config/gtk-3.0"
cp "$CACHE_DIR/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"

FIREFOX_PROFILE_DIR=$(find "$HOME/.mozilla/firefox/" -maxdepth 1 -type d -name "*.default-release")
if [ -d "$FIREFOX_PROFILE_DIR" ]; then
    mkdir -p "$FIREFOX_PROFILE_DIR/chrome"
    cp "$CACHE_DIR/userChrome.css" "$FIREFOX_PROFILE_DIR/chrome/userChrome.css"
    echo "Firefox theme updated. Restart Firefox to see changes."
fi

# --- Reload Components ---
echo "Sending reload signal to Waybar..."
pkill -SIGUSR2 waybar

echo "Sending reload signal to Kitty..."
pkill -SIGUSR1 kitty || true

echo "Desktop theme fully and reliably updated."
