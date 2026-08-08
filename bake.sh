#!/bin/bash

set -eu

if [ $# != 1 ]; then
    echo 'Error: OS name expected' >&2
    exit 1
fi

OS_TYPE="$1"

case "$1" in
    linux)
        QT_VERSION=6.12
    ;;
    linux-6.11)
        QT_VERSION=6.11
        OS_TYPE=linux
    ;;
    linux-6.10)
        QT_VERSION=6.10
        OS_TYPE=linux
    ;;
    macos-arm64)
        QT_VERSION=6.10
    ;;
    macos-x86_64)
        QT_VERSION=6.10
    ;;
    windows)
        QT_VERSION=6.11
    ;;
    *)
        echo 'Error: unknown OS name' >&2
        exit 1
    ;;
esac


docker build --build-context qt="$HOME"/Qt/qt -t crossetta/crossetta:"$OS_TYPE"-"$QT_VERSION"-latest -f dockerfiles/crossetta-"$1".Dockerfile .
