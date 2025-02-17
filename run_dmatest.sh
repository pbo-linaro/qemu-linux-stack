#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

./run.sh "$@" -device virtio-dma-test-pci,iommu_platform=on
