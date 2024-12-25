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

build_initrd()
{
    rm -rf initrd
    mkdir initrd
    pushd initrd
    wget https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-minirootfs-3.21.0-aarch64.tar.gz
    tar xzf alpine-*
    rm alpine-*
    cat > init << EOF
#!/bin/sh

export PATH=/usr/bin:/bin:/sbin

mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys
ifconfig eth0 up
ifconfig eth0 10.0.2.15 netmask 255.255.255.0 broadcast 10.0.2.255
route add default gw 10.0.2.2
# we need to change tty used, to have job control
# ttyAMA0 is the first serial console on arm systems
busybox getty 0 ttyAMA0 -l /bin/bash -n
# force shutdown
echo o > /proc/sysrq-trigger
sleep 10
EOF
    chmod +x init
    cat > etc/resolv.conf << EOF
nameserver 8.8.8.8
EOF
    proot -q qemu-aarch64 -r $(pwd) sh -c 'apk update && apk add bash'
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
build_linux
build_initrd
output
