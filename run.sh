#!/usr/bin/env bash

set -euo pipefail

qemu-system-aarch64 \
    -nographic \
    -M virt,iommu=smmuv3 \
    -cpu max \
    -kernel ./out/Image \
    -initrd ./out/initrd.cpio
