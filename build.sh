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
            --single-branch --branch v6.13-rc4 --depth 1 \
            linux
    fi
}

clone_busybox()
{
    if [ ! -d busybox ]; then
        git clone \
            https://git.busybox.net/busybox/ \
            --single-branch --branch 1_36_0 \
            busybox
    fi
}

build_linux()
{
    pushd linux
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig -j$(nproc)
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- all -j$(nproc)
    popd
}

build_busybox()
{
    pushd busybox
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig -j$(nproc)
    echo "CONFIG_STATIC=y" >> .config
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- install -j$(nproc) \
        CONFIG_PREFIX=$(pwd)/out/
    popd
}

build_initrd()
{
    rm -rf initrd
    mkdir initrd
    rsync -a busybox/out/ initrd/
    pushd initrd
    ln -s bin/busybox init
    mkdir -p etc/init.d
    cat > etc/init.d/rcS << EOF
#!/bin/sh

export PATH=/bin:/sbin

mkdir /proc
mount -t proc none /proc
sh
poweroff
EOF
    chmod +x etc/init.d/rcS
    find . | cpio -o -H newc > ../initrd.cpio
    popd
}

output()
{
    mkdir -p out
    mv ./initrd.cpio out/
    rsync ./linux/arch/arm64/boot/Image out/
}

clone_linux
clone_busybox
build_linux
build_busybox
build_initrd
output
