#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

### BUILD PROPERTIES ###

BUILD_NAME="arch64-develop"

IMAGE_CPUS=1
IMAGE_MEMORY_MB=1024

### BUILD VARIABLES  ###

: "${BUILD_CPUS:=8}"
: "${BUILD_MEMORY_MB:=8192}"

: "${BOOT_WAIT_TIME_SECS:=120}"

########################

ORIG_WD="$(pwd)"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR=`mktemp -d`

if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
    echo "Could not create temp dir"
    exit 1
fi

function cleanup {
    cd "$ORIG_WD" 
    rm -rf "$WORK_DIR"
    echo "Deleted temp working directory $WORK_DIR"
}
trap cleanup EXIT

build_date="$(date +%+4Y-%m-%d)"

cd "$WORK_DIR"
env PACKER_CACHE_DIR="$SCRIPT_DIR/.packer_cache" \
packer build \
    -var="build_name="$BUILD_NAME"" \
    -var="build_date="$build_date"" \
    -var="build_cpus=$BUILD_CPUS" \
    -var="build_memory=$BUILD_MEMORY_MB" \
    -var="boot_wait_time=$BOOT_WAIT_TIME_SECS" \
    -var="image_cpus=$IMAGE_CPUS" \
    -var="image_memory=$IMAGE_MEMORY_MB" \
    "$SCRIPT_DIR"

crc_dir="$WORK_DIR/crc"
mkdir -p "$crc_dir"

cd "$WORK_DIR/output"
b2sum * > "$crc_dir/b2sums.txt"
md5sum * > "$crc_dir/md5sums.txt"
sha256sum * > "$crc_dir/sha256sums.txt"
sha512sum * > "$crc_dir/sha512sums.txt"

mv "$crc_dir"/* "$WORK_DIR/output"

mkdir -p "$SCRIPT_DIR/dist/${BUILD_NAME}_${build_date}"
cd "$SCRIPT_DIR"
mv "$WORK_DIR/output"/* "$SCRIPT_DIR/dist/${BUILD_NAME}_${build_date}"
