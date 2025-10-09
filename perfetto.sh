#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 3 ]; then
    echo "usage: from_timestamp to_timestamp out_file"
    exit 1
fi

if [ -z "${DISABLE_CONTAINER_CHECK:-}" ]; then
    ./container.sh ./perfetto.sh "$@"
    exit 0
fi

from=$1;shift
to=$1;shift
out=$1;shift

set -x
uftrace dump --chrome --time-range=${from}~${to} > $out
set +x

echo "open $out on https://ui.perfetto.dev/"
