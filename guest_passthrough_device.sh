#!/usr/bin/env bash

set -euo pipefail
set -x

cd /host

disk=0000:$(lspci | grep -i storage | cut -f 1 -d ' ' | head -n 1)
if [ "$(cat /sys/bus/pci/devices/$disk/driver_override)" != vfio-pci ]; then
    echo $disk > /sys/bus/pci/drivers/virtio-pci/unbind
    echo vfio-pci > /sys/bus/pci/devices/$disk/driver_override
    echo $disk > /sys/bus/pci/drivers/vfio-pci/bind
fi

qemu-system-aarch64 -m 1G -M virt -net none -display none -serial stdio \
    -drive format=raw,file=./out/guest.ext4 \
    -append 'nokaslr root=/dev/vdb rw init=/init' \
    -cpu max -kernel ./out/Image -enable-kvm \
    -device vfio-pci,host=$disk \
    -virtfs local,path=$(pwd)/,mount_tag=host,security_model=mapped,readonly=off \
    -netdev user,id=vnet \
    -device virtio-net-pci,netdev=vnet \
    "$@"
