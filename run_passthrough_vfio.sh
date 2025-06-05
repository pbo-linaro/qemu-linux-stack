#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

dd if=/dev/random of=disk bs=512 count=1 status=none

INIT_CMD=${INIT_CMD:-"/host/guest_passthrough_vfio.sh"} \
./run.sh "$@" \
-machine type=virt,gic-version=max,virtualization=true,iommu=smmuv3 \
-drive file=disk,if=none,id=nvm,format=raw \
-device nvme,serial=deadbeef,drive=nvm

rm disk
