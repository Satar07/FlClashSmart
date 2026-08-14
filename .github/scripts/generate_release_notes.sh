#!/usr/bin/env bash

set -euo pipefail

changelog="${1:-CHANGELOG.md}"
output="${2:-release.md}"

: > "$output"

awk '
  /^## / {
    if (in_section) exit
    in_section = 1
    next
  }
  in_section && NF {
    print
    print ""
  }
' "$changelog" > "$output"
