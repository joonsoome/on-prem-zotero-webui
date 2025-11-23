# Environments

This project is designed to run in a few distinct contexts so you can experiment safely before touching any long-lived or personal data.

## Local Dev Stack (code-server host)

- **Purpose:** Fast iteration on the PDF Proxy and Web Library subtree/overlay integration.
- **Where:** Your code-server / development machine.
- **Data:** Synthetic/sample WebDAV layout mounted from a local directory (no real Zotero WebDAV).
- **How to use:** Bring up the `dev` compose stack (see README "Getting Started: Test Environment") and open the documented URLs in your browser.

## NAS Staging Stack (Synology)

- **Purpose:** Optional staging environment that mirrors your eventual NAS deployment more closely.
- **Where:** Synology NAS (via Docker Compose / Portainer).
- **Data:** Either the same synthetic sample WebDAV directory or a dedicated staging copy of your Zotero WebDAV data.
- **How to use:** Deploy a separate compose stack (or Portainer stack) clearly labeled as "staging", with ports/hostnames distinct from any future "prod" stack.

## When to Use Which

- **Local dev stack**
  - Quick UI/proxy iteration.
  - Trying out subtree/overlay changes.
  - Verifying error handling with synthetic fixtures.
- **NAS staging stack**
  - Pre-release smoke testing in an environment that matches NAS constraints.
  - Checking performance characteristics (network, disk, CPU) on the real hardware.
  - Validating reverse proxy / TLS integration without touching any public endpoints.

Always start in the local dev stack; only move to NAS staging once your changes behave as expected and you are comfortable with the sample data you are using.

