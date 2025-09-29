#!/usr/bin/env bash

set -euo pipefail

rm -rf out

if ! podman run -it --rm docker.io/debian:trixie echo; then
    echo "error: podman must be installed on your machine"
    exit 1
fi

if ! podman run -it --rm docker.io/arm64v8/debian:trixie echo; then
    echo "error: qemu-user-static must be installed on your machine"
    exit 1
fi

./container.sh ccache -M 50GB

./build_kernel.sh
echo '-------------------------------------------------------------------------'
./build_uboot.sh
echo '-------------------------------------------------------------------------'
./build_arm_trusted_firmware.sh
echo '-------------------------------------------------------------------------'
./build_rootfs.sh
echo '-------------------------------------------------------------------------'

du -hc out/*
