#!/bin/bash
# Usage: notify BUSID

NOTIFY_CONF="${NOTIFY_CONF:-/etc/usbip/notify.conf}"

busid="$1"

# shellcheck source=/dev/null
[[ -r "$NOTIFY_CONF" ]] && source "$NOTIFY_CONF"

NOTIFY_PORT="${NOTIFY_PORT:-9955}"

if [[ -z "$NOTIFY_HOST" ]]; then
  echo "No NOTIFY_HOST set in $NOTIFY_CONF, not sending notification." >&2
  exit 0
fi

if ! printf '%s\n' "$busid" >"/dev/tcp/$NOTIFY_HOST/$NOTIFY_PORT"; then
  echo "Could not notify system at $NOTIFY_HOST:$NOTIFY_PORT." >&2
  exit 1
fi
