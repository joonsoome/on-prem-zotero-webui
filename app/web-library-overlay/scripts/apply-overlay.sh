#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
UPSTREAM_DIR="$REPO_ROOT/app/web-library-upstream"
OVERLAY_DIR="$REPO_ROOT/app/web-library-overlay"
BUILD_DIR="${1:-$REPO_ROOT/app/web-library-build}"

if [ ! -d "$UPSTREAM_DIR" ]; then
  echo "Upstream subtree not found at $UPSTREAM_DIR. Run git subtree add first." >&2
  exit 1
fi

echo "Preparing build directory at $BUILD_DIR..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "Copying upstream Web Library into build directory..."
rsync -a --delete "$UPSTREAM_DIR/" "$BUILD_DIR/"

if [ -d "$OVERLAY_DIR/src" ]; then
  echo "Overlaying custom src files..."
  rsync -a "$OVERLAY_DIR/src/" "$BUILD_DIR/src/"
fi

if [ -d "$OVERLAY_DIR/config" ]; then
  echo "Copying overlay config..."
  rsync -a "$OVERLAY_DIR/config/" "$BUILD_DIR/config/"
fi

if compgen -G "$OVERLAY_DIR/patches/*.patch" > /dev/null; then
  echo "Applying overlay patches..."
  for patch in "$OVERLAY_DIR"/patches/*.patch; do
    [ -e "$patch" ] || continue
    echo "  -> $patch"
    (cd "$BUILD_DIR" && git apply --allow-empty "$patch")
  done
fi

echo "Overlay apply completed. Build the Web Library from $BUILD_DIR."
