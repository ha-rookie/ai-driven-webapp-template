#!/usr/bin/env bash
set -euo pipefail

: "${PRODUCTION_URL:?PRODUCTION_URL is required}"
: "${STABLE_MARKER:?STABLE_MARKER is required}"

INDEX_POLICY="${INDEX_POLICY:-skip}"
REQUIRE_SECURITY_HEADERS="${REQUIRE_SECURITY_HEADERS:-false}"
REQUIRED_ASSET_URLS="${REQUIRED_ASSET_URLS:-}"
OG_IMAGE_URL="${OG_IMAGE_URL:-}"

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

if [ -n "$OG_IMAGE_URL" ]; then
  case "$OG_IMAGE_URL" in
    https://*) ;;
    *)
      echo "::error title=Production Verification::OG_IMAGE_URL must use HTTPS: $OG_IMAGE_URL"
      exit 1
      ;;
  esac
fi

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

  for header in "${required_headers[@]}"; do
    grep -qi "^${header}:" "$headers_lower" || {
      echo "::error title=Production Verification::Missing required security header: $header"
      exit 1
    }
  done

  grep -Eqi '^strict-transport-security:[[:space:]]*.*max-age=([3-9][0-9]{7,}|[1-9][0-9]{8,})' "$headers_lower" || {
    echo "::error title=Production Verification::HSTS max-age must be at least 31536000 seconds"
    exit 1
  }

  grep -Eqi '^x-content-type-options:[[:space:]]*nosniff[[:space:]]*    csp="$(grep -i '^content-security-policy:' "$headers_lower" | tail -n 1 || true)"
    if ! printf '%s' "$csp" | grep -qi 'frame-ancestors'; then
      echo "::error title=Production Verification::Missing X-Frame-Options and CSP frame-ancestors"
      exit 1
    fi
  fi
fi

ogp_checked="false"
if [ -n "$OG_IMAGE_URL" ]; then
  meta_tags="$(grep -Eoi '<meta[^>]+>' "$html_file" || true)"

  for property in og:title og:description og:image; do
    if ! printf '%s\n' "$meta_tags" | grep -Eqi "property[[:space:]]*=[[:space:]]*[\"']${property}[\"']"; then
      echo "::error title=Production Verification::Missing required OGP meta: $property"
      exit 1
    fi
  done

  og_image_tag="$(
    printf '%s\n' "$meta_tags"       | grep -Ei "property[[:space:]]*=[[:space:]]*[\"']og:image[\"']"       | head -n 1 || true
  )"
  printf '%s' "$og_image_tag" | grep -Fq "$OG_IMAGE_URL" || {
    echo "::error title=Production Verification::og:image does not match OG_IMAGE_URL"
    exit 1
  }

  grep -Fq 'name="twitter:card" content="summary_large_image"' "$html_file" || {
    echo "::error title=Production Verification::twitter:card summary_large_image not found"
    exit 1
  }
  grep -Fq "name=\"twitter:image\" content=\"$OG_IMAGE_URL\"" "$html_file" || {
    echo "::error title=Production Verification::twitter:image does not match OG_IMAGE_URL"
    exit 1
  }
  curl --fail --silent --show-error --location --output "$tmp_dir/og-image" "$OG_IMAGE_URL" || {
    echo "::error title=Production Verification::OGP image is not reachable: $OG_IMAGE_URL"
    exit 1
  }
  test -s "$tmp_dir/og-image" || {
    echo "::error title=Production Verification::OGP image is empty: $OG_IMAGE_URL"
    exit 1
  }
  ogp_checked="true"
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
echo "OGP checked: $ogp_checked"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
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
    echo "| OGP checked | \`$ogp_checked\` |"
    echo "| Workflow run | [Open run]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID) |"
    echo "| Generated at (UTC) | \`$generated_at\` |"
    echo
    echo "> This is automated Production Evidence. Browser, smartphone, sensor, business-flow, Analytics, GSC, and external security diagnostics remain separate when applicable."
  } >> "$GITHUB_STEP_SUMMARY"
