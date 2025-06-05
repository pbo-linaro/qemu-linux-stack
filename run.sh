#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

INIT_CMD="${INIT_CMD:-}"

"$@" \
-nographic \
-netdev user,id=vnet \
-device virtio-net-pci,netdev=vnet \
-M virt,virtualization=on \
-cpu max \
-m 8G \
-kernel ./out/Image \
-drive format=raw,file=./out/host.ext4,if=virtio \
-append "nokaslr root=/dev/vda rw init=/init -- $INIT_CMD" \
-virtfs local,path=$(pwd)/,mount_tag=host,security_model=mapped,readonly=off
