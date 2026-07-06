#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_home=$(mktemp -d)
trap 'rm -rf "$test_home"' EXIT

assert_file() {
  local path=$1
  if [[ ! -f "$repo_root/$path" ]]; then
    echo "missing required file: $path" >&2
    return 1
  fi
}

assert_contains() {
  local path=$1
  local pattern=$2
  if ! grep -Fq -- "$pattern" "$repo_root/$path"; then
    echo "$path does not contain: $pattern" >&2
    return 1
  fi
}

assert_not_contains() {
  local path=$1
  local pattern=$2
  if grep -Fq -- "$pattern" "$repo_root/$path"; then
    echo "$path unexpectedly contains: $pattern" >&2
    return 1
  fi
}

assert_file .chezmoiroot
assert_file chezmoi/.chezmoi.toml.tmpl
assert_file chezmoi/.chezmoiignore

if [[ $(<"$repo_root/.chezmoiroot") != "chezmoi" ]]; then
  echo ".chezmoiroot must select the chezmoi subdirectory" >&2
  exit 1
fi

assert_contains docs/chezmoi-bootstrap.md 'chezmoi init beso1225/nix-dotfiles'
assert_contains docs/chezmoi-bootstrap.md 'chezmoi apply'
assert_contains docs/chezmoi-bootstrap.md 'darwin-rebuild switch --flake "$source_dir"#TY'
assert_contains docs/chezmoi-bootstrap.md 'single owner'
assert_not_contains nix/home/shell.nix '".config/chezmoi"'

source_state=$(HOME="$test_home" chezmoi --source "$repo_root" source-path)
if [[ "$source_state" != "$repo_root/chezmoi" ]]; then
  echo "chezmoi resolved an unexpected source state: $source_state" >&2
  exit 1
fi

HOME="$test_home" chezmoi --source "$repo_root" execute-template --init \
  < "$repo_root/chezmoi/.chezmoi.toml.tmpl" \
  > /dev/null

managed=$(HOME="$test_home" chezmoi --source "$repo_root" managed)
if [[ -n "$managed" ]]; then
  echo "Phase 2 must not introduce managed home paths:" >&2
  echo "$managed" >&2
  exit 1
fi
