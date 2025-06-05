#!/usr/bin/env bash

set -euo pipefail
set -x

cd /host

source ./guest_passthrough_bind_disk.sh

INIT_CMD="$*" \
./guest.sh qemu-system-aarch64 \
-device vfio-pci,host=$disk
