#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "usage: qemu_cmd"
    exit 1
fi

qemu_bin=$(readlink -f $1)
qemu_src_dir=$(dirname $qemu_bin)/../

uftrace_plugin=$qemu_src_dir/build/contrib/plugins/libuftrace.so
uftrace_symbols=$qemu_src_dir/contrib/plugins/uftrace_symbols.py

if [ -z "$(which tee)" ]; then
    echo "trace.sh: coreutils (tee) needs to be installed on your machine"
    exit 1
fi

if [ -z "$(which ts)" ]; then
    echo "trace.sh: moreutils (ts) needs to be installed on your machine"
    exit 1
fi

if [ ! -f $uftrace_plugin ]; then
    echo "trace.sh: can't find QEMU uftrace plugin ($uftrace_plugin)"
    exit 1
fi

if [ ! -f $uftrace_symbols ]; then
    echo "trace.sh: can't find QEMU uftrace symbols script ($uftrace_symbols)"
    exit 1
fi

set -x

rm -rf ./uftrace.data
binaries=$(cat gdbinit | grep '^add-symbol-file' |
           sed -e 's/add-symbol-file\s*//' -e 's/\s\+/:/')
./container.sh $uftrace_symbols --prefix-symbols $binaries

qemu_cmd=$*
./run.sh $qemu_cmd -plugin $uftrace_plugin,trace-privilege-level=on |&
    ts "%.s" | tee ./uftrace.data/exec.log
echo >> ./uftrace.data/exec.log

set +x

echo "----------------------------------------"
echo "execution log is available in ./uftrace.data/exec.log"
