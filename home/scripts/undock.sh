#!/bin/sh
# Toggle eGPU display state without touching the kernel PCI devices.
# Undock: disables eGPU outputs in Hyprland so the cable can be safely yanked.
# Redock: reloads config so desc: monitor rules re-apply (auto-detect usually handles this already).
set -e

GPU_ADDR="0000:64:00.0"

if [ -d "/sys/bus/pci/devices/$GPU_ADDR" ]; then
    # --- UNDOCK: tell Hyprland to drop eGPU outputs, then user physically unplugs ---
    notify-send "eGPU Undock" "Disabling external outputs..." -u normal

    # Dynamically find all monitors except the laptop panel (BOE = internal eDP)
    EGPU_OUTPUTS=$(hyprctl -j monitors 2>/dev/null | python3 -c \
        "import json,sys; [print(m['name']) for m in json.load(sys.stdin) if 'BOE' not in m.get('description','')]")

    if [ -z "$EGPU_OUTPUTS" ]; then
        notify-send "eGPU Undock" "No external outputs found." -u normal
        exit 0
    fi

    for out in $EGPU_OUTPUTS; do
        hyprctl keyword monitor "$out,disable" >/dev/null 2>&1 || true
    done

    notify-send "eGPU Undock" "Safe to unplug. Press Super+U again after re-plugging to restore monitors." -u critical -t 15000

else
    # --- REDOCK: GPU already re-enumerated (Hyprland auto-detects on hotplug).
    # Reload config to ensure desc: monitor rules are applied. ---
    hyprctl reload >/dev/null 2>&1 || true
    notify-send "eGPU Redock" "Config reloaded. External displays should be active." -u normal -t 8000
fi
