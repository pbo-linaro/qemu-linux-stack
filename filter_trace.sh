#!/usr/bin/env bash

grep --line-buffered -v 'Unhandled read' |
grep --line-buffered -v 'Unhandled write' |
grep --line-buffered -v 'SMC_RMI_GRANULE_DELEGATE.*RMI_ERROR_INPUT'
