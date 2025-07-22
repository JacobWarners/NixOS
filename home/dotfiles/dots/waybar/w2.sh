#!/usr/bin/env sh

# --- Define Your Colors ---
COLOR_ACTIVE='#03d7fc'
COLOR_INACTIVE='#03fc45'
COLOR_EMPTY='#e6e600'
COLOR_SUPER_CHARGE='#fcf403'

# --- Get Battery Level ---
# Note: Your battery might be BAT1. Check with: ls /sys/class/power_supply/
BATT_PATH="/sys/class/power_supply/BAT0"
BATT_LEVEL=0 # Default to 0 if battery not found
if [ -f "${BATT_PATH}/capacity" ]; then
    BATT_LEVEL=$(cat "${BATT_PATH}/capacity")
fi

# --- Prepare variables ---
A=$(hyprctl monitors | grep workspace | head -n 1 | awk '{print $3}')
L=1
output_text=""
css_class="" # This will hold our dynamic class name

# --- Build the workspace string ---
for i in $(hyprctl workspaces | grep "workspace ID" | grep -v lastwindowtitle | cut -d ' ' -f 3 | sort -g)
do
    while [ $L -le $i ]; do
        if [ ! $L == $i ]; then
            output_text="${output_text} <span color='${COLOR_EMPTY}'>o</span>   "
        fi
        L=$(( $L + 1 ))
    done

    if [ "$A" -eq "$i" ]; then
        if [ "$BATT_LEVEL" -eq 100 ]; then
            output_text="${output_text}<span color='${COLOR_SUPER_CHARGE}'>B</span>   "
            css_class="super-charge-flash" # Set class for full battery
        else
            output_text="${output_text}<span color='${COLOR_ACTIVE}'>A</span>   "
        fi
    else
        output_text="${output_text}<span color='${COLOR_INACTIVE}'>C</span>   "
    fi
done

# --- Output JSON for Waybar ---
# This prints the final JSON object that Waybar understands.
printf '{"text": "%s", "class": "%s"}\n' "$output_text" "$css_class"
