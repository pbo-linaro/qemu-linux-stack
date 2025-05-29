#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

qemu-img create -f qcow2 disk 1g

INIT_CMD="/host/guest_passthrough_device.sh" \
ROOT="/dev/vdb" \
./run.sh "$@" \
-machine type=virt,gic-version=max,virtualization=true,iommu=smmuv3 \
-drive if=none,format=raw,id=passthrough,file=disk \
-device virtio-blk,drive=passthrough,iommu_platform=on,disable-legacy=on

rm disk
