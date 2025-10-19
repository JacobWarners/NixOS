#!/bin/sh
#
# This is a helper script that MUST be run as root.
# It contains only the privileged kernel-level commands for undocking.

set -e

# --- PCI Addresses (Copied from main script for clarity) ---
GPU_ADDR="0000:64:00.0"
GPU_AUDIO_ADDR="0000:64:00.1"
PARENT_BRIDGE_ADDR="0000:60:00.0"

# --- Privileged Operations ---
echo "Unbinding drivers (as root)..." >&2
echo "$GPU_ADDR" > /sys/bus/pci/drivers/amdgpu/unbind
echo "$GPU_AUDIO_ADDR" > /sys/bus/pci/drivers/snd_hda_intel/unbind

sleep 1

echo "Removing PCI device (as root)..." >&2
echo 1 > /sys/bus/pci/devices/$PARENT_BRIDGE_ADDR/remove
