#!/usr/bin/env sh

# --- Define Your Colors ---
COLOR_ACTIVE='#03d7fc'
COLOR_INACTIVE='#03fc45'
COLOR_EMPTY='#e6e600'
COLOR_SUPER_CHARGE='#fcf403' # The yellow from your super-sonic animation

# --- Get Battery Level ---
# Note: Your battery might be BAT1 or something else.
# Check your system with the command: ls /sys/class/power_supply/
BATT_PATH="/sys/class/power_supply/BAT0"
BATT_LEVEL=0 # Default to 0 if battery not found
if [ -f "${BATT_PATH}/capacity" ]; then
    BATT_LEVEL=$(cat "${BATT_PATH}/capacity")
fi

# --- Workspace Logic ---
A=$(hyprctl monitors | grep workspace | head -n 1 | awk '{print $3}')
L=1

for i in $(hyprctl workspaces | grep "workspace ID" | grep -v lastwindowtitle | cut -d ' ' -f 3 | sort -g)
do
    while [ $L -le $i ]
    do
        if [ ! $L == $i ]; then
            echo -n " <span color='${COLOR_EMPTY}'>o</span>   "
        fi
        L=$(( $L + 1 ))
    done

    # This is the main conditional logic block
    if [ "$A" -eq "$i" ]; then
        # If workspace is active, check battery level
        if [ "$BATT_LEVEL" -eq 19 ]; then
            # AT 100%: Display 'B' with the super-charge flashing animation
            echo -n " <span class='super-charge-flash' color='${COLOR_SUPER_CHARGE}'>B</span>   "
        else
            # BELOW 100%: Display 'A' with the regular flashing animation
            echo -n " <span class='flashing' color='${COLOR_ACTIVE}'>A</span>   "
        fi
    else
        # Inactive but occupied workspaces
        echo -n " <span color='${COLOR_INACTIVE}'>C</span>   "
    fi
done

echo ""
