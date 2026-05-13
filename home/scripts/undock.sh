#!/bin/sh
# Toggle eGPU dock state. Detects whether the Navi 23 is on the bus and
# branches to undock (kernel detach) or redock (PCI rescan).
set -e

GPU_ADDR="0000:64:00.0"
UNDOCK_HELPER="$HOME/.config/scripts/undock-helper.sh"
REDOCK_HELPER="$HOME/.config/scripts/redock-helper.sh"
EGPU_OUTPUTS="DP-9 DP-10 DP-11 HDMI-A-1"

if [ -d "/sys/bus/pci/devices/$GPU_ADDR" ]; then
    # --- UNDOCK ---
    notify-send "eGPU Undock" "Preparing to undock..." -u normal

    for out in $EGPU_OUTPUTS; do
        hyprctl keyword monitor "$out,disable" >/dev/null || true
    done
    sleep 1

    if sudo "$UNDOCK_HELPER"; then
        notify-send "eGPU Undock" "SUCCESS: Safe to unplug Thunderbolt." -u critical -t 10000
    else
        notify-send "eGPU Undock" "ERROR: Privileged undock failed. Check sudo config." -u critical
        exit 1
    fi
else
    # --- REDOCK ---
    notify-send "eGPU Redock" "Rescanning PCI bus..." -u normal

    if sudo "$REDOCK_HELPER"; then
        sleep 2
        # Drop runtime monitor disables; let main config + EDIDs take over.
        hyprctl reload >/dev/null || true
        notify-send "eGPU Redock" "SUCCESS: External displays restored." -u normal -t 8000
    else
        notify-send "eGPU Redock" "ERROR: PCI rescan failed; check cable + dock." -u critical
        exit 1
    fi
fi
