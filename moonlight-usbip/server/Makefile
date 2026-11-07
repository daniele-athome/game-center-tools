.PHONY: all install uninstall

all:
	@echo "Use 'make install' or 'make uninstall'."

install:
	install -m 0644 modules-load.conf /etc/modules-load.d/usbip.conf
	install -Dm 0755 usbip-receiver.sh /usr/local/lib/usbip/receiver
	install -m 0644 usbip-receiver.socket /etc/systemd/system/usbip-receiver.socket
	install -m 0644 usbip-receiver@.service /etc/systemd/system/usbip-receiver@.service
	systemctl daemon-reload

uninstall:
	rm -f /etc/modules-load.d/usbip.conf
	rm -fr /usr/local/lib/usbip
	rm -f /etc/systemd/system/usbip-receiver.socket
	rm -f /etc/systemd/system/usbip-receiver@.service
	# systemd will realize at next reboot
