#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="${WEB_LIBRARY_SUBTREE_PREFIX:-app/web-library-upstream}"
REMOTE_URL="${WEB_LIBRARY_REMOTE_URL:-https://github.com/zotero/web-library.git}"
REMOTE_REF="${WEB_LIBRARY_REMOTE_REF:-master}"
TRACK_FILE="${WEB_LIBRARY_TRACK_FILE:-WEB_LIBRARY_UPSTREAM_COMMIT}"

cd "$REPO_ROOT"

if [ ! -d ".git" ]; then
  echo "This script must be run from within a git repository." >&2
  exit 1
fi

if [ ! -d "$PREFIX" ]; then
  echo "Subtree prefix '$PREFIX' does not exist yet."
  echo "To add it for the first time, run something like:"
  echo "  git subtree add --prefix=$PREFIX $REMOTE_URL $REMOTE_REF --squash"
  exit 1
fi

echo "Pulling latest $REMOTE_REF from $REMOTE_URL into subtree at $PREFIX..."
git subtree pull --prefix="$PREFIX" "$REMOTE_URL" "$REMOTE_REF" --squash

echo "Recording current upstream commit to $TRACK_FILE..."
UPSTREAM_COMMIT="$(git -C "$PREFIX" rev-parse HEAD)"
echo "$UPSTREAM_COMMIT" > "$TRACK_FILE"

echo "Done. Current Web Library upstream commit: $UPSTREAM_COMMIT"
