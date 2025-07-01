#!/usr/bin/env bash

set -euo pipefail

rm -rf out

./build_kernel.sh
./build_uboot.sh
./build_rmm.sh
./build_edk2.sh
./build_arm_trusted_firmware.sh
./build_rootfs.sh

du -hc out/*
