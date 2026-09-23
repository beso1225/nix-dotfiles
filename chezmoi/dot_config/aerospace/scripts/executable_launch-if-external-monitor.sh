#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
config_dir=$(cd "$script_dir/.." && pwd)
source "$config_dir/config.env"
if [ -f "$config_dir/config.local" ]; then
  source "$config_dir/config.local"
fi

mkdir -p "$AEROSPACE_LOG_DIR"
log_file="$AEROSPACE_LOG_DIR/external-monitor.log"
log() {
  printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >> "$log_file"
}

attempt=1
while [ "$attempt" -le "$AEROSPACE_MONITOR_RETRIES" ]; do
  if "$AEROSPACE_MONITOR_CHECK_SCRIPT" >/dev/null 2>&1; then
    log "external display detected on attempt $attempt; starting bootstrap"
    exec "$script_dir/bootstrap.sh"
  fi

  log "no external display on attempt $attempt/$AEROSPACE_MONITOR_RETRIES"
  if [ "$attempt" -lt "$AEROSPACE_MONITOR_RETRIES" ]; then
    sleep "$AEROSPACE_MONITOR_RETRY_SECONDS"
  fi
  attempt=$((attempt + 1))
done

log "external display was not detected; AeroSpace was not started"
exit 0
