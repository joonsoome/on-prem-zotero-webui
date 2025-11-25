## 1. Investigation
- [ ] 1.1 Inspect overlay config and build-time env to see which API host/user/key are currently used by the on-prem Web Library (zotero.org defaults?).
- [ ] 1.2 Cross-check upstream defaults and any runtime config injection paths (apiConfig, apiKey, userSlug/userId, libraries.include) to locate the active metadata endpoint.
- [ ] 1.3 Compare item counts/collections between on-prem UI and zotero.org to confirm divergence scope (collections, groups, My Library).

## 2. Configuration plan
- [ ] 2.1 Decide the intended metadata source for on-prem (zotero.org vs on-prem metadata service) and document how to switch.
- [ ] 2.2 Add env-based configuration (docker/env examples) so operators can select metadata host/user/key and included libraries/groups.
- [ ] 2.3 Provide default values that mirror zotero.org, with notes for on-prem metadata endpoints.

## 3. Validation
- [ ] 3.1 Manual test: after config, verify item count/collections match zotero.org for the chosen account; log the result.
- [ ] 3.2 Add troubleshooting notes (e.g., API key/host mismatch, wrong userId/libraryKey, group inclusion flags).
