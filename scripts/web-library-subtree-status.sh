#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${WEB_LIBRARY_SUBTREE_PREFIX:-app/web-library-upstream}"
TRACK_FILE="${WEB_LIBRARY_TRACK_FILE:-WEB_LIBRARY_UPSTREAM_COMMIT}"

cd "$REPO_ROOT"

if [ ! -d "$PREFIX" ]; then
  echo "Subtree prefix '$PREFIX' does not exist. Nothing to report." >&2
  exit 1
fi

CURRENT_HEAD="$(git -C "$PREFIX" rev-parse HEAD)"
echo "Web Library subtree path : $PREFIX"
echo "Current subtree HEAD     : $CURRENT_HEAD"

if [ -f "$TRACK_FILE" ]; then
  RECORDED="$(cat "$TRACK_FILE" | tr -d '[:space:]')"
  echo "Recorded upstream commit : $RECORDED"
  if [ "$RECORDED" != "$CURRENT_HEAD" ]; then
    echo "NOTE: subtree HEAD differs from recorded upstream commit."
  fi
else
  echo "No $TRACK_FILE found; you may want to create one after first pulling/updating the subtree."
fi

echo
echo "Local changes in subtree (if any):"
git status --short "$PREFIX" || true

