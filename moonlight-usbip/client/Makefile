.PHONY: all install uninstall

all:
	@echo "Use 'make install' or 'make uninstall'."

install:
	# no way to do this with a xdg command
	install -Dm 0644 moonlight.svg /usr/local/share/icons/hicolor/scalable/apps/moonlight
	# no way to do this with a xdg command
	install -Dm 0644 moonlight-usbip.desktop /usr/local/share/applications/moonlight-usbip.desktop
	install -m 0755 moonlight-usbip.sh /usr/local/bin/moonlight-usbip
	install -m 0644 modules-load.conf /etc/modules-load.d/usbip.conf
	install -m 0644 usbipd.service /etc/systemd/system/usbipd.service
	install -m 0644 usbip-bind@.service /etc/systemd/system/usbip-bind@.service
	install -Dm 0644 -t /etc/usbip/bind-devices/ bind-devices/*
	install -m 0644 polkit.rules /etc/polkit-1/rules.d/10-usbip-gaming.rules
	systemctl daemon-reload
	systemctl restart polkit.service

uninstall:
	rm -f /etc/modules-load.d/usbip.conf
	rm -f /etc/systemd/system/usbipd.service
	rm -f /etc/systemd/system/usbip-bind@.service
	# systemd will realize at next reboot
	rm -fr /etc/usbip/bind-devices/
	rm -f /etc/polkit-1/rules.d/10-usbip-gaming.rules
	systemctl restart polkit.service
