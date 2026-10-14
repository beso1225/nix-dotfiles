#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
config_dir=$(cd "$script_dir/.." && pwd)
source "$config_dir/config.env"
if [ -f "$config_dir/config.local" ]; then
  source "$config_dir/config.local"
fi

learn_current=false
case "${1:-}" in
  "") ;;
  --learn-current) learn_current=true ;;
  *) echo "usage: $0 [--learn-current]" >&2; exit 2 ;;
esac

mkdir -p "$AEROSPACE_STATE_DIR" "$AEROSPACE_LOG_DIR"
state_file="$AEROSPACE_STATE_DIR/chrome-windows.tsv"
log_file="$AEROSPACE_LOG_DIR/restore.log"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/aerospace-restore.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT
windows_file="$tmp_dir/windows.tsv"
inspection_file="$tmp_dir/chrome.tsv"
assignments_file="$tmp_dir/assignments.tsv"
pending_default_file="$tmp_dir/pending-default.tsv"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >> "$log_file"
}

list_windows() {
  "$AEROSPACE_BIN" list-windows --all --format '%{window-id}%{tab}%{app-bundle-id}%{tab}%{workspace}%{tab}%{window-title}%{newline}'
}

app_count() {
  awk -F '\t' -v app="$1" '$2 == app { count++ } END { print count + 0 }' "$windows_file"
}

required_windows_ready() {
  [ "$(app_count "$LINE_APP_BUNDLE_ID")" -eq 1 ] || return 1
  [ "$(app_count "$DISCORD_APP_BUNDLE_ID")" -eq 1 ] || return 1
  [ "$(app_count "$GHOSTTY_APP_BUNDLE_ID")" -eq 1 ] || return 1
  [ "$(app_count "$CHATGPT_APP_BUNDLE_ID")" -eq 1 ] || return 1
  [ "$(app_count "$MUSIC_APP_BUNDLE_ID")" -eq 1 ] || return 1
  [ "$(app_count "$CHROME_APP_BUNDLE_ID")" -ge 3 ] || return 1
}

attempt=1
while [ "$attempt" -le "$AEROSPACE_WINDOW_RETRIES" ]; do
  if list_windows > "$windows_file" 2>/dev/null && required_windows_ready; then
    break
  fi
  if [ "$attempt" -eq "$AEROSPACE_WINDOW_RETRIES" ]; then
    log "required application windows did not appear before timeout"
    exit 1
  fi
  sleep "$AEROSPACE_WINDOW_RETRY_SECONDS"
  attempt=$((attempt + 1))
done

attempt=1
while :; do
  if CHROME_APP_PATH="$CHROME_APP_PATH" CHROME_PIN_HELPER="$script_dir/chrome-pinned-tabs.js" /usr/bin/osascript -l JavaScript "$script_dir/inspect-chrome-windows.js" > "$inspection_file" 2>"$tmp_dir/osascript.stderr" &&
    awk -F '\t' '$6 == 1 { one++ } $6 == 2 { two++ } END { exit !(one == 1 && two == 1) }' "$inspection_file"; then
    # Refresh titles after session restoration, before resolving native IDs.
    list_windows > "$windows_file"
    break
  fi
  if [ "$attempt" -ge "$AEROSPACE_WINDOW_RETRIES" ]; then
    log "Chrome pinned-mail classification did not become unambiguous before timeout"
    exit 1
  fi
  [ "$attempt" -ne 1 ] || log "waiting for current Chrome session and pinned-mail tabs"
  sleep "$AEROSPACE_WINDOW_RETRY_SECONDS"
  attempt=$((attempt + 1))
done

normalize_urls() {
  printf '%s' "$1" | tr '\037' '\n' | LC_ALL=C sort | tr '\n' '\037'
}

fingerprint() {
  printf '%s\t%s' "$1" "$2" | /usr/bin/shasum -a 256 | awk '{ print $1 }'
}

state_workspace_for_fingerprint() {
  local profile="$1"
  local value="$2"
  [ -f "$state_file" ] || return 0
  awk -F '\t' -v profile="$profile" -v fingerprint="$value" \
    '$1 == profile && $3 == fingerprint { print $2; exit }' "$state_file"
}

state_workspace_for_active_url() {
  local profile="$1"
  local active_url="$2"
  [ -f "$state_file" ] || return 0
  awk -F '\t' -v profile="$profile" -v active_url="$active_url" \
    '$1 == profile && $4 == active_url { print $2; exit }' "$state_file"
}

