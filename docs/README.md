# Design Documentation Index

このディレクトリは、プロジェクトの設計上の正本と、設計に従って作業するための共通手順を管理する。

## 正本

- 開発上の正本はGitHubの `main` にある設計書・コード・Issue・PR
- PR Branch上の設計書は「提案中の設計」
- Google Driveは構築キャプチャー、操作証跡、外部資料の保管先であり、設計本文の正本にしない
- Cloudflare等へ配信するDesign Previewはレビュー用の表示面であり、正本はRepository内のファイル
- Chat上の説明だけで仕様を確定しない。確定事項は該当設計書へ反映する
- `playbooks/` は作業工程の正本であり、Requirement / Architecture / Security / Release条件の意味を複製しない

## 設計書体系

| 文書 | 答える質問 | 主な更新契機 |
| --- | --- | --- |
| `HUMAN_AI_COLLABORATION.md` | HumanとAIがどう共同作業し、どこで停止するか | GitHub受け渡し・画像生成・共同作業ガードレールの変更 |
| `00_PROJECT_OVERVIEW.md` | なぜ作るか、誰の何を解決するか | 目的・対象・成功条件の変更 |
| `01_REQUIREMENTS.md` | 何を満たすか | 機能・非機能・制約の変更 |
| `02_SYSTEM_ARCHITECTURE.md` | システム全体をどう構成するか | Hosting、外部サービス、データ経路、環境分離の変更 |
| `03_APPLICATION_ARCHITECTURE.md` | アプリ内部をどう分割し責務を持たせるか | Module、状態、IF、実行時処理の変更 |
| `04_REPOSITORY_STRUCTURE.md` | ファイルをどこに置き、何を正とするか | Directory、生成物、配置規則の変更 |
| `05_DESIGN_MANAGEMENT.md` | 設計書をどう更新・承認・版管理するか | 設計プロセス自体の変更 |
| `06_REQUIREMENTS_TRACEABILITY.md` | 要件がどの設計・実装・テストに対応するか | 要件・設計・実装の追加変更 |
| `CONVERGENCE_GATE.md` | 実装・test・Evidence・Productionが仕様と収束しているか | 完了判定・Release判定の変更 |
| `design/` | UI・画面・視覚的な動きをどう見せるか | 画面・操作・視覚設計の変更 |
| `DESIGN_PREVIEW.md` | 視覚設計をどう安全に配信・レビューするか | Design Preview運用変更 |
| `adr/` | なぜ重要な技術判断をしたか | 代替案がある重要な設計判断 |
| `GIT_WORKFLOW.md` | Git/PRをどう進めるか | Git運用変更 |
| `CLOUDFLARE_SETUP.md` | Cloudflareをどう構成・確認するか | Cloudflare構成変更 |
| `SECURITY_BASELINE.md` | 公開WebアプリのSecurity Headerをどう設計・実測するか | Security・Hosting構成変更 |
| `PUBLIC_WEB_QUALITY.md` | SEO・Search Console・Public Trust・公開範囲をどう判断するか | 公開品質・検索公開方針変更 |
| `ASSET_WORKFLOW.md` | Assetをどう生成・承認・引き継ぐか | Asset運用変更 |
| `RELEASE_CHECKLIST.md` | 何を確認して公開するか | Release条件変更 |
| `TROUBLESHOOTING.md` | 既知問題をどう回避・復旧するか | 再発可能な障害・制約の発見 |

## Execution Playbooks

`playbooks/` は特定AI製品に依存しない実行手順を管理する。

| Playbook | 答える質問 |
| --- | --- |
| `playbooks/README.md` | Playbookをどう選び、他の正本とどう分担するか |
| `playbooks/feature-development.md` | 新機能・改善をどの順序で進めるか |
| `playbooks/bugfix.md` | 不具合をどう切り分け、修正・回帰確認するか |
| `playbooks/design-change.md` | 設計変更を実装より先にどう確定するか |
| `playbooks/release.md` | Merge後、Release完了まで何を確認するか |
| `playbooks/production-verification.md` | Productionをどう実測するか |

Playbookは既存文書の内容をコピーせず参照する。Tool固有Skill / Command / Ruleを将来追加する場合もAdapterとしてPlaybookを参照する。

## 設計ID

必要な設計項目には安定したIDを付与する。

- `REQ-xxx`: 機能要件
- `NFR-xxx`: 非機能要件
- `ARCH-xxx`: システムアーキテクチャ
- `APP-xxx`: アプリ内部設計
- `UI-xxx`: 画面・操作
- `DATA-xxx`: データ
- `IF-xxx`: 外部/内部インターフェース
- `TBD-xxx`: 未決事項
- `ADR-xxxx`: Architecture Decision Record

IDは内容変更時も可能な限り維持し、別概念になった場合だけ新規IDを採番する。

## 重複禁止

同じ事実を複数設計書へコピーして正本を複数作らない。

例:

- Cloudflare Pagesを採用する理由 → System Architecture / ADR
- Pagesの具体的な初期設定手順 → Cloudflare Setup
- Security Headerの共通基準 → Security Baseline
- `public/` の責務 → Repository Structure
- 画面上のボタン配置 → design/
- そのボタンが必要な理由 → Requirements
- Requirement / Design / Implementation / Test / Productionの整合判定 → Convergence Gate
- Feature開発をどの順序で実行するか → `playbooks/feature-development.md`
- Release条件そのもの → Release Checklist（Playbookへコピーしない）

他文書からはリンクまたは設計IDで参照する。

## 設計変更の原則

1. 変更要求と影響範囲を確認する
2. 該当する正本設計書を先に更新する
3. 必要ならDesign Previewで人間確認する
4. Issueに対象設計ID・非対象・受け入れ条件を残す
5. 実装・テストを行う
6. PRで設計差分と実装差分を同時にレビューする
7. `CONVERGENCE_GATE.md` に従いDevelopment Convergenceを確認する
8. CI成功後、人間承認してMergeする
9. `main` を承認済み最新設計とする
10. Production Releaseがある場合はProduction VerificationとRelease Convergenceを確認する

詳細は `05_DESIGN_MANAGEMENT.md`、`CONVERGENCE_GATE.md`、対象作業の `playbooks/` を参照する。
