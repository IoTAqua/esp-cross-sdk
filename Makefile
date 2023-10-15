
# Directory to install toolchain to, by default inside current dir.
TOOLCHAIN = $(TOP)/xtensa-lx106-elf

.PHONY: crosstool-NG toolchain

TOP = $(PWD)
SHELL = /bin/bash
PATCH = patch -b -N
SED = gsed
VENDOR_SDK_DIR = ESP8266_NONOS_SDK

all: standalone sdk $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc
	@echo
	@echo "Xtensa toolchain is built, to use it:"
	@echo
	@echo 'export PATH=$(TOOLCHAIN)/bin:$$PATH'
	@echo
	@echo "Espressif ESP8266 SDK is installed, its libraries and headers are merged with the toolchain"
	@echo

standalone: sdk toolchain
	@chmod +w $(TOOLCHAIN)/bin
	@chmod +w $(TOOLCHAIN)/xtensa-lx106-elf/include
	@chmod +w $(TOOLCHAIN)/xtensa-lx106-elf/lib
	@echo "Installing vendor SDK headers into toolchain"
	@cp -Rf sdk/include/* $(TOOLCHAIN)/xtensa-lx106-elf/include/
	@echo "Installing vendor SDK libs into toolchain"
	@cp -Rf sdk/lib/* $(TOOLCHAIN)/xtensa-lx106-elf/lib/
	@echo "Installing vendor SDK linker scripts into toolchain sysroot"
#	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.ld | sed -e 's|0x40210000, len = 0x5C000|0x40210000, len = 0x6C000|' | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.new.1024.app1.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.new.1024.app1.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.new.1024.app2.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.new.1024.app2.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.new.2048.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.new.2048.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.new.512.app1.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.new.512.app1.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.new.512.app2.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.new.512.app2.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.old.1024.app1.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.old.1024.app1.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.old.1024.app2.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.old.1024.app2.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.old.512.app1.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.old.512.app1.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.app.v6.old.512.app2.ld | sed -e s@../ld/@@ >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.app.v6.old.512.app2.ld
	@$(SED) -e 's/\r//' sdk/ld/eagle.rom.addr.v6.ld >$(TOOLCHAIN)/xtensa-lx106-elf/lib/eagle.rom.addr.v6.ld
	@cp tools/gen_appbin.py $(TOOLCHAIN)/bin/
	@chmod +x $(TOOLCHAIN)/bin/gen_appbin.py

clean: clean-sdk
	$(MAKE) -C crosstool-NG clean MAKELEVEL=0
	-rm -f crosstool-NG/.built
	-rm -rf crosstool-NG/.build/src
	-rm -rf $(TOOLCHAIN)

clean-sdk:
	rm -f sdk

clean-sysroot:
	rm -rf $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/lib/*
	rm -rf $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/usr/include/*

toolchain $(TOOLCHAIN)/bin/xtensa-lx106-elf-gcc $(TOOLCHAIN)/xtensa-lx106-elf/sysroot/lib/libc.a: crosstool-NG/.built

crosstool-NG/.built: crosstool-NG/ct-ng
	$(MAKE) -C crosstool-NG -f ../Makefile _toolchain
	touch $@

_toolchain:
	./ct-ng xtensa-lx106-elf
	$(SED) -r -i.org s%CT_PREFIX_DIR=.*%CT_PREFIX_DIR="$(TOOLCHAIN)"% .config
	$(SED) -r -i s%CT_INSTALL_DIR_RO=y%"#"CT_INSTALL_DIR_RO=y% .config
	./ct-ng build

crosstool-NG: crosstool-NG/ct-ng

crosstool-NG/ct-ng: crosstool-NG/bootstrap
	$(MAKE) -C crosstool-NG -f ../Makefile _ct-ng

_ct-ng:
	./bootstrap
	./configure --prefix=`pwd`
	$(MAKE) MAKELEVEL=0
	$(MAKE) install MAKELEVEL=0

crosstool-NG/bootstrap:
	@echo "You cloned without --recursive, fetching submodules for you."
	git submodule update --init --recursive

$(VENDOR_SDK_DIR)/.dir:
	touch $@

sdk: $(VENDOR_SDK_DIR)/.dir
	ln -snf $(VENDOR_SDK_DIR) sdk
