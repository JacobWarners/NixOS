#!/bin/sh
#
# /home/scripts/undock.sh
# This script safely prepares the system for eGPU hot-unplugging.
# It MUST be run with root privileges (e.g., via pkexec or sudo).

set -e

# --- User-configurable PCI Addresses ---
# You can find these with `lspci`.
# This is your Radeon RX 6600.
GPU_ADDR="0000:64:00.0"
# This is the audio device on the GPU.
GPU_AUDIO_ADDR="0000:64:00.1"
# This is the parent Thunderbolt PCI bridge.
PARENT_BRIDGE_ADDR="0000:60:00.0"
# --- End of Configuration ---

# Send a notification that the process has started.
notify-send "eGPU Undock" "Preparing to undock... Moving windows and disabling displays." -u normal

# 1. Tell Hyprland to disable the external monitors.
#    This gracefully moves all windows back to the primary display.
hyprctl keyword monitor "DP-11,disable"
hyprctl keyword monitor "HDMI-A-1,disable"

# 2. Wait a moment for the display server to settle.
sleep 2

notify-send "eGPU Undock" "Unbinding GPU drivers..." -u normal

# 3. Unbind the drivers from the PCI devices. This tells the kernel to let go.
echo "$GPU_ADDR" > /sys/bus/pci/drivers/amdgpu/unbind
echo "$GPU_AUDIO_ADDR" > /sys/bus/pci/drivers/snd_hda_intel/unbind

sleep 1

notify-send "eGPU Undock" "Removing PCI device..." -u normal

# 4. Logically remove the entire PCI device tree from the parent bridge.
echo 1 > /sys/bus/pci/devices/$PARENT_BRIDGE_ADDR/remove

# 5. Send a final success notification.
notify-send "eGPU Undock" "SUCCESS: It is now safe to unplug the Thunderbolt cable." -u critical -t 10000
