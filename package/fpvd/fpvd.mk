################################################################################
#
# fpvd
#
################################################################################

FPVD_VERSION = 9c28e219a07689952d30e359234856f0c1078e8f
FPVD_SITE = $(call github,gilankpam,fpvd,$(FPVD_VERSION))
FPVD_LICENSE = MIT

# The C++ project (and its CMakeLists.txt) live under drone/ in the repo.
FPVD_SUBDIR = drone

FPVD_SUPPORTS_IN_SOURCE_BUILD = NO

# CMakeLists.txt owns the install rules (fpvd binary, radio-up.sh, radio-tune.sh,
# S99fpvd, defaults.json -> /rom), so let the default cmake-package install run.
# Tests are gated behind NOT CMAKE_CROSSCOMPILING, so they are skipped here.

# probe-feeder is a standalone static C binary that fpvd execs at runtime
# (/usr/libexec/fpvd/probe-feeder, see drone/src/daemon.cpp). It is not a CMake
# target, so build and install it ourselves.
define FPVD_BUILD_PROBE_FEEDER
	$(TARGET_CC) -static -Os -o $(FPVD_BUILDDIR)/probe-feeder \
		$(FPVD_SRCDIR)/src/probe/feeder.c
endef
FPVD_POST_BUILD_HOOKS += FPVD_BUILD_PROBE_FEEDER

define FPVD_INSTALL_PROBE_FEEDER
	$(INSTALL) -D -m 0755 $(FPVD_BUILDDIR)/probe-feeder \
		$(TARGET_DIR)/usr/libexec/fpvd/probe-feeder
endef
FPVD_POST_INSTALL_TARGET_HOOKS += FPVD_INSTALL_PROBE_FEEDER

$(eval $(cmake-package))
