#!/usr/bin/env sh

SPELLING_BEE_URL="https://www.nytimes.com/puzzles/spelling-bee"
BUDDY_URL="https://www.nytimes.com/interactive/2023/upshot/spelling-bee-buddy.html"

hyprctl dispatch workspace 9
chromium --new-window &
paplay ~/.config/waybar/sounds/spellingbee.wav
sleep 2
hyprctl dispatch workspace 5
firefox --new-window "$SPELLING_BEE_URL" &
sleep 2
firefox --new-window "$BUDDY_URL" &
hyprctl dispatch togglefloating active
hyprctl dispatch fullscreen 1

