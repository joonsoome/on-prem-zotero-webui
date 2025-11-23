## ADDED Requirements

### Requirement: Reproducible Test Environment
The project MUST provide at least one clearly defined, reproducible test environment for the Web Library + PDF Proxy stack.

#### Scenario: Local dev stack
- **GIVEN** a developer on the code-server host
- **WHEN** they follow the documented test environment instructions
- **THEN** they can start the Web Library + PDF Proxy stack with a single documented `docker compose` (or equivalent) command
- **AND** access it via the documented local URLs in a browser.

### Requirement: Safe Test Data Usage
Test environments MUST avoid accidental use of sensitive or production WebDAV data by default.

#### Scenario: Sample WebDAV configuration
- **GIVEN** a fresh clone of the repository
- **WHEN** a developer inspects the example test environment configuration files
- **THEN** they see placeholder or sample WebDAV paths, not real personal locations or credentials
- **AND** the documentation explains how to point the stack at synthetic/sample data.

### Requirement: Documented Manual Test Scenarios
The project MUST document basic manual test scenarios to be executed against the test environment.

#### Scenario: Open PDF via Web Library
- **WHEN** a test environment is running with sample data
- **AND** the tester opens a known Zotero item in the Web Library UI
- **THEN** they can trigger an "Open PDF" action that routes through the PDF Proxy
- **AND** confirm that a PDF is rendered or downloaded successfully.

#### Scenario: Error behavior
- **WHEN** the tester requests a non-existent or malformed key in the test environment
- **THEN** the proxy responds with an appropriate error (e.g. 404)
- **AND** the Web Library UI displays an understandable error state or message (if applicable).

### Requirement: On-Prem Web Library Image for Tests
Test/staging environments MUST run the Web Library from an image built from the local subtree + overlay (not the upstream `zotero/web-library` image).

#### Scenario: Dev compose uses local image
- **WHEN** the dev/staging compose stack is started
- **THEN** the Web Library service uses a locally built or registry-published image derived from `app/web-library-upstream/` + `app/web-library-overlay/`
- **AND** the image/tag is configurable via environment (e.g. `WEB_LIBRARY_IMAGE`), avoiding any implicit pull of upstream images.
