# AI Driven Web App Template

AIと人間でWebアプリを継続開発するための標準テンプレートです。

コードの雛形だけでなく、設計、Issue、Branch、Pull Request、CI、Cloudflare、Asset、Security、SEO、Search Console、リリース、公開後確認、知見還流までを一つのGolden Pathとして管理します。

## このTemplateが提供するもの

| 領域 | 主な内容 |
| --- | --- |
| Design | Requirements / System Architecture / Application Architecture / ADR / Traceability |
| Delivery | Issue → Branch → PR → CI → Preview → Human Merge Gate |
| AI/Human Governance | Human/AI Guardrails / Tool-neutral Playbooks / Scoped Instructions / Convergence Gate |
| CI / Evidence | Risk-aware CI / Planned Files Guard / Release Evidence / Evidence-derived Workflow Status |
| Production | Cloudflare workflow templates / Production Verification / OGP / Security Headers / Release Checklist |
| Public Repository | Fork monitoring / Ruleset guidance / Contribution / Security reporting / MIT License |

### 対象

- 軽量〜中小規模のWebアプリ
- AIを開発に使いながらHuman ReviewとEvidenceを残したいProject
- GitHub中心で設計・Issue・PR・CI・Releaseを一貫管理したいProject
- Cloudflare Pages / Workers等を利用する公開Web Delivery

### 非対象

このRepositoryは、認証・認可、Database migration、Transaction、排他、idempotency、監査ログ等を標準装備するBusiness Application Templateではありません。これらを必要とする業務システム向けTemplateは別系統として扱います。

## Quick Start

1. GitHubのTemplate Repository機能から新しいRepositoryを作成する
2. [Project Bootstrap](docs/PROJECT_BOOTSTRAP.md) を確認する
3. `Project Bootstrap` Issue Templateで初期化Issueを作成する
4. Core Designの `CHANGE-ME` をProject固有設計へ置き換える
5. 必要なWorkflow Templateを有効化する
6. Issue → Branch → PR → CI → Human Merge GateのGolden Pathで開発を始める

外部からこのRepository自体へ変更を提案する場合は [CONTRIBUTING.md](CONTRIBUTING.md) を、脆弱性報告は [SECURITY.md](SECURITY.md) を先に確認してください。

