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

Dependencies: `usbip`, Polkit (client only), `notify-send` (client only, optional) 

This is a set of systemd units, configuration files and script that somewhat integrates Moonlight
with [USB/IP](https://wiki.archlinux.org/title/USB/IP), which is basically a tool to "forward" USB devices through the network to another host. This has the
advantage that **games will see the controller as if it's attached directly to the gaming system** and will be able to
use all its features - something that can't be done with the built-in Sunshine/Moonlight emulation.

> [!NOTE]
> This integration will make your controller work only for your gaming (Sunshine) host **but not in Moonlight GUI itself**.
> This is because of USB/IP taking exclusive access to the controller. You must use another device to control the Moonlight GUI (mouse/keyboard).

Heavily inspired by the USB/IP Arch wiki page, I tried to streamline the process as much as I could, automating almost
everything. The idea is this:

* connect a controller to your Moonlight system
* the Moonlight system sends a notification to the gaming system, which attaches the controller
* start Moonlight via a wrapper script

### On the Moonlight system (streaming client)

Each device you want to bind requires a new udev rule in `udev-autobind.rules`. Rules for DualShock 4 and DualSense
controllers are provided. If you need a new one, just duplicate an existing one and edit `idVendor` and `idProduct`
accordingly.

Run `make && sudo make install` to install everything. After that, you can start Moonlight via the wrapper script
`moonlight-usbip` or via application shortcut "Moonlight USB/IP".

The wrapper script will:

* start the `usbip` daemon and try to bind anything that is configured in the udev rules (whatever it will find connected)
* start Moonlight
* stop `usbip` when Moonlight quits

Privileged operations (e.g. start `usbip`) will use `systemctl` and should work out-of-the-box if Polkit is installed.

Set `NOTIFY_HOST` in `notify.conf` to the host name or ip of your gaming system, so that it is told to attach the
controller as soon as it is bound. Leave it empty to disable the notification.

### On the gaming system (streaming server, e.g. Sunshine)

Run `make && sudo make install`, then enable the notification receiver:

```shell
systemctl enable --now usbip-receiver.socket
```

The Moonlight system will notify the gaming system to connect back to the client and attach the gamepads. You may
connect the controller whenever you like, before or during the stream.

> [!IMPORTANT]
> The receiver server is unauthenticated, so it's not safe for public exposure. Be sure to keep your system properly
> firewalled or otherwise secure.
