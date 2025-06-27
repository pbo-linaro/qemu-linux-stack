#!/usr/bin/env bash

set -euo pipefail

./build_kernel.sh
./build_uboot.sh
./build_arm_trusted_firmware.sh
./build_rootfs.sh

du -hc out/*