- [Contribution Guide](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [Changelog](CHANGELOG.md)
- [MIT License](LICENSE)

## 基本原則

1. 設計変更 → 設計書 → Issue → 実装 → テスト → Pull Request
2. 1 Issue・1 Branch・1 Pull Request
3. mainを直接変更しない
4. 通常PR＋人間承認ゲートを標準とする
5. Previewでスマホ確認してからProductionへ反映する
6. ProductionとPreviewのデータ・Bindingsを分離する
7. 失敗をKnown Issue、手順、テンプレート、CIへ順に昇格する
8. GitHubのmainを承認済み設計の正本とする
9. 設計書ごとの責務を分け、同じ事実を複数文書へ重複管理しない
10. CIは品質ゲートであると同時に有限の実行資源として扱う
11. PWA・Analytics・検索index公開・LLMO等は一律必須にせずHuman decisionを残す
12. Merge / Deploy成功だけでRelease完了とせず、Production実測・実機確認・設計書同期まで行う
13. 実装・test・Deploy成功と仕様収束を分け、Merge前にDevelopment Convergence、Production後にRelease Convergenceを確認する
14. 反復する作業工程はTool-neutral Playbookを正本とし、AI製品固有のSkill / Command / Ruleへ手順を重複させない
15. 対象領域固有の制約はTool-neutral Scoped Instructionとして分離し、非該当ルールを全作業のContextへ常時読み込ませない
16. 作業現在地はGitHub Evidenceから導出し、手更新のWorkflow Statusを新しい正本にしない

## Golden Path

アイデア → 企画 → 要件 → Architecture → UI設計 → Issue → Branch → 実装 → CI → Preview → Development Convergence → 人間レビュー → Merge → Production Deploy → Production Verification → 設計書同期 → Release Convergence → 公開後観測 → 振り返り / 知見還流

## 使い始めるとき

最初に [Project Bootstrap](docs/PROJECT_BOOTSTRAP.md) を確認し、GitHubの `Project Bootstrap` Issue Templateから初期化する。Repository validationはTemplate / Bootstrap / Projectを自動判定するため、CI切替専用Issueは不要。

- `docs/00_PROJECT_OVERVIEW.md` のCHANGE-MEをProject固有設計へ置き換える
- `docs/01_REQUIREMENTS.md` に機能・非機能要件を定義する
- `docs/02_SYSTEM_ARCHITECTURE.md` でHosting、外部Service、データ経路、環境分離を設計する
- `docs/03_APPLICATION_ARCHITECTURE.md` でModule責務、State、Data、IFを設計する
- `docs/04_REPOSITORY_STRUCTURE.md` を実際のRepository treeへ合わせる
- 重要な技術判断は `docs/adr/` に残す
- UIの認識差が出る場合は `docs/design/` でVisual Designを作る
- Design Previewが必要なら `docs/DESIGN_PREVIEW.md` に従いWorkflow Templateを有効化する
- CloudflareのHello World Gateを先に通す
- Production配信が必要なら `docs/workflow-templates/deploy-production.yml` をアプリ側へコピーしてCHANGE-MEを置き換える
- Security baseline、公開範囲、index/noindex、About/Privacy、GSC、PWA、Analyticsの採否を決める
- 必要なIssueをテンプレートから作る
- 対象作業の [Tool-neutral Playbooks](docs/playbooks/README.md) を確認する
- Planned Files / Impact Flags / 作業内容に応じて [Scoped Instructions](docs/instructions/README.md) から必要な領域だけ追加で読む
- 中断後の復帰では必要に応じて [Evidence-derived Workflow Status](docs/WORKFLOW_STATUS.md) をNavigation Hintとして使い、直接GitHub Evidenceを確認する
- Release Checklistをプロジェクトに合わせて更新する

## 設計書の管理

設計書の入口は [Design Documentation Index](docs/README.md) とする。

- 承認済み最新設計: GitHub `main`
- 提案中設計: PR Branch
- 視覚レビュー: `docs/design/` + 必要に応じDesign Preview
- 設計判断履歴: `docs/adr/`
- 反復作業工程: `docs/playbooks/`
- 対象領域の追加制約: `docs/instructions/`
- 作業現在地のNavigation View: `docs/WORKFLOW_STATUS.md` + `scripts/derive-workflow-status.sh`（非正本）
- 構築キャプチャー・外部資料: Google Drive
- 複数アプリで再利用する開発判断: Notion
- Chat上の確定事項: 必ず該当設計書へ反映

詳細は [Design Management](docs/05_DESIGN_MANAGEMENT.md) を参照する。

外部Contributorは、非公開のNotion / Google Driveへアクセスする必要はありません。このPublic RepositoryにあるIssue、設計書、PR EvidenceをContributionの基準とします。

## 文書

### Core Design

- [Design Documentation Index](docs/README.md)
- [Project Overview](docs/00_PROJECT_OVERVIEW.md)
- [Requirements](docs/01_REQUIREMENTS.md)
- [System Architecture](docs/02_SYSTEM_ARCHITECTURE.md)
- [Application Architecture](docs/03_APPLICATION_ARCHITECTURE.md)
- [Repository Structure](docs/04_REPOSITORY_STRUCTURE.md)
- [Design Management](docs/05_DESIGN_MANAGEMENT.md)
- [Requirements Traceability](docs/06_REQUIREMENTS_TRACEABILITY.md)
- [Convergence Gate](docs/CONVERGENCE_GATE.md)
- [Visual Design](docs/design/README.md)
- [Design Preview](docs/DESIGN_PREVIEW.md)
- [Architecture Decision Records](docs/adr/README.md)

### Development / Operations

- [Tool-neutral Playbooks](docs/playbooks/README.md)
- [Feature Development Playbook](docs/playbooks/feature-development.md)
- [Bugfix Playbook](docs/playbooks/bugfix.md)
- [Design Change Playbook](docs/playbooks/design-change.md)
- [Release Playbook](docs/playbooks/release.md)
- [Production Verification Playbook](docs/playbooks/production-verification.md)
- [Scoped Instructions](docs/instructions/README.md)
- [Testing Instruction](docs/instructions/testing.md)
- [Security Instruction](docs/instructions/security.md)
- [Frontend / UI Instruction](docs/instructions/frontend-ui.md)
- [Cloudflare / Infrastructure Instruction](docs/instructions/cloudflare-infrastructure.md)
- [Documentation Instruction](docs/instructions/documentation.md)
- [Evidence-derived Workflow Status](docs/WORKFLOW_STATUS.md)
- [Project Bootstrap](docs/PROJECT_BOOTSTRAP.md)
- [Git Workflow](docs/GIT_WORKFLOW.md)
- [Risk-aware CI](docs/RISK_AWARE_CI.md)
- [Planned Files Guard](docs/PLANNED_FILES_GUARD.md)
- [Release Evidence](docs/RELEASE_EVIDENCE.md)
- [Production Verification](docs/PRODUCTION_VERIFICATION.md)
- [Asset Workflow](docs/ASSET_WORKFLOW.md)
- [Cloudflare Setup](docs/CLOUDFLARE_SETUP.md)
- [Security Baseline](docs/SECURITY_BASELINE.md)
- [Public Web Quality](docs/PUBLIC_WEB_QUALITY.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Release Checklist](docs/RELEASE_CHECKLIST.md)

Workflow Statusのread-only生成:

```bash
scripts/derive-workflow-status.sh <Issue番号>
```

生成JSONは `authoritative: false` であり、Repositoryへ手更新の状態正本としてcommitしない。

### Workflow Templates

Template Repository自身ではCloudflareへ自動Deployしない。

新規アプリで利用する場合に、以下を `.github/workflows/` へコピーしてCHANGE-MEを置き換える。

- `docs/workflow-templates/risk-aware-ci.yml`
- `docs/workflow-templates/deploy-production.yml`
- `docs/workflow-templates/deploy-design-preview.yml`

## Template境界

このRepositoryは、軽量なWeb DeliveryとAI/Human開発Governanceを主対象とする。

認証・認可、Database migration、Transaction、排他、idempotency、監査ログ等を標準装備するBusiness Application Templateは別系統として設計し、Scoped Instruction追加を理由に両Templateを同一化しない。

## v0.3の位置づけ

v0.3では、v0.2以降の実開発とTemplate比較から、AI/Human協働の開発ガバナンス、CI、Release Verification、作業復帰性、Public Repository運用を大きく強化した。

主な追加・強化:

- Evidence-based work resumption / GR-008
- Project BootstrapとTemplate / Bootstrap / Projectの3状態validation
- Risk-aware CI / Planned Files Guard / Release Evidence
- Production Verification / OGP Verification
- Runtime / Data Integrity設計観点とHigh-risk Boundary Testing
- External Resource Budget
- Development / Release Convergence Gate
- Tool-neutral Playbooks / Scoped Instructions
- Evidence-derived Workflow Status
- Public Repository Gate / Fork monitoring / Human-managed Ruleset
- MIT License

詳細な変更履歴は [CHANGELOG.md](CHANGELOG.md) を参照する。

個別アプリ固有のロジックや、LitLink・ProtoPedia固有の運用はTemplateへ直接固定せず、再利用できる原則だけを標準化する。

## License

このRepositoryは [MIT License](LICENSE) で提供する。

Copyright (c) 2026 ha-rookie
