.PHONY: all install uninstall

all:
	@echo "Use 'make install' or 'make uninstall'."

# TODO parametrize subdirectories

install:
	make -C gamepad-power install
	make -C steam-compat-updater install

uninstall:
	make -C gamepad-power uninstall
	make -C steam-compat-updater uninstall
