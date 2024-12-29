.PHONY: all install uninstall

all:
	@echo "Use 'make install' or 'make uninstall'."

install:
	install -m 0644 modules-load.conf /etc/modules-load.d/usbip.conf
	install -m 0644 usbip@.service /etc/systemd/system/usbip@.service
	install -Dm 0644 -t /etc/usbip/remote-devices/ remote-devices/*
	systemctl daemon-reload

uninstall:
	rm -f /etc/modules-load.d/usbip.conf
	rm -f /etc/systemd/system/usbip@.service
	# systemd will realize at next reboot
	rm -fr /etc/usbip/remote-devices/
