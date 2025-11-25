# Portainer Deployment (GHCR + Synology)

This guide covers deploying the Web Library + PDF Proxy stack to a Synology NAS via Portainer using GHCR-hosted images.

## Prerequisites
- Portainer access to the NAS (Container Manager or Docker mode).
- WebDAV data mounted on the NAS (e.g., `/volume1/Reference/zotero`) with read/write access for the container.
- GitHub username and a Personal Access Token with `read:packages` for pulling from GHCR (Portainer registry entry).
- Optional: GHCR images already published by the GitHub Actions workflow (`Publish Docker images`).

## GHCR Images
- PDF Proxy: `ghcr.io/joonsoome/on-prem-zotero-webui/pdf-proxy`
- Web Library: `ghcr.io/joonsoome/on-prem-zotero-webui/web-library`
- Tags published by CI: `latest`/`main` for the default branch, `sha-<commit>`, branch names, and git tags (`v*`).

## Prepare environment file
1) Copy `.env.portainer.example` to `.env.portainer`.
2) Set values:
   - `PDF_PROXY_IMAGE` / `WEB_LIBRARY_IMAGE` → choose the GHCR tags to deploy (e.g., `:main` or a specific `:sha-...`).
   - `ZOTERO_ROOT_HOST_PATH` → NAS path for WebDAV data (`/volume1/Reference/zotero`).
   - `PDF_PROXY_PORT` / `WEB_LIBRARY_PORT` → host ports (default `8280/8281`).

## Add GHCR registry in Portainer
1) Portainer → *Settings → Registries* → *Add Registry* → *Docker Hub Compatible*.
2) Registry URL: `ghcr.io`.
3) Username: your GitHub username.
4) Password/Token: PAT with `read:packages`.
5) Save. The stack will use this registry entry to pull images.

## Deploy the stack
1) Portainer → *Stacks* → *Add stack*.
2) Upload or paste `docker-compose.yml` and attach the `.env.portainer` file (or paste env values).
3) Deploy.
4) Verify:
   - PDF Proxy health: `http://<NAS_IP>:<PDF_PROXY_PORT>/health`.
   - Web Library: `http://<NAS_IP>:<WEB_LIBRARY_PORT>/`.
5) When updating, bump image tags in `.env.portainer` (e.g., to a new `sha-...` or `main`) and redeploy the stack.

## CLI fallback (optional)
If Portainer is unavailable, you can run the same stack directly on the NAS host:

```bash
docker compose --env-file .env.portainer up -d
```

Ensure the env file points to the correct NAS paths and GHCR tags before running.
