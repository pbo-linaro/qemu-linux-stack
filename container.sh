#!/usr/bin/env bash

set -euo pipefail

podman build -t build-linux-stack - < ./Dockerfile

podman run \
    -it --rm -v $(pwd):$(pwd) -w $(pwd) -v $HOME:$HOME --init \
    --network host \
    -e DISABLE_CONTAINER_CHECK=1 \
    build-linux-stack \
    "$@"
