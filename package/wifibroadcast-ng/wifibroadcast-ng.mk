################################################################################
#
# wifibroadcast-ng (overlay: SHM-input wfb_tx for waybeam_venc)
#
################################################################################

WIFIBROADCAST_NG_VERSION = ae2122c1fb70cd215bbc2e1b517b7b91f9401220
WIFIBROADCAST_NG_SITE = $(call github,svpcom,wfb-ng,$(WIFIBROADCAST_NG_VERSION))
WIFIBROADCAST_NG_LICENSE = GPL-3.0

WIFIBROADCAST_NG_DEPENDENCIES += libpcap libsodium waybeam-venc

define WIFIBROADCAST_NG_INJECT_VENC_RING
	cp $(WAYBEAM_VENC_DIR)/include/venc_ring.h $(@D)/src/venc_ring.h
	cp $(WAYBEAM_VENC_DIR)/src/venc_ring.c     $(@D)/src/venc_ring.c
	# venc_ring.h uses _Static_assert (C11, accepted as a gcc extension in
	# -std=gnu99). g++ does not recognise it in -std=gnu++11, so map it to
	# the C++ keyword via a shim before the first declaration.
	sed -i '1i #ifdef __cplusplus\n#define _Static_assert(cond, msg) static_assert(cond, msg)\n#endif' \
		$(@D)/src/venc_ring.h
endef
WIFIBROADCAST_NG_PRE_BUILD_HOOKS += WIFIBROADCAST_NG_INJECT_VENC_RING

define WIFIBROADCAST_NG_BUILD_CMDS
	$(MAKE) CC=$(TARGET_CC) CXX=$(TARGET_CXX) LDFLAGS=-s -C $(@D) all_bin
endef

define WIFIBROADCAST_NG_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -d $(TARGET_DIR)/etc
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc $(WIFIBROADCAST_NG_PKGDIR)/files/drone.key
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc $(WIFIBROADCAST_NG_PKGDIR)/files/wfb.yaml

	$(INSTALL) -m 755 -d $(TARGET_DIR)/etc/init.d
	$(INSTALL) -m 755 -t $(TARGET_DIR)/etc/init.d $(WIFIBROADCAST_NG_PKGDIR)/files/S98wifibroadcast

	$(INSTALL) -m 755 -d $(TARGET_DIR)/etc/sensors
	$(INSTALL) -m 644 -t $(TARGET_DIR)/etc/sensors $(WIFIBROADCAST_NG_PKGDIR)/sensor/*

	$(INSTALL) -m 755 -d $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 755 -t $(TARGET_DIR)/usr/bin $(@D)/wfb_rx
	$(INSTALL) -m 755 -t $(TARGET_DIR)/usr/bin $(@D)/wfb_tx
	$(INSTALL) -m 755 -t $(TARGET_DIR)/usr/bin $(@D)/wfb_tx_cmd
	$(INSTALL) -m 755 -t $(TARGET_DIR)/usr/bin $(@D)/wfb_tun
	$(INSTALL) -m 755 -t $(TARGET_DIR)/usr/bin $(WIFIBROADCAST_NG_PKGDIR)/files/wifibroadcast
endef

$(eval $(generic-package))
