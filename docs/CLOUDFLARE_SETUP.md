# Cloudflare Setup

## 1. Readiness Check

- [ ] GitHub Repository接続権限
- [ ] Production Branch
- [ ] Build Command
- [ ] Output Directory
- [ ] Node.js version
- [ ] Environment Variables
- [ ] Secrets
- [ ] Bindings
- [ ] Analytics Engine
- [ ] Web Analytics
- [ ] Domain / DNS
- [ ] Design Preview採用有無
- [ ] Design ProjectをProduction Application Projectと分離したか

## 2. Hello World

mainでProduction Deploy、非main BranchでPreview URLが作られることを確認する。失敗中は機能開発へ進まない。

## 3. Environment Separation

ProductionとPreviewの変数、Secrets、Bindings、書き込み先を分離する。PreviewはProductionデータへ書き込まない。

Design Previewを採用する場合は、Production Application用Projectとは別のDesign Projectを使用する。

## 4. Domain・SEO

HTTPS、www有無、canonical、title、description、OGP、favicon、robots.txt、sitemap.xml、Preview noindexを確認する。

Design Previewは `X-Robots-Tag: noindex, nofollow, noarchive` とHTML meta robotsを使う。

## 5. Security

秘密情報をRepositoryへ入れない。Security Headersはbaselineから導入する。CSPは外部script、Beacon、PWA、same-origin APIをPreviewで確認してから強制する。

Design HTMLへProduction Secrets、Bindings、本番データを埋め込まない。

## 6. Analytics

Production受信を確認し、Previewを本番計測から除外する。Analytics側の未設定とアプリのBuild失敗を分ける。

Design Previewは原則としてProduction Analytics対象外とする。

## 7. Operations

Deploy履歴、ログ、前回正常版、Rollback、障害時判断、データ更新方法を記録する。

## 8. Design Preview

UI・Interactionの事前レビューが有効なアプリでは、朝マズメ潮ナビで実証した方式を汎用化して使用できる。

標準:

- Design Project名: `<app-name>-design` 等、Production App Projectと別名
- PR Branch: `pr-<PR番号>`
- main最新: `latest`
- 手動: `manual-<run-id>`
- Production apex: `docs/design-public/` のplaceholderのみ
- Design本文: `docs/design/`
- Workflow Template: `templates/github-actions/deploy-design-preview.yml`

新規AppではWorkflow Templateを `.github/workflows/deploy-design-preview.yml` へコピーし、Project名とSecretsを設定してから有効化する。

Template Repository自身ではCloudflareへDesign Deployしない。

詳細は `DESIGN_PREVIEW.md` を参照する。