fi
 "$headers_lower" || {
    echo "::error title=Production Verification::X-Content-Type-Options must be nosniff"
    exit 1
  }

  grep -Eqi '^x-permitted-cross-domain-policies:[[:space:]]*none[[:space:]]*    csp="$(grep -i '^content-security-policy:' "$headers_lower" | tail -n 1 || true)"
    if ! printf '%s' "$csp" | grep -qi 'frame-ancestors'; then
      echo "::error title=Production Verification::Missing X-Frame-Options and CSP frame-ancestors"
      exit 1
    fi
  fi
fi

ogp_checked="false"
if [ -n "$OG_IMAGE_URL" ]; then
  meta_tags="$(grep -Eoi '<meta[^>]+>' "$html_file" || true)"

  for property in og:title og:description og:image; do
    if ! printf '%s\n' "$meta_tags" | grep -Eqi "property[[:space:]]*=[[:space:]]*[\"']${property}[\"']"; then
      echo "::error title=Production Verification::Missing required OGP meta: $property"
      exit 1
    fi
  done

  og_image_tag="$(
    printf '%s\n' "$meta_tags"       | grep -Ei "property[[:space:]]*=[[:space:]]*[\"']og:image[\"']"       | head -n 1 || true
  )"
  printf '%s' "$og_image_tag" | grep -Fq "$OG_IMAGE_URL" || {
    echo "::error title=Production Verification::og:image does not match OG_IMAGE_URL"
    exit 1
  }

  grep -Fq 'name="twitter:card" content="summary_large_image"' "$html_file" || {
    echo "::error title=Production Verification::twitter:card summary_large_image not found"
    exit 1
  }
  grep -Fq "name=\"twitter:image\" content=\"$OG_IMAGE_URL\"" "$html_file" || {
    echo "::error title=Production Verification::twitter:image does not match OG_IMAGE_URL"
    exit 1
  }
  curl --fail --silent --show-error --location --output "$tmp_dir/og-image" "$OG_IMAGE_URL" || {
    echo "::error title=Production Verification::OGP image is not reachable: $OG_IMAGE_URL"
    exit 1
  }
  test -s "$tmp_dir/og-image" || {
    echo "::error title=Production Verification::OGP image is empty: $OG_IMAGE_URL"
    exit 1
  }
  ogp_checked="true"
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
echo "OGP checked: $ogp_checked"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
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
    echo "| OGP checked | \`$ogp_checked\` |"
    echo "| Workflow run | [Open run]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID) |"
    echo "| Generated at (UTC) | \`$generated_at\` |"
    echo
    echo "> This is automated Production Evidence. Browser, smartphone, sensor, business-flow, Analytics, GSC, and external security diagnostics remain separate when applicable."
  } >> "$GITHUB_STEP_SUMMARY"
fi
 "$headers_lower" || {
    echo "::error title=Production Verification::X-Permitted-Cross-Domain-Policies must be none"
    exit 1
  }

  if grep -qi '^x-frame-options:' "$headers_lower"; then
    grep -Eqi '^x-frame-options:[[:space:]]*(deny|sameorigin)[[:space:]]*    csp="$(grep -i '^content-security-policy:' "$headers_lower" | tail -n 1 || true)"
    if ! printf '%s' "$csp" | grep -qi 'frame-ancestors'; then
      echo "::error title=Production Verification::Missing X-Frame-Options and CSP frame-ancestors"
      exit 1
    fi
  fi
fi

