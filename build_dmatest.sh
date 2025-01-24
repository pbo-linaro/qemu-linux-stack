#!/usr/bin/env bash

set -euo pipefail

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    echo "run command using ./container.sh ./build_dmatest.sh"
    exit 1
fi

run_in_initrd()
{
    proot -q qemu-aarch64 -r $(pwd)/initrd sh -c "$*"
}

mkdir -p dmate/bin
rsync -a linux/include/ dmate/include/
rsync -a linux/tools/dmate/ dmate/tools/
for s in ./dmate/tools/*.c; do
    aarch64-linux-gnu-gcc -static $s -o dmate/bin/$(basename $s .c) \
        -I dmate/include/uapi/ -I dmate/include/ \
        -g -Wno-cpp -Wall -Wextra
done
