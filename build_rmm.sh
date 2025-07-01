#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_rmm.sh
    exit 0
fi

clone_rmm()
{
    if [ ! -d tf-rmm ]; then
        git clone \
            https://github.com/TF-RMM/tf-rmm \
            --single-branch --branch tf-rmm-v0.7.0 \
            tf-rmm
        git submodule update --init
    fi
}

build_rmm()
{
    pushd tf-rmm
    env CROSS_COMPILE=aarch64-linux-gnu- \
      cmake -DRMM_CONFIG=qemu_virt_defcfg \
      -DCMAKE_BUILD_TYPE=Debug \
      -S . -B build
    make -C build -j "$(nproc)"
    popd
}

clone_rmm
build_rmm
