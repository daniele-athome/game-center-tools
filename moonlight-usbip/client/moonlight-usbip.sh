#!/bin/bash

MOONLIGHT_BIN="$(which moonlight || which moonlight-qt)"

start_and_check() {
  if systemctl is-active --quiet "$1"; then
    return 0
  fi

  systemctl start "$1" &&
  sleep 1s &&
  systemctl is-active --quiet "$1"
}

notify() {
  # fallback to journal
  notify-send -i "${3:-moonlight}" -u "${4:-normal}" "${2:-Moonlight USB/IP}" "$1" 2>/dev/null ||
    echo "$1" | systemd-cat -p warning
}

# shellcheck disable=SC2329
finish() {
  rm -f /tmp/usbip-autobind-enabled
  systemctl stop usbipd.service
}

if ! start_and_check usbipd.service; then
  notify "Failed to start usbipd. Controllers will not work."
else
  touch /tmp/usbip-autobind-enabled
  start_and_check usbip-rescan.service || notify "Failed to rescan controllers."
fi

trap finish QUIT TERM EXIT

"$MOONLIGHT_BIN" "$@"
status="$?"
if [[ "$status" != "0" ]]; then
  notify "Moonlight exited with status $status"
fi
exit "$status"
