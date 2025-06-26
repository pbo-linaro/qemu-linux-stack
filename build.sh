#!/usr/bin/env bash

set -euo pipefail

./container.sh ./build_kernel.sh
./container.sh ./build_uboot.sh
./build_rootfs.sh

du -hc out/*
