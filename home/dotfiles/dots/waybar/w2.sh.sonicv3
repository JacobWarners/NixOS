#!/usr/bin/env sh

# --- Create a log file for debugging ---
# After running, you can check this file to see what happened.
LOG_FILE="/tmp/waybar-debug.log"
echo "--- Script Start: $(date) ---" > "$LOG_FILE"

# --- Your Color Definitions ---
COLOR_ACTIVE='#03d7fc'
COLOR_INACTIVE='#03fc45'
COLOR_EMPTY='#e6e600'
COLOR_SUPER_CHARGE='#fcf403'

# --- Get Battery Level ---
BATT_PATH="/sys/class/power_supply/BAT1" # Adjust if your battery is not BAT0
BATT_LEVEL=0
if [ -f "${BATT_PATH}/capacity" ]; then
    BATT_LEVEL=$(cat "${BATT_PATH}/capacity")
fi
# Write the battery level to our log file
echo "DEBUG: Battery Level is $BATT_LEVEL" >> "$LOG_FILE"


# --- Get Active Workspace ---
A=$(hyprctl activeworkspace | head -n 1 | awk '{print $3}')
# Write the active workspace ID to our log file
echo "DEBUG: Active Workspace (A) is $A" >> "$LOG_FILE"


# --- Prepare variables ---
L=1
output_text=""
css_class="" # The class starts as an empty string


# --- Build the workspace string ---
for i in $(hyprctl workspaces | grep "workspace ID" | grep -v lastwindowtitle | cut -d ' ' -f 3 | sort -g)
do
    echo "DEBUG: ------ Loop for workspace $i ------" >> "$LOG_FILE"

    # This inner loop for empty workspaces is likely fine, but we'll leave it
    while [ $L -le $i ]; do
        if [ ! $L == $i ]; then
            output_text="${output_text} <span color='${COLOR_EMPTY}'>o</span>   "
        fi
        L=$(( $L + 1 ))
    done

    # --- THE CORE LOGIC BLOCK ---
    echo "DEBUG: Comparing Active ($A) to Current ($i)" >> "$LOG_FILE"
    if [ "$A" -eq "$i" ]; then
        echo "DEBUG: MATCH FOUND! Now checking battery." >> "$LOG_FILE"
        # NOTE: Set your test battery level here
        if [ "$BATT_LEVEL" -eq 85 ]; then
            echo "DEBUG: Battery match. Setting class to 'super-charge-flash'." >> "$LOG_FILE"
            css_class="super-charge-flash"
            output_text="${output_text}<span color='${COLOR_SUPER_CHARGE}'>B</span>   "
        else
            echo "DEBUG: Battery NOT matched. Setting class to 'flashing'." >> "$LOG_FILE"
            css_class="flashing"
            output_text="${output_text}<span color='${COLOR_ACTIVE}'>A</span>   "
        fi
    else
        echo "DEBUG: No match. Workspace $i is not active." >> "$LOG_FILE"
        output_text="${output_text}<span color='${COLOR_INACTIVE}'>C</span>   "
    fi
    echo "DEBUG: At end of loop $i, css_class is now '$css_class'" >> "$LOG_FILE"
done

echo "--- Loop Finished ---" >> "$LOG_FILE"
echo "FINAL: The final class being sent to Waybar is '$css_class'" >> "$LOG_FILE"

# --- Output the final JSON for Waybar ---
printf '{"text": "%s", "class": "%s"}\n' "$output_text" "$css_class"
