#!/usr/bin/env bash

set -euo pipefail
set -x

cd /host

ROOT=${ROOT:-/dev/vda}

qemu-system-aarch64 \
-netdev user,id=vnet \
-device virtio-net-pci,netdev=vnet \
-M virt \
-display none \
-serial stdio \
-cpu host \
-enable-kvm \
-m 2G \
-kernel ./out/Image \
-drive format=raw,file=./out/guest.ext4,if=virtio \
-append "nokaslr root=$ROOT rw init=/init" \
-virtfs local,path=$(pwd)/,mount_tag=host,security_model=mapped,readonly=off \
"$@"
