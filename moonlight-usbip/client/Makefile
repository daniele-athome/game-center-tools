.PHONY: all install uninstall

all:
	@echo "Use 'make install' or 'make uninstall'."

install:
	# TODO desktop launcher file
	install -m 0755 moonlight-usbip.sh /usr/local/bin/moonlight-usbip
	install -m 0644 modules-load.conf /etc/modules-load.d/usbip.conf
	install -m 0644 usbipd.service /etc/systemd/system/usbipd.service
	install -m 0644 usbip-bind@.service /etc/systemd/system/usbip-bind@.service
	install -Dm 0644 -t /etc/usbip/bind-devices/ bind-devices/*
	systemctl daemon-reload
	systemctl enable --now usbipd.service

uninstall:
	rm -f /etc/modules-load.d/usbip.conf
	rm -f /etc/systemd/system/usbipd.service
	# systemd will realize at next reboot
	rm -fr /etc/usbip/bind-devices/
