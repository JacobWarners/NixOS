#!/usr/bin/env bash
set -e

# --- Configuration ---
CACHE_DIR="$HOME/.cache/wallust"
TEMPLATE_DIR="$HOME/.config/wallust/templates"
WALLPAPER_IMAGE="$1"
# THIS LINE IS NOW CORRECTLY ADDED BACK:
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
# THIS LINE IS NOW CORRECTLY ADDED BACK:
# Pass the --palette argument to wallust
WALLUST_OUTPUT=$(wallust run --palette "$PALETTE" "$WALLPAPER_IMAGE" 2>&1)
echo "$WALLUST_OUTPUT"

# --- Correctly find the JSON file ---
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

# --- Robustly Generate ALL Theme Files from Templates ---
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

# --- Apply GTK and Firefox themes by copying them ---
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

echo "Desktop theme fully updated."
