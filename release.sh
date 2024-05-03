#!/usr/bin/env bash
set -e

release_date="$(date +"%Y-%m-%d")"
git tag "$release_date" -m "Release $release_date"

./build.sh
