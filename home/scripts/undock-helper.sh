#!/bin/sh
# Privileged half of eGPU undock. Must run as root via sudo.
set -e

GPU_ADDR="0000:64:00.0"
GPU_AUDIO_ADDR="0000:64:00.1"
PARENT_BRIDGE_ADDR="0000:60:00.0"

echo "Powering off external displays at kernel level..." >&2
CARD=$(ls /sys/bus/pci/devices/$GPU_ADDR/drm/ 2>/dev/null | grep '^card' | head -1)
if [ -n "$CARD" ]; then
    for connector in /sys/class/drm/${CARD}-*/status; do
        [ -f "$connector" ] && echo "off" > "$connector" || true
    done
fi

sleep 1

echo "Unbinding drivers..." >&2
[ -e "/sys/bus/pci/devices/$GPU_ADDR/driver" ] && \
    echo "$GPU_ADDR" > /sys/bus/pci/drivers/amdgpu/unbind || true
[ -e "/sys/bus/pci/devices/$GPU_AUDIO_ADDR/driver" ] && \
    echo "$GPU_AUDIO_ADDR" > /sys/bus/pci/drivers/snd_hda_intel/unbind || true

sleep 1

echo "Removing PCI bridge $PARENT_BRIDGE_ADDR..." >&2
if [ -d "/sys/bus/pci/devices/$PARENT_BRIDGE_ADDR" ]; then
    echo 1 > /sys/bus/pci/devices/$PARENT_BRIDGE_ADDR/remove
else
    echo "Bridge already gone; nothing to do." >&2
fi
