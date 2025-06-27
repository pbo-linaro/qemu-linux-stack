#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

vfio=disk_vfio
iommufd=disk_iommufd
dd if=/dev/random of=$vfio bs=512 count=1 status=none
dd if=/dev/random of=$iommufd bs=1024 count=1 status=none

INIT=${INIT:-"/host/guest_passthrough.sh /host/$vfio /host/$iommufd"} \
./run.sh "$@" \
-M virt,gic-version=max,virtualization=on,iommu=smmuv3 \
-drive file=$vfio,if=none,id=vfio,format=raw \
-device nvme,serial=vfio,drive=vfio \
-drive file=$iommufd,if=none,id=iommufd,format=raw \
-device nvme,serial=iommufd,drive=iommufd

rm $vfio $iommufd
