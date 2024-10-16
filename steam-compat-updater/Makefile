.PHONY: all install uninstall

all:
	@echo "Use 'make install' or 'make uninstall'."

install:
	install -Dm 0755 steam-compat-updater.sh /usr/local/bin/steam-compat-updater
	install -m 0644 steam-compat-updater.service /etc/systemd/user

uninstall:
	rm -f /usr/local/bin/steam-compat-updater
	rm -f /etc/systemd/user/steam-compat-updater.service