profile_has_url() {
  local profile_dir="$1"
  local url="$2"
  [ -n "$url" ] || return 1
  local session_file
  for session_file in "$CHROME_DATA_DIR/$profile_dir"/Sessions/Session_* "$CHROME_DATA_DIR/$profile_dir"/Sessions/Tabs_*; do
    [ -f "$session_file" ] || continue
    if /usr/bin/strings "$session_file" | /usr/bin/grep -Fq -- "$url"; then
      return 0
    fi
  done
  return 1
}

profile_candidates() {
  local active_url="$1"
  local all_urls="$2"
  local profile_dir
  local url
  local old_ifs="$IFS"
  local -a urls
  IFS=$'\037' read -r -a urls <<< "$all_urls"
  IFS="$old_ifs"

  for profile_dir in "$CHROME_DEFAULT_PROFILE_DIR" "$CHROME_PROFILE_4_DIR"; do
    if profile_has_url "$profile_dir" "$active_url"; then
      printf '%s\n' "$profile_dir"
      continue
    fi
    for url in "${urls[@]}"; do
      if profile_has_url "$profile_dir" "$url"; then
        printf '%s\n' "$profile_dir"
        break
      fi
    done
  done
}

hint_workspace() {
  local all_urls="$1"
  if printf '%s' "$all_urls" | tr '\037' '\n' | /usr/bin/grep -Eiq -- "$DEFAULT_WORKSPACE_1_HINTS"; then
    printf '1\n'
  fi
  if printf '%s' "$all_urls" | tr '\037' '\n' | /usr/bin/grep -Eiq -- "$DEFAULT_WORKSPACE_2_HINTS"; then
    printf '2\n'
  fi
}

single_candidate() {
  local candidates="$1"
  local candidate
  local found=""
  while IFS= read -r candidate; do
    [ -n "$candidate" ] || continue
    [ -z "$found" ] || return 1
    found="$candidate"
  done <<< "$candidates"
  [ -n "$found" ] || return 1
  printf '%s\n' "$found"
}

unique_chrome_window_id() {
  local window_name="$1"
  local expected_workspace="${2:-}"
  local ids
  local workspace_ids

  ids=$(chrome_window_ids_for_title "$window_name")
  if [ -n "$expected_workspace" ]; then
    workspace_ids=$(awk -F '\t' -v workspace="$expected_workspace" -v ids="$ids" \
      'BEGIN {
        count = split(ids, values, "\\n")
        for (i = 1; i <= count; i++) {
          wanted[values[i]] = 1
        }
      }
      $3 == workspace && wanted[$1] { print $1 }' "$windows_file")
    if single_candidate "$workspace_ids"; then
      return 0
    fi
  fi

  single_candidate "$ids" || true
}

chrome_window_ids_for_title() {
  local window_name="$1"
  awk -F '\t' -v app="$CHROME_APP_BUNDLE_ID" -v title="$window_name" \
    '
      function title_matches(aerospace_title, chrome_title, prefix) {
        # Chrome can abbreviate the AppleScript window name with an ellipsis
        # while AeroSpace still sees the full native window title.
        if (index(chrome_title, "…") > 0) {
          prefix = substr(chrome_title, 1, index(chrome_title, "…") - 1)
          if (length(prefix) >= 16 && index(aerospace_title, prefix) == 1) {
            return 1
          }
        }
        return aerospace_title == chrome_title ||
          index(aerospace_title, chrome_title " - Google Chrome") == 1 ||
          index(aerospace_title, chrome_title " 🔊 - Google Chrome") == 1 ||
          (index(aerospace_title, chrome_title) == 1 &&
            index(aerospace_title, " - Google Chrome") > 0)
      }
      $2 == app && title_matches($4, title) { print $1 }
    ' "$windows_file"
}

profile_display_name() {
  /usr/bin/plutil -extract "profile.info_cache.$1.name" raw -o - \
    "$CHROME_DATA_DIR/Local State" 2>/dev/null || true
}

workspace_candidates_for_chrome_data() {
  local active_url="$1"
  local all_urls="$2"
  local normalized_urls
  local profile
  local candidate_fingerprint
  local candidate_workspace

  normalized_urls=$(normalize_urls "$all_urls")
  for profile in "$CHROME_DEFAULT_PROFILE_DIR" "$CHROME_PROFILE_4_DIR"; do
    candidate_fingerprint=$(fingerprint "$profile" "$normalized_urls")
    candidate_workspace=$(state_workspace_for_fingerprint "$profile" "$candidate_fingerprint")
    if [ -z "$candidate_workspace" ]; then
      candidate_workspace=$(state_workspace_for_active_url "$profile" "$active_url")
    fi
    if [ -n "$candidate_workspace" ]; then
      printf '%s\n' "$candidate_workspace"
    fi
  done | sort -u
}

