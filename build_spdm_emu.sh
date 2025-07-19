#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_spdm_emu.sh
    exit 0
fi

clone()
{
    rm -f spdm-emu
    url=https://github.com/DMTF/spdm-emu
    version=3.8.0
    src=spdm-emu-$version
    if [ ! -d $src ]; then
        git clone $url --single-branch --branch $version --depth 1 $src
        pushd $src
        git submodule update --init --recursive --depth 1
        popd
    fi
    ln -s $src spdm-emu
}

build()
{
    pushd spdm-emu
    cmake -DARCH=x64 -DTOOLCHAIN=GCC -DTARGET=Debug -DCRYPTO=openssl -S . -B build
    pushd build
    make copy_sample_key
    make -j $(nproc)
    popd
    popd
}

clone
build
