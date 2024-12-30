#!/bin/bash

MOONLIGHT_BIN="$(which moonlight)"

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

# TODO enumerate devices in the configuration folders and try to bind all of them

start_and_check usbipd.service || notify "Failed to start usbipd. Controllers will not work."
# TODO if usbipd failed, there is no need to bind devices
start_and_check usbip-bind@ds4.service || notify "Failed to bind DualShock 4 controller."
start_and_check usbip-bind@ds5.service || notify "Failed to bind DualSense controller."

"$MOONLIGHT_BIN" "$@"

# TODO enumerate devices in the configuration folders and try to unbind all of them
systemctl stop \
  usbipd.service \
  usbip-bind@ds4.service \
  usbip-bind@ds5.service
