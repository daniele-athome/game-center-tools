.PHONY: all install uninstall

all:
	@echo "Use 'make install' or 'make uninstall'."

install:
	install -m 0644 modules-load.conf /etc/modules-load.d/usbip.conf

uninstall:
	rm -f /etc/modules-load.d/usbip.conf
