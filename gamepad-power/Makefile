.PHONY: all install uninstall

all:
	@echo "Use 'make install' or 'make uninstall'."

install:
	install -Dm 0755 gamepad-power.sh /usr/local/bin/gamepad-power
	install -Dm 0755 lib-gamepad-power-sysfs.sh /usr/local/lib/gamepad-power/lib-sysfs.sh
	install -Dm 0755 lib-gamepad-power-upower.sh /usr/local/lib/gamepad-power/lib-upower.sh
	install -m 0644 gamepad-power.service /etc/systemd/user

uninstall:
	rm -f /usr/local/bin/gamepad-power
	rm -fr /usr/local/lib/gamepad-power
	rm -f /etc/systemd/user/gamepad-power.service
