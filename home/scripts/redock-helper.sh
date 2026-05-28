#!/bin/sh
# Privileged half of eGPU redock. Must run as root via sudo.
set -e

GPU_ADDR="0000:64:00.0"

if [ -d "/sys/bus/pci/devices/$GPU_ADDR" ]; then
    echo "eGPU already enumerated." >&2
    exit 0
fi

echo "Triggering PCI rescan..." >&2
echo 1 > /sys/bus/pci/rescan

echo "Waiting for GPU on bus..." >&2
found=0
for i in $(seq 1 20); do
    if [ -d "/sys/bus/pci/devices/$GPU_ADDR" ]; then
        echo "GPU on bus after ${i}s." >&2
        found=1
        break
    fi
    sleep 1
done
[ "$found" = "1" ] || { echo "GPU did not appear after rescan." >&2; exit 1; }

echo "Waiting for amdgpu driver to bind..." >&2
for i in $(seq 1 15); do
    if [ -e "/sys/bus/pci/devices/$GPU_ADDR/driver" ]; then
        echo "Driver bound after ${i}s." >&2
        break
    fi
    sleep 1
done

echo "Waiting for DRM card to initialize..." >&2
for i in $(seq 1 10); do
    if ls /sys/bus/pci/devices/$GPU_ADDR/drm/ 2>/dev/null | grep -q '^card'; then
        echo "DRM card ready after ${i}s." >&2
        exit 0
    fi
    sleep 1
done

echo "DRM card did not initialize in time." >&2
exit 1
