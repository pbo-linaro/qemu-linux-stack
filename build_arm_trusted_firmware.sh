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
            --single-branch --branch master \
            arm-trusted-firmware
    fi
}

build_tfa()
{
    pushd arm-trusted-firmware
    # tf-a is not very good to handle config changes, so simply clean it
    git clean -ffdx
    # boot with edk2, as uboot does not seem to work with rme
    # https://trustedfirmware-a.readthedocs.io/en/latest/components/realm-management-extension.html#building-and-running-tf-a-with-rme
    make PLAT=qemu QEMU_USE_GIC_DRIVER=QEMU_GICV3 \
         BL33=../edk2/Build/ArmVirtQemuKernel-AARCH64/RELEASE_GCC5/FV/QEMU_EFI.fd \
         ENABLE_RME=1 \
         RMM=../tf-rmm/build/Debug/rmm.img \
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
