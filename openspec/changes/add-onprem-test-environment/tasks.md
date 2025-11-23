## 1. Scope and Environment Definition

- [x] 1.1 Decide on the primary test environment scope:
  - Local dev stack on the code-server host, using sample WebDAV data.
  - Staging stack on the Synology NAS (separate from any future "prod" stack).
- [x] 1.2 Document the chosen environment types and their roles in a new doc (e.g. `docs/environments.md`) or a new "Environments" section in `README-draft.md`.
- [x] 1.3 Clarify which environment should be used when:
  - Quick UI/proxy iteration.
  - Pre-release smoke testing.
  - Experiments that might impact WebDAV data.

## 2. Compose and Configuration for Test Runs

- [x] 2.1 Design how test/dev Compose configuration will be represented:
  - Dedicated overlay file such as `docker-compose.dev.yml`, or
  - Profiles/services inside `docker-compose.yml` with clear naming.
- [x] 2.2 Add the chosen Compose configuration file(s) with:
  - Web Library service built from `app/web-library-upstream/` + `app/web-library-overlay/`.
  - PDF Proxy service as already defined in the project.
  - Volume mappings for a test WebDAV root.
- [x] 2.3 Create example environment files (e.g. `.env.dev`, `.env.test.example`) with placeholder values for:
  - WebDAV base path.
  - Ports for Web Library and PDF Proxy.
  - Any special flags needed for subtree/overlay builds.
- [x] 2.4 Ensure all examples avoid embedding real secrets or personal WebDAV paths; include comments explaining what users must fill in locally.
- [x] 2.5 Update dev/staging compose to consume the on-prem Web Library image built from subtree + overlay (not the upstream image), with configurable image/tag via env (e.g. `WEB_LIBRARY_IMAGE`).

## 3. Sample WebDAV Data and Fixtures

- [x] 3.1 Decide on a strategy for test data:
  - A small, curated directory with a handful of `<key>.prop` + `<key>.zip` pairs.
  - Or a helper script (Python, shell) that generates sample zips and PDFs for testing.
- [x] 3.2 If using a static sample directory, document:
  - Expected location on disk.
  - Mapping into containers via volumes.
  - Which keys/filenames are available for manual testing.
- [x] 3.3 If using a generator script, add it under `scripts/` with simple CLI usage, and ensure it produces only non-sensitive, synthetic data.

## 4. Run Instructions and Manual Test Scenarios

- [x] 4.1 Add a "Getting Started: Test Environment" section to `README-draft.md` that describes:
  - How to bring up the test stack (e.g. `docker compose -f docker-compose.yml -f docker-compose.dev.yml up`).
  - Which URLs to open for the Web Library UI and PDF Proxy.
- [x] 4.2 Define a minimal set of manual test scenarios, for example:
  - Open a known PDF via Web Library → verify it hits `/pdf/{key}` and renders.
  - Request a non-existent key → verify appropriate 404 behavior.
  - Test a zip with no PDF → verify error handling and UI messaging.
- [x] 4.3 Optionally introduce a simple checklist or markdown doc (e.g. `docs/test-scenarios.md`) listing these scenarios for reuse before each release.

## 5. Build and Publish On-Prem Web Library Image

- [x] 5.1 Add a Dockerfile (or reuse an existing one) that builds the combined subtree + overlay into a runnable Web Library image.
- [x] 5.2 Add a script/Make target/CI job to build and push the image to the chosen registry (e.g. GHCR or NAS registry), using placeholder credentials.
- [x] 5.3 Document expected image name/tag (e.g. `WEB_LIBRARY_IMAGE=ghcr.io/<user>/zotero-web-library:onprem-dev`) and how dev/staging compose files should reference it.

## 6. Feedback Loop into Future Planning

- [x] 5.1 Decide where to capture observations from the test environment (e.g. a "Notes" section in `docs/environments.md` or a running `TODO.md`).
- [x] 5.2 Establish a guideline that significant issues or new ideas found while testing should be turned into OpenSpec changes (`add-*` / `update-*`), rather than ad-hoc edits.
- [x] 5.3 Optionally add a short note in `AGENTS.md` under the workflow section reminding Codex to use the test environment before proposing structural changes to Web Library or Proxy behavior.

## 7. Spec and Validation

- [x] 6.1 Add a test-environment capability spec under `openspec/changes/add-onprem-test-environment/specs/test-env/spec.md` describing:
  - The existence of at least one reproducible test environment.
  - Requirements for run commands and basic manual scenarios.
- [x] 6.2 Once the spec delta is in place, run:
  - `openspec validate add-onprem-test-environment --strict`
  - Fix any validation errors that appear.
- [ ] 6.3 When the implementation work for this change is done, consider creating/aligning a long-lived capability spec under `openspec/specs/test-env/spec.md` to describe the final, stable behavior.
