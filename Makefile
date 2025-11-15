# Makefile
# Copyright Marta Lewandowska <mlewando@redhat.com
#

VERSION := 1
RELEASE := 1
OS_DIST := $(shell rpm --eval '%{dist}')
ARCH := $(shell rpm --eval '%{_build_arch}')
VR := $(VERSION)-$(RELEASE)$(OS_DIST)
KVRA := $(VERSION)-$(RELEASE).$(ARCH)

all:

bootupd8r : bootupd8r-$(VR).src.rpm

bootupd8r-$(VERSION).tar.xz :
	@git archive --format=tar --prefix=bootupd8r-$(VERSION)/ HEAD -- \
		AB-boot.service \
		create_boot_path \
		install_bootloader \
		set_boot_entry \
		Makefile \
	| xz > $@

bootupd8r-$(VR).src.rpm : bootupd8r.spec bootupd8r-$(VERSION).tar.xz
	rpmbuild $(RPMBUILD_ARGS) -bs $<

bootupd8r-$(KVRA).rpm : bootupd8r-$(VR).src.rpm
	mock  -r "$(MOCK_ROOT_NAME)" --installdeps bootupd8r-$(VR).src.rpm --cache-alterations --no-clean --no-cleanup-after
	mock -r "$(MOCK_ROOT_NAME)" --rebuild bootupd8r-$(VR).src.rpm --no-clean

install :
	install -m 0755 -d "/usr/lib/bootloader/install_bootloader"
	install -m 0600 -d "/usr/sbin/set_boot_entry"
	install -m 0600 -d "/usr/sbin/create_boot_path"
	install -m 0600 -d "/etc/systemd/system/AB-boot.service"

clean :
	@rm -vf bootupd8r-$(VERSION).tar.xz
