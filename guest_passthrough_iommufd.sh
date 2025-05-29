#!/usr/bin/env bash

set -euo pipefail
set -x

cd /host

# https://www.qemu.org/docs/master/devel/vfio-iommufd.html
# https://docs.kernel.org/driver-api/vfio.html#vfio-device-cdev

disk=0000:$(lspci | grep -i storage | cut -f 1 -d ' ' | head -n 1)
if [ "$(cat /sys/bus/pci/devices/$disk/driver_override)" != vfio-pci ]; then
    echo $disk > /sys/bus/pci/drivers/virtio-pci/unbind
    echo vfio-pci > /sys/bus/pci/devices/$disk/driver_override
    echo $disk > /sys/bus/pci/drivers/vfio-pci/bind
fi

ROOT=/dev/vdb \
./guest.sh \
-object iommufd,id=iommufd0 \
-device vfio-pci,host=$disk,iommufd=iommufd0 \
"$@"
