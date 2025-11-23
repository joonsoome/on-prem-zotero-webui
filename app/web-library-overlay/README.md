This directory contains on-prem Web Library customizations that sit on top of the upstream `zotero/web-library` git subtree stored in `app/web-library-upstream/`.

Refer to `docs/web-library-overlay.md` for the recommended layout. At a minimum:

- `src/` — drop-in overrides or additional components.
- `config/` — overlay configuration (e.g., PDF proxy base URL).
- `patches/` — patch files applied to upstream sources.
- `scripts/apply-overlay.sh` — helper that copies upstream files into a build directory and overlays these changes before running the normal Web Library build.

Run:

```bash
app/web-library-overlay/scripts/apply-overlay.sh
```

before executing `yarn install && yarn build` to ensure the overlay is included in the final assets/Docker image.