chrome_window_ids_for_profile() {
  local window_name="$1"
  local profile="$2"
  local display_name

  display_name=$(profile_display_name "$profile")
  [ -n "$display_name" ] || return 0
  chrome_window_ids_for_title "$window_name" | while IFS= read -r window_id; do
    awk -F '\t' -v id="$window_id" -v marker="($display_name)" \
      '$1 == id && index($4, marker) > 0 { print $1 }' "$windows_file"
  done
}

profile_from_aerospace_title() {
  local aerospace_title="$1"
  local profile
  local display_name
  local marker
  local matched_profile=""

  for profile in "$CHROME_DEFAULT_PROFILE_DIR" "$CHROME_PROFILE_4_DIR"; do
    display_name=$(profile_display_name "$profile")
    [ -n "$display_name" ] || continue
    marker="($display_name)"
    case "$aerospace_title" in
      *"$marker"*)
        if [ -n "$matched_profile" ] && [ "$matched_profile" != "$profile" ]; then
          return 0
        fi
        matched_profile="$profile"
        ;;
    esac
  done

  [ -n "$matched_profile" ] && printf '%s\n' "$matched_profile"
}

append_assignment() {
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$@" >> "$assignments_file"
}

: > "$assignments_file"
: > "$pending_default_file"

# Non-Chrome applications are safe to identify by their actual Bundle ID. A
# duplicate window is treated as ambiguous and prevents the whole initial
# arrangement, rather than moving an arbitrary window.
for spec in \
  "line:$LINE_APP_BUNDLE_ID:1" \
  "discord:$DISCORD_APP_BUNDLE_ID:1" \
  "ghostty:$GHOSTTY_APP_BUNDLE_ID:2" \
  "chatgpt:$CHATGPT_APP_BUNDLE_ID:3" \
  "music:$MUSIC_APP_BUNDLE_ID:9"; do
  role=${spec%%:*}
  rest=${spec#*:}
  app=${rest%%:*}
  workspace=${rest#*:}
  count=$(app_count "$app")
  if [ "$count" -ne 1 ]; then
    log "$role has $count matching windows; leaving it untouched"
    continue
  fi
  id=$(awk -F '\t' -v app="$app" '$2 == app { print $1; exit }' "$windows_file")
  append_assignment "$role" "$id" "$workspace" "" "" "" ""
done

# Chrome AppleScript IDs are not persistent and are not the same namespace as
# AeroSpace window IDs. The move target is therefore resolved from the window
# title, and ambiguous titles are deliberately skipped.
while IFS=$'\t' read -r chrome_window_id window_name active_url tab_count all_urls pinned_mail_workspace; do
  [ -n "$window_name" ] || continue

  normalized_urls=$(normalize_urls "$all_urls")
  candidate_profiles=$(profile_candidates "$active_url" "$all_urls" | sort -u)
  state_workspaces=$(workspace_candidates_for_chrome_data "$active_url" "$all_urls")
  expected_workspace=""
  expected_workspace=$(single_candidate "$state_workspaces" || true)
  if [ -z "$expected_workspace" ] && \
    [ "$(single_candidate "$candidate_profiles" || true)" = "$CHROME_PROFILE_4_DIR" ]; then
    expected_workspace=4
  fi
  if [ -z "$expected_workspace" ]; then
    hints=$(hint_workspace "$all_urls" | sort -u || true)
    expected_workspace=$(single_candidate "$hints" || true)
  fi

  [ "$learn_current" = false ] || expected_workspace=""
  case "$pinned_mail_workspace" in
    1|2) expected_workspace="$pinned_mail_workspace" ;;
  esac
  window_id=$(unique_chrome_window_id "$window_name" "$expected_workspace" || true)
  if [ -z "$window_id" ] && \
    [ -n "$(single_candidate "$candidate_profiles" || true)" ]; then
    profile_ids=$(chrome_window_ids_for_profile "$window_name" "$candidate_profiles")
    window_id=$(single_candidate "$profile_ids" || true)
  fi
  if [ -z "$window_id" ]; then
    candidate_ids=$(chrome_window_ids_for_title "$window_name" | tr '\n' ',')
    log "Chrome title candidates are ambiguous or missing in AeroSpace: $window_name (candidates=${candidate_ids:-none}, expected_workspace=${expected_workspace:-none})"
    continue
  fi

  aerospace_title=$(awk -F '\t' -v id="$window_id" '$1 == id { print $4; exit }' "$windows_file")
  title_profile=$(profile_from_aerospace_title "$aerospace_title")

  profile=""
  workspace=""

  if [ -n "$title_profile" ]; then
    profile="$title_profile"
    if [ "$profile" = "$CHROME_PROFILE_4_DIR" ]; then
      workspace=4
    fi
  fi

  for candidate in "$CHROME_DEFAULT_PROFILE_DIR" "$CHROME_PROFILE_4_DIR"; do
    [ "$learn_current" = false ] || break
    [ -z "$profile" ] || [ "$profile" = "$candidate" ] || continue
    candidate_fingerprint=$(fingerprint "$candidate" "$normalized_urls")
    candidate_workspace=$(state_workspace_for_fingerprint "$candidate" "$candidate_fingerprint")
    if [ -z "$candidate_workspace" ]; then
      candidate_workspace=$(state_workspace_for_active_url "$candidate" "$active_url")
    fi
    if [ -n "$candidate_workspace" ]; then
      if [ -n "$profile" ] && [ "$profile" != "$candidate" ]; then
        profile=""
        workspace=""
        break
      fi
      profile="$candidate"
      workspace="$candidate_workspace"
    fi
  done

  if [ -z "$profile" ] && [ -n "$(single_candidate "$candidate_profiles" || true)" ]; then
    profile=$(single_candidate "$candidate_profiles")
    if [ "$profile" = "$CHROME_PROFILE_4_DIR" ]; then
      workspace=4
    fi
  fi

  current_workspace=$(awk -F '\t' -v id="$window_id" '$1 == id { print $3; exit }' "$windows_file")
  if [ "$learn_current" = true ]; then
    workspace=""
    case "$profile:$current_workspace" in
      "$CHROME_DEFAULT_PROFILE_DIR:1"|"$CHROME_DEFAULT_PROFILE_DIR:2"|"$CHROME_PROFILE_4_DIR:4")
        workspace="$current_workspace" ;;
    esac
  fi
  if [ "$learn_current" = false ] && [ ! -s "$state_file" ] && [ "$profile" = "$CHROME_DEFAULT_PROFILE_DIR" ] && [ -z "$workspace" ]; then
    chrome_windows_here=$(awk -F '\t' -v app="$CHROME_APP_BUNDLE_ID" -v workspace="$current_workspace" \
      '$2 == app && $3 == workspace { count++ } END { print count + 0 }' "$windows_file")
    if [ "$chrome_windows_here" -eq 1 ]; then
      case "$current_workspace" in
        1|2) workspace="$current_workspace" ;;
      esac
    fi
  fi

  if [ "$learn_current" = false ] && [ ! -s "$state_file" ] && [ "$profile" = "$CHROME_DEFAULT_PROFILE_DIR" ] && [ -z "$workspace" ]; then
    hints=$(hint_workspace "$all_urls" | sort -u || true)
    workspace=$(single_candidate "$hints" || true)
  fi

  if [ "$learn_current" = false ] && [ ! -s "$state_file" ] && [ -z "$profile" ] && [ -z "$candidate_profiles" ]; then
    hints=$(hint_workspace "$all_urls" | sort -u || true)
    if workspace=$(single_candidate "$hints"); then
      profile="$CHROME_DEFAULT_PROFILE_DIR"
      log "using configurable first-run hint for a Chrome window; profile inferred as Default"
    fi
  fi

  if [ "$learn_current" = false ]; then
    case "$pinned_mail_workspace" in
      1|2)
        profile="$CHROME_DEFAULT_PROFILE_DIR"
        workspace="$pinned_mail_workspace"
        log "matched Default Chrome window $window_id to workspace $workspace using pinned mail tabs"
        ;;
      *)
        if [ "$profile" = "$CHROME_DEFAULT_PROFILE_DIR" ]; then
          log "pinned-mail rule is unresolved for Default Chrome window $window_id; refusing saved-state fallback"
          continue
        fi
        ;;
    esac
  fi

  if [ -z "$profile" ] || [ -z "$workspace" ]; then
    if [ "$profile" = "$CHROME_DEFAULT_PROFILE_DIR" ] && [ -z "$workspace" ]; then
      profile_fingerprint=$(fingerprint "$profile" "$normalized_urls")
      printf '%s\t%s\t%s\t%s\n' "$window_id" "$profile_fingerprint" "$active_url" "$normalized_urls" >> "$pending_default_file"
    fi
    log "Chrome window could not be identified safely: $window_name"
    continue
  fi

  case "$profile:$workspace" in
    "$CHROME_DEFAULT_PROFILE_DIR:1") role=chrome-default-1 ;;
    "$CHROME_DEFAULT_PROFILE_DIR:2") role=chrome-default-2 ;;
    "$CHROME_PROFILE_4_DIR:4") role=chrome-profile-4 ;;
    *) log "unexpected Chrome assignment for $window_name"; continue ;;
  esac
  profile_fingerprint=$(fingerprint "$profile" "$normalized_urls")
  append_assignment "$role" "$window_id" "$workspace" "$profile" "$profile_fingerprint" "$active_url" "$normalized_urls"
