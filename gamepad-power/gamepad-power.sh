#!/usr/bin/env bash
# Daemon that monitors power of wireless gamepads.
# Needs upower or sysfs (choose implementation in source directives below).

# charge status less or equal than this value will be notified as low battery
LOW_BATTERY_THRESHOLD=15

# for gettext
# shellcheck disable=SC2034
TEXTDOMAIN=gamepad-power
# shellcheck disable=SC2034
TEXTDOMAINDIR=/usr/local/share/locale

set -eo pipefail
declare -A LAST_STATUS

notify() {
  notify-send -i "${3:-battery}" -u "${4:-normal}" "${2:-Battery notifications}" "$1"
}

die() {
  notify "$@"
  exit 1
}

# implementation to be used - keep one line uncommented only
# see lib-gamepad-power-interface.sh for abstract functions to be implemented
source /usr/local/lib/gamepad-power/lib-sysfs.sh || source "$(dirname "$0")/lib-gamepad-power-sysfs.sh"
#source /usr/local/lib/gamepad-power/lib-upower.sh || source "$(dirname "$0")/lib-gamepad-power-upower.sh"

get_device_name() {
  grep "model: " | awk -F':' '{print $2}' | sed 's/^\s*\|\s*$//g'
}

get_charging_status() {
  grep "state: " | awk -F':' '{print $2}' | sed 's/^\s*\|\s*$//g'
}

get_charging_status_sysfs() {
  native_path="$(grep "native-path: " | awk -F'native-path:' '{print $2}' | sed 's/^\s*\|\s*$//g')"
  grep "POWER_SUPPLY_STATUS=" "/sys/class/power_supply/$native_path/uevent" | awk -F'=' '{print tolower($2)}'
}

get_battery_status() {
  grep "percentage: " | awk '{print $2}' | tr -d '%'
}

notify_fully_charged() {
  notify $"Notification: Battery charged" "$1"
}

notify_charging() {
  # shellcheck disable=SC2182
  notify "$(printf $"Notification: Battery charging" "$2")" "$1"
}

notify_discharging() {
  # shellcheck disable=SC2182
  notify "$(printf $"Notification: Battery discharging" "$2")" "$1"
}

notify_low_battery() {
  # shellcheck disable=SC2182
  notify "$(printf $"Notification: Battery low" "$2")" "$1" "battery-caution"
}

check_prereqs

while read -r line; do
  #echo "### $line"

  device="$(echo "$line" | awk -F'|' '{print $1}')"
  event="$(echo "$line" | awk -F'|' '{print $2}')"
  #echo "event: $event, device: $device"
  if is_device_excluded "$device"; then
    continue
  fi

  if [[ "$event" == "removed" ]]; then
    LAST_STATUS["$device"]=""
    continue
  fi

  device_info="$(get_device_info "$device")"
  device_name="$(echo "$device_info" | get_device_name)"
  battery_status="$(echo "$device_info" | get_battery_status)"
  charging_state="$(echo "$device_info" | get_charging_status || echo "$device_info" | get_charging_status_sysfs)"
  #echo "<$device_name>: <$battery_status> / <$charging_state>"

  if [[ "${LAST_STATUS["$device"]}" == "$charging_state:$battery_status" ]]; then
    # already notified
    continue;
  fi

  LAST_STATUS["$device"]="$charging_state:$battery_status"

  if [[ "$battery_status" == "100" ]]; then
    notify_fully_charged "$device_name"
  elif (( battery_status > LOW_BATTERY_THRESHOLD )); then
    if [[ "$charging_state" == "discharging" ]]; then
      notify_discharging "$device_name" "$battery_status"
    else
      notify_charging "$device_name" "$battery_status"
    fi
  elif (( battery_status <= LOW_BATTERY_THRESHOLD )); then
    if [[ "$charging_state" == "discharging" ]]; then
      notify_low_battery "$device_name" "$battery_status"
    else
      notify_charging "$device_name" "$battery_status"
    fi
  fi
done < <(monitor_events)
