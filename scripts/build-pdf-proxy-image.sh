#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="${PDF_PROXY_IMAGE:-ghcr.io/joonsoome/on-prem-zotero-webui/pdf-proxy:dev}"
PUSH="${PDF_PROXY_IMAGE_PUSH:-false}"

cd "$REPO_ROOT"

echo "Building PDF Proxy image..."
docker build -f Dockerfile.pdf-proxy -t "$IMAGE" .

if [ "$PUSH" = "true" ]; then
  echo "Pushing image $IMAGE ..."
  docker push "$IMAGE"
else
  echo "Skipping push. To push, set PDF_PROXY_IMAGE_PUSH=true"
fi
