# Web Library Overlay Strategy

The upstream Zotero Web Library lives under `app/web-library-upstream/` as a git subtree. All on-prem customizations belong in `app/web-library-overlay/` so that upstream pulls remain clean and reviewable.

## Goals

- Keep upstream code untouched except via subtree pulls.
- Apply home-lab specific tweaks (Open PDF button, environment config, branding) without forking the entire project elsewhere.
- Make it obvious how to rebuild the Web Library Docker image from the combined source.

## Recommended Layout

```
app/
  web-library-upstream/   # git subtree (do not edit directly)
  web-library-overlay/
    patches/              # optional .patch files applied to upstream files
    src/                  # drop-in replacements or additional components
    config/
      onprem-settings.json
    scripts/
      apply-overlay.sh    # copies/patches overlay into the upstream tree before build
```

## Building with the Overlay

1. Run `app/web-library-overlay/scripts/apply-overlay.sh` (sample stub provided) to copy overlay files into a temporary build directory (e.g., `app/web-library-build/`).
2. Execute the standard Web Library build (`yarn install && yarn build`) inside that build directory.
3. Package or dockerize the build output as usual.

## Open PDF Integration

Use the overlay to ensure attachment actions point at the PDF Proxy:

- Keep a small config file (e.g., `config/onprem-settings.json`) with `{"pdfProxyBaseUrl": "https://pdf.example.com/pdf"}`.
- In your overlay script, inject that config into the upstream settings module (for example by replacing a `PLACEHOLDER_PDF_PROXY_URL` string or by overriding the component responsible for generating attachment URLs).
- Document whichever component you override so future upstream pulls can reconcile conflicts quickly.

## Applying Patches

If you prefer patch files over scripts:

```bash
cd app/web-library-upstream
git apply ../web-library-overlay/patches/open-pdf-proxy.patch
```

When upstream changes break the patch, rebase it and update the patch file inside the overlay directory.

## Tests and Manual Checks

- Smoke test the “Open PDF” button in the built UI against `/pdf/{key}`.
- Confirm overlay code doesn’t introduce new lint/test failures.
- Consider adding Cypress/Playwright integration tests in the overlay directory if the workflow grows more complex.

