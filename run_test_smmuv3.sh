#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

INIT_CMD=${INIT_CMD:-"insmod /host/out/arm-smmu-v3-test.ko"} \
./run.sh "$@" \
-machine type=virt,gic-version=max,secure=true,virtualization=true,iommu=smmuv3
