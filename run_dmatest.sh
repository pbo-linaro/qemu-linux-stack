#!/usr/bin/env bash

set -euo pipefail

QEMU_ARGS="-device virtio-dma-test-pci,iommu_platform=on" ./run.sh "$@"
