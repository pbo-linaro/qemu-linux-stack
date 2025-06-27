#!/usr/bin/env bash

set -euo pipefail

mkdir -p out

build_rootfs()
{
    r=$1
    rm -f out/$r.ext4
    podman build -t build-linux-stack-$r \
        --build-context common=rootfs/common rootfs/$r
    container=$(podman create build-linux-stack-$r)
    # export a tar, and pass it to mke2fs directly
    podman export -o /dev/stdout $container |
        env CONTAINER_NO_TTY= \
        ./container.sh /sbin/mke2fs -t ext4 -d - out/$r.ext4 10g
    podman rm -f $container
}

build_rootfs host
build_rootfs guest
