#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
config_dir=$(cd "$script_dir/.." && pwd)
source "$config_dir/config.env"
if [ -f "$config_dir/config.local" ]; then
  source "$config_dir/config.local"
fi

mkdir -p "$AEROSPACE_STATE_DIR" "$AEROSPACE_LOG_DIR"
log_file="$AEROSPACE_LOG_DIR/bootstrap.log"
boot_time=$(/usr/sbin/sysctl -n kern.boottime 2>/dev/null || true)
boot_token=$(printf '%s\n' "$boot_time" | awk '{ gsub(/[^0-9]/, ""); print }')
if [ -z "$boot_token" ]; then
  boot_token="fallback-$(date '+%Y%m%d')"
fi
marker="$AEROSPACE_STATE_DIR/session-initialized-$boot_token"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >> "$log_file"
}

force=false
if [ "${1:-}" = "--force" ]; then
  force=true
fi

if ! "$AEROSPACE_MONITOR_CHECK_SCRIPT" >/dev/null 2>&1; then
  log "external display is absent; refusing to start AeroSpace"
  exit 0
fi

if [ "$force" = false ] && [ -f "$marker" ]; then
  log "initial arrangement already completed for this login session"
  exit 0
fi

if [ ! -x "$AEROSPACE_BIN" ]; then
  log "AeroSpace CLI not found: $AEROSPACE_BIN"
  exit 1
fi

# start-at-login is intentionally false in aerospace.toml. This open call is
# the only process launch path, and open -a reuses a running app instead of
# creating a new instance.
if ! /usr/bin/open -a "$AEROSPACE_APP_NAME" >/dev/null 2>&1; then
  log "failed to open $AEROSPACE_APP_NAME"
  exit 1
fi

attempt=1
while [ "$attempt" -le "$AEROSPACE_WINDOW_RETRIES" ]; do
  if "$AEROSPACE_BIN" list-monitors --count >/dev/null 2>&1; then
    break
  fi
  if [ "$attempt" -eq "$AEROSPACE_WINDOW_RETRIES" ]; then
    log "AeroSpace server did not become ready"
    exit 1
  fi
  sleep "$AEROSPACE_WINDOW_RETRY_SECONDS"
  attempt=$((attempt + 1))
done

# Do not pass --profile-directory here: a normal Chrome launch is required so
# Chrome can restore its own previous session, including all profile windows.
for app in "Google Chrome" "LINE" "Discord" "Ghostty" "ChatGPT" "Music"; do
  if ! /usr/bin/open -a "$app" >/dev/null 2>&1; then
    log "failed to open $app"
    exit 1
  fi
done

if "$script_dir/restore-windows.sh"; then
  : > "$marker"
  log "initial arrangement completed"
  exit 0
fi

log "initial arrangement was not completed; no session marker was written"
exit 1
