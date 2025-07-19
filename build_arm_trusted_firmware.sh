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
    url=https://git.codelinaro.org/linaro/dcap/tf-a/trusted-firmware-a
    version=alp12
    src=arm-trusted-firmware-$version-patch-tcr2-sctlr2-sbsa-device-assignment
    if [ ! -d $src ]; then
        git clone $url --single-branch --branch $version --depth 1 $src
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
    intercept-build --append \
    make PLAT=qemu_sbsa \
         ENABLE_RME=1 \
         RMM=../tf-rmm/build/Debug/rmm.img \
         LOG_LEVEL=40 \
         DEBUG=1 \
         all fip -j$(nproc)
    sed -i compile_commands.json -e 's/"cc"/"aarch64-linux-gnu-gcc"/'
    popd
}

clone
build
