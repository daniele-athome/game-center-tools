# Game center tools

This repository contains some opinionated scripts that I wrote for my specific purposes:

* headless Linux gaming system streamed to my TV set via [Sunshine](https://app.lizardbyte.dev/Sunshine/)/[Moonlight](https://moonlight-stream.org/)
* no keyboard, only a Bluetooth gamepad
* XFCE desktop environment
* Steam Big Picture as main UI

## Gamepad battery notifications (`gamepad-power`)

Dependencies: `udev`, mounted sysfs on `/sys`

A little systemd service that monitors battery-powered gamepads and sends notifications when the battery charge changes.
Notifications are sent using `notify-send` which must be installed on the system. Battery status detection requires a
mounted sysfs in `/sys` and `udev` running.

Run `make && sudo make install` to install the shell scripts and a systemd unit for the user daemon. After that, enable it:

```shell
systemctl --user enable --now gamepad-power.service
```

Note that you need a desktop environment that supports systemd and `graphical-session.target` (XFCE is **not**
one of them). You can also start `/usr/local/bin/gamepad-power` in whatever way you prefer.

## Steam compatibility tools updater (`steam-compat-updater`)

Dependencies: `notify-send`, `curl`, `tar`, `gunzip` 

This is a script that will update Steam compatibility tools (currently only [GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom)).  
Just run it under the same user you also run Steam with and it will use desktop notifications (using `notify-send`) to
notify upgrades or errors. If no upgrades are found, no notifications are displayed.

> Please note that if Steam was running during an upgrade, it needs to be restarted to detect the upgrade.

Run `make && sudo make install` to install the shell script and a systemd unit for the user daemon. After that, enable it:

```shell
systemctl --user enable --now steam-compat-updater.service
```

Note that you need a desktop environment that supports systemd and `graphical-session.target` (XFCE is not one of them).
You can also start `/usr/local/bin/steam-compat-updater` in whatever way you prefer. This script is not a daemon and
just runs once, does the upgrades, then exits - it is intended to be run once at system startup.
