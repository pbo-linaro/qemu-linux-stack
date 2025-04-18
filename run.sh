#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

qemu_aarch64_cmd=$*

$qemu_aarch64_cmd \
-nographic \
-netdev user,id=vnet \
-device virtio-net-pci,netdev=vnet \
-M virt \
-cpu max \
-m 8G \
-kernel ./out/Image \
-initrd ./out/initrd.cpio \
-append 'nokaslr' \
-virtfs local,path=$(pwd)/,mount_tag=host,security_model=mapped,readonly=on
