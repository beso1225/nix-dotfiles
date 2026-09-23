#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
swift_cache_dir="${TMPDIR:-/tmp}/aerospace-swift-cache"
mkdir -p "$swift_cache_dir/clang" "$swift_cache_dir/swift"
CLANG_MODULE_CACHE_PATH="$swift_cache_dir/clang" \
SWIFT_MODULECACHE_PATH="$swift_cache_dir/swift" \
  exec /usr/bin/swift "$script_dir/has-external-monitor.swift"
