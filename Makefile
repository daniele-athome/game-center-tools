.PHONY: all install uninstall

# TODO parametrize subdirectories

all:
	make -C gamepad-power all
	make -C steam-compat-updater all

install:
	make -C gamepad-power install
	make -C steam-compat-updater install

uninstall:
	make -C gamepad-power uninstall
	make -C steam-compat-updater uninstall
