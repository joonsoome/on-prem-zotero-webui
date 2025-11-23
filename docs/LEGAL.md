# Licensing and Notices

This project is distributed under the **GNU Affero General Public License v3.0 (AGPLv3)**.

It embeds and modifies the Zotero Web Library (`zotero/web-library`), which is:

- Licensed under AGPLv3.
- Copyright © Corporation for Digital Scholarship.

## Source Availability

When you deploy this stack (PDF Proxy + Web Library) for yourself or share it with others, you must provide access to the corresponding source code for the exact version running in your environment, per AGPLv3 section 13. That includes:

- The PDF proxy (`app/main.py` and supporting modules).
- The Web Library subtree under `app/web-library-upstream/`.
- Any local customizations under `app/web-library-overlay/`.
- Build scripts, configuration, and release tooling stored in this repository.

Publishing a copy of this repository (with your local changes) in an accessible Git host satisfies the requirement for on-prem/home-lab sharing scenarios.

## File Header Convention

All new source files created in this repository **must** include the following header (tweak the year/author as needed):

```
/*
 * Copyright (c) 2024-2025 Your Name
 * SPDX-License-Identifier: AGPL-3.0-only
 */
```

For Python files, use a docstring-style comment:

```python
"""
Copyright (c) 2024-2025 Your Name
SPDX-License-Identifier: AGPL-3.0-only
"""
```

If a file originates from the upstream Zotero Web Library subtree, keep its original header intact and add an additional line referencing local modifications when applicable (e.g., “Modified for on-prem PDF proxy integration”).

