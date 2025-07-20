#!/usr/bin/env sh

# The directory where your .wav sounds are stored.
SOUND_DIR="$HOME/.config/waybar/sounds/stardewsounds"

# Exit silently if the directory doesn't exist.
if [ ! -d "$SOUND_DIR" ]; then
    exit 0
fi

# Find all .wav files in the directory.
# The 'nullglob' option prevents errors if the folder is empty.
shopt -s nullglob
SOUND_FILES=("$SOUND_DIR"/*.wav)
shopt -u nullglob

# If no .wav files were found, exit silently.
if [ ${#SOUND_FILES[@]} -eq 0 ]; then
    exit 0
fi

# Pick a random .wav file from the array.
CHOSEN_FILE="${SOUND_FILES[RANDOM % ${#SOUND_FILES[@]}]}"

# Play the chosen file with paplay and run it in the background.
paplay "$CHOSEN_FILE" &
