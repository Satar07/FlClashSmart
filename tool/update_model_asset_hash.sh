#!/bin/sh
set -eu
repo_root=$(git rev-parse --show-toplevel)
shasum -a 256 "$repo_root/assets/data/Model.bin" | awk '{print $1}' > "$repo_root/assets/data/Model.bin.sha256"
