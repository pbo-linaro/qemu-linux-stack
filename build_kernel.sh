#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_kernel.sh
    exit 0
fi

clone()
{
    rm -f linux
    url=https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
    version=v6.16
    src=linux_${version}_16k
    if [ ! -d $src ]; then
        git clone $url --single-branch --branch $version --depth 1 $src
        pushd $src
        git am ../patches/linux-include-linux-compiler-add-DEBUGGER-attribute-for-functions.patch
        popd
    fi
    ln -s $src linux
}

build()
{
    pushd linux
    rm -f .config
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig -j$(nproc)
    # reduce number of timer interrupts
    scripts/config --disable CONFIG_HZ_250
    scripts/config --enable CONFIG_HZ_100
    # nvme
    scripts/config --enable BLK_DEV_NVME
    # iommufd
    # https://docs.kernel.org/driver-api/vfio.html#vfio-device-cdev
    scripts/config --enable IOMMUFD
    scripts/config --enable VFIO_DEVICE_CDEV
    scripts/config --enable ARM_SMMU_V3_IOMMUFD
    # 16KB pages
    scripts/config --enable ARM64_16K_PAGES

    # disable all modules
    sed -i -e 's/=m$/=n/' .config

    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig -j$(nproc)
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- all -j$(nproc)

    # compile commands
    ./scripts/clang-tools/gen_compile_commands.py
    sed -i ./compile_commands.json \
        -e 's/-femit-struct-debug-baseonly//' \
        -e 's/-fconserve-stack//' \
        -e 's/-fno-allow-store-data-races//' \
        -e 's/-mabi=lp64//' \
        -e 's/aarch64-linux-gnu-gcc/clang -target aarch64-pc-none-gnu -Wno-unknown-warning-option -enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang/'

    popd
}

output()
{
    mkdir -p out
    rsync ./linux/arch/arm64/boot/Image.gz out/
}

clone
build
output
