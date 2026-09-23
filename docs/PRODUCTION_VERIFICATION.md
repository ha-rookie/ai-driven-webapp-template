# Production Verification

## 1. 目的

Deploy成功とProductionで正しく動いていることを分け、複数Projectで繰り返している基本的なProduction smokeを共通化する。

共通script:

\`scripts/verify-production.sh\`

Cloudflare Production workflow templateからこのscriptを呼び出す。

## 2. 必須確認

毎回の基本確認:

- Production URLがHTTPS
- Production URLがHTTP 2xx
- 正しいApplicationを示すstable markerが存在

Deploy commandが成功しても、この確認が失敗した場合はProduction Verifiedとしない。

## 3. Optional checks

Project特性に応じて有効化する。

### Index policy

\`INDEX_POLICY=index\`

- X-Robots-Tagまたはrobots metaにnoindexがないことを確認

\`INDEX_POLICY=noindex\`

- X-Robots-Tagまたはrobots metaにnoindexがあることを確認

\`INDEX_POLICY=skip\`

- 自動判定しない
- Issue / Project Overviewで検索公開方針を別途管理する

### Security Headers

\`REQUIRE_SECURITY_HEADERS=true\`

以下をProduction実レスポンスで確認:

- Content-Security-Policy
- Strict-Transport-Security
- X-Content-Type-Options
- Referrer-Policy
- Permissions-Policy
- X-Permitted-Cross-Domain-Policies
- X-Frame-Options または CSP frame-ancestors

共通baselineとして、HSTSは `max-age` 1年以上、`X-Content-Type-Options` は `nosniff`、`X-Frame-Options` を使う場合は `DENY` または `SAMEORIGIN`、`X-Permitted-Cross-Domain-Policies` は `none` まで値を検証する。CSP・Referrer-Policy・Permissions-Policyの具体値はProject要件依存のため、共通scriptでは存在確認とframe protectionまでに留め、Project固有smokeで追加検証する。

External Security Headers診断は毎Deployではなく、\`docs/SECURITY_BASELINE.md\` の条件に従う。

### OGP

`OG_IMAGE_URL` にProductionのOGP画像absolute HTTPS URLを指定すると、以下を自動確認する。

- `OG_IMAGE_URL` がHTTPS
- `og:title` が存在
- `og:description` が存在
- `og:image` が存在し、指定URLと一致
- `twitter:card` が `summary_large_image`
- `twitter:image` が指定URLと一致
- OGP画像がHTTP取得可能かつ空でない

`OG_IMAGE_URL` のscheme不正はProduction fetch前にfailさせる。OGPを採用しないProjectでは未指定でよい。画像の視覚品質やSNS側キャッシュは別途Human確認する。

### Major assets

\`REQUIRED_ASSET_URLS\` にHTTPS absolute URLを改行区切りで指定する。

例:

\`\`\`text
https://example.com/favicon.ico
https://example.com/ogp.png
https://example.com/manifest.webmanifest
\`\`\`

指定したURLが取得できなければfailする。

## 4. 使用例

\`\`\`bash
PRODUCTION_URL="https://example.com/" \\
STABLE_MARKER="Example App" \\
INDEX_POLICY="index" \\
REQUIRE_SECURITY_HEADERS="true" \\
OG_IMAGE_URL="https://example.com/ogp.png" \\
REQUIRED_ASSET_URLS=$'https://example.com/favicon.ico\\nhttps://example.com/manifest.webmanifest' \\
bash scripts/verify-production.sh
\`\`\`

## 5. Production Evidence

GitHub Actions上で実行した場合、scriptは \`$GITHUB_STEP_SUMMARY\` へProduction Evidenceを出力する。

記録:

- Production URL
- HTTP result
- HTTPS
- stable marker
- index policy
- Security Headers checkの有無
- major asset件数
- OGP検証の有無
- Workflow run URL
- timestamp

これはPR CIのRelease Evidenceとは別フェーズ。

\`\`\`text
PR CI Evidence
↓ Human Review / Merge
Production Deploy
↓
Production Evidence
\`\`\`

## 6. 自動化しない確認

共通scriptだけでProduction Verifiedを完結させない。

別Gateとして残すもの:

- Browser上の画面確認
- Smartphone実機
- Sensor / Geolocation / Camera / Microphone
- business-specific user flow
- APIの業務的な正しさ
- Analytics event受信
- Google Search Console
- external Security Headers診断
- PWA installability / cache挙動

該当するImpact FlagsやProject要件に応じてHuman / Project-specific testで確認する。

## 7. Analytics

Analyticsは採用している場合でも、単純なHTTP smokeで「受信成功」を推測しない。

Cloudflare Web Analytics等は、Project固有の方法でProduction受信を確認する。

Preview / ChatGPT / smoke accessをProduction利用統計と区別する設計もProject側で行う。

## 8. Search / LLMO

Production Verificationでは検索公開方針の破壊だけを自動検知する。

- index予定なのにnoindex → fail
- noindex予定なのにindex可能 → fail

title / description / canonical / robots.txt / sitemap / structured data / LLMO向け公開情報の品質は \`docs/PUBLIC_WEB_QUALITY.md\` とRelease Checklistで確認する。

## 9. Failure

自動検証失敗時:

1. Deploy成功とProduction Verifiedを分離して記録
2. first failing checkを確認
3. code / Cloudflare / DNS / cache / Header / assetのどこかを切り分け
4. 同一原因のrerunを繰り返さない
5. 修正後にProduction Verificationを再実行

## 10. 既存Project

一括backportしない。

Project側で次を確認してから導入する。

- stable marker
- index/noindex方針
- Security Headers baseline採用状況
- major assets
- app固有の追加smoke
- Analytics / PWA / API / Sensorの追加確認
