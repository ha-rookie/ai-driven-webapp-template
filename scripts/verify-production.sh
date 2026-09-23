#!/usr/bin/env bash
set -euo pipefail

: "\${PRODUCTION_URL:?PRODUCTION_URL is required}"
: "\${STABLE_MARKER:?STABLE_MARKER is required}"

INDEX_POLICY="\${INDEX_POLICY:-skip}"
REQUIRE_SECURITY_HEADERS="\${REQUIRE_SECURITY_HEADERS:-false}"
REQUIRED_ASSET_URLS="\${REQUIRED_ASSET_URLS:-}"

case "$PRODUCTION_URL" in
  https://*) ;;
  *)
    echo "::error title=Production Verification::PRODUCTION_URL must use HTTPS: $PRODUCTION_URL"
    exit 1
    ;;
esac

case "$INDEX_POLICY" in
  index|noindex|skip) ;;
  *)
    echo "::error title=Production Verification::INDEX_POLICY must be index, noindex, or skip"
    exit 1
    ;;
esac

case "$REQUIRE_SECURITY_HEADERS" in
  true|false) ;;
  *)
    echo "::error title=Production Verification::REQUIRE_SECURITY_HEADERS must be true or false"
    exit 1
    ;;
esac

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

headers_file="$tmp_dir/headers.txt"
html_file="$tmp_dir/production.html"
headers_lower="$tmp_dir/headers.lower"
html_lower="$tmp_dir/html.lower"

echo "Fetching Production: $PRODUCTION_URL"
http_code="$(
  curl \
    --silent \
    --show-error \
    --location \
    --output "$html_file" \
    --dump-header "$headers_file" \
    --write-out '%{http_code}' \
    "$PRODUCTION_URL"
)"

if [[ ! "$http_code" =~ ^2[0-9][0-9]$ ]]; then
  echo "::error title=Production Verification::Production returned HTTP $http_code"
  exit 1
fi

grep -Fq "$STABLE_MARKER" "$html_file" || {
  echo "::error title=Production Verification::Stable marker not found"
  exit 1
}

tr '[:upper:]' '[:lower:]' < "$headers_file" > "$headers_lower"
tr '[:upper:]' '[:lower:]' < "$html_file" > "$html_lower"

robots_header="$(grep -i '^x-robots-tag:' "$headers_file" | tail -n 1 || true)"
has_noindex="false"

if printf '%s' "$robots_header" | grep -qi 'noindex'; then
  has_noindex="true"
fi

if grep -Eqi '<meta[^>]+name=["'\'']*robots["'\'']*[^>]+content=["'\''][^"'\'']*noindex|<meta[^>]+content=["'\''][^"'\'']*noindex[^"'\'']*["'\''][^>]+name=["'\'']*robots' "$html_lower"; then
  has_noindex="true"
fi

case "$INDEX_POLICY" in
  index)
    if [ "$has_noindex" = "true" ]; then
      echo "::error title=Production Verification::Production is expected to be indexable but noindex was detected"
      exit 1
    fi
    ;;
  noindex)
    if [ "$has_noindex" != "true" ]; then
      echo "::error title=Production Verification::Production is expected to be noindex but noindex was not detected"
      exit 1
    fi
    ;;
  skip)
    ;;
esac

if [ "$REQUIRE_SECURITY_HEADERS" = "true" ]; then
  required_headers=(
    "content-security-policy"
    "strict-transport-security"
    "x-content-type-options"
    "referrer-policy"
    "permissions-policy"
    "x-permitted-cross-domain-policies"
  )

  for header in "\${required_headers[@]}"; do
    grep -qi "^\${header}:" "$headers_lower" || {
      echo "::error title=Production Verification::Missing required security header: $header"
      exit 1
    }
  done

  if ! grep -qi '^x-frame-options:' "$headers_lower"; then
    csp="$(grep -i '^content-security-policy:' "$headers_lower" | tail -n 1 || true)"
    if ! printf '%s' "$csp" | grep -qi 'frame-ancestors'; then
      echo "::error title=Production Verification::Missing X-Frame-Options and CSP frame-ancestors"
      exit 1
    fi
  fi
fi

asset_count=0
if [ -n "$REQUIRED_ASSET_URLS" ]; then
  while IFS= read -r asset_url; do
    asset_url="$(printf '%s' "$asset_url" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [ -n "$asset_url" ] || continue

    case "$asset_url" in
      https://*) ;;
      *)
        echo "::error title=Production Verification::Asset URL must use HTTPS: $asset_url"
        exit 1
        ;;
    esac

    curl --fail --silent --show-error --location --output /dev/null "$asset_url" || {
      echo "::error title=Production Verification::Required asset is not reachable: $asset_url"
      exit 1
    }
    asset_count=$((asset_count + 1))
  done <<< "$REQUIRED_ASSET_URLS"
fi

echo "Production Verification passed."
echo "HTTP: $http_code"
echo "Index policy: $INDEX_POLICY"
echo "Security headers required: $REQUIRE_SECURITY_HEADERS"
echo "Required assets checked: $asset_count"

if [ -n "\${GITHUB_STEP_SUMMARY:-}" ]; then
  generated_at="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  {
    echo "## Production Evidence"
    echo
    echo "| Field | Value |"
    echo "| --- | --- |"
    echo "| Production URL | \`$PRODUCTION_URL\` |"
    echo "| HTTP | \`$http_code\` |"
    echo "| HTTPS | \`passed\` |"
    echo "| Stable marker | \`passed\` |"
    echo "| Index policy | \`$INDEX_POLICY\` |"
    echo "| Security headers required | \`$REQUIRE_SECURITY_HEADERS\` |"
    echo "| Required assets checked | \`$asset_count\` |"
    echo "| Workflow run | [Open run]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID) |"
    echo "| Generated at (UTC) | \`$generated_at\` |"
    echo
    echo "> This is automated Production Evidence. Browser, smartphone, sensor, business-flow, Analytics, GSC, and external security diagnostics remain separate when applicable."
  } >> "$GITHUB_STEP_SUMMARY"
fi
