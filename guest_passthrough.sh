#!/usr/bin/env bash

set -euo pipefail
set -x

cd /host

image_vfio=$1; shift
image_iommufd=$1; shift

# find disk from serial
dev_vfio=$(lsblk --nvme | grep vfio | cut -f 1 -d ' ')
dev_iommufd=$(lsblk --nvme | grep iommufd | cut -f 1 -d ' ')
pci_vfio=$(basename $(readlink -f /sys/block/$dev_vfio/../../../))
pci_iommufd=$(basename $(readlink -f /sys/block/$dev_iommufd/../../../))

for p in "$pci_vfio" "$pci_iommufd"; do
    if [ "$(cat /sys/bus/pci/devices/$p/driver_override)" == vfio-pci ]; then
        continue
    fi
    echo $p > /sys/bus/pci/drivers/nvme/unbind || bash
    echo vfio-pci > /sys/bus/pci/devices/$p/driver_override
    echo $p > /sys/bus/pci/drivers/vfio-pci/bind
done

INIT_CMD="bash -c \"diff /dev/nvme0n1 $image_vfio && diff /dev/nvme1n1 $image_iommufd\"" \
./guest.sh qemu-system-aarch64 \
-device vfio-pci,host=$pci_vfio \
-object iommufd,id=iommufd0 \
-device vfio-pci,host=$pci_iommufd,iommufd=iommufd0
