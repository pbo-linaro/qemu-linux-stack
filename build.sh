#!/usr/bin/env bash

set -euo pipefail

rm -rf out

if ! podman run -it --rm docker.io/debian:trixie true; then
    echo "error: podman must be installed on your machine"
    exit 1
fi

if ! podman run -it --rm --platform linux/arm64 docker.io/arm64v8/debian:trixie true; then
    echo "error: qemu-user-static must be installed on your machine"
    exit 1
fi

./container.sh ccache -M 50GB

./build_kernel.sh
echo '-------------------------------------------------------------------------'
./build_edk2.sh
echo '-------------------------------------------------------------------------'
./build_tf_rmm.sh
echo '-------------------------------------------------------------------------'
./build_arm_trusted_firmware.sh
echo '-------------------------------------------------------------------------'
./build_kvmtool.sh
echo '-------------------------------------------------------------------------'
./build_rootfs.sh
echo '-------------------------------------------------------------------------'

du -hc out/*
