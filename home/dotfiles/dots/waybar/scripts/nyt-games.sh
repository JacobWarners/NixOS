#!/usr/bin/env sh

SPELLING_BEE_URL="https://www.nytimes.com/puzzles/spelling-bee"
BUDDY_URL="https://www.nytimes.com/interactive/2023/upshot/spelling-bee-buddy.html"
SOUND_FILE=~/.config/waybar/sounds/spellingbee.wav

# Turn on TV and switch to HDMI 1 via Home Assistant (runs in background, non-blocking)
(
  HA_POD=$(kubectl get pod -n homelab -l app=homeassistant -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  HA_TOKEN=$(kubectl exec -n homelab "$HA_POD" -- python3 -c "
import json, jwt, time
with open('/config/.storage/auth') as f:
    d = json.load(f)
for t in d['data']['refresh_tokens']:
    if t.get('client_name') == 'n8n' and t.get('token_type') == 'long_lived_access_token':
        now = int(time.time())
        print(jwt.encode({'iss': t['id'], 'iat': now, 'exp': now + 3600}, t['jwt_key'], algorithm='HS256'))
        break
" 2>/dev/null)
  if [ -n "$HA_TOKEN" ]; then
    HA_URL="http://192.168.5.120:30123"
    curl -s -X POST -H "Authorization: Bearer $HA_TOKEN" -H "Content-Type: application/json" \
      -d '{"entity_id": "media_player.65_crystal_uhd"}' \
      "$HA_URL/api/services/media_player/turn_on" > /dev/null
    sleep 3
    curl -s -X POST -H "Authorization: Bearer $HA_TOKEN" -H "Content-Type: application/json" \
      -d '{"entity_id": "media_player.65_crystal_uhd", "source": "HDMI1"}' \
      "$HA_URL/api/services/media_player/select_source" > /dev/null
  fi
) &

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


