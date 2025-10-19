#!/bin/sh
# This helper script MUST be run as root. It performs all privileged undock operations.
set -e

# --- Find your DRM connector names ---
# Run this command to see your connectors: ls /sys/class/drm/ | grep 'card.-'
# Your eGPU is likely card1. Your connectors will be card1-DP-1, card1-HDMI-A-1, etc.
# Replace the names below with the correct ones for your system.
# It's safe to list ones that aren't connected; the script will just skip them.
EXTERNAL_DISPLAYS="card1-DP-11 card1-HDMI-A-1"

# --- PCI Addresses ---
GPU_ADDR="0000:64:00.0"
GPU_AUDIO_ADDR="0000:64:00.1"
PARENT_BRIDGE_ADDR="0000:60:00.0"

# --- Operations ---

echo "Powering off external displays at kernel level..." >&2
for display in $EXTERNAL_DISPLAYS; do
    # Check if the DRM connector path exists before trying to write to it
    if [ -d "/sys/class/drm/$display" ]; then
        echo "off" > "/sys/class/drm/$display/status"
    fi
done

sleep 1 # Give the kernel a moment to process the display-off command.

echo "Unbinding drivers (as root)..." >&2
echo "$GPU_ADDR" > /sys/bus/pci/drivers/amdgpu/unbind
echo "$GPU_AUDIO_ADDR" > /sys/bus/pci/drivers/snd_hda_intel/unbind

sleep 1

echo "Removing PCI device (as root)..." >&2
echo 1 > /sys/bus/pci/devices/$PARENT_BRIDGE_ADDR/remove
