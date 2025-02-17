#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

qemu_aarch64_cmd=$*; shift

tmux_session()
{
    qemu_cmd="$*"
    unset TMUX
    tmux -L PATH \
    new-session -s smmu bash -cx "set -x; $qemu_cmd || read" \; \
    split-window -h "./container.sh cgdb -d gdb-multiarch -ex 'set remotetimeout 99999' -ex 'set pagination off' -ex 'target remote :1234' -ex 'b start_kernel' -ex 'c' -ex 'c' ./out/vmlinux"
}

# nokaslr is needed to be able to debug
# add network device
tmux_session $qemu_aarch64_cmd \
-nographic \
-nodefaults \
-serial stdio \
-netdev user,id=vnet \
-device virtio-net-pci,netdev=vnet \
-M virt,iommu=smmuv3 \
-cpu max \
-m 2G \
-kernel ./out/Image \
-initrd ./out/initrd.cpio \
-append 'nokaslr' \
-virtfs local,path=$(pwd)/,mount_tag=host,security_model=mapped,readonly=on \
-S -s
