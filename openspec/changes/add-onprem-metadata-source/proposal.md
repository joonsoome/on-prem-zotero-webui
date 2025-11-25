# Change: On-prem metadata source configuration for Web Library

## Why
- Current setup keeps Zotero metadata on zotero.org while attachments live on WebDAV, creating ambiguity and dependence on cloud metadata.
- We need a way to point the on-prem Web Library overlay to a self-hosted metadata source (Synology) or, if still using zotero.org, clearly configure API keys/endpoints.

## What Changes
- Investigate and document how the upstream Web Library config handles metadata endpoints/auth.
- Add overlay configuration to select between zotero.org metadata and on-prem metadata service.
- Provide env-based defaults and staging instructions for Synology-hosted metadata.

## Impact
- Affected code: Web Library overlay config and deployment env files.
- Affected specs: add/update deployment/metadata capability to reflect on-prem metadata sourcing.
