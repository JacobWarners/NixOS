#!/bin/sh
# Toggle eGPU display state without touching the kernel PCI devices.
# Undock: dpms off eGPU outputs so cable can be safely yanked.
# Redock: dpms on + reload to restore monitors.
set -e

GPU_ADDR="0000:64:00.0"
EGPU_OUTPUT_CACHE="/tmp/egpu-outputs"

if [ -d "/sys/bus/pci/devices/$GPU_ADDR" ]; then
    # --- UNDOCK ---
    notify-send "eGPU Undock" "Disabling external outputs..." -u normal

    # Find all monitors except the laptop panel (BOE = internal eDP)
    EGPU_OUTPUTS=$(hyprctl -j monitors 2>/dev/null | python3 -c \
        "import json,sys; [print(m['name']) for m in json.load(sys.stdin) if 'BOE' not in m.get('description','')]")

    if [ -z "$EGPU_OUTPUTS" ]; then
        notify-send "eGPU Undock" "No external outputs found." -u normal
        exit 0
    fi

    # Save names so redock can restore them
    echo "$EGPU_OUTPUTS" > "$EGPU_OUTPUT_CACHE"

    for out in $EGPU_OUTPUTS; do
        hyprctl dispatch dpms off "$out" >/dev/null 2>&1 || true
    done

    notify-send "eGPU Undock" "Safe to unplug. Press Super+U again after re-plugging to restore monitors." -u critical -t 15000

else
    # --- REDOCK ---
    # Try to restore saved outputs first, then reload config
    if [ -f "$EGPU_OUTPUT_CACHE" ]; then
        for out in $(cat "$EGPU_OUTPUT_CACHE"); do
            hyprctl dispatch dpms on "$out" >/dev/null 2>&1 || true
        done
        rm -f "$EGPU_OUTPUT_CACHE"
    fi

    hyprctl reload >/dev/null 2>&1 || true
    notify-send "eGPU Redock" "Config reloaded. External displays should be active." -u normal -t 8000
fi
