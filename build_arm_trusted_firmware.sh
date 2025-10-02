#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_arm_trusted_firmware.sh
    exit 0
fi

clone()
{
    rm -f arm-trusted-firmware
    url=https://github.com/ARM-software/arm-trusted-firmware
    version=v2.13.0
    src=arm-trusted-firmware-$version-patch-tcr2-sctlr2-pie-gcs
    if [ ! -d $src ]; then
        git clone $url --single-branch --branch $version --depth 1 $src
        pushd $src
        git am ../patches/arm-trusted-firmware-support-FEAT_TCR2-and-FEAT-SCTLR2.patch
        git am ../patches/arm-trusted-firmware-support-PIE-GCS.patch
        popd
    fi
    ln -s $src arm-trusted-firmware
}

build()
{
    pushd arm-trusted-firmware
    # tf-a is not very good to handle config changes, so simply clean it
    git clean -ffdx
    intercept-build --append \
    make PLAT=qemu QEMU_USE_GIC_DRIVER=QEMU_GICV3 \
         BL33=../u-boot/u-boot.bin \
         LOG_LEVEL=40 \
         DEBUG=1 \
         all fip -j$(nproc)
    dd if=build/qemu/debug/bl1.bin of=flash.bin bs=4096 conv=notrunc
    dd if=build/qemu/debug/fip.bin of=flash.bin seek=64 bs=4096 conv=notrunc
    sed -i compile_commands.json -e 's/"cc"/"aarch64-linux-gnu-gcc"/'
    popd
}

output()
{
    mkdir -p out
    rsync ./arm-trusted-firmware/flash.bin out/flash.bin
}

clone
build
output
