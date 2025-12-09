#!/usr/bin/env sh
set -e

# Defaults for runtime substitution
: "${ZOTERO_API_KEY:=}"
: "${ZOTERO_API_AUTHORITY_PART:=api.zotero.org}"
: "${ZOTERO_USER_SLUG:=zotero-user}"
: "${ZOTERO_USER_ID:=0}"
: "${ZOTERO_INCLUDE_MY_LIBRARY:=true}"
: "${ZOTERO_INCLUDE_USER_GROUPS:=true}"
: "${ZOTERO_LIBRARIES_INCLUDE_JSON:=[]}"
: "${WEB_LIBRARY_ALLOW_UPLOADS:=false}"
: "${PDF_PROXY_BASE_URL:=http://localhost:8280/pdf}"
: "${WEB_LIBRARY_BASIC_AUTH_REALM:=Zotero WebUI}"

# Render index.html with current env vars (placeholders remain if empty)
if [ -f /usr/share/nginx/html/index.html ]; then
  envsubst \
    '$ZOTERO_API_KEY $ZOTERO_API_AUTHORITY_PART $ZOTERO_USER_SLUG $ZOTERO_USER_ID $ZOTERO_INCLUDE_MY_LIBRARY $ZOTERO_INCLUDE_USER_GROUPS $ZOTERO_LIBRARIES_INCLUDE_JSON $WEB_LIBRARY_ALLOW_UPLOADS $PDF_PROXY_BASE_URL' \
    < /usr/share/nginx/html/index.html \
    > /usr/share/nginx/html/index.html.rendered
  mv /usr/share/nginx/html/index.html.rendered /usr/share/nginx/html/index.html
fi

AUTH_SNIPPET=""

if [ -n "${WEB_LIBRARY_BASIC_AUTH_USER:-}" ] && [ -n "${WEB_LIBRARY_BASIC_AUTH_PASSWORD:-}" ]; then
  HTPASSWD_PATH="/etc/nginx/.htpasswd"
  htpasswd -bBc "$HTPASSWD_PATH" "$WEB_LIBRARY_BASIC_AUTH_USER" "$WEB_LIBRARY_BASIC_AUTH_PASSWORD"
  AUTH_SNIPPET=$(printf "    auth_basic \"%s\";\n    auth_basic_user_file %s;" "$WEB_LIBRARY_BASIC_AUTH_REALM" "$HTPASSWD_PATH")
fi

if [ -f /etc/nginx/conf.d/default.conf.template ]; then
  AUTH_SNIPPET="$AUTH_SNIPPET" envsubst '$AUTH_SNIPPET' \
    < /etc/nginx/conf.d/default.conf.template \
    > /etc/nginx/conf.d/default.conf
fi

exec "$@"
