#!/usr/bin/env bash

set -euo pipefail

build_rootfs()
{
    rm -rf rootfs
    mkdir rootfs
    pushd rootfs
    podman build -t build-linux-stack-rootfs - < ../Dockerfile_rootfs
    container=$(podman create build-linux-stack-rootfs)
    podman export -o /dev/stdout $container | tar xf -
    podman rm -f $container
    cat > init << EOF
#!/usr/bin/env bash

set -euo pipefail
set -x

export PATH=/usr/bin:/bin:/sbin

mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys

mkdir -p /host
mount -t 9p -o trans=virtio host /host
ifconfig eth0 up
ifconfig eth0 10.0.2.15 netmask 255.255.255.0 broadcast 10.0.2.255
route add default gw 10.0.2.2
if [ -f /host/init ]; then
    /host/init || true
else
    setsid -c -w /usr/bin/bash -l || true
fi
EOF
    chmod +x init
    cat > etc/resolv.conf << EOF
nameserver 1.1.1.1
EOF
    popd
    rm -f out/rootfs.ext4
    ./container.sh /sbin/mke2fs -t ext4 -d rootfs/ out/rootfs.ext4 10g
}

build_rootfs
