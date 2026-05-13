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

for i in $(seq 1 20); do
    if [ -d "/sys/bus/pci/devices/$GPU_ADDR" ]; then
        echo "eGPU detected after ${i}s." >&2
        exit 0
    fi
    sleep 1
done

echo "eGPU did not appear after rescan." >&2
exit 1
