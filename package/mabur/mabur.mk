################################################################################
#
# mabur
#
################################################################################

# Tracks master HEAD rather than a fixed SHA. Same reasoning and same
# mechanics as devourer.mk: buildroot's git backend cannot check out a branch
# literally named "master" (it refuses to fetch into the branch `git init`
# already has checked out), so resolve it to a commit id here.
MABUR_SITE = https://github.com/gilankpam/mabur
MABUR_BRANCH = master
MABUR_VERSION := $(shell git ls-remote $(MABUR_SITE) refs/heads/$(MABUR_BRANCH) | cut -f1)
ifeq ($(MABUR_VERSION),)
$(error mabur: cannot resolve $(MABUR_BRANCH) at $(MABUR_SITE) (no network?))
endif
MABUR_SITE_METHOD = git
MABUR_LICENSE = MIT
MABUR_SUPPORTS_IN_SOURCE_BUILD = NO

# devourer comes from its own package, NOT from mabur's git submodule
# (MABUR_GIT_SUBMODULES is deliberately unset). The submodule records a fixed
# SHA that lags the fork's master, and the in-tree cross-build
# (tools/build-arm.sh) does not use the submodule either -- it points
# DEVOURER_DIR at a sibling checkout. Sourcing devourer separately keeps the
# buildroot build consistent with that and lets both trees float.
MABUR_DEPENDENCIES = libusb host-pkgconf devourer

# BUILD_SHARED_LIBS=OFF: devourer's add_library(devourer ...) has no explicit
# STATIC/SHARED, so it follows BUILD_SHARED_LIBS. Buildroot defaults that ON,
# which built libdevourer.so -- but the recipe installs only maburd, so on target
# maburd died with "error while loading shared libraries: libdevourer.so".
# Forcing it OFF links devourer (and mabur_common) statically into maburd, the
# same self-contained layout tools/build-arm.sh produces; the only remaining
# runtime deps are Buildroot's own libusb/libstdc++/libc, which are on the image.
# (maburd also dlopens the SigmaStar MI libraries from the vendor rootfs at
# runtime -- that is why it must stay a glibc DYNAMIC executable.)
#
# DEVOURER_LOG_MAX_LEVEL=WARN: compile out info/debug/trace. devourer logs one
# info line per TX frame ("bulk_send EP 5 OK N bytes"); at maburd's frame rate
# that floods RAM-backed /tmp/mabur.log until the next respawn truncates it.
#
# The DEVOURER_* chip selects mirror tools/build-arm.sh exactly. Without them
# every Realtek family is compiled in -- including DEVOURER_8733B, which
# defaults ON upstream and must be OFF here. Keep the two lists in step.
#
# MABUR_BUILD_GS/LINKBENCH=OFF: this is the drone image. maburgs and the bench
# harnesses are neither installed nor useful on the SSC338Q.
MABUR_CONF_OPTS = \
	-DDEVOURER_DIR=$(DEVOURER_DIR) \
	-DMABUR_BUILD_TESTS=OFF \
	-DMABUR_BUILD_DRONE=ON \
	-DMABUR_BUILD_GS=OFF \
	-DMABUR_BUILD_LINKBENCH=OFF \
	-DBUILD_SHARED_LIBS=OFF \
	-DDEVOURER_LOG_MAX_LEVEL=WARN \
	-DDEVOURER_JAGUAR1=OFF \
	-DDEVOURER_8814=OFF \
	-DDEVOURER_JAGUAR2_8822B=OFF \
	-DDEVOURER_JAGUAR2_8821C=OFF \
	-DDEVOURER_JAGUAR3_8822C=OFF \
	-DDEVOURER_JAGUAR3_8822E=ON \
	-DDEVOURER_8733B=OFF \
	-DDEVOURER_KESTREL_8852B=OFF \
	-DDEVOURER_KESTREL_8852C=OFF

# The default config is installed under whichever name the checkout ships,
# because MABUR_VERSION floats: master ships bundle/mabur.default.json today,
# while the pending TOML cutover (branch toml-config) ships
# bundle/mabur.default.toml with S96mabur's CONF= changed to match. Picking the
# file that exists keeps config, init script and binary from the same commit --
# which is the whole point, since an unknown key fails boot and the wrapper then
# respawns maburd forever at 2 s.
define MABUR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(MABUR_BUILDDIR)/drone/maburd $(TARGET_DIR)/usr/bin/maburd
	$(INSTALL) -D -m 0755 $(@D)/bundle/S96mabur $(TARGET_DIR)/etc/init.d/S96mabur
	if [ -f $(@D)/bundle/mabur.default.toml ]; then \
		$(INSTALL) -D -m 0644 $(@D)/bundle/mabur.default.toml $(TARGET_DIR)/etc/mabur.toml; \
	else \
		$(INSTALL) -D -m 0644 $(@D)/bundle/mabur.default.json $(TARGET_DIR)/etc/mabur.json; \
	fi
endef

$(eval $(cmake-package))
