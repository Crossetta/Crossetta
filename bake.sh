#!/bin/bash

set -eu

if [ $# != 1 ]; then
    echo 'Error: OS name expected' >&2
fi

docker build --build-context qt="$HOME"/Qt/qt -t crossetta-"$1":latest -f dockerfiles/crossetta-"$1".Dockerfile .
