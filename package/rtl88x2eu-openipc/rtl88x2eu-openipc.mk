################################################################################
#
# rtl88x2eu-openipc
#
################################################################################

RTL88X2EU_OPENIPC_SITE = $(call github,gilankpam,rtl88x2eu-20230815,$(RTL88X2EU_OPENIPC_VERSION))
RTL88X2EU_OPENIPC_VERSION = 0bf8557b4eeb0cc29724faa6ae77e8bf7ddbc422

RTL88X2EU_OPENIPC_LICENSE = GPL-2.0
RTL88X2EU_OPENIPC_LICENSE_FILES = COPYING

RTL88X2EU_OPENIPC_MODULE_MAKE_OPTS = CONFIG_RTL8822EU=m \
	KVER=$(LINUX_VERSION_PROBED) \
	KSRC=$(LINUX_DIR) \
	USER_EXTRA_CFLAGS=-DCONFIG_BEAMFORMING_MONITOR

$(eval $(kernel-module))
$(eval $(generic-package))
