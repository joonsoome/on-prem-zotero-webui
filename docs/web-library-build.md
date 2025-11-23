## Image Build & Registry

If you prefer to run the Web Library as a container (dev/staging), build the image from the combined subtree + overlay:

```bash
WEB_LIBRARY_IMAGE=zotero-web-library:dev \
scripts/build-web-library-image.sh
```

This uses `Dockerfile.web-library` at the repo root to:

- Copy `app/web-library-upstream/` + `app/web-library-overlay/` into a build dir.
- Run `npm ci && npm run build`.
- Package the `build/` output into an nginx-based image.

To push to a registry (e.g., GHCR/NAS), set `WEB_LIBRARY_IMAGE_PUSH=true` and ensure `WEB_LIBRARY_IMAGE` includes the registry prefix:

```bash
WEB_LIBRARY_IMAGE=ghcr.io/<user>/zotero-web-library:onprem-dev \
WEB_LIBRARY_IMAGE_PUSH=true \
scripts/build-web-library-image.sh
```

In `docker-compose.dev.yml`, the Web Library service consumes this image via the `WEB_LIBRARY_IMAGE` env var (default `zotero-web-library:dev`).

