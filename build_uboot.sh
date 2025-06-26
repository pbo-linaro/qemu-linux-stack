#!/usr/bin/env bash

set -euo pipefail

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    echo "run command using ./container.sh ./build_uboot.sh"
    exit 1
fi

clone_uboot()
{
    if [ ! -d uboot ]; then
        git clone \
            https://github.com/u-boot/u-boot \
            --single-branch --branch v2025.04 --depth 1 \
            uboot
    fi
}

build_uboot()
{
    pushd uboot
    rm -f .config
    make CROSS_COMPILE=aarch64-linux-gnu- qemu_arm64_defconfig
    scripts/config --set-val BOOT_DELAY 0
    make CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
    popd
}

output()
{
    mkdir -p out
    rsync ./uboot/u-boot.bin out/u-boot.bin
}

clone_uboot
build_uboot
output
