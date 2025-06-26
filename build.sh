#!/usr/bin/env bash

set -euo pipefail

./container.sh ./build_kernel.sh
./container.sh ./build_uboot.sh
./container.sh ./build_arm_trusted_firmware.sh
./build_rootfs.sh

du -hc out/*
