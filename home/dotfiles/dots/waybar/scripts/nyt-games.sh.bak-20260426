#!/usr/bin/env sh

SPELLING_BEE_URL="https://www.nytimes.com/puzzles/spelling-bee"
BUDDY_URL="https://www.nytimes.com/interactive/2023/upshot/spelling-bee-buddy.html"
SOUND_FILE=~/.config/waybar/sounds/spellingbee.wav

# Set master volume to 100%
pactl set-sink-volume @DEFAULT_SINK@ 100%
pactl set-sink-mute @DEFAULT_SINK@ 0

# Play the intro sound at 100% (65536) using paplay
paplay --volume=65536 "$SOUND_FILE" &

# --- Launch all your applications ---
hyprctl dispatch workspace 5
librewolf --new-window "$BUDDY_URL" &
sleep 1
librewolf --new-window "$SPELLING_BEE_URL" &
sleep 1
hyprctl dispatch togglefloating active
hyprctl dispatch fullscreen 1
sleep 1
hyprctl dispatch workspace 9
chromium --new-window &

# --- Reset the paplay volume using your logic ---

# Wait 5 seconds for the loud sound to finish
sleep 5

# Mute the system
pactl set-sink-mute @DEFAULT_SINK@ 1

# Play the sound again at 30% (approx 19660)
# This sets the "remembered" volume for paplay to 30%
paplay --volume=19660 "$SOUND_FILE" &

# Wait 1 second for the quiet sound to play (while muted)
sleep 5

# Unmute the system
pactl set-sink-mute @DEFAULT_SINK@ 0


