################################################################################
#
# mabur
#
################################################################################

MABUR_VERSION = 641bdeded57cf42304fc97283ea18ddbb216bc7c
MABUR_SITE = https://github.com/gilankpam/mabur
MABUR_SITE_METHOD = git
MABUR_GIT_SUBMODULES = YES
MABUR_LICENSE = MIT
MABUR_DEPENDENCIES = libusb host-pkgconf
MABUR_SUPPORTS_IN_SOURCE_BUILD = NO

# BUILD_SHARED_LIBS=OFF: devourer's add_library(devourer ...) has no explicit
# STATIC/SHARED, so it follows BUILD_SHARED_LIBS. Buildroot defaults that ON,
# which built libdevourer.so — but the recipe installs only maburd, so on target
# maburd died with "error while loading shared libraries: libdevourer.so".
# Forcing it OFF links devourer (and mabur_common) statically into maburd, the
# same self-contained layout tools/build-arm.sh produces; the only remaining
# runtime deps are Buildroot's own libusb/libstdc++/libc, which are on the image.
# DEVOURER_LOG_MAX_LEVEL=WARN: compile out info/debug/trace. devourer logs one
# info line per TX frame ("bulk_send EP 5 OK N bytes"); at maburd's frame rate
# that floods RAM-backed /tmp/mabur.log until the next respawn truncates it.
# tools/build-arm.sh sets the same floor for the standalone static binary.
MABUR_CONF_OPTS = \
	-DDEVOURER_DIR=$(@D)/third_party/devourer \
	-DMABUR_BUILD_TESTS=OFF \
	-DMABUR_BUILD_DRONE=ON \
	-DBUILD_SHARED_LIBS=OFF \
	-DDEVOURER_LOG_MAX_LEVEL=WARN

define MABUR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(MABUR_BUILDDIR)/drone/maburd $(TARGET_DIR)/usr/bin/maburd
	$(INSTALL) -D -m 0755 $(@D)/bundle/S96mabur $(TARGET_DIR)/etc/init.d/S96mabur
	$(INSTALL) -D -m 0644 $(@D)/bundle/mabur.default.json $(TARGET_DIR)/etc/mabur.json
endef

$(eval $(cmake-package))
