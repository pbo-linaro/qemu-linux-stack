#!/usr/bin/env bash

set -euo pipefail

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_arm_trusted_firmware.sh
    exit 0
fi

clone_tfa()
{
    if [ ! -d arm-trusted-firmware ]; then
        git clone \
            https://github.com/ARM-software/arm-trusted-firmware \
            --single-branch --branch master \
            arm-trusted-firmware
    fi
}

build_tfa()
{
    pushd arm-trusted-firmware
    make PLAT=qemu QEMU_USE_GIC_DRIVER=QEMU_GICV3 \
         BL33=../u-boot/u-boot.bin \
         all fip -j$(nproc)
    dd if=build/qemu/release/bl1.bin of=flash.bin bs=4096 conv=notrunc
    dd if=build/qemu/release/fip.bin of=flash.bin seek=64 bs=4096 conv=notrunc
    popd
}

output()
{
    mkdir -p out
    rsync ./arm-trusted-firmware/flash.bin out/flash.bin
}

clone_tfa
build_tfa
output
