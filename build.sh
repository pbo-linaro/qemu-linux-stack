#!/usr/bin/env bash

set -euo pipefail

mkdir -p out

build_rootfs()
{
    r=$1
    rm -f out/$r.ext4
    podman build -t build-linux-stack-$r $r
    container=$(podman create build-linux-stack-$r)
    podman export -o /dev/stdout $container > out/$r.tar
    ./container.sh /sbin/mke2fs -t ext4 -d out/$r.tar out/$r.ext4 10g
    podman rm -f $container
}

./container.sh ./build_kernel.sh
build_rootfs rootfs
