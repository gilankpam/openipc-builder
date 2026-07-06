################################################################################
#
# fpvd
#
################################################################################

# NOTE: glyph-OSD HEAD of feat/glyph-osd (PR #32). The bundled UbuntuMono Nerd
# Font below is only useful with a fpvd binary that emits the glyph column;
# rebump to the main merge commit once PR #32 lands.
FPVD_VERSION = 01b7425fe13848f343302c12a10dffa71fd985d3
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

define FPVD_INSTALL_FILES
	$(INSTALL) -D -m 0644 $(FPVD_PKGDIR)/files/config.json \
		$(TARGET_DIR)/etc/fpvd/config.json
	$(INSTALL) -D -m 0644 $(FPVD_PKGDIR)/files/imx415_greg_fpvXIX_colortrans.bin \
		$(TARGET_DIR)/etc/sensors/imx415_greg_fpvXIX_colortrans.bin
	# OSD glyph font: msposd loads this fixed path; the Nerd-Font-patched
	# (monospaced) UbuntuMono gives the OSD its icon glyphs.
	$(INSTALL) -D -m 0644 $(FPVD_PKGDIR)/files/UbuntuMono-Regular.ttf \
		$(TARGET_DIR)/usr/share/fonts/truetype/UbuntuMono-Regular.ttf
endef
FPVD_POST_INSTALL_TARGET_HOOKS += FPVD_INSTALL_FILES

$(eval $(cmake-package))
