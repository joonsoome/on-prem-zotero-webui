#!/usr/bin/env python3
"""
Generate a tiny synthetic Zotero WebDAV layout for local testing.

Creates:
  sample-webdav/zotero/
    SAMPLE1.prop
    SAMPLE1.zip  (contains sample1.pdf)
    SAMPLE2.prop
    SAMPLE2.zip  (contains sample2.pdf and notes.txt)
"""

import os
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ZOTERO_DIR = ROOT / "sample-webdav" / "zotero"


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def write_prop(path: Path, key: str) -> None:
    # Minimal placeholder; real .prop files are more complex but not needed for proxy tests.
    content = f"key={key}\ncreated-by=sample-generator\n"
    path.write_text(content, encoding="utf-8")


def create_pdf_bytes(title: str) -> bytes:
    # Create a minimal, valid PDF file as bytes.
    # This is intentionally simple; it just needs to be recognized by PDF viewers.
    pdf = f"""%PDF-1.1
1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj
2 0 obj<</Type/Pages/Count 1/Kids[3 0 R]>>endobj
3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 300 144]/Contents 4 0 R/Resources<</Font<</F1 5 0 R>>>>>>endobj
4 0 obj<</Length 44>>stream
BT /F1 24 Tf 50 100 Td ({title}) Tj ET
endstream endobj
5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj
xref
0 6
0000000000 65535 f 
0000000010 00000 n 
0000000061 00000 n 
0000000112 00000 n 
0000000277 00000 n 
0000000390 00000 n 
trailer<</Root 1 0 R/Size 6>>
startxref
481
%%EOF
"""
    return pdf.encode("utf-8")


def create_zip_with_pdf(zip_path: Path, pdf_name: str, title: str, extra_files: dict | None = None) -> None:
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr(pdf_name, create_pdf_bytes(title))
        if extra_files:
            for name, data in extra_files.items():
                zf.writestr(name, data)


def main() -> None:
    ensure_dir(ZOTERO_DIR)

    # SAMPLE1: single PDF
    key1 = "SAMPLE1"
    write_prop(ZOTERO_DIR / f"{key1}.prop", key1)
    create_zip_with_pdf(
        ZOTERO_DIR / f"{key1}.zip",
        "sample1.pdf",
        "Sample PDF 1",
    )

    # SAMPLE2: PDF + extra file
    key2 = "SAMPLE2"
    write_prop(ZOTERO_DIR / f"{key2}.prop", key2)
    create_zip_with_pdf(
        ZOTERO_DIR / f"{key2}.zip",
        "nested/sample2.pdf",
        "Sample PDF 2",
        extra_files={"notes.txt": b"This is a text file in the zip."},
    )

    print(f"Sample WebDAV data generated under: {ZOTERO_DIR}")


if __name__ == "__main__":
    main()

