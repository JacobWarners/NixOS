#!/usr/bin/env sh

# --- Define Your Colors ---
COLOR_ACTIVE='blue'
COLOR_INACTIVE='green'
COLOR_EMPTY='yellow'

# --- Define Your Icons ---
ICON_ACTIVE='A'
ICON_INACTIVE='C'
ICON_EMPTY='O'

# 1. Get the active workspace ID
ACTIVE_WORKSPACE=$(hyprctl monitors | grep 'focused: yes' -B 1 | head -n 1 | awk '{print $2}')

# 2. Build the output string
FINAL_OUTPUT=""
for I in $(seq 1 10); do # Loop from 1 to 10
    ICON=$ICON_EMPTY
    COLOR=$COLOR_EMPTY

    # Check if the workspace is active
    if [ "$I" -eq "$ACTIVE_WORKSPACE" ]; then
        ICON=$ICON_ACTIVE
        COLOR=$COLOR_ACTIVE
    # Check if the workspace exists but is not active
    elif hyprctl workspaces | grep -q "ID $I on"; then
        ICON=$ICON_INACTIVE
        COLOR=$COLOR_INACTIVE
    fi

    # Append the formatted character to the final output string
    # Using printf for better formatting control
    FINAL_OUTPUT="${FINAL_OUTPUT}$(printf "<span color='%s'>%s</span> " "$COLOR" "$ICON")"
done

# 3. Echo the final, fully-formatted string once
echo "${FINAL_OUTPUT}"
