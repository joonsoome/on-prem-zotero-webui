## 1. Container images
- [x] 1.1 Add/build Dockerfile for PDF proxy with production-ready entrypoint and tag defaults.
- [x] 1.2 Ensure Web Library image tagging fits GHCR conventions; align compose defaults to use tagged images via env (e.g., `WEB_LIBRARY_IMAGE`).
- [x] 1.3 Add .dockerignore as needed to keep build context lean and avoid leaking repo artifacts.

## 2. GHCR publishing workflow
- [x] 2.1 Create GitHub Actions workflow that logs into GHCR with `GITHUB_TOKEN` and builds/pushes both images on pushes to `main` and tags.
- [x] 2.2 Include branch/SHA tags and `latest`/`main` tags; document registry names (e.g., `ghcr.io/<owner>/on-prem-zotero-webui/pdf-proxy`).
- [x] 2.3 Document required repo secrets/permissions (packages:write) and how to trigger manual builds if needed.

## 3. Portainer/Synology deployment
- [x] 3.1 Add Portainer-friendly compose stack (Synology paths/ports/env) using GHCR images; include sample env file.
- [x] 3.2 Document how to deploy/update the stack in Portainer, including GHCR registry credentials.
- [x] 3.3 Provide notes for volume mounts (`/volume1/Reference/zotero` → `/data/zotero`) and optional reverse proxy ports.

## 4. Docs & AGENTS
- [x] 4.1 Update `README-draft.md` (roadmap + deployment instructions) and any relevant docs to reflect GHCR + Portainer flow.
- [x] 4.2 If deployment workflow expectations change, add a brief reminder to `AGENTS.md`.

## 5. Validation
- [x] 5.1 Run `openspec validate add-ghcr-portainer-deploy --strict` and ensure new deltas are clean.

## 6. Portainer staging (mcphub-driven)
- [ ] 6.1 Use the configured Portainer tool (via mcphub) to deploy the GHCR images to the staging stack.
- [ ] 6.2 Capture stack status/health after deployment (proxy + web library up, ports responding) and note the deployed tags.
- [x] 6.3 Tag policy recorded: local dev builds use `:dev`; staging/Portainer defaults pinned to `:v0.1.1` (override to `:main`/`:latest` as needed).
