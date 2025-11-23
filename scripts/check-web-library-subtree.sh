#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${WEB_LIBRARY_SUBTREE_PREFIX:-app/web-library-upstream}"
TRACK_FILE="${WEB_LIBRARY_TRACK_FILE:-WEB_LIBRARY_UPSTREAM_COMMIT}"

cd "$REPO_ROOT"

if [ ! -d "$PREFIX" ]; then
  echo "Web Library subtree path '$PREFIX' does not exist yet." >&2
  exit 0
fi

CURRENT_HEAD="$(git -C "$PREFIX" rev-parse HEAD)"
DIRTY_SUBTREE="$(git status --porcelain "$PREFIX" || true)"

echo "Web Library subtree check"
echo "  path          : $PREFIX"
echo "  current HEAD  : $CURRENT_HEAD"

if [ -f "$TRACK_FILE" ]; then
  RECORDED="$(cat "$TRACK_FILE" | tr -d '[:space:]')"
  echo "  recorded HEAD : $RECORDED"
  if [ "$RECORDED" != "$CURRENT_HEAD" ]; then
    echo "WARNING: subtree HEAD differs from recorded upstream commit ($TRACK_FILE)." >&2
  fi
else
  echo "  recorded HEAD : (none; $TRACK_FILE not found)"
fi

if [ -n "$DIRTY_SUBTREE" ]; then
  echo
  echo "ERROR: There are uncommitted changes in the Web Library subtree:" >&2
  echo "$DIRTY_SUBTREE" >&2
  exit 1
fi

echo
echo "Web Library subtree is clean."