ogp_checked="false"
if [ -n "$OG_IMAGE_URL" ]; then
  meta_tags="$(grep -Eoi '<meta[^>]+>' "$html_file" || true)"

  for property in og:title og:description og:image; do
    if ! printf '%s\n' "$meta_tags" | grep -Eqi "property[[:space:]]*=[[:space:]]*[\"']${property}[\"']"; then
      echo "::error title=Production Verification::Missing required OGP meta: $property"
      exit 1
    fi
  done

  og_image_tag="$(
    printf '%s\n' "$meta_tags"       | grep -Ei "property[[:space:]]*=[[:space:]]*[\"']og:image[\"']"       | head -n 1 || true
  )"
  printf '%s' "$og_image_tag" | grep -Fq "$OG_IMAGE_URL" || {
    echo "::error title=Production Verification::og:image does not match OG_IMAGE_URL"
    exit 1
  }

  grep -Fq 'name="twitter:card" content="summary_large_image"' "$html_file" || {
    echo "::error title=Production Verification::twitter:card summary_large_image not found"
    exit 1
  }
  grep -Fq "name=\"twitter:image\" content=\"$OG_IMAGE_URL\"" "$html_file" || {
    echo "::error title=Production Verification::twitter:image does not match OG_IMAGE_URL"
    exit 1
  }
  curl --fail --silent --show-error --location --output "$tmp_dir/og-image" "$OG_IMAGE_URL" || {
    echo "::error title=Production Verification::OGP image is not reachable: $OG_IMAGE_URL"
    exit 1
  }
  test -s "$tmp_dir/og-image" || {
    echo "::error title=Production Verification::OGP image is empty: $OG_IMAGE_URL"
    exit 1
  }
  ogp_checked="true"
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
echo "OGP checked: $ogp_checked"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
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
    echo "| OGP checked | \`$ogp_checked\` |"
    echo "| Workflow run | [Open run]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID) |"
    echo "| Generated at (UTC) | \`$generated_at\` |"
    echo
    echo "> This is automated Production Evidence. Browser, smartphone, sensor, business-flow, Analytics, GSC, and external security diagnostics remain separate when applicable."
  } >> "$GITHUB_STEP_SUMMARY"
fi
 "$headers_lower" || {
      echo "::error title=Production Verification::X-Frame-Options must be DENY or SAMEORIGIN"
      exit 1
    }
  else
    csp="$(grep -i '^content-security-policy:' "$headers_lower" | tail -n 1 || true)"
    if ! printf '%s' "$csp" | grep -qi 'frame-ancestors'; then
      echo "::error title=Production Verification::Missing X-Frame-Options and CSP frame-ancestors"
      exit 1
    fi
  fi
fi

ogp_checked="false"
if [ -n "$OG_IMAGE_URL" ]; then
  meta_tags="$(grep -Eoi '<meta[^>]+>' "$html_file" || true)"

  for property in og:title og:description og:image; do
    if ! printf '%s\n' "$meta_tags" | grep -Eqi "property[[:space:]]*=[[:space:]]*[\"']${property}[\"']"; then
      echo "::error title=Production Verification::Missing required OGP meta: $property"
      exit 1
    fi
  done

  og_image_tag="$(
    printf '%s\n' "$meta_tags"       | grep -Ei "property[[:space:]]*=[[:space:]]*[\"']og:image[\"']"       | head -n 1 || true
  )"
  printf '%s' "$og_image_tag" | grep -Fq "$OG_IMAGE_URL" || {
    echo "::error title=Production Verification::og:image does not match OG_IMAGE_URL"
    exit 1
  }

  grep -Fq 'name="twitter:card" content="summary_large_image"' "$html_file" || {
    echo "::error title=Production Verification::twitter:card summary_large_image not found"
    exit 1
  }
  grep -Fq "name=\"twitter:image\" content=\"$OG_IMAGE_URL\"" "$html_file" || {
    echo "::error title=Production Verification::twitter:image does not match OG_IMAGE_URL"
    exit 1
  }
  curl --fail --silent --show-error --location --output "$tmp_dir/og-image" "$OG_IMAGE_URL" || {
    echo "::error title=Production Verification::OGP image is not reachable: $OG_IMAGE_URL"
    exit 1
  }
  test -s "$tmp_dir/og-image" || {
    echo "::error title=Production Verification::OGP image is empty: $OG_IMAGE_URL"
    exit 1
  }
  ogp_checked="true"
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
echo "OGP checked: $ogp_checked"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
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
    echo "| OGP checked | \`$ogp_checked\` |"
    echo "| Workflow run | [Open run]($GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID) |"
    echo "| Generated at (UTC) | \`$generated_at\` |"
    echo
    echo "> This is automated Production Evidence. Browser, smartphone, sensor, business-flow, Analytics, GSC, and external security diagnostics remain separate when applicable."
  } >> "$GITHUB_STEP_SUMMARY"
fi
