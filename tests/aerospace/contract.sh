#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
source_root="$repo_root/chezmoi"
aerospace_root="$source_root/dot_config/aerospace"
config="$aerospace_root/aerospace.toml"

test -f "$config"
test -f "$aerospace_root/config.env"
test -f "$aerospace_root/scripts/executable_check-external-monitor.sh"
test -f "$aerospace_root/scripts/has-external-monitor.swift"
test -f "$aerospace_root/scripts/executable_bootstrap.sh"
test -f "$aerospace_root/scripts/executable_launch-if-external-monitor.sh"
test -f "$aerospace_root/scripts/executable_restore-windows.sh"
test -f "$aerospace_root/scripts/executable_arrange-workspaces.sh"
test -f "$aerospace_root/scripts/inspect-chrome-windows.js"
test -f "$source_root/Library/LaunchAgents/com.yutarotakagi.aerospace-external-monitor.plist.tmpl"

grep -Eq '^start-at-login[[:space:]]*=[[:space:]]*false$' "$config"
grep -Fq "alt-shift-semicolon = 'mode service'" "$config"
grep -Fq 'alt-1 = '\''workspace 1'\''' "$config"
grep -Fq 'alt-shift-1 = '\''move-node-to-workspace 1'\''' "$config"
grep -Fq 'if.app-id = "com.apple.finder"' "$config"
grep -Fq 'enable-normalization-flatten-containers = true' "$config"
grep -Fq 'CGDisplayIsBuiltin' "$aerospace_root/scripts/has-external-monitor.swift"
grep -Fq 'CGGetActiveDisplayList' "$aerospace_root/scripts/has-external-monitor.swift"
grep -Fq 'Default' "$aerospace_root/config.env"
grep -Fq 'Profile 4' "$aerospace_root/config.env"
grep -Fq 'com.google.Chrome' "$aerospace_root/config.env"
grep -Fq -- '--window-id' "$aerospace_root/scripts/executable_arrange-workspaces.sh"
grep -Fq 'join-with' "$aerospace_root/scripts/executable_arrange-workspaces.sh"
grep -Fq 'h_tiles' "$aerospace_root/scripts/executable_arrange-workspaces.sh"
grep -Fq 'v_tiles' "$aerospace_root/scripts/executable_arrange-workspaces.sh"
grep -Fq 'index(aerospace_title, chrome_title " - Google Chrome") == 1' "$aerospace_root/scripts/executable_restore-windows.sh"
grep -Fq 'profile.info_cache' "$aerospace_root/scripts/executable_restore-windows.sh"
grep -Fq 'profile_from_aerospace_title' "$aerospace_root/scripts/executable_restore-windows.sh"
grep -Fq 'workspace_candidates_for_chrome_data' "$aerospace_root/scripts/executable_restore-windows.sh"
grep -Fq 'chrome_window_ids_for_profile' "$aerospace_root/scripts/executable_restore-windows.sh"
grep -Fq 'Chrome title candidates' "$aerospace_root/scripts/executable_restore-windows.sh"
grep -Fq 'AEROSPACE_STAGING_WORKSPACE' "$aerospace_root/config.env"
grep -Fq ': "${AEROSPACE_WORKSPACE_2_LEFT_RESIZE_PX:=688}"' "$aerospace_root/config.env"
grep -Fq ': "${AEROSPACE_WINDOW_RETRIES:=180}"' "$aerospace_root/config.env"
grep -Fq 'empty staging workspace' "$aerospace_root/scripts/executable_arrange-workspaces.sh"
grep -Fq 'is_managed_id' "$aerospace_root/scripts/executable_arrange-workspaces.sh"
grep -Fq 'move_unmanaged_windows_to_workspace_5' "$aerospace_root/scripts/executable_arrange-workspaces.sh"
grep -Fq 'h_accordion' "$aerospace_root/scripts/executable_arrange-workspaces.sh"
grep -Fq 'resize --window-id "$ghostty" width "+$AEROSPACE_WORKSPACE_2_LEFT_RESIZE_PX"' "$aerospace_root/scripts/executable_arrange-workspaces.sh"
grep -Fq 'RunAtLoad' "$source_root/Library/LaunchAgents/com.yutarotakagi.aerospace-external-monitor.plist.tmpl"
grep -Fq 'start-at-login' "$aerospace_root/scripts/executable_bootstrap.sh"

if rg -n --fixed-strings 'open -na' "$aerospace_root"; then
  echo 'AeroSpace automation must not use open -na (it creates a new app instance).' >&2
  exit 1
fi

echo 'AeroSpace contract: ok'
