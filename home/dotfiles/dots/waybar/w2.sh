#!/usr/bin/env sh

# --- Configuration ---
# Define the icons and colors you want for each state.
# This makes it easy to change them later.
ICON_ACTIVE='A'
ICON_OCCUPIED='C'
ICON_EMPTY='O'

COLOR_ACTIVE='blue'
COLOR_OCCUPIED='green'
COLOR_EMPTY='yellow'
# --------------------

# 1. Determine the Primary Monitor and its Active Workspace
# We check for DP-3, then DP-7, and fall back to eDP-1.
if hyprctl monitors | grep -q "DP-3"; then
    PRIMARY_MONITOR="DP-3"
elif hyprctl monitors | grep -q "DP-7"; then
    PRIMARY_MONITOR="DP-7"
else
    PRIMARY_MONITOR="eDP-1"
fi
ACTIVE_WS=$(hyprctl monitors | grep "Monitor $PRIMARY_MONITOR" -A 7 | grep 'active workspace' | awk '{print $3}')

# 2. Get all occupied workspaces
# This creates a list of workspaces that have at least one window.
OCCUPIED_WSP=$(hyprctl workspaces | grep "windows: [1-9]" | awk '{print $3}' | sort -n)

# 3. Find the highest numbered workspace that is occupied
# This prevents us from printing infinite empty 'O's.
LAST_WSP=$(echo "$OCCUPIED_WSP" | tail -n 1)
if [ -z "$LAST_WSP" ]; then
    LAST_WSP=0
fi

# 4. Loop from 1 to the last occupied workspace and build the output
FINAL_OUTPUT=""
for i in $(seq 1 "$LAST_WSP"); do
    STATUS="EMPTY" # Default to empty

    # Check if the workspace is in our list of occupied ones
    for ws in $OCCUPIED_WSP; do
        if [ "$i" -eq "$ws" ]; then
            STATUS="OCCUPIED"
            break
        fi
    done

    # The active workspace always takes top priority
    if [ "$i" -eq "$ACTIVE_WS" ]; then
        STATUS="ACTIVE"
    fi

    # 5. Append the correctly formatted and colored icon to our output string
    case $STATUS in
        "ACTIVE")
            FINAL_OUTPUT="${FINAL_OUTPUT}<span color='${COLOR_ACTIVE}'>${ICON_ACTIVE}</span>"
            ;;
        "OCCUPIED")
            FINAL_OUTPUT="${FINAL_OUTPUT}<span color='${COLOR_OCCUPIED}'>${ICON_OCCUPIED}</span>"
            ;;
        "EMPTY")
            FINAL_OUTPUT="${FINAL_OUTPUT}<span color='${COLOR_EMPTY}'>${ICON_EMPTY}</span>"
            ;;
    esac
    # Add spacing between icons
    FINAL_OUTPUT="${FINAL_OUTPUT} "
done

# 6. Print the final result to Waybar
echo "$FINAL_OUTPUT"
