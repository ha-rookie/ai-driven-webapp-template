# Changelog

## Unreleased

### Added

- `CONTRIBUTING.md` を追加し、外部Contributor向けにChange Contract / Planned Files / Scope Guard / Human Merge Gateを明文化
- `SECURITY.md` を追加し、Repository自身の脆弱性報告とPublic Issueへ機密・exploit detailsを書かない方針を明文化

### Changed

- README冒頭に対象 / 非対象 / Quick Start / Contribution / Security / License導線を追加
- Repository validationで `CONTRIBUTING.md` と `SECURITY.md` を必須ファイルとして検証

## v0.3 - 2026-09-27

v0.2以降の実開発とTemplate比較から、AI/Human協働の開発ガバナンス、CI、Release Verification、作業復帰性、Public Repository運用を大きく強化した。

### Added

- Public Repository GateとしてFork監視とRuleset運用標準を追加
- GR-008としてEvidence-based work resumption / recognition mismatch時の実体確認を追加
- Project BootstrapとRepository validationのTemplate / Bootstrap / Project 3状態を追加
- Risk-aware CIのdocs / design / runtime / strict profileとfail-safe分類を追加
- Planned Files Guardを追加し、Issue Change ContractとPR実変更fileをCIで自動照合
- Release EvidenceをGitHub Actions Job Summaryへ自動集約
- 共通Production Verification scriptを追加し、HTTPS / stable marker / index policy / Security Headers / major assetsを検証可能にした
- OGP Production Verificationを追加し、og:title / og:description / og:image / twitter card / OGP画像配信を検証可能にした
- Google Drive → Google Sheets / Apps Script → GitHub work branchのbinary Asset代替輸送経路を標準化
- Runtime / Data Integrity設計観点としてTrust Boundary / State Transition / Atomicity / Concurrency / Invariant Enforcementを追加
- High-risk Boundary TestingとしてPositive / Reject / Concurrency・stale / Failure-after-stateの観点を追加
- External Resource BudgetとしてActions利用量と外部Service quota / rate limit / billing / shared quotaを分離して扱う指針を追加
- Development Convergence / Release Convergenceを分離するConvergence Gateを追加
- Feature / Bugfix / Design Change / Release / Production VerificationのTool-neutral Playbookを追加
- testing / security / frontend-ui / cloudflare-infrastructure / documentationのScoped Instructionsを追加
- GitHub Evidenceからread-onlyで現在地を導出するEvidence-derived Workflow Statusを追加
- MIT Licenseを導入し、`Copyright (c) 2026 ha-rookie` を明記

### Changed

- Risk LevelとImpact Flagsに応じて必要なGateだけを適用し、Change Contract合意後は次のHuman GateまでAIが連続実行する標準へ整理
- Issue / Branch / PR / SHA / CI / mainを優先する作業復帰順序へ整理し、手更新の進捗状態を新しいSource of Truthにしない方針を明確化
- Ruleset作成はAdministration権限を外部TokenやWorkflowへ渡さず、Human operationとして扱う標準へ変更
- AI製品固有のSkill / Command / Ruleと、Tool-neutralなPlaybook / Scoped Instructionの責務を分離
- 軽量Web Delivery Templateと、将来のBusiness Application Templateの責務境界を明確化
- Repository validationで`LICENSE`を必須ファイルとして検証

### Fixed

- Production Verification scriptに残っていたescaped shell variable expansionを修正
- OGP検証をattribute順序に依存しにくい形へ補強し、非HTTPSのOGP image URLをProduction fetch前にfail-fastするよう改善

## v0.2 - 2026-09-20

朝マズメ潮ナビ、あと一杯ナビ、よう拝（遥拝）アプリ、くるくるソムリエ等の実証から、公開・運用フェーズの共通知見をTemplateへ還流した。

### Added

- GitHub Actionsを有限の実行資源として扱う運用ルール
- 80% / 90%利用時の確認、重複trigger監査、failed job rerun判断
- Assetの原本保存型 / ビルド時生成型 / 同一Blob再利用型
- OGP / favicon / Apple Touch / PWA icon / maskable iconの標準
- Git Blob + Base64直接輸送の判断基準と切り分け手順
- Cloudflare Pages bootstrap / Hello World Gate / Production Workflow Template
- Design Preview専用Pages Projectの標準
- Design Preview starter / noindex / security placeholder
- Recommended Security Headers baseline
- Public Web Quality標準
- Google Search Console初期登録、HTML所有権確認、URL検査、sitemap運用
- About / Disclaimer / Privacy / Footerの判断基準
- 検索公開 / URL限定共有の選択
- Production Verification中心のRelease Checklist

### Changed

- Golden PathをDeploy後のProduction Verification、設計書同期、公開後観測まで拡張
- Merge / Deploy成功だけではRelease完了としない
- Production / App Preview / Design Previewの責務を分離
- PWA / Analytics / index公開 / LLMOを一律必須ではなくHuman decisionへ変更
- Cloudflare SetupをGitHub Actions + Wrangler中心の再現可能な手順へ拡張
- Template validationでCloudflare / Security / Public Web Quality / Design Preview / Asset / CI運用規約を検証
- Notionを「開発のやり方」の正本、GitHubをコードとコード密接設計の正本として役割分担を明確化

## v0.1

朝マズメ潮ナビの開発実証から、共通化できる開発プロセスを抽出した初版。

- Golden Path
- Git、Asset、Cloudflare、Troubleshooting、Releaseの標準文書
- Feature／Bug Issue Forms
- Pull Request Template
- Template構造検証Workflow
- AI向けAGENTS.md
- 要件、System Architecture、Application Architecture、Repository Structureの標準設計書
- Design ManagementとRequirements Traceability
- Visual Design管理方針
- Architecture Decision Record運用
