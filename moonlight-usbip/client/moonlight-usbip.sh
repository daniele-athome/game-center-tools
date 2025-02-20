#!/bin/bash

MOONLIGHT_BIN="$(which moonlight || which moonlight-qt)"
USBIP_DEVICES_PATH="/etc/usbip/bind-devices"

start_and_check() {
  if systemctl is-active --quiet "$1"; then
    return 0
  fi

  systemctl start "$1" &&
  sleep 1s &&
  systemctl is-active --quiet "$1"
}

notify() {
  notify-send -i "${3:-moonlight}" -u "${4:-normal}" "${2:-Moonlight USB/IP}" "$1"
}


if ! start_and_check usbipd.service; then
  notify "Failed to start usbipd. Controllers will not work."
else
  find "$USBIP_DEVICES_PATH" -type f -name '*.conf' | while read -r line; do
    bind_name="$(basename "$line" .conf)"
    start_and_check "usbip-bind@$bind_name.service" || notify "Failed to bind controller $bind_name."
  done
fi

"$MOONLIGHT_BIN" "$@"

systemctl stop usbipd.service

find "$USBIP_DEVICES_PATH" -type f -name '*.conf' | while read -r line; do
  bind_name="$(basename "$line" .conf)"
  systemctl stop "usbip-bind@$bind_name.service"
done
