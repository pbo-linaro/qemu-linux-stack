#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_uboot.sh
    exit 0
fi

clone()
{
    rm -f u-boot
    url=https://github.com/u-boot/u-boot
    version=v2025.04
    src=u-boot-$version
    if [ ! -d $src ]; then
        git clone $url --single-branch --branch $version --depth 1 $src
    fi
    ln -s $src u-boot
}

build()
{
    pushd u-boot
    rm -f .config
    make CROSS_COMPILE=aarch64-linux-gnu- qemu_arm64_defconfig
    scripts/config --set-val BOOTDELAY 1
    scripts/config --enable CC_OPTIMIZE_FOR_DEBUG
    make CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
    # duplicate elf to load it twice with gdb
    cp u-boot u-boot.relocated
    popd
}

clone
build
