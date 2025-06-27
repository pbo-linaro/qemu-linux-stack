#!/usr/bin/env bash

set -euo pipefail

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    echo "run command using ./container.sh ./build_uboot.sh"
    exit 1
fi

clone_uboot()
{
    if [ ! -d u-boot ]; then
        git clone \
            https://github.com/u-boot/u-boot \
            --single-branch --branch v2025.04 --depth 1 \
            u-boot
    fi
}

build_uboot()
{
    pushd u-boot
    rm -f .config
    make CROSS_COMPILE=aarch64-linux-gnu- qemu_arm64_defconfig
    scripts/config --set-val BOOTDELAY 0
    make CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
    popd
}

clone_uboot
build_uboot
