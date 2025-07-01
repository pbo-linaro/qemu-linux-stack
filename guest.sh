#!/usr/bin/env bash

set -euo pipefail
set -x

INIT=${INIT:-}

cd /host
# lkvm is not able to boot a compressed kernel
./out/lkvm run \
    --realm -m 256m \
    --restricted_mem \
    --kernel ./out/Image \
    --disk ./out/guest.ext4 \
    --params "root=/dev/vda rw init=/init -- $INIT"
