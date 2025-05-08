# Game center tools

This repository contains some opinionated scripts that I wrote for my specific purposes:

* headless Linux gaming system streamed to my TV set via [Sunshine](https://app.lizardbyte.dev/Sunshine/)/[Moonlight](https://moonlight-stream.org/)
* no keyboard, only a Bluetooth gamepad connected directly to the gaming system OR a gamepad connected to the client and
  forwarded via USB/IP
* XFCE desktop environment
* Steam Big Picture as main UI

## Gamepad battery notifications (`gamepad-power`)

Dependencies: `notify-send`, `udev`, mounted sysfs on `/sys`

A little systemd service that monitors battery-powered gamepads and sends notifications when the battery charge changes.
Notifications are sent using `notify-send` which must be installed on the system. Battery status detection requires a
mounted sysfs in `/sys` and `udev` running.

Run `make && sudo make install` to install the shell scripts and a systemd unit for the user daemon. After that, enable it:

```shell
systemctl --user enable --now gamepad-power.service
```

Note that in order to start the service automatically at login time you need a desktop environment that supports systemd
and `graphical-session.target` (XFCE is **not** one of them, I had to make it work in some other way). You can also
start `/usr/local/bin/gamepad-power` in whatever way you prefer.

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

Note that in order to start the service automatically at login time you need a desktop environment that supports systemd
and `graphical-session.target` (XFCE is **not** one of them, I had to make it work in some other way). You can also
start `/usr/local/bin/steam-compat-updater` in whatever way you prefer. This script is not a daemon and just runs once,
does the upgrades, then exits - it is intended to be run once at system startup.

## Moonlight USB/IP integration

Dependencies: `notify-send` (client only), Polkit (client only), `usbip`

This is a set of systemd units, configuration files and script that somewhat integrates Moonlight
with [USB/IP](https://wiki.archlinux.org/title/USB/IP), which is basically a tool to "forward" USB devices through the network to another host. This has the
advantage that **games will see the controller as if it's attached directly to the gaming system** and will be able to
use all its features - something that can't be done with the built-in Sunshine/Moonlight emulation.

Heavily inspired by the USB/IP Arch wiki page, I tried to streamline the process as much as I could, automating almost
everything. The idea is this:

* connect a controller to your Moonlight system
* start Moonlight via a wrapper script
* start a service on the server (Sunshine) system to attach the controller

### On the Moonlight system (streaming client)

Configuration files exist for the DualShock 4 and DualSense controllers.

Run `make && sudo make install` to install everything. After that, you can start Moonlight via the wrapper script
`moonlight-usbip` or via application shortcut "Moonlight USB/IP".

The wrapper script will:

* start the `usbip` daemon and try to bind both the DS4 and the DS5 (whatever it will find connected)
* start Moonlight
* stop `usbip` when Moonlight quits

Privileged operations (e.g. start `usbip`) will use `systemctl` and should work out-of-the-box if Polkit is installed.

### On the gaming system (streaming server, e.g. Sunshine)

Configure the host of your streaming client in all files inside `moonlight-usbip/server/remote-devices`: set the
`USBIP_HOST` variable.

Run `make && sudo make install` to install everything.

> [!NOTE]
> The following command may be configured in Sunshine as preparation steps: the `start` command for the "Do" (mandatory), the `stop` command for the "Undo" (optional).
> This way the system will be completely automated, as long as you connect the controller before starting Moonlight.

Execute this command **after starting Moonlight**:

```shell
systemctl start usbip@CONTROLLER.service
```

Replace `CONTROLLER` with:

* `ds4` if you have a DualShock 4 controller
* `ds5` if you have a DualSense controller

Privileged operations (i.e. systemctl) should work out-of-the-box if Polkit is installed.
