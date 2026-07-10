################################################################################
#
# mabur
#
################################################################################

MABUR_VERSION = 85f2f2aa2bff2137f0e24352ebc5880a54e3d184
MABUR_SITE = https://github.com/gilankpam/mabur
MABUR_SITE_METHOD = git
MABUR_GIT_SUBMODULES = YES
MABUR_LICENSE = MIT
MABUR_DEPENDENCIES = libusb host-pkgconf
MABUR_SUPPORTS_IN_SOURCE_BUILD = NO

MABUR_CONF_OPTS = \
	-DDEVOURER_DIR=$(@D)/third_party/devourer \
	-DMABUR_BUILD_TESTS=OFF \
	-DMABUR_BUILD_DRONE=ON

define MABUR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(MABUR_BUILDDIR)/drone/maburd $(TARGET_DIR)/usr/bin/maburd
	$(INSTALL) -D -m 0755 $(@D)/bundle/S96mabur $(TARGET_DIR)/etc/init.d/S96mabur
	$(INSTALL) -D -m 0644 $(@D)/bundle/mabur.default.json $(TARGET_DIR)/etc/mabur.json
endef

$(eval $(cmake-package))
