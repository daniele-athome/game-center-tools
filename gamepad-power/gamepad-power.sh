#!/usr/bin/env bash
# Daemon that monitors power of wireless gamepads.
# Needs upower or sysfs (choose implementation in source directives below).

# TODO device name should be included in notifications
# TODO i18n
TEXT_FULLY_CHARGED="Battery charged"
TEXT_CHARGING="Battery discharging: %d%%"
TEXT_DISCHARGING="Battery discharging: %d%%"
TEXT_LOW_BATTERY="Battery low: %d%%"

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
  notify "$TEXT_FULLY_CHARGED" "$1"
}

notify_charging() {
  # shellcheck disable=SC2059
  notify "$(printf "$TEXT_CHARGING" "$2")" "$1"
}

notify_discharging() {
  # shellcheck disable=SC2059
  notify "$(printf "$TEXT_DISCHARGING" "$2")" "$1"
}

notify_low_battery() {
  # shellcheck disable=SC2059
  notify "$(printf "$TEXT_LOW_BATTERY" "$2")" "$1" "battery-caution"
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
  elif (( battery_status > 10 )); then
    if [[ "$charging_state" == "discharging" ]]; then
      notify_discharging "$device_name" "$battery_status"
    else
      notify_charging "$device_name" "$battery_status"
    fi
  elif (( battery_status <= 10 )); then
    if [[ "$charging_state" == "discharging" ]]; then
      notify_low_battery "$device_name" "$battery_status"
    else
      notify_charging "$device_name" "$battery_status"
    fi
  fi
done < <(monitor_events)
