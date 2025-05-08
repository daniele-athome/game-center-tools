.PHONY: all install uninstall

all:
	@echo "Use 'make install' or 'make uninstall'."

install:
	install -m 0644 modules-load.conf /etc/modules-load.d/usbip.conf
	install -m 0644 usbip@.service /etc/systemd/system/usbip@.service
	install -Dm 0644 -t /etc/usbip/remote-devices/ remote-devices/*
	install -m 0644 polkit.rules /etc/polkit-1/rules.d/10-usbip-gaming.rules
	systemctl daemon-reload
	systemctl restart polkit.service

uninstall:
	rm -f /etc/modules-load.d/usbip.conf
	rm -f /etc/systemd/system/usbip@.service
	# systemd will realize at next reboot
	rm -fr /etc/usbip/remote-devices/
	rm -f /etc/polkit-1/rules.d/10-usbip-gaming.rules
	systemctl restart polkit.service