done < "$inspection_file"

# When one of exactly two Default windows is known, the other can be assigned
# by elimination. Require Profile 4 to be resolved as well, so an unrelated
# Chrome window cannot be mistaken for the remaining Default window.
if [ "$learn_current" = false ] && [ "$(app_count "$CHROME_APP_BUNDLE_ID")" -eq 3 ] && \
  [ "$(wc -l < "$pending_default_file" | tr -d ' ')" -eq 1 ] && \
  [ "$(awk -F '\t' '$1 == "chrome-profile-4" { count++ } END { print count + 0 }' "$assignments_file")" -eq 1 ]; then
  assigned_default=$(awk -F '\t' '$1 == "chrome-default-1" || $1 == "chrome-default-2" { print $1 }' "$assignments_file")
  case "$assigned_default" in
    chrome-default-1) remaining_role=chrome-default-2; remaining_workspace=2 ;;
    chrome-default-2) remaining_role=chrome-default-1; remaining_workspace=1 ;;
    *) remaining_role="" ;;
  esac
  if [ -n "$remaining_role" ]; then
    IFS=$'\t' read -r pending_id pending_fingerprint pending_url pending_urls < "$pending_default_file"
    append_assignment "$remaining_role" "$pending_id" "$remaining_workspace" \
      "$CHROME_DEFAULT_PROFILE_DIR" "$pending_fingerprint" "$pending_url" "$pending_urls"
    log "assigned remaining Default Chrome window to workspace $remaining_workspace by elimination"
  fi
