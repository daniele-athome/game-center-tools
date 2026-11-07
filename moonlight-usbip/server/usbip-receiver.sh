#!/bin/bash
# Socket-activated receiver: a Moonlight client tells us the busid of a device it
# just exported via usbip, we attach it. The client is $REMOTE_ADDR, set by
# systemd for Accept=yes sockets, so there is nothing to configure here.

USBIP_BIN="$(which usbip || echo /usr/sbin/usbip)"

log() {
  echo "$1" >&2
}

if [[ -z "$REMOTE_ADDR" ]]; then
  log "No remote address: is Accept=yes set on the socket?"
  exit 1
fi

# stdin is the client connection
if ! read -r -t 5 busid; then
  log "No busid received from $REMOTE_ADDR"
  exit 1
fi

if [[ ! "$busid" =~ ^[0-9]+-[0-9]+(\.[0-9]+)*$ ]]; then
  log "Refusing invalid busid '$busid' from $REMOTE_ADDR"
  exit 1
fi

# bare minimal idempotentency
if "$USBIP_BIN" port 2>/dev/null | grep -qE "usbip://$REMOTE_ADDR:[0-9]+/$busid\$"; then
  log "Device $busid from $REMOTE_ADDR is attached already"
  exit 0
fi

if ! "$USBIP_BIN" attach -r "$REMOTE_ADDR" -b "$busid"; then
  log "Failed to attach device $busid from $REMOTE_ADDR"
  exit 1
fi

log "Attached device $busid from $REMOTE_ADDR"
