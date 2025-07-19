#!/usr/bin/env bash

set -euo pipefail
set -x

git log --all --decorate-refs='refs/heads/*' --oneline --graph --simplify-by-decoration