fi

for role in chrome-default-1 chrome-default-2 chrome-profile-4 line discord ghostty chatgpt music; do
  if [ "$(awk -F '\t' -v role="$role" '$1 == role { count++ } END { print count + 0 }' "$assignments_file")" -ne 1 ]; then
    log "required role is unresolved: $role"
    exit 1
  fi
done

if [ "$learn_current" = false ] && ! "$script_dir/arrange-workspaces.sh" "$assignments_file"; then
  log "AeroSpace arrangement failed; state was not updated"
  exit 1
fi

state_tmp="$tmp_dir/chrome-windows.tsv"
: > "$state_tmp"
if [ "$learn_current" = true ] && [ -f "$state_file" ]; then
  cp -p "$state_file" "$state_file.before-learn-$(date '+%Y%m%d%H%M%S')"
fi
if [ "$learn_current" = false ] && [ -f "$state_file" ]; then
  while IFS= read -r state_line; do
    [ -n "$state_line" ] || continue
    state_profile=$(printf '%s\n' "$state_line" | awk -F '\t' '{ print $1 }')
    state_fingerprint=$(printf '%s\n' "$state_line" | awk -F '\t' '{ print $3 }')
    if ! awk -F '\t' -v profile="$state_profile" -v fingerprint="$state_fingerprint" \
      '$4 == profile && $5 == fingerprint { found = 1 } END { exit found ? 0 : 1 }' "$assignments_file"; then
      printf '%s\n' "$state_line" >> "$state_tmp"
    fi
  done < "$state_file"
fi
while IFS=$'\t' read -r role window_id workspace profile profile_fingerprint active_url normalized_urls; do
  [ -n "$profile" ] || continue
  printf '%s\t%s\t%s\t%s\t%s\n' "$profile" "$workspace" "$profile_fingerprint" "$active_url" "$normalized_urls" >> "$state_tmp"
done < "$assignments_file"
chmod 600 "$state_tmp"
mv "$state_tmp" "$state_file"
if [ "$learn_current" = true ]; then
  log "learned current Chrome workspace mapping without rearranging windows"
else
  log "Chrome window mapping and workspace arrangement completed"
fi
