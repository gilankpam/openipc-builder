#!/usr/bin/env bash
#
# Build only the wifibroadcast-ng package and copy the binaries out.
#
# Usage:
#   ./build-wfb-ng.sh [BOARD]                  # build, copy to ./wfb-ng-bin/
#   ./build-wfb-ng.sh [BOARD] root@<host>      # also scp to <host>:/usr/bin/
#
# BOARD defaults to ssc338q_fpv_openipc-urllc-aio.

set -euo pipefail

BOARD="${1:-ssc338q_fpv_openipc-urllc-aio}"
SCP_DEST="${2:-}"

BUILDER_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_PKG="$BUILDER_DIR/package/wifibroadcast-ng"
DST_PKG="$BUILDER_DIR/openipc/general/package/wifibroadcast-ng"
OUT_DIR="$BUILDER_DIR/wfb-ng-bin"
SHELL_NIX="$BUILDER_DIR/shell.nix"

if [ ! -d "$BUILDER_DIR/openipc" ]; then
    echo "error: $BUILDER_DIR/openipc does not exist — run ./builder.sh $BOARD once first" >&2
    exit 1
fi

# Re-exec inside the FHS nix-shell if we're not already in it.
if [ -z "${IN_NIX_SHELL:-}" ]; then
    echo "==> Entering nix-shell ($SHELL_NIX)"
    exec nix-shell "$SHELL_NIX" --run "IN_NIX_SHELL=1 '$0' '$BOARD' '$SCP_DEST'"
fi

echo "==> Syncing $SRC_PKG -> $DST_PKG"
mkdir -p "$DST_PKG"
cp -af "$SRC_PKG"/. "$DST_PKG"/

VERSION=$(awk -F' = ' '/^WIFIBROADCAST_NG_VERSION/ {print $2}' "$DST_PKG/wifibroadcast-ng.mk")
echo "==> Target version: $VERSION"
echo "==> Target board:   $BOARD"

cd "$BUILDER_DIR/openipc"

echo "==> make br-wifibroadcast-ng-dirclean"
make BOARD="$BOARD" br-wifibroadcast-ng-dirclean

echo "==> make br-wifibroadcast-ng"
make BOARD="$BOARD" br-wifibroadcast-ng

BUILD_DIR="$BUILDER_DIR/openipc/output/build/wifibroadcast-ng-$VERSION"
if [ ! -d "$BUILD_DIR" ]; then
    echo "error: build dir not found: $BUILD_DIR" >&2
    exit 1
fi

echo "==> Copying binaries to $OUT_DIR"
mkdir -p "$OUT_DIR"
cp -a "$BUILD_DIR"/wfb_rx "$BUILD_DIR"/wfb_tx "$BUILD_DIR"/wfb_tx_cmd "$BUILD_DIR"/wfb_tun "$OUT_DIR"/
ls -la "$OUT_DIR"

if [ -n "$SCP_DEST" ]; then
    echo "==> scp to $SCP_DEST:/usr/bin/"
    scp "$OUT_DIR"/wfb_rx "$OUT_DIR"/wfb_tx "$OUT_DIR"/wfb_tx_cmd "$OUT_DIR"/wfb_tun "$SCP_DEST":/usr/bin/
fi

echo "==> Done."
