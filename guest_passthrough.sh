#!/usr/bin/env bash

set -euo pipefail
set -x

cd /host

image_vfio=$1; shift
image_iommufd=$1; shift

disk_vfio=$(lspci | grep -i 'NVM Express Controller' | head -n 1 | cut -f 1 -d ' ' || true)
disk_iommufd=$(lspci | grep -i 'NVM Express Controller' | tail -n 1 | cut -f 1 -d ' ' || true)
if [ "$disk_vfio" == "" ] || [ "$disk_iommufd" == "" ]; then
    lspci
    echo "Can't find nvme disks"
    exit 1
fi
if [ "$disk_vfio" == "$disk_iommufd" ]; then
    lspci
    echo "Only one nvme disk was found"
    exit 1
fi
disk_vfio=0000:$disk_vfio
disk_iommufd=0000:$disk_iommufd

for d in "$disk_vfio" "$disk_iommufd"; do
    if [ "$(cat /sys/bus/pci/devices/$d/driver_override)" == vfio-pci ]; then
        continue
    fi
    echo $d > /sys/bus/pci/drivers/nvme/unbind || bash
    echo vfio-pci > /sys/bus/pci/devices/$d/driver_override
    echo $d > /sys/bus/pci/drivers/vfio-pci/bind
done

INIT_CMD="bash -c \"diff /dev/nvme0n1 $image_vfio && diff /dev/nvme1n1 $image_iommufd\"" \
./guest.sh qemu-system-aarch64 \
-device vfio-pci,host=$disk_vfio \
-object iommufd,id=iommufd0 \
-device vfio-pci,host=$disk_iommufd,iommufd=iommufd0
