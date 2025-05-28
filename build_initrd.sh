#!/usr/bin/env bash

set -euo pipefail

build_initrd()
{
    rm -rf initrd
    mkdir initrd
    pushd initrd
    podman build -t build-linux-stack-initrd - < ../Dockerfile_initrd
    container=$(podman create build-linux-stack-initrd)
    podman export -o /dev/stdout $container | tar xf -
    podman rm -f $container
    cat > init << EOF
#!/usr/bin/env bash

set -euo pipefail
set -x

mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys

mkdir /rootfs
mount /dev/vda /rootfs
chroot /rootfs/ /init || true

sync
echo o > /proc/sysrq-trigger
sleep 10
EOF
    chmod +x init
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
