#!/usr/bin/env nix-shell
#!nix-shell -i sh -p evtest coreutils util-linux gawk
#
# key_counter_daemon.sh
#
# This script listens for events from multiple keyboards, increments a counter,
# and triggers a special state based on user input.

# --- Configuration ---
# We export these variables so they are available to background processes.
export COUNTER_FILE="/tmp/waybar_counter.txt"
export LOG_FILE="/tmp/key_counter_debug.log"
export WORKSPACE_STATE_FILE="/tmp/waybar_status.txt"
export BACKSLASH_COUNT_FILE="/tmp/waybar_backslash_count.txt"
export DECREMENTER_PID_FILE="/tmp/waybar_decrementing.pid"

# Set to "true" to reset the counter to 0 every time the script starts.
RESET_COUNTER_ON_START="true"

# --- IMPORTANT: Set these to unique words from your keyboards' names ---
KEYBOARD_1_HINT="GMMK Pro Keyboard"
KEYBOARD_2_HINT="Translated" # For "AT Translated Set 2 keyboard"

# --- Clear previous log and start fresh ---
echo "--- Key Counter Daemon Started: $(date) ---" > "$LOG_FILE"

# --- Function to find a device path from its name hint ---
find_device_path() {
    local hint="$1"
    local device_block=$(awk -v RS='\n\n' -v HINT="$hint" '
        $0 ~ "N: Name=.*" HINT ".*" { print $0; exit }
    ' /proc/bus/input/devices)

    if [ -n "$device_block" ]; then
        local event_handler=$(echo "$device_block" | grep "H: Handlers=" | grep -o 'event[0-9]*')
        if [ -n "$event_handler" ]; then
            echo "/dev/input/$event_handler"
        fi
    fi
}

# --- Find keyboard devices automatically ---
KEYBOARD_1_DEVICE=$(find_device_path "$KEYBOARD_1_HINT")
KEYBOARD_2_DEVICE=$(find_device_path "$KEYBOARD_2_HINT")

# --- Initialize or reset state files ---
if [ "$RESET_COUNTER_ON_START" = "true" ] || [ ! -f "$COUNTER_FILE" ]; then
    echo 0 > "$COUNTER_FILE"
    echo 0 > "$BACKSLASH_COUNT_FILE"
    # Ensure old PID file is gone on restart
    rm -f "$DECREMENTER_PID_FILE"
fi

# --- Decrementer Loop ---
# This runs in the background when triggered.
decrementer_loop() {
    while true; do
        sleep 1
        # Use flock on the counter file to prevent race conditions.
        flock "$COUNTER_FILE" -c "
            current_count=\$(cat '$COUNTER_FILE');
            if [ \$current_count -gt 0 ]; then
                next_count=\$((current_count - 1));
                echo \$next_count > '$COUNTER_FILE';
                echo 'DECREMENT: Counter is now \$next_count' >> '$LOG_FILE';
            else
                echo 'INFO: Decrementer finished. Resetting state.' >> '$LOG_FILE';
                echo 'flashing' > '$WORKSPACE_STATE_FILE';
                rm -f '$DECREMENTER_PID_FILE';
                break;
            fi
        "
    done
}

# Export the function so it's available to subshells.
export -f decrementer_loop

# --- Main Logic to process a key press ---
process_key_event() {
    local key_code="$1"

    # A simple check to ensure key_code is not empty.
    if [ -z "$key_code" ]; then
        return
    fi

    # Pass key_code as an argument to the subshell invoked by flock.
    flock "$COUNTER_FILE" sh -c '
        # In this subshell, $1 is the key_code passed from the parent.
        key_code="$1"

        # If the decrementer is running, ignore all key presses.
        if [ -f "$DECREMENTER_PID_FILE" ]; then
            exit
        fi

        current_count=$(cat "$COUNTER_FILE")
        backslash_count=$(cat "$BACKSLASH_COUNT_FILE")

        # Keycode for '\'' is 43
        if [ "$key_code" -eq 43 ] && [ "$current_count" -ge 50 ]; then
            # --- Handle the special trigger key ---
            backslash_count=$((backslash_count + 1))
            echo "$backslash_count" > "$BACKSLASH_COUNT_FILE"
            echo "INFO: Backslash pressed. Count is now $backslash_count." >> "$LOG_FILE"

            if [ "$backslash_count" -ge 3 ]; then
                echo "ACTION: Special mode triggered!" >> "$LOG_FILE"
                echo "super-charge-flash" > "$WORKSPACE_STATE_FILE"
                echo 0 > "$BACKSLASH_COUNT_FILE"
                # Start the decrementer in the background and store its PID
                decrementer_loop &
                echo $! > "$DECREMENTER_PID_FILE"
            fi
        else
            # --- Handle a normal key press ---
            echo 0 > "$BACKSLASH_COUNT_FILE" # Reset on any other key
            next_count=$((current_count + 1))
            echo "$next_count" > "$COUNTER_FILE"
            echo "INCREMENT: Counter is now $next_count" >> "$LOG_FILE"
        fi
    ' sh-flock "$key_code"
}

# --- Function to start a listener for a device ---
start_listener() {
    local device_path="$1"
    local device_name="$2"

    if [ -z "$device_path" ]; then
        echo "WARNING: Could not find a keyboard device matching '$device_name'. Skipping." >> "$LOG_FILE"
        return
    fi

    echo "INFO: Starting listener for $device_name at $device_path" >> "$LOG_FILE"
    # Run evtest and parse its output to get the key code.
    evtest "$device_path" | while read -r line; do
        if echo "$line" | grep -q 'type 1 (EV_KEY),' && echo "$line" | grep -q ', value 1'; then
            # This robust command extracts the key code number.
            key_code=$(echo "$line" | grep -o 'code [0-9]*' | awk '{print $2}')
            process_key_event "$key_code"
        fi
    done
}

# --- Start listeners for both keyboards in the background ---
start_listener "$KEYBOARD_1_DEVICE" "$KEYBOARD_1_HINT" &
start_listener "$KEYBOARD_2_DEVICE" "$KEYBOARD_2_HINT" &

# --- Wait forever ---
# This keeps the main script alive, which in turn keeps the background listeners running.
wait

