#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Running release checks..."

"$REPO_ROOT/scripts/check-web-library-subtree.sh"

echo
echo "TODO: add tests/linting/build checks here."
echo "Release checks completed."

