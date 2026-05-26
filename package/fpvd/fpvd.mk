################################################################################
#
# fpvd
#
################################################################################

FPVD_VERSION = b6f26e5b223f34392e843202fdc03b350f6a9634
FPVD_SITE = $(call github,gilankpam,fpvd,$(FPVD_VERSION))
FPVD_LICENSE = MIT
FPVD_LICENSE_FILES = LICENSE

FPVD_SUPPORTS_IN_SOURCE_BUILD = NO

define FPVD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/build/fpvd $(TARGET_DIR)/usr/bin/fpvd
	$(INSTALL) -D -m 0755 $(@D)/scripts/S99fpvd $(TARGET_DIR)/etc/init.d/S99fpvd
	$(INSTALL) -D -m 0755 $(@D)/scripts/radio-up.sh $(TARGET_DIR)/usr/libexec/fpvd/radio-up.sh
	$(INSTALL) -D -m 0644 $(@D)/etc/defaults.json $(TARGET_DIR)/rom/etc/fpvd/defaults.json
endef

$(eval $(cmake-package))
