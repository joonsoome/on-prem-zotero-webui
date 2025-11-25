# Change: Investigate and align on-prem Web Library metadata with zotero.org

## Why
- The on-prem Web Library shows a different item set than zotero.org (official) even though Zotero Desktop syncs metadata to zotero.org and attachments to WebDAV.
- Need to confirm which metadata source the on-prem UI is using and make it selectable/consistent.

## What Changes
- Trace metadata source/config in the overlay and upstream (API host, user/group IDs, keys).
- Decide and document the intended source (zotero.org vs on-prem metadata service) and how to configure it.
- Provide env-based configuration and tests/checks to ensure the on-prem UI mirrors zotero.org when desired.

## Impact
- Affects Web Library overlay config and deployment env files; adds troubleshooting guidance.
- May add a small spec delta under deployment/metadata.
