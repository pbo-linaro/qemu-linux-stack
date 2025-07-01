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
    split-window -p 80 "./container.sh cgdb -d gdb-multiarch -x gdbinit"
}

tmux_session ./run.sh $qemu_aarch64_cmd -S -s
