# 📚 On-Prem Zotero WebUI with WebDAV PDF Proxy

**Self-hosted Zotero WebUI Opensource Library + WebDAV-based PDF viewer **Avoid storage fees, keep privacy, and still enjoy a full browser-based Zotero library.

---

## 🚀 Overview

Zotero 7 introduced a new WebDAV sync format where each attachment is stored as:

```
<key>.prop
<key>.zip
```

Stored under the WebDAV root. Zotero always appends `/zotero` to the WebDAV URL (cannot be changed).

This works perfectly for Zotero Desktop — the Standalone app automatically unzips attachments into its local data directory during sync, so users never see the zip-based WebDAV storage structure. When you use Zotero Storage (including paid cloud plans), attachments are also available directly in the Zotero Web Library; this limitation only applies to WebDAV-based setups. but **Zotero Web Library (zotero.org) and the official on-prem web-library cannot open PDFs when using WebDAV**, because attachments remain on your private server and are not hosted by Zotero Storage.

This project provides a clean, fully-self-hosted solution:

```
Zotero Desktop → WebDAV (zip-based)
                      ↓
     On-Prem Web Library (zotero/web-library)
                      ↓
             PDF Proxy (zip → PDF streaming)
```

You get:

* ✔ No Zotero Storage costs
* ✔ Keep all PDFs on-prem (NAS / local server)
* ✔ Modern WebUI to browse your Zotero Library
* ✔ Click-to-open PDFs from the browser
* ✔ Works with Zotero 7 WebDAV zip structure
* ✔ Safe: does NOT modify Zotero’s zip or prop files

---

## 🧩 Architecture

```
Zotero Desktop (official)
       |
       | WebDAV sync (attachments in <key>.zip)
       v
Synology / Self-hosted WebDAV
       |
       | 1) On-prem Web Library UI (zotero/web-library)
       | 2) PDF Proxy (/pdf/<key>)
       v
Browser → https://pdf.example.com/pdf/<key>
```

### What the PDF Proxy does

1. Check if a cached PDF exists at:

   ```
   /zotero/<key>/<extracted.pdf>
   ```
2. If not, open `<key>.zip`, extract the first PDF into:

   ```
   /zotero/<key>/<pdf>
   ```
3. Stream the extracted PDF to the browser (`Content-Type: application/pdf`)

**Zotero itself keeps using **``** for syncing, unchanged.**

---

## 🗂 Folder Layout (Zotero 7 WebDAV)

### Original WebDAV structure (created by Zotero)

```
/zotero
  7A7BDC9P.prop
  7A7BDC9P.zip
  9CDWYJ9A.prop
  9CDWYJ9A.zip
  ...
```

### After PDF Proxy runs (cache folders added)

```
/zotero
  7A7BDC9P.prop
  7A7BDC9P.zip
  7A7BDC9P/               ← created by proxy
     paper.pdf
  9CDWYJ9A.prop
  9CDWYJ9A.zip
  9CDWYJ9A/
     article.pdf
```

---

## 🛠 Components

### 1. PDF Proxy (FastAPI)

* Reads WebDAV root directly from filesystem
* Lazy-extraction: only extracts PDF when first requested
* Caches the extracted PDF locally
* Streams to the browser

### 2. Self-Hosted Web Library

Fork or use `zotero/web-library` to provide:

* Web-based library browsing
* Custom “Open PDF” button pointing to:

  ```
  https://pdf.example.com/pdf/<key>
  ```

### 3. Optional Reverse Proxy

* Nginx Proxy Manager or Traefik
* Cloudflare optional

---

## 🐳 Docker Compose (Synology Example)

```yaml
version: "3.8"

services:
  zotero-pdf-proxy:
    image: python:3.11-slim
    container_name: zotero-pdf-proxy
    working_dir: /app
    volumes:
      - /volume1/Reference/zotero:/data/zotero
      - ./app:/app
    command: >
      bash -c "
      pip install fastapi uvicorn python-multipart &&
      uvicorn main:app --host 0.0.0.0 --port 8000
      "
    ports:
      - "8280:8000"
    restart: unless-stopped
```

---

## 🧩 Sample `main.py` (FastAPI)

```python
from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
import os, zipfile

app = FastAPI()
ZOTERO_ROOT = "/data/zotero"

@app.get("/pdf/{key}")
def get_pdf(key: str):
    folder = os.path.join(ZOTERO_ROOT, key)

    # 1. Cached PDF exists?
    if os.path.isdir(folder):
        for f in os.listdir(folder):
            if f.lower().endswith(".pdf"):
                return stream_pdf(os.path.join(folder, f))

    # 2. Otherwise: extract from <key>.zip
    zip_path = os.path.join(ZOTERO_ROOT, f"{key}.zip")
    if not os.path.exists(zip_path):
        raise HTTPException(404, "No zip found")

    os.makedirs(folder, exist_ok=True)

    with zipfile.ZipFile(zip_path, "r") as z:
        pdfs = [n for n in z.namelist() if n.lower().endswith(".pdf")]
        if not pdfs:
            raise HTTPException(404, "No PDF in zip")
        pdf_name = pdfs[0]
        extracted = os.path.join(folder, os.path.basename(pdf_name))
        z.extract(pdf_name, folder)

    return stream_pdf(extracted)


def stream_pdf(path):
    def iterfile():
        with open(path, "rb") as f:
            while chunk := f.read(8192):
                yield chunk
    return StreamingResponse(iterfile(), media_type="application/pdf")
```

---

## 🌐 Reverse Proxy Setup

In Nginx Proxy Manager:

```
Domain:   pdf.example.com
Forward:  http://NAS_IP:8280
SSL:      Cloudflare or Let's Encrypt
```

Then in Web-Library UI, set each PDF link to:

```
https://pdf.example.com/pdf/<key>
```

---

## 💡 Why This Project Exists

Zotero Web Library cannot display PDFs when using WebDAV, because:

* WebDAV content is private
* Zotero’s web UI cannot fetch files from your NAS
* Zotero 7 stores attachments in zip bundles

This project bridges that gap with:

* A tiny on-prem PDF server
* A self-hosted Web Library
* Zero changes to Zotero sync behavior
* Zero cloud fees

---

## 🛣 Roadmap
- [ ] Batch pre-extraction of all PDFs
- [ ] Thumbnail generator (/thumb/<key>)
- [ ] Simple auth ( **Need to find lightweight opensource solution** , OAuth, API tokens)
- [ ] (Optional) pdf.js viewer integration
- [ ] Better WebUI integration (custom toolbar button)
- [ ] Docker Hub image publishing
- [ ] Docker-Compose (Portainer) For Synology Container Manager
* [ ] (Optional) Generic Linux Docker-Compose

---

## 📜 License

MIT (recommended) —
You may include credits to Zotero / CHNM for the `zotero/web-library` code.

---

## ❤️ Contributions

Issues and PRs welcome!
If you're also running Zotero with WebDAV on a NAS, this project was built for you.

---
