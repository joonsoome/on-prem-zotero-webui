#!/usr/bin/env sh
set -e

# Defaults for runtime substitution
: "${ZOTERO_API_KEY:=}"
: "${ZOTERO_API_AUTHORITY_PART:=api.zotero.org}"
: "${ZOTERO_USER_SLUG:=zotero-user}"
: "${ZOTERO_USER_ID:=0}"
: "${PDF_PROXY_BASE_URL:=http://localhost:8280/pdf}"

# Render index.html with current env vars (placeholders remain if empty)
if [ -f /usr/share/nginx/html/index.html ]; then
  envsubst \
    '$ZOTERO_API_KEY $ZOTERO_API_AUTHORITY_PART $ZOTERO_USER_SLUG $ZOTERO_USER_ID $PDF_PROXY_BASE_URL' \
    < /usr/share/nginx/html/index.html \
    > /usr/share/nginx/html/index.html.rendered
  mv /usr/share/nginx/html/index.html.rendered /usr/share/nginx/html/index.html
fi

exec "$@"
