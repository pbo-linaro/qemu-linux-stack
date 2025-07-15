#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_arm_trusted_firmware.sh
    exit 0
fi

clone_tfa()
{
    if [ ! -d arm-trusted-firmware ]; then
        git clone \
            https://github.com/ARM-software/arm-trusted-firmware \
            --single-branch --branch v2.13.0 \
            arm-trusted-firmware
        pushd arm-trusted-firmware
        git am ../patches/arm-trusted-firmware-support-FEAT_TCR2-and-FEAT-SCTLR2.patch
        popd
    fi
}

build_tfa()
{
    pushd arm-trusted-firmware
    # tf-a is not very good to handle config changes, so simply clean it
    git clean -ffdx
    make PLAT=qemu QEMU_USE_GIC_DRIVER=QEMU_GICV3 \
         BL33=../u-boot/u-boot.bin \
         DEBUG=1 \
         all fip -j$(nproc)
    dd if=build/qemu/debug/bl1.bin of=flash.bin bs=4096 conv=notrunc
    dd if=build/qemu/debug/fip.bin of=flash.bin seek=64 bs=4096 conv=notrunc
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
