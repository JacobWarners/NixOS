#!/bin/sh
# Privileged half of eGPU undock. Must run as root via sudo.
set -e

EXTERNAL_DISPLAYS="card0-DP-9 card0-DP-10 card0-DP-11 card0-HDMI-A-1"

GPU_ADDR="0000:64:00.0"
GPU_AUDIO_ADDR="0000:64:00.1"
PARENT_BRIDGE_ADDR="0000:60:00.0"

echo "Powering off external displays at kernel level..." >&2
for display in $EXTERNAL_DISPLAYS; do
    if [ -d "/sys/class/drm/$display" ]; then
        echo "off" > "/sys/class/drm/$display/status" || true
    fi
done

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
