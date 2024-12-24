#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "usage: qemu_bin_dir"
    exit 1
fi

qemu_bin_dir=$1; shift

gdb --args $qemu_bin_dir/qemu-system-aarch64 \
    -nographic \
    -M virt,iommu=smmuv3 \
    -cpu max \
    -m 2G \
    -kernel ./out/Image \
    -initrd ./out/initrd.cpio \

# aarch virt already uses virtio-net-pci by default
#    -netdev user,id=vnet \
#    -device virtio-net-pci,netdev=vnet \
