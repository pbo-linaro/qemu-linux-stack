#!/usr/bin/env bash

set -euo pipefail
set -x

cd /host

disk=0000:$(lspci | grep -i storage | cut -f 1 -d ' ')
if [ "$(cat /sys/bus/pci/devices/$disk/driver_override)" != vfio-pci ]; then
    echo $disk > /sys/bus/pci/drivers/virtio-pci/unbind
    echo vfio-pci > /sys/bus/pci/devices/$disk/driver_override
    echo $disk > /sys/bus/pci/drivers/vfio-pci/bind
fi

./qemu-system-aarch64-iommufd -m 1G \
    -M virt,gic-version=3,iommu=nested-smmuv3,iommufd=iommufd0 \
    -object iommufd,id=iommufd0 \
    -net none -display none -serial stdio \
    -enable-kvm \
    -cpu max -kernel ./out/Image -initrd ./out/initrd.cpio \
    -device vfio-pci,host=$disk,iommufd=iommufd0 \
    "$@"
