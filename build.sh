#!/usr/bin/env bash

set -euo pipefail

./container.sh ./build_kernel.sh
./build_initrd.sh
./build_rootfs.sh
