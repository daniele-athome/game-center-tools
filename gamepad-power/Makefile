.PHONY: all install uninstall

all: locale
	@echo "Use 'make install' or 'make uninstall'."

# TODO generify
locale:
	msgfmt -o locales/en.mo locales/en.po
	msgfmt -o locales/it.mo locales/it.po

install:
	install -Dm 0755 gamepad-power.sh /usr/local/bin/gamepad-power
	install -Dm 0755 lib-gamepad-power-sysfs.sh /usr/local/lib/gamepad-power/lib-sysfs.sh
	install -Dm 0755 lib-gamepad-power-upower.sh /usr/local/lib/gamepad-power/lib-upower.sh
	install -m 0644 gamepad-power.service /etc/systemd/user
	install -Dm 0644 locales/en.mo /usr/local/share/locale/en/LC_MESSAGES/gamepad-power.mo
	install -Dm 0644 locales/it.mo /usr/local/share/locale/it/LC_MESSAGES/gamepad-power.mo

uninstall:
	rm -f /usr/local/bin/gamepad-power
	rm -fr /usr/local/lib/gamepad-power
	rm -f /etc/systemd/user/gamepad-power.service
	rm -f /usr/local/share/locale/en/LC_MESSAGES/gamepad-power.mo
	rm -f /usr/local/share/locale/it/LC_MESSAGES/gamepad-power.mo
