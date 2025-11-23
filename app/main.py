import logging
import os
import re
import zipfile
from pathlib import Path
from typing import Iterable, Optional

from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("zotero_pdf_proxy")


def get_zotero_root() -> Path:
    root = os.getenv("ZOTERO_ROOT", "/data/zotero")
    return Path(root)


ZOTERO_ROOT = get_zotero_root()


app = FastAPI(title="Zotero WebDAV PDF Proxy")


def validate_key(key: str) -> None:
    if not re.fullmatch(r"[A-Za-z0-9]+", key):
        raise HTTPException(status_code=400, detail="Invalid key format")


def key_folder(key: str) -> Path:
    return ZOTERO_ROOT / key


def key_zip_path(key: str) -> Path:
    return ZOTERO_ROOT / f"{key}.zip"


def find_cached_pdf(path: Path) -> Optional[Path]:
    if not path.is_dir():
        return None
    for entry in sorted(path.iterdir()):
        if entry.is_file() and entry.suffix.lower() == ".pdf":
            return entry
    return None


def select_pdf_member(archive: zipfile.ZipFile) -> Optional[str]:
    pdf_members = [
        name for name in archive.namelist() if name.lower().endswith(".pdf")
    ]
    if not pdf_members:
        return None
    return sorted(pdf_members)[0]


def extract_pdf_from_zip(key: str) -> Path:
    folder = key_folder(key)
    zip_path = key_zip_path(key)

    if not zip_path.exists():
        raise HTTPException(status_code=404, detail="Zip not found")

    folder.mkdir(parents=True, exist_ok=True)

    with zipfile.ZipFile(zip_path, "r") as archive:
        member_name = select_pdf_member(archive)
        if member_name is None:
            raise HTTPException(status_code=404, detail="No PDF in zip")

        pdf_name = os.path.basename(member_name)
        target_path = folder / pdf_name

        if target_path.exists():
            return target_path

        with archive.open(member_name, "r") as source, target_path.open("wb") as target:
            for chunk in iter_file_chunks(source):
                target.write(chunk)

    return target_path


def iter_file_chunks(file_obj, chunk_size: int = 64 * 1024) -> Iterable[bytes]:
    while True:
        chunk = file_obj.read(chunk_size)
        if not chunk:
            break
        yield chunk


def stream_pdf(path: Path) -> StreamingResponse:
    if not path.is_file():
        raise HTTPException(status_code=404, detail="PDF not found")

    def iterator() -> Iterable[bytes]:
        with path.open("rb") as file_obj:
            for chunk in iter_file_chunks(file_obj):
                yield chunk

    headers = {"Content-Type": "application/pdf"}
    return StreamingResponse(iterator(), media_type="application/pdf", headers=headers)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/pdf/{key}")
def get_pdf(key: str):
    validate_key(key)

    try:
        folder = key_folder(key)
        cached = find_cached_pdf(folder)

        if cached:
            logger.info("cache_hit key=%s path=%s", key, cached)
            return stream_pdf(cached)

        extracted = extract_pdf_from_zip(key)
        logger.info("cache_miss key=%s path=%s", key, extracted)
        return stream_pdf(extracted)
    except HTTPException:
        raise
    except Exception as error:
        logger.exception("Unexpected error while processing key=%s", key)
        raise HTTPException(status_code=500, detail="Internal server error") from error

