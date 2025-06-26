#!/usr/bin/env bash

set -euo pipefail

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    echo "run command using ./container.sh ./build_kernel.sh"
    exit 1
fi

clone_linux()
{
    if [ ! -d linux ]; then
        git clone \
            https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/ \
            --single-branch --branch master --depth 1 \
            linux
    fi
}

build_linux()
{
    pushd linux
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig -j$(nproc)
    # nvme
    scripts/config --enable BLK_DEV_NVME
    # iommufd
    # https://docs.kernel.org/driver-api/vfio.html#vfio-device-cdev
    scripts/config --enable IOMMUFD
    scripts/config --enable VFIO_DEVICE_CDEV
    scripts/config --enable ARM_SMMU_V3_IOMMUFD
    # tdisp
    scripts/config --enable PCI_CMA
    # dmatest
    scripts/config --enable VIRTIO_DMATEST
    # smmuv3 tests
    scripts/config --enable KUNIT
    scripts/config --enable ARM_SMMU_V3
    scripts/config --enable ARM_SMMU_V3_SVA
    scripts/config --module ARM_SMMU_V3_KUNIT_TEST
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig -j$(nproc)
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- all -j$(nproc)
    popd
}

copy_optional()
{
    path=$1; shift
    name=$(basename "$path")
    rm -rf "out/$name"
    if [ -e "$path" ]; then
        rsync "$path" out/
    fi
}

output()
{
    mkdir -p out
    copy_optional linux/drivers/iommu/arm/arm-smmu-v3/arm-smmu-v3-test.ko
    rsync ./linux/arch/arm64/boot/Image out/
    rsync ./linux/vmlinux out/
}

clone_linux
build_linux
output
