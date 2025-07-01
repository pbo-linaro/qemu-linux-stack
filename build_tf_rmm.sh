#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_tf_rmm.sh
    exit 0
fi

clone()
{
    url=https://github.com/TF-RMM/tf-rmm
    version=tf-rmm-v0.7.0
    src=$version-support-lower-pmu-versions
    if [ ! -d $src ]; then
        git clone $url --single-branch --branch $version --depth 1 $src
        pushd $src
        git submodule update --init
        git am ../patches/rmm-support-lower-pmu-versions.patch
        popd
    fi
    rm -f tf-rmm && ln -s $src tf-rmm
}

build()
{
    pushd tf-rmm
    env CROSS_COMPILE=aarch64-linux-gnu- \
      cmake -DRMM_CONFIG=qemu_virt_defcfg \
      -DCMAKE_BUILD_TYPE=Debug \
      -S . -B build
    make -C build -j "$(nproc)"
    popd
}

clone
build
