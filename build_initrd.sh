#!/usr/bin/env bash

set -euo pipefail

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    echo "run command using ./container.sh ./build.sh"
    exit 1
fi

build_initrd()
{
    rm -rf initrd
    mkdir initrd
    pushd initrd
    base=docker.io/arm64v8/debian:trixie
    podman pull --platform linux/arm64/v8 $base
    podman export -o /dev/stdout $(podman create $base) | tar xf -
    cat > init << EOF
#!/bin/sh

export PATH=/usr/bin:/bin:/sbin

mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys
mkdir /host
mount -t 9p -o trans=virtio host /host
ifconfig eth0 up
ifconfig eth0 10.0.2.15 netmask 255.255.255.0 broadcast 10.0.2.255
route add default gw 10.0.2.2
# we need to change tty used, to have job control
# ttyAMA0 is the first serial console on arm systems
if [ -f /host/init ]; then
    /host/init
else
    setsid -c -w /usr/bin/bash -l
fi
# force shutdown
echo o > /proc/sysrq-trigger
sleep 10
EOF
    chmod +x init
    cat > etc/resolv.conf << EOF
nameserver 1.1.1.1
EOF
    run="proot -q qemu-aarch64 -S $(pwd) -w /"
    $run apt update
    $run apt install -y bash bash-completion pciutils net-tools \
                        iputils-ping util-linux procps htop
    $run apt install -y libglib2.0-dev
    find . | cpio -o -H newc > ../initrd.cpio
    popd
}

output()
{
    mkdir -p out
    mv ./initrd.cpio out/
}

build_initrd
output
