#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_edk2.sh
    exit 0
fi

clone()
{
    url=https://github.com/tianocore/edk2.git
    version=edk2-stable202505
    src=$version
    if [ ! -d $src ]; then
        git clone $url --single-branch --branch $version --depth 1 $src
        pushd $src
        git submodule update --init
        popd
    fi
    rm -f edk2 && ln -s $src edk2
}

build()
{
    pushd edk2
    make -C BaseTools -j $(nproc)
    export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
    bash -c ". edksetup.sh && build -q -a AARCH64 -b DEBUG -t GCC5 -p ArmVirtPkg/ArmVirtQemuKernel.dsc"
    popd
}

clone
build
