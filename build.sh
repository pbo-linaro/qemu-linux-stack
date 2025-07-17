#!/usr/bin/env bash

set -euo pipefail

rm -rf out

./container.sh ccache -M 50GB

./build_kernel.sh
echo '-------------------------------------------------------------------------'
./build_tf_rmm.sh
echo '-------------------------------------------------------------------------'
./build_arm_trusted_firmware.sh
echo '-------------------------------------------------------------------------'
# for sbsa platform, edk2 is responsible for packaging flash images, so it must
# be built *after* firmwares
./build_edk2.sh
echo '-------------------------------------------------------------------------'
./build_kvmtool.sh
echo '-------------------------------------------------------------------------'
./build_rootfs.sh
echo '-------------------------------------------------------------------------'

du -hc out/*
