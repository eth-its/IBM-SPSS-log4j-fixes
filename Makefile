CURDIR := $(shell pwd)
DEPNOTIFY_URL := "https://files.nomad.menu/DEPNotify.zip"
DEPNOTIFY_ZIPPATH := $(CURDIR)/DEPNotify.zip
MUNKIPKG := /usr/local/bin/munkipkg
PKG_ROOT := $(CURDIR)/pkg/erase-install/payload
PKG_BUILD := $(CURDIR)/pkg/erase-install/build
PKG_VERSION := $(shell defaults read $(CURDIR)/pkg/erase-install/build-info.plist version)


all: build

.PHONY : build
build: 
	@echo "Copying erase-install.sh into /Library/Management/erase-install"
	mkdir -p "$(PKG_ROOT)/Library/Management/erase-install"
	cp "$(CURDIR)/erase-install.sh" "$(PKG_ROOT)/Library/Management/erase-install/erase-install.sh"
	chmod 755 "$(PKG_ROOT)/Library/Management/erase-install/erase-install.sh"

	@echo "Copying installinstallmacos.py into /Library/Management/erase-install"
	cp "$(CURDIR)/../macadmin-scripts/installinstallmacos.py" "$(PKG_ROOT)/Library/Management/erase-install/installinstallmacos.py"

	@echo "Installing Python into /Library/Management/erase-install"
	"$(PYTHON_INSTALLER_SCRIPT)" --destination "$(PKG_ROOT)/Library/Management/erase-install/" --python-version=$(PYTHON_VERSION) --pip-requirements="$(PYTHON_REQUIREMENTS)"

	@echo "Downloading and extracting DEPNotify.app into /Applications/Utilities"
	mkdir -p "$(PKG_ROOT)/Applications/Utilities"
	curl -L "$(DEPNOTIFY_URL)" -o "$(DEPNOTIFY_ZIPPATH)"
	unzip -o "$(DEPNOTIFY_ZIPPATH)" -d "$(PKG_ROOT)/Applications/Utilities"
	chmod -R 755 "$(PKG_ROOT)/Applications/Utilities"
	rm -Rf "$(PKG_ROOT)/Applications/Utilities/__MACOSX"

	@echo "Making package in $(PKG_BUILD_DEPNOTIFY) directory"
	cd $(CURDIR)/pkg && $(MUNKIPKG) erase-install-depnotify
	open $(PKG_BUILD_DEPNOTIFY)



.PHONY : clean
clean :
	@echo "Cleaning up package root"
	rm -Rf "$(PKG_ROOT)/Library/Management/erase-install/"* ||:
	rm -Rf "$(PKG_ROOT)/Applications/Utilities/"* ||:
	rm $(CURDIR)/pkg/erase-install/build/*.pkg ||:
	rm $(CURDIR)/pkg/erase-install-nopython/build/*.pkg ||:
	rm $(CURDIR)/pkg/erase-install-depnotify/build/*.pkg ||:
