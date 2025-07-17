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
    src=arm-trusted-firmware-$version-patch-tcr2-sctlr2-sbsa
    if [ ! -d $src ]; then
        git clone $url --single-branch --branch $version --depth 1 $src
        pushd $src
        git am ../patches/arm-trusted-firmware-support-FEAT_TCR2-and-FEAT-SCTLR2.patch
        popd
    fi
    ln -s $src arm-trusted-firmware
}

build()
{
    pushd arm-trusted-firmware
    # tf-a is not very good to handle config changes, so simply clean it
    git clean -ffdx
    # boot with edk2, as uboot does not seem to work with rme
    # https://trustedfirmware-a.readthedocs.io/en/latest/components/realm-management-extension.html#building-and-running-tf-a-with-rme
    make PLAT=qemu_sbsa \
         ENABLE_RME=1 \
         RMM=../tf-rmm/build/Debug/rmm.img \
         LOG_LEVEL=40 \
         DEBUG=1 \
         all fip -j$(nproc)
    popd
}

clone
build
