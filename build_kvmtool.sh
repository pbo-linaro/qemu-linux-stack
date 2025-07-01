#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_kvmtool.sh
    exit 0
fi

clone_kvmtool()
{
    if [ ! -d kvmtool ]; then
        git clone \
            https://gitlab.arm.com/linux-arm/kvmtool-cca \
            --single-branch --branch cca/v7 --depth 1 \
            kvmtool
    fi
}

build_kvmtool()
{
    pushd kvmtool
    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
    popd
}

output()
{
    mkdir -p out
    rsync ./kvmtool/lkvm out/
}

clone_kvmtool
build_kvmtool
output
