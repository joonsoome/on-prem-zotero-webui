#!/usr/bin/env bash
# Copyright (c) 2025 joonsoo-me
# SPDX-License-Identifier: AGPL-3.0-only

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/npm-basic-auth-fix.sh <url> [user] [password]

Checks whether a proxied URL properly challenges with HTTP basic auth.
- url: Full URL to the WebUI or PDF proxy (e.g., https://pdf.example.com/).
- user/password: Basic auth credentials. If omitted, use BASIC_AUTH_USER/BASIC_AUTH_PASSWORD env vars.
- Set CURL_OPTS (e.g., "-k" for self-signed) to tweak curl behavior.
EOF
}

TARGET_URL="${1:-}"
AUTH_USER="${2:-${BASIC_AUTH_USER:-}}"
AUTH_PASSWORD="${3:-${BASIC_AUTH_PASSWORD:-}}"
read -r -a CURL_OPTS_ARRAY <<<"${CURL_OPTS:-}"

if [[ -z "$TARGET_URL" ]]; then
  usage
  exit 1
fi

if [[ -z "$AUTH_USER" || -z "$AUTH_PASSWORD" ]]; then
  echo "error: provide basic-auth credentials as args or BASIC_AUTH_USER/BASIC_AUTH_PASSWORD env vars." >&2
  exit 1
fi

status_without_auth=$(curl -s -o /dev/null -w "%{http_code}" "${CURL_OPTS_ARRAY[@]}" "$TARGET_URL")
status_with_auth=$(curl -s -o /dev/null -w "%{http_code}" "${CURL_OPTS_ARRAY[@]}" -u "$AUTH_USER:$AUTH_PASSWORD" "$TARGET_URL")

echo "Target         : $TARGET_URL"
echo "Without auth   : HTTP $status_without_auth"
echo "With auth      : HTTP $status_with_auth"

if [[ "$status_without_auth" != "401" && "$status_without_auth" != "403" ]]; then
  cat >&2 <<'EOF'
warning: endpoint is reachable without basic auth.
 - Confirm your Cloudflare tunnel points at the NPM instance (not the NAS container).
 - Ensure an NPM Access List is attached to the host.
 - Consider enabling in-container auth via PDF_PROXY_BASIC_AUTH_*/WEB_LIBRARY_BASIC_AUTH_* env vars.
EOF
fi

case "$status_with_auth" in
  2*|3*)
    echo "Auth success   : credentials accepted (expected 2xx/3xx)."
    ;;
  *)
    echo "warning: authenticated request did not succeed (HTTP $status_with_auth)." >&2
    ;;
esac
