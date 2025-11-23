# Updating the Embedded Web Library Subtree

This repository vendors `zotero/web-library` using `git subtree` under `app/web-library-upstream/`. Follow this checklist whenever you want to pull upstream changes or prepare a release.

## 1. Pull the Latest Upstream Code

```bash
# Optional: override defaults with env vars if you track a fork
WEB_LIBRARY_REMOTE_URL=https://github.com/zotero/web-library.git \
WEB_LIBRARY_REMOTE_REF=master \
scripts/web-library-subtree-pull.sh
```

The script:

1. Runs `git subtree pull --prefix=app/web-library-upstream` from the configured remote/ref (default: upstream `master`).
2. Writes the resulting commit hash to `WEB_LIBRARY_UPSTREAM_COMMIT`.

> **Heads-up:** `git subtree` requires a clean working tree and index. Commit or stash unrelated work (including untracked files) before running the command, then re-apply your changes afterward.

If you have not added the subtree yet, run:

```bash
git subtree add --prefix=app/web-library-upstream https://github.com/zotero/web-library.git master --squash
```

## 2. Apply Overlay Customizations

Make sure any on-prem additions under `app/web-library-overlay/` still apply cleanly after the pull. If you keep patch files or scripts in that directory, re-run them here.

## 3. Test the Combined Build

1. Build the Web Library frontend or Docker image using the overlay + subtree (see `docs/web-library-overlay.md`).
2. Smoke test the “Open PDF” flow against your PDF Proxy.
3. Run local lint/tests as needed.

## 4. Update Documentation and Notices

- Note the pulled upstream commit in release notes (and keep `WEB_LIBRARY_UPSTREAM_COMMIT` committed).
- If upstream changed licensing notices, mirror them under `docs/LEGAL.md` when applicable.

## 5. Release Checklist

Run the release helper before tagging or deploying:

```bash
scripts/check-release.sh
```

This script invokes `scripts/check-web-library-subtree.sh` to ensure:

- The subtree matches `WEB_LIBRARY_UPSTREAM_COMMIT`.
- There are no uncommitted changes under `app/web-library-upstream/`.

Add additional checks (tests, linting, Docker builds) to `check-release.sh` as the project grows.
