
### BEGIN IMPLEMENTATION

udevadm_path=$(which udevadm)

install_udev() {
  die "udev not found"
}

last_device_state="$(mktemp --tmpdir gpp_devices_last.XXXXX)"
current_device_state="$(mktemp --tmpdir gpp_devices_current.XXXXX)"

cleanup() {
  rm -f "$current_device_state" "$last_device_state"
}

trap cleanup EXIT

_state_add_device() {
  local device_path="$1"
  grep -F -q -x "$device_path" < "$current_device_state" || echo "$device_path" >>"$current_device_state"

  if grep -F -q -x "$device_path" < "$last_device_state"; then
    echo "changed"
  else
    echo "added"
  fi
}

sysfs_monitor_events() {
  while true; do
    while read -r js_dev; do
      js_devpath="$(udevadm info --query=all --json=pretty --name="$js_dev" | jq -r .DEVPATH)"
      js_syspath="/sys${js_devpath}"

      if [[ -d "${js_syspath}/../../../power_supply" ]]; then
        state="$(_state_add_device "$js_syspath")"
        echo "${js_syspath}|$state"
      fi

    done < <(find /dev -name "js*")

    # handle disappeared devices
    while read -r js_syspath; do
      echo "${js_syspath}|removed"
    # this will output lines that are present in the last state file that are not in the current state file
    done < <(join -v 2 <(sort "$current_device_state") <(sort "$last_device_state"))

    cp "$current_device_state" "$last_device_state"
    truncate -s0 "$current_device_state"

    sleep 10s
  done
}

sysfs_get_device_info() {
  device_name="$(cat "${1}/device/name")"
  power_supply_path="$(find "${1}/../../../power_supply" -mindepth 1 -maxdepth 1 -type d -exec realpath "{}" \; | head -n1)"
  power_state="$(awk '{print tolower($0)}' < "$power_supply_path/status")"
  charge_state="$(cat "$power_supply_path/capacity")"

  echo "model: $device_name"
  echo "state: $power_state"
  echo "percentage: $charge_state"
}

### END IMPLEMENTATION

### BEGIN INTERFACE

check_prereqs() {
    if [[ -z "${udevadm_path}" ]]; then
        install_udev
    fi
}

monitor_events() {
  sysfs_monitor_events
}

is_device_excluded() {
  false
}

get_device_info() {
  sysfs_get_device_info "$1"
}

## END INTERFACE
