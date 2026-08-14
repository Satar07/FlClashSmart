#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
generator="$script_dir/generate_release_notes.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

cat > "$temp_dir/CHANGELOG.md" <<'EOF'
## v1.2.0

- Second release change

- Another second release change

## v1.1.0

- First release change

## v1.0.0

- Initial release
EOF

actual="$temp_dir/actual.md"
expected="$temp_dir/expected.md"

printf '%s\n' \
  "- Second release change" \
  "" \
  "- Another second release change" \
  "" > "$expected"

bash "$generator" "$temp_dir/CHANGELOG.md" "$actual"
diff -u "$expected" "$actual"

printf '%s\n' "stale content" > "$actual"
bash "$generator" "$temp_dir/CHANGELOG.md" "$actual"
diff -u "$expected" "$actual"
! grep -q -- "- First release change" "$actual"
! grep -q -- "- Initial release" "$actual"
