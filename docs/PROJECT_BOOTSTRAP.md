# Project Bootstrap

## 1. 目的

Templateから新規Repositoryを作成した直後に、毎回同じ初期化判断をやり直さず、Project固有の設計へ安全に移行するための標準手順。

Bootstrapは「要件を自動生成する処理」ではない。

- Repository名、Project名など確定済みの機械的な事実は早く反映する
- User Problem、Requirements、Architecture、Data、Security等の意味はHumanの意図と実証に基づいて設計する
- 未確定事項をAIがCHANGE-MEから推測して埋めない

## 2. Repository Validationの3状態

同じWorkflowをTemplate / Bootstrap / Projectで使う。

### Template mode

対象: `ha-rookie/ai-driven-webapp-template`

Core Design文書にCHANGE-MEが残っていることを検証する。Template自身からplaceholderを消さない。

### Bootstrap mode

対象: Templateから作成したProject Repositoryで、`docs/00_PROJECT_OVERVIEW.md` にCHANGE-MEが残っている状態。

初期設計PRを作成中のため、Core Design文書の未確定placeholderを許容する。

ただし、これは長期運用状態ではない。最初のProject initialization PRでOverview、Requirements、Architecture、Repository Structure、TraceabilityをProject固有内容へ更新する。

### Project mode

対象: Derived Repositoryで、`docs/00_PROJECT_OVERVIEW.md` のCHANGE-MEを解消した状態。

Project modeへ入ったら、以下のProject固有文書にCHANGE-MEが残っている場合はValidationをfailする。

- `docs/00_PROJECT_OVERVIEW.md`
- `docs/01_REQUIREMENTS.md`
- `docs/02_SYSTEM_ARCHITECTURE.md`
- `docs/03_APPLICATION_ARCHITECTURE.md`
- `docs/04_REPOSITORY_STRUCTURE.md`
- `docs/06_REQUIREMENTS_TRACEABILITY.md`

`docs/adr/ADR-0000-template.md` は雛形なのでCHANGE-MEを維持してよい。

## 3. 標準Bootstrap Flow

1. GitHub Templateから新しいRepositoryを作成
2. `Project Bootstrap` Issue Templateで初期Change Contractを作る
3. AIがRepository / main / Template由来文書をRead-onlyで確認
4. Issue専用Branchを作成
5. Humanが示した目的・対象・制約をもとにCore DesignをProject固有化
6. 未確認の外部仕様・Data・Security要件は一次情報確認またはTBDとして残す
7. Repository validationでBootstrap / Project状態を確認
8. Human Review
9. Merge
10. Cloudflareを使う場合はHello World Gateへ進む

**Template validation → Project validationを切り替えるためだけの別Issueは作らない。**

Workflow自身がRepositoryとProject Overviewの状態から判定する。

## 4. Bootstrap Issueで最低限確定すること

- Project名
- Repository
- User Problem / 何を解決したいか
- Target User
- 最初の成功条件
- In Scope / Out of Scope
- 技術候補
- Runtime / Hosting候補
- Data / External API候補
- Mobile / Sensor / PWA等の有無
- Public / Private方針
- 初期Human Decision Points
- 未決事項

全項目を最初から確定する必要はない。未確定はTBDとして明示し、AIが推測で閉じない。

## 5. 機械的に決めてよいもの / 設計が必要なもの

### 機械的に反映してよい

HumanまたはGitHub実体から確定できるもの。

- Repository full name
- default branch
- Project表示名
- Issue / Branch / PR番号
- 既存Cloudflare Project名
- 確定済みProduction URL
- file path

### 自動で埋めない

- User Problem
- Success Condition
- Requirement
- Architecture
- Auth / Authorization
- Data retention
- Security boundary
- API採否
- PWA採否
- Analytics採否
- Public index方針
- Production release判断

## 6. Cloudflare

Bootstrap時点でCloudflare構成が未確定ならWorkflow Templateを有効化しない。

設計確定後に：

1. Pages / Workersを決める
2. Project名・Output Directory・Wrangler versionを決める
3. Secrets / Bindingsを確認する
4. `docs/workflow-templates/` から必要Workflowを有効化する
5. Hello World Gateを通す

Bootstrapを理由にProduction Deployを自動実行しない。

## 6.5 Project CI有効化

Application実装へ進む前に、lint / test / build等のProject固有commandが確定したら `docs/RISK_AWARE_CI.md` を確認する。

Risk-aware CIを使う場合：

1. `docs/workflow-templates/risk-aware-ci.yml` を `.github/workflows/project-ci.yml` へコピー
2. CHANGE-ME validation commandをProject固有commandへ置換
3. docs / design / runtime / strict の分類がProject構成と合うか確認
4. PRで `CI Gate` が常に生成されることを確認
5. RulesetへProject CIの `CI Gate` をRequired Checkとして登録するかHumanが判断

command未確定のままactive workflowへコピーしない。

## 7. 完了条件

Project Bootstrap完了は、単にRepositoryを作った状態ではない。

- Project Bootstrap Issueが存在
- Project固有Core Designがmainへ反映
- Repository validationがProject modeで成功
- mainとNotion最終設計の役割分担が確定
- 次の実装IssueまたはPoC Issueが明確
- Runtime開発を始める場合はHello World Gateへ進める状態

## 8. 既存Projectへの適用

既存派生Repositoryへ自動backportしない。

必要になった時点でTemplateとの差分を確認し、Project固有変更を壊さない範囲で個別Issueとして取り込む。
