#!/usr/bin/env sh

SPELLING_BEE_URL="https://www.nytimes.com/puzzles/spelling-bee"
BUDDY_URL="https://www.nytimes.com/interactive/2023/upshot/spelling-bee-buddy.html"

pactl set-sink-volume @DEFAULT_SINK@ 100%
pactl set-sink-mute @DEFAULT_SINK@ 0
aplay ~/.config/waybar/sounds/spellingbee.wav
hyprctl dispatch workspace 5
firefox --new-window "$SPELLING_BEE_URL" &
sleep 1
firefox --new-window "$BUDDY_URL" &
hyprctl dispatch togglefloating active
hyprctl dispatch fullscreen 1
sleep 1
hyprctl dispatch workspace 9
chromium --new-window &

