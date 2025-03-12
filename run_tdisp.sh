#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "usage: qemu_src_dir qemu_aarch64_cmd"
    exit 1
fi

qemu_src_dir=$1; shift

tdisp_data="$qemu_src_dir/tests/data/tdisp"

if [ ! -d $tdisp_data ]; then
    echo "can't find tdisp data at $tdisp_data"
    exit 1
fi

./run.sh "$@" \
-device pcie-root-port,id=pcie.1 \
-device tdisp-testdev,bus=pcie.1,spdm-responder=spdm.0 \
-object spdm-responder-libspdm,id=spdm.0,\
base-asym-algo=rsa-3072,base-hash-algo=sha-384,\
certs=$tdisp_data/rsa3072/device.certchain.der,\
keys=$tdisp_data/rsa3072/device.key,\
certs=$tdisp_data/ecp256/device.certchain.der,\
keys=$tdisp_data/ecp256/device.key,\
certs=$tdisp_data/ecp384/device.certchain.der,\
keys=$tdisp_data/ecp384/device.key
