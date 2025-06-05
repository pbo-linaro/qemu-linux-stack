#!/usr/bin/env bash

set -euo pipefail

INIT_CMD="/host/guest_passthrough_iommufd.sh diff /host/disk /dev/nvme0n1" \
./run_passthrough_vfio.sh "$@"
