#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
source_root="$repo_root/chezmoi"

test -f "$source_root/.chezmoi.toml.tmpl"
test -f "$source_root/.chezmoiignore"

expected_sources=(
  "$source_root/dot_config/nvim/init.lua"
  "$source_root/dot_config/nvim/lua/core/filetypes.lua"
  "$source_root/dot_config/zsh/functions/ccnew"
  "$source_root/dot_config/zsh/functions/y"
  "$source_root/dot_config/zsh-abbr/user-abbreviations"
)

for source in "${expected_sources[@]}"; do
  test -f "$source"
done

test ! -e "$repo_root/home-manager/nvim"
test ! -e "$repo_root/home-manager/zsh/functions"

if sed -n '/^  home\.file = {/,/^  };/p' "$repo_root/nix/home/shell.nix" \
  | rg -n '\.config/(nvim|zsh/functions|zsh-abbr)'; then
  echo "migrated target paths must not be owned by Home Manager" >&2
  exit 1
fi

tmp_home=$(mktemp -d "${TMPDIR:-/tmp}/nix-dotfiles-chezmoi.XXXXXX")
trap 'rm -rf "$tmp_home"' EXIT
config_path="$tmp_home/chezmoi.toml"
touch "$config_path"

chezmoi \
  --config "$config_path" \
  --source "$source_root" \
  --destination "$tmp_home" \
  init --guess-repo-url=false

chezmoi \
  --config "$config_path" \
  --source "$source_root" \
  --destination "$tmp_home" \
  --persistent-state "$tmp_home/chezmoistate.boltdb" \
  --force \
  apply

expected_targets=(
  "$tmp_home/.config/nvim/init.lua"
  "$tmp_home/.config/zsh/functions/ccnew"
  "$tmp_home/.config/zsh/functions/y"
  "$tmp_home/.config/zsh-abbr/user-abbreviations"
)

for target in "${expected_targets[@]}"; do
  test -f "$target"
done

diff -r -q \
  "$source_root/dot_config/nvim" \
  "$tmp_home/.config/nvim"
cmp \
  "$source_root/dot_config/zsh/functions/ccnew" \
  "$tmp_home/.config/zsh/functions/ccnew"
cmp \
  "$source_root/dot_config/zsh/functions/y" \
  "$tmp_home/.config/zsh/functions/y"
cmp \
  "$source_root/dot_config/zsh-abbr/user-abbreviations" \
  "$tmp_home/.config/zsh-abbr/user-abbreviations"

test ! -e "$tmp_home/flake.nix"
test ! -e "$tmp_home/nix"

rg -q 'fpath=\(\$HOME/\.config/zsh/functions \$fpath\)' \
  "$repo_root/nix/home/shell.nix"
rg -q 'autoload -Uz ccnew y' "$repo_root/nix/home/shell.nix"

echo "chezmoi phase 3 ownership contract: ok"
