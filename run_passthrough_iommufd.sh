#!/usr/bin/env bash

set -euo pipefail

INIT_CMD="/host/guest_passthrough_iommufd.sh" \
./run_passthrough_vfio.sh "$@"
