## Change ID

add-onprem-test-environment

## Summary

Define and implement a reproducible on‑prem test environment for the subtree‑based Web Library + PDF Proxy stack so you can deploy it on a real host, exercise it in a browser, and use those findings to refine future plans and specs.

## Why

- You now have a git subtree integration of `zotero/web-library` and an overlay strategy, but there is no clearly defined environment where the combined stack is actually running end‑to‑end.
- Being able to "put it on the web" (even if only inside your LAN) and click through real flows is critical to validate:
  - The subtree/overlay integration and build steps.
  - WebDAV access patterns against real or sample data.
  - Performance and UX implications in a realistic browser context.
- A named test environment, with documented commands and configuration, makes it much easier to:
  - Reproduce bugs and iterate on UI/Proxy changes.
  - Share the setup with other home‑lab users (or your future self) without re‑figuring everything each time.
  - Separate "experiment" deployments from any eventual long‑lived production stack on the NAS.

## What Changes

- **Environment scope and naming**
  - Define what "test environment" means in this project:
    - A **local dev stack** running on the code‑server host, using sample WebDAV data.
    - And/or a **staging stack on the Synology NAS**, isolated from your eventual "real" Zotero WebDAV.
  - Capture that scope in project docs (e.g. new "Environments" section in `README-draft.md` or a dedicated `docs/environments.md`).

- **Docker Compose and configuration for test runs**
  - Introduce a dedicated test/dev Compose configuration, for example:
    - `docker-compose.dev.yml` as an overlay for local testing.
    - Or explicit `profiles` / `services` in the existing `docker-compose.yml` to distinguish "test" from "prod" usage.
  - Provide example `.env.dev` / `.env.test` files with:
    - WebDAV mount paths (e.g. a sample directory with fake PDFs).
    - Host ports for the Web Library and PDF Proxy.
    - Any feature flags or config needed for the subtree‑based Web Library build.
  - Ensure no real credentials or personal data are committed; use placeholders and document where to fill them in.

- **On-prem Web Library image build/publish**
  - Build the Web Library from the local subtree + overlay (e.g. via a repo-level Dockerfile) and tag it for on-prem use.
  - Add a simple build/push script or CI job to publish that image to a private registry (e.g. GHCR / NAS registry).
  - Update dev/staging Compose configs to consume this locally built image (or locally built tag) instead of pulling upstream `zotero/web-library`, so the test stack always reflects your overlay changes.

- **Sample data and fixtures (for WebDAV / Zotero)**
  - Decide how to provide or reference test data:
    - A tiny sample WebDAV directory layout under a local path (with a couple of `<key>.prop` + `<key>.zip` entries).
    - Optional helper scripts to generate test zips/PDFs for specific scenarios (e.g. "PDF missing", "no PDF in zip").
  - Document how to point the test stack at this sample data versus a real WebDAV mount.

- **Run instructions and feedback loop**
  - Add a "Getting Started: Test Environment" section that explains:
    - How to bring up the stack (e.g. `docker compose -f docker-compose.yml -f docker-compose.dev.yml up`).
    - Which URLs to open for:
      - Web Library UI.
      - PDF Proxy endpoint (direct debug).
    - Which test scenarios to verify manually (e.g. "open PDF via Web Library", "404 when zip missing").
  - Encourage a workflow where:
    - New ideas or issues discovered in the test environment result in small OpenSpec changes (new `add-*` or `update-*` change IDs) rather than ad‑hoc edits.

- **OpenSpec and documentation alignment**
  - Add a test‑environment capability spec (requirements + scenarios) under `openspec/specs/` and a matching delta under this change.
  - Ensure AGENTS/project docs reference the test environment as the default way to validate subtree/overlay work before touching any production‑like stack.

## Impact

- **Developer workflow**
  - Clear "one command" path to see the full stack in a browser, which speeds up iteration and debugging.
  - Reduced risk of breakage when editing subtree/overlay code, because changes are always exercised in a realistic stack before being considered "done".

- **Safety and separation**
  - Encourages using sample or staging WebDAV data instead of your real Zotero WebDAV when experimenting.
  - Makes it easier to keep future "production" deployment on the NAS deliberately simple and stable.

## Open Questions

- How much of the test environment should live on the code‑server host versus on the NAS itself (e.g. a dedicated "staging" Portainer stack)?
- Do you want CI (GitHub Actions) to exercise the test Compose stack, or should it remain a purely local/home‑lab convention?
- How far should fixtures go (only a couple of hard‑coded zips, or a small generator script for more complex cases)?
