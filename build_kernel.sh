#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_kernel.sh
    exit 0
fi

clone()
{
    url=https://gitlab.arm.com/linux-arm/linux-cca
    version=cca-host/v9
    src=linux_$(echo $version | tr '/' '_')
    if [ ! -d $src ]; then
        git clone $url --single-branch --branch $version --depth 1 $src
    fi
    rm -f linux && ln -s $src linux
}

build()
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
    # # Enable the configfs-tsm driver that provides the attestation interface
    scripts/config --enable VIRT_DRIVERS
    scripts/config --enable ARM_CCA_GUEST

    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig -j$(nproc)
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- all -j$(nproc)
    popd
}

output()
{
    mkdir -p out
    # kvmtool is not able to boot a compressed kernel
    rsync ./linux/arch/arm64/boot/Image out/
}

clone
build
output
