# 📚 On-Prem Zotero WebUI with WebDAV PDF Proxy

> Unofficial, self‑hosted web UI for reading PDFs from a Zotero library that syncs attachments via WebDAV.

**Status:** PoC / early preview (v0.1.14). Things may break; please treat this as an experiment, not production‑ready software.

Screenshot:


https://github.com/user-attachments/assets/46697d2f-0320-47f1-b843-a2abc02c350f



---

## TL;DR

- You use **official Zotero** + **WebDAV** as usual.
- This project runs on your own server and lets you **open those PDFs in a browser**, without installing the Zotero desktop app on every machine.
- Designed for **locked‑down / enterprise** environments where desktop installs or direct internet access are hard.

If you are a developer and want full architecture and deployment details, see `docs/development-overview.md`.

---

## What is this?

On-Prem Zotero WebUI is an open-source, self-hosted web application that lets you open and read PDFs from a Zotero library whose attachments are stored on WebDAV (or a local filesystem path).

It is especially useful when:

- You must keep **PDFs on your own NAS / server** (e.g. WebDAV on Synology).
- Users cannot install the Zotero desktop app easily (locked-down PCs, VDI, etc.).
- Only your server is allowed to reach Zotero.org over the internet, but users still want a browser-based view of PDFs.

Behind the scenes, the project:

- Reads Zotero-style attachment files (e.g. `<key>.zip` on WebDAV).
- Extracts the first PDF from each attachment into a cache folder.
- Serves that PDF to your browser through a small FastAPI-based PDF proxy.
- Integrates with a self-hosted copy of the Zotero Web Library UI.

---

## Prerequisite: you still need Zotero once

Because of how Zotero works today, **you still need the official Zotero desktop client at least once** (on some machine that can reach the internet):

1. Install Zotero and create / sign in to a **Zotero.org** account.
2. Let Zotero sync your **metadata** (items, notes, tags, etc.) with Zotero.org.
3. Configure **WebDAV** (or compatible storage) as the file sync target for **attachments (PDFs)**.

After this initial setup:

- **Metadata** continues to live in Zotero and (optionally) sync with Zotero.org as usual.
- **PDF files** live on your own WebDAV / storage, which this project reads via the PDF proxy.
- You can use this project as a **browser-based PDF viewer** for that library, instead of installing the Zotero desktop client everywhere.

> Note: This project does **not** replace all of Zotero’s features. It focuses on self-hosted PDF access; advanced metadata editing, search, and so on are on the roadmap.

---

## Who is this for?

- Researchers / academics / students working behind restrictive institutional proxies.
- Organizations that must keep data **on-premise** (no third-party cloud).
- HomeLab / NAS users who already use Zotero + WebDAV and just want a **simple browser UI** to open PDFs from their library.

If you already have:

- A Zotero library with WebDAV attachments.
- A server / NAS that can run Docker (e.g. Synology, home server).

…then you are the target audience.

---

## Quick Start (Docker)

> This is the simplest path if you already have Zotero configured with WebDAV on your NAS or server. For full Synology + Portainer recipes, see `docs/deployment-portainer.md`.

1. Clone the repo:

   ```bash
   git clone https://github.com/joonsoome/on-prem-zotero-webui.git
   cd on-prem-zotero-webui
   ```

2. Copy and edit the example env file for your environment (host paths, ports, etc.):

   ```bash
   cp .env.stage.example .env.stage
   # then edit .env.stage to point ZOTERO_ROOT_HOST_PATH to your WebDAV directory
   ```

3. Bring up the stack with Docker:

   ```bash
   docker compose --env-file .env.stage up -d
   # or: docker-compose --env-file .env.stage up -d
   ```

4. Open in your browser (default ports; adjust if you changed them):

   - Web Library UI: `http://<your-server-ip>:8281`
   - PDF Proxy test: `http://<your-server-ip>:8280/pdf/<key>`

If everything is wired correctly, clicking “Open PDF” in the Web Library should load the file via this on‑prem PDF proxy.

---

## Basic concepts

- **Zotero Desktop** stays the source of truth for metadata and WebDAV sync. This project never writes to your WebDAV store; it only reads and adds cache folders like `<key>/paper.pdf`.
- **PDF Proxy**:
  - Looks for cached PDFs under `/data/zotero/<key>/`.
  - If not found, opens `/data/zotero/<key>.zip`, extracts the first PDF into `/data/zotero/<key>/`, and streams it to the browser.
- **Web Library**:
  - A self-hosted copy of Zotero’s Web Library UI (via git subtree + overlay).
  - “Open PDF” buttons are configured to call this proxy (e.g. `/pdf/<key>`).

For a deeper architecture walkthrough and sample `main.py`, see `docs/development-overview.md`.

---

## Reverse proxy / HTTPS (optional)

Many users will want nicer URLs and HTTPS in front of the containers.

Example with Nginx Proxy Manager:

```text
Domain:   pdf.example.com
Forward:  http://NAS_IP:8280
SSL:      Cloudflare or Let's Encrypt
```

Then configure the Web Library so each PDF link points to:

```text
https://pdf.example.com/pdf/<key>
```

More detailed deployment notes are in `docs/deployment-portainer.md`.

---

## Roadmap (high level)

- 🔐 Simple authentication / access control.
- 🧾 Better Web Library integration and toolbar UX.
- 🧠 Optional pdf.js or similar in-browser viewer.
- 🧪 Smoother Synology / Portainer templates and examples.

For maintainer-focused TODOs and CI/CD details, see `docs/development-overview.md`.

---

## License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPLv3)**.

It includes and modifies the Zotero Web Library, which is:

- Licensed under AGPLv3
- © Corporation for Digital Scholarship

By using or deploying this project, you must provide access to the corresponding source code of the running service in accordance with AGPLv3. See `docs/LEGAL.md` for notice/header details.

---

## Contributing

Issues and PRs are welcome.

If you're also running Zotero with WebDAV on a NAS or HomeLab, this project was built for you — feel free to open issues in English or Korean if that’s easier. 
