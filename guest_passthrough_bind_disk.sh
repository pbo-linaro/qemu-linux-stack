#!/usr/bin/env bash

set -euo pipefail
set -x

cd /host

disk=$(lspci | grep -i 'NVM Express Controller' | cut -f 1 -d ' ' || true)
if [ "$disk" == "" ]; then
    lspci
    echo "Can't find nvme disk"
    exit 1
fi
disk=0000:$disk
if [ "$(cat /sys/bus/pci/devices/$disk/driver_override)" != vfio-pci ]; then
    echo $disk > /sys/bus/pci/drivers/nvme/unbind
    echo vfio-pci > /sys/bus/pci/devices/$disk/driver_override
    echo $disk > /sys/bus/pci/drivers/vfio-pci/bind
fi
