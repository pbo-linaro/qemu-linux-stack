#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

cp -f ./guest_nested_smmu.sh init
qemu-img create -f qcow2 disk 1g

./run.sh "$@" \
-machine type=virt,gic-version=max,virtualization=true,iommu=smmuv3 \
-drive if=none,id=disk,file=disk \
-device virtio-blk,drive=disk,iommu_platform=on,disable-legacy=on

rm init disk
