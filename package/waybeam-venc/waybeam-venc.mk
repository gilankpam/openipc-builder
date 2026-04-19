################################################################################
#
# waybeam-venc
#
################################################################################

WAYBEAM_VENC_VERSION = c703c0ff2d95f0c163aa538769bc436aa8282ba6
WAYBEAM_VENC_SITE = https://github.com/gilankpam/waybeam_venc
WAYBEAM_VENC_SITE_METHOD = git
WAYBEAM_VENC_LICENSE = MIT
WAYBEAM_VENC_LICENSE_FILES = LICENSE

define WAYBEAM_VENC_BUILD_CMDS
	$(MAKE) -C $(@D) build \
		SOC_BUILD=star6e \
		CC_BIN=$(TARGET_CC) \
		STAR6E_CC="$(TARGET_CC)" \
		HOST_CC="$(HOSTCC)"
endef

define WAYBEAM_VENC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/out/star6e/venc $(TARGET_DIR)/usr/bin/venc
	$(INSTALL) -D -m 0755 $(WAYBEAM_VENC_PKGDIR)/files/S95venc $(TARGET_DIR)/etc/init.d/S95venc
endef

$(eval $(generic-package))
