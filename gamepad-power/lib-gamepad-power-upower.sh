
### BEGIN IMPLEMENTATION

# FIXME we should detect gamepads and whitelist them, not blacklist other devices!
EXCLUDED_DEVICES=$(cat <<EOF
/org/freedesktop/UPower/devices/line_power_AC
/org/freedesktop/UPower/devices/battery_BAT0
/org/freedesktop/UPower/devices/DisplayDevice
EOF
)

upower_path=$(which upower)

install_upower() {
  die "upower not found"
}

# uses upower to monitor events. Outputs device changed
upower_monitor_events() {
  #cat test/enumeration.out
  while read -r line; do
    echo "$line" | grep -q 'Monitoring activity from the power daemon' && continue

    event="$(echo "$line" | awk '{print $3}' | tr -d ':')"
    device="$(echo "$line" | awk '{print $4}')"
    echo "$device|$event"
  done < <($upower_path -m)
}

upower_get_device_info() {
  #cat test/ps4controller.out
  "$upower_path" -i "$1"
}

### END IMPLEMENTATION

### BEGIN INTERFACE

check_prereqs() {
    if [[ -z "${upower_path}" ]]; then
        install_upower
    fi
}

monitor_events() {
  upower_monitor_events
}

is_device_excluded() {
  grep -q -F -x -- "$1" <<<"$EXCLUDED_DEVICES"
}

get_device_info() {
  upower_get_device_info "$1"
}

## END INTERFACE
