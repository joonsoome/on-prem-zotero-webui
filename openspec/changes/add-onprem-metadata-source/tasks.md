## 1. Discovery
- [x] 1.1 Review upstream `zotero/web-library` config to identify metadata endpoint/auth settings (zotero.org defaults, API keys, user/group config).
- [x] 1.2 Check overlay code for existing overrides (e.g., pdf proxy base, userSlug/userId) and note gaps for metadata endpoint selection.

## 2. On-prem metadata option
- [x] 2.1 Define how to point Web Library to an on-prem metadata backend (e.g., Zotero API proxy/self-hosted sync target on Synology) and document required env vars.
- [x] 2.2 Add overlay config/hooks to select metadata source via env (e.g., `METADATA_BASE_URL`, `ZOTERO_API_KEY`), including zotero.org fallback.
- [x] 2.3 Provide staging defaults (Synology) in env examples and Compose notes.

## 3. Validation
- [ ] 3.1 Manual check: Web Library loads collections/items from the chosen metadata source (on-prem vs zotero.org) while attachments remain WebDAV.
- [ ] 3.2 Update docs/OpenSpec spec delta to capture the metadata-source selection requirement and scenarios.
