#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_aarch64_cmd"
    exit 1
fi

qemu_aarch64_cmd=$*

tmux_session()
{
    qemu_cmd="$*"
    unset TMUX
    tmux -L PATH \
    new-session -s qemu-linux bash -cx "set -x; $qemu_cmd || read" \; \
    split-window -h "./container.sh cgdb -d gdb-multiarch -ex 'set remotetimeout 99999' -ex 'set pagination off' -ex 'target remote :1234' -ex 'b start_kernel' -ex c ./linux/vmlinux"
}

tmux_session ./run.sh $qemu_aarch64_cmd -S -s
