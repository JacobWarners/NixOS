#!/usr/bin/env sh

# --- Define Your Colors ---
COLOR_ACTIVE='blue'
COLOR_INACTIVE='green'
COLOR_EMPTY='yellow'

# --- Your Original Logic ---
A=$(hyprctl monitors | grep workspace | head -n 1 | awk '{print $3}')
L=1

# The only change is wrapping the output of each 'echo' in a span tag for color.
for i in $(hyprctl workspaces | grep "workspace ID" | grep -v lastwindowtitle | cut -d ' ' -f 3 | sort -g)
do
    while [ $L -le $i ]
    do
        if [ ! $L == $i ]; then
            # This is your 'O' for empty workspaces, now colored yellow.
            # I've used the character 'O' as requested.
            echo -n "<span color='${COLOR_EMPTY}'>o</span>   "
        fi
        L=$(( $L + 1 ))
    done

    if [ "$A" -eq "$i" ]; then
        # This is your 'A' for the active workspace, now colored blue.
        echo -n "<span color='${COLOR_ACTIVE}'>A</span>   "
    else
        # This is your 'C' for inactive but occupied workspaces, now colored green.
        echo -n "<span color='${COLOR_INACTIVE}'>C</span>   "
    fi
done

# This final echo prevents the next shell prompt from appearing on the same line.
echo ""
