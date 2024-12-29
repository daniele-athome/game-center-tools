#!/bin/bash

MOONLIGHT_BIN="$(which moonlight)"

start_and_check() {
  if systemctl is-active --quiet "$1"; then
    return 0
  fi

  # TODO avoid sudo and use GUI?
  sudo systemctl start "$1" &&
  sleep 1s &&
  systemctl is-active --quiet "$1"
}

notify() {
  notify-send -i "${3:-moonlight}" -u "${4:-normal}" "${2:-Moonlight USB/IP}" "$1"
}

start_and_check usbipd.service || notify "Failed to start usbipd. Controllers will not work."
# TODO if usbipd failed, there is no need to bind devices
start_and_check usbip-bind@ds4.service || notify "Failed to bind DualShock 4 controller."
start_and_check usbip-bind@ds5.service || notify "Failed to bind DualSense controller."

"$MOONLIGHT_BIN" "$@"

sudo systemctl stop usbipd.service
sudo systemctl stop usbip-bind@ds4.service
sudo systemctl stop usbip-bind@ds5.service
