from pathlib import Path

from app.main import get_zotero_root, key_folder, key_zip_path


def test_zotero_root_default_env(monkeypatch):
    monkeypatch.delenv("ZOTERO_ROOT", raising=False)
    root = get_zotero_root()
    assert isinstance(root, Path)
    assert str(root) == "/data/zotero"


def test_zotero_root_env_override(monkeypatch):
    monkeypatch.setenv("ZOTERO_ROOT", "/tmp/zotero-test")
    root = get_zotero_root()
    assert root == Path("/tmp/zotero-test")


def test_key_paths(monkeypatch):
    monkeypatch.setenv("ZOTERO_ROOT", "/data/z-root")
    root = get_zotero_root()
    monkeypatch.setattr("app.main.ZOTERO_ROOT", root, raising=False)
    key = "7A7BDC9P"

    assert key_folder(key) == root / key
    assert key_zip_path(key) == root / f"{key}.zip"
