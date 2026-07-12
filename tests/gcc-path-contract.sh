#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
package=$(nix build \
  --no-link \
  --print-out-paths \
  "path:$repo_root#gccWithoutCc")

test -n "$package"
test -x "$package/bin/gcc"
test ! -e "$package/bin/cc"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'int main(void) { return 0; }\n' > "$tmpdir/main.c"
"$package/bin/gcc" "$tmpdir/main.c" -o "$tmpdir/main"
"$tmpdir/main"
