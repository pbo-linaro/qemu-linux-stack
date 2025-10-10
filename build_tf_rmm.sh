#!/usr/bin/env bash

set -euo pipefail
set -x

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./build_tf_rmm.sh
    exit 0
fi

clone()
{
    rm -f tf-rmm
    url=https://github.com/TF-RMM/tf-rmm
    version=481cb7f4
    src=tf-rmm-main-s1pie-sbsa-release
    if [ ! -d $src ]; then
        git clone $url $src
        pushd $src
        git checkout $version
        git submodule update --init --depth 1
        git am ../patches/rmm-support-lower-pmu-versions.patch
        popd
    fi
    ln -s $src tf-rmm
}

build()
{
    pushd tf-rmm
    env CROSS_COMPILE=aarch64-linux-gnu- \
      cmake -DRMM_CONFIG=qemu_sbsa_defcfg \
      -DCMAKE_BUILD_TYPE=Release \
      -DLOG_LEVEL=40 \
      -S . -B build
    intercept-build --append \
    make -C build -j "$(nproc)"
    sed -i compile_commands.json -e 's/"cc"/"aarch64-linux-gnu-gcc"/'
    popd
}

clone
build
