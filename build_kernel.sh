#!/usr/bin/env bash

set -euo pipefail

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    echo "run command using ./container.sh ./build.sh"
    exit 1
fi

clone_linux()
{
    if [ ! -d linux ]; then
        git clone \
            https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/ \
            --single-branch --branch v6.14 --depth 1 \
            linux
    fi
}

build_linux()
{
    pushd linux
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig -j$(nproc)
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- all -j$(nproc)
    popd
}

output()
{
    mkdir -p out
    rsync ./linux/arch/arm64/boot/Image out/
    rsync ./linux/vmlinux out/
}

clone_linux
build_linux
output
