#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_kernel.sh
    exit 0
fi

clone_linux()
{
    if [ ! -d linux ]; then
        git clone \
            https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/ \
            --single-branch --branch v6.15 --depth 1 \
            linux
    fi
}

build_linux()
{
    pushd linux
    rm -f .config
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig -j$(nproc)
    # nvme
    scripts/config --enable BLK_DEV_NVME
    # iommufd
    # https://docs.kernel.org/driver-api/vfio.html#vfio-device-cdev
    scripts/config --enable IOMMUFD
    scripts/config --enable VFIO_DEVICE_CDEV
    scripts/config --enable ARM_SMMU_V3_IOMMUFD
    # 16KB pages
    # scripts/config --enable ARM64_16K_PAGES
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig -j$(nproc)
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- all -j$(nproc)
    popd
}

output()
{
    mkdir -p out
    rsync ./linux/arch/arm64/boot/Image.gz out/
}

clone_linux
build_linux
output
