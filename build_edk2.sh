#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_edk2.sh
    exit 0
fi

clone_edk2()
{
    if [ ! -d edk2 ]; then
        git clone \
            https://github.com/tianocore/edk2.git \
            --single-branch --branch edk2-stable202505 \
            edk2

        pushd edk2
        git submodule update --init
        popd
    fi
}

build_edk2()
{
    pushd edk2
    make -C BaseTools -j $(nproc)
    export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
    bash -c ". edksetup.sh && build -q -a AARCH64 -b RELEASE -t GCC5 -p ArmVirtPkg/ArmVirtQemuKernel.dsc"
    popd
}

clone_edk2
build_edk2
