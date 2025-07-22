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

# --- Colors for non-flashing icons ---
COLOR_INACTIVE='#03fc45'
COLOR_EMPTY='#e6e600'

# --- Prepare variables for generating workspace icons ---
A=$(hyprctl activeworkspace | head -n 1 | awk '{print $3}')
L=1
output_text=""

# --- This loop builds the string of workspace icons ---
for i in $(hyprctl workspaces | grep "workspace ID" | grep -v lastwindowtitle | cut -d ' ' -f 3 | sort -g); do
    # This sub-loop finds and adds empty workspaces ('o')
    while [ $L -le $i ]; do
        if [ ! $L == $i ]; then
            output_text="${output_text}<span color='${COLOR_EMPTY}'>o</span>   "
        fi
        L=$(( $L + 1 ))
    done

    # This handles the active workspace ('A' or 'B') or occupied ones ('C')
    if [ "$A" -eq "$i" ]; then
        # THIS IS THE ACTIVE WORKSPACE
        # Check the class from the state file to decide which character to show.
        if [ "$css_class" = "super-charge-flash" ]; then
            # If class is 'super-charge-flash', show 'B'
            output_text="${output_text}<span>B</span>   "
        else
            # For the 'flashing' class (or any other), show 'A'
            output_text="${output_text}<span>A</span>   "
        fi
    else
        # This is for an inactive but occupied workspace
        output_text="${output_text}<span color='${COLOR_INACTIVE}'>C</span>   "
    fi
done

# --- Final JSON Output ---
# It sends the icon string and the class read from the file to Waybar.
printf '{"text": "%s", "class": "%s"}\n' "$output_text" "$css_class"
