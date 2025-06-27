#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "usage: out_tar_gz"
    exit 1
fi

out=$1; shift

du -hc out/*
# create a sparse archive with:
# - kernel
# - guest rootfs
# - host rootfs
tar czvfS $out out/
du -h $out
