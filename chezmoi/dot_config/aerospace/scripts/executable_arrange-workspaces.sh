#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
config_dir=$(cd "$script_dir/.." && pwd)
source "$config_dir/config.env"
if [ -f "$config_dir/config.local" ]; then
  source "$config_dir/config.local"
fi

assignments_file="${1:-}"
if [ -z "$assignments_file" ] || [ ! -f "$assignments_file" ]; then
  echo "usage: $0 ASSIGNMENTS_FILE" >&2
  exit 2
fi

log() {
  mkdir -p "$AEROSPACE_LOG_DIR"
  printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >> "$AEROSPACE_LOG_DIR/arrange.log"
}

role_id() {
  awk -F '\t' -v role="$1" '$1 == role { print $2; exit }' "$assignments_file"
}

role_workspace() {
  awk -F '\t' -v role="$1" '$1 == role { print $3; exit }' "$assignments_file"
}

required_roles=(
  chrome-default-1 line discord
  ghostty chrome-default-2
  chatgpt chrome-profile-4 music
)
for role in "${required_roles[@]}"; do
  if [ -z "$(role_id "$role")" ]; then
    log "missing assignment for $role"
    exit 1
  fi
done

managed_ids() {
  awk -F '\t' '{ print $2 }' "$assignments_file"
}

is_managed_id() {
  local window_id="$1"
  managed_ids | awk -v id="$window_id" '$1 == id { found = 1 } END { exit found ? 0 : 1 }'
}

move_unmanaged_windows_to_workspace_5() {
  local current
  local window_id
  local app_bundle_id
  local workspace
  local window_title

  current=$("$AEROSPACE_BIN" list-windows --all \
    --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{workspace}%{tab}%{window-title}%{newline}')
  while IFS=$'\t' read -r window_id app_bundle_id workspace window_title; do
    [ -n "$window_id" ] || continue
    is_managed_id "$window_id" && continue

    log "moving unmanaged window ($window_id, $app_bundle_id, $window_title) to workspace 5"
    "$AEROSPACE_BIN" layout --window-id "$window_id" tiling
    if [ "$workspace" != "5" ]; then
      "$AEROSPACE_BIN" move-node-to-workspace --window-id "$window_id" -- 5
    fi
  done <<EOF
$current
EOF

  "$AEROSPACE_BIN" layout --workspace 5 --root h_accordion
}

move_unmanaged_windows_to_workspace_5

preflight_workspace() {
  local workspace="$1"
  local current
  current=$("$AEROSPACE_BIN" list-windows --workspace "$workspace" \
    --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{window-title}%{newline}')
  while IFS=$'\t' read -r window_id app_bundle_id window_title; do
    [ -n "$window_id" ] || continue
    if ! is_managed_id "$window_id"; then
      log "workspace $workspace contains an unmanaged window ($window_id, $app_bundle_id, $window_title); refusing to rebuild its tree"
      return 1
    fi
  done <<EOF
$current
EOF
}

for workspace in 1 2 3 4 9; do
  preflight_workspace "$workspace"
done
preflight_workspace "$AEROSPACE_STAGING_WORKSPACE"

move_role() {
  local role="$1"
  local id
  local workspace
  id=$(role_id "$role")
  workspace=$(role_workspace "$role")
  "$AEROSPACE_BIN" layout --window-id "$id" tiling
  "$AEROSPACE_BIN" move-node-to-workspace --window-id "$id" -- "$workspace"
}

# AeroSpace's list-windows output is not a reliable representation of sibling
# order on all versions. Use an empty staging workspace to rebuild the two
# multi-window roots in an explicit insertion order instead.
for role in chrome-default-1 line discord ghostty chrome-default-2; do
  id=$(role_id "$role")
  "$AEROSPACE_BIN" layout --window-id "$id" tiling
  "$AEROSPACE_BIN" move-node-to-workspace --window-id "$id" -- "$AEROSPACE_STAGING_WORKSPACE"
done

for role in chrome-default-1 line discord ghostty chrome-default-2 chatgpt chrome-profile-4 music; do
  move_role "$role"
done

"$AEROSPACE_BIN" flatten-workspace-tree --workspace 1
"$AEROSPACE_BIN" flatten-workspace-tree --workspace 2
"$AEROSPACE_BIN" layout --workspace 1 --root h_tiles
"$AEROSPACE_BIN" layout --workspace 2 --root h_tiles

chrome_one=$(role_id chrome-default-1)
line=$(role_id line)
ghostty=$(role_id ghostty)

# After staging, the insertion order is Chrome, LINE, Discord. In this
# AeroSpace version `join-with ... right` joins LINE with its right sibling,
# producing h_tiles(Chrome, v_tiles(LINE, Discord)).
"$AEROSPACE_BIN" join-with --window-id "$line" right
"$AEROSPACE_BIN" layout --window-id "$line" v_tiles
"$AEROSPACE_BIN" layout --workspace 1 --root h_tiles

"$AEROSPACE_BIN" layout --workspace 2 --root h_tiles

"$AEROSPACE_BIN" resize --window-id "$chrome_one" width "+$AEROSPACE_LEFT_RESIZE_PX"
"$AEROSPACE_BIN" resize --window-id "$ghostty" width "+$AEROSPACE_WORKSPACE_2_LEFT_RESIZE_PX"

log "arranged workspaces 1, 2, 3, 4, and 9"
