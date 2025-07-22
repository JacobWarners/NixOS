#!/usr/bin/env sh

# --- This is the file your external script will write to ---
STATE_FILE="/tmp/waybar_status.txt"

# --- Read the desired class from the state file ---
# If the file doesn't exist, it defaults to the 'flashing' state.
if [ -f "$STATE_FILE" ]; then
    css_class=$(cat "$STATE_FILE")
else
    css_class="flashing"
fi

# --- Define Colors ---
COLOR_ACTIVE='#03d7fc'
COLOR_SUPER_CHARGE='#ffffff' # Base color for the super state (animation will make it yellow)
COLOR_INACTIVE='#03fc45'
COLOR_EMPTY='#e6e600'

# --- Prepare variables ---
A=$(hyprctl activeworkspace | head -n 1 | awk '{print $3}')
L=1
output_text=""

# --- This loop builds the string of workspace icons ---
for i in $(hyprctl workspaces | grep "workspace ID" | grep -v lastwindowtitle | cut -d ' ' -f 3 | sort -g); do
    while [ $L -le $i ]; do
        if [ ! $L == $i ]; then
            output_text="${output_text}<span color='${COLOR_EMPTY}'>o</span>   "
        fi
        L=$(( $L + 1 ))
    done

    if [ "$A" -eq "$i" ]; then
        if [ "$css_class" = "super-charge-flash" ]; then
            # Set the base color directly for the super state
            output_text="${output_text}<span color='${COLOR_SUPER_CHARGE}'>B</span>   "
        else
            # Set the color directly for the normal state
            output_text="${output_text}<span color='${COLOR_ACTIVE}'>A</span>   "
        fi
    else
        output_text="${output_text}<span color='${COLOR_INACTIVE}'>C</span>   "
    fi
done

# --- Final JSON Output ---
printf '{"text": "%s", "class": "%s"}\n' "$output_text" "$css_class"

