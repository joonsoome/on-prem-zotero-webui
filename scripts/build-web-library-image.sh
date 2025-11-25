#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${WEB_LIBRARY_IMAGE:-ghcr.io/joonsoome/on-prem-zotero-webui/web-library:dev}"
PUSH="${WEB_LIBRARY_IMAGE_PUSH:-false}"

cd "$REPO_ROOT"

echo "Building Web Library image from subtree + overlay..."
docker build -f Dockerfile.web-library -t "$IMAGE" .

if [ "$PUSH" = "true" ]; then
  echo "Pushing image $IMAGE ..."
  docker push "$IMAGE"
else
  echo "Skipping push. To push, set WEB_LIBRARY_IMAGE_PUSH=true"
fi
