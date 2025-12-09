"""
Copyright (c) 2025 joonsoo-me
SPDX-License-Identifier: AGPL-3.0-only
"""

import importlib

import app.main as main
from fastapi.testclient import TestClient


def reload_main(monkeypatch, user=None, password=None, realm="Zotero PDF Proxy"):
    monkeypatch.delenv("PDF_PROXY_BASIC_AUTH_USER", raising=False)
    monkeypatch.delenv("PDF_PROXY_BASIC_AUTH_PASSWORD", raising=False)
    monkeypatch.delenv("PDF_PROXY_BASIC_AUTH_REALM", raising=False)

    if user is not None:
        monkeypatch.setenv("PDF_PROXY_BASIC_AUTH_USER", user)
    if password is not None:
        monkeypatch.setenv("PDF_PROXY_BASIC_AUTH_PASSWORD", password)
    if realm is not None:
        monkeypatch.setenv("PDF_PROXY_BASIC_AUTH_REALM", realm)

    return importlib.reload(main)


def test_basic_auth_disabled_by_default(monkeypatch):
    module = reload_main(monkeypatch, user=None, password=None)
    client = TestClient(module.app)

    response = client.get("/health")
    assert response.status_code == 200


def test_basic_auth_requires_credentials(monkeypatch):
    module = reload_main(monkeypatch, user="alice", password="wonderland")
    client = TestClient(module.app)

    response = client.get("/health")
    assert response.status_code == 401
    assert 'Basic realm="Zotero PDF Proxy"' in response.headers.get(
        "WWW-Authenticate", ""
    )

    authed = client.get("/health", auth=("alice", "wonderland"))
    assert authed.status_code == 200


def test_basic_auth_rejects_invalid_credentials(monkeypatch):
    module = reload_main(monkeypatch, user="alice", password="wonderland")
    client = TestClient(module.app)

    response = client.get("/health", auth=("alice", "wrongpass"))
    assert response.status_code == 401
