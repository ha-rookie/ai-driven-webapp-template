# Git Workflow

## 原則

1 Issue・1 Branch・1 Pull Requestを基本とし、mainは直接変更しない。

## Branch命名

- `feat/issue-<number>-<summary>`
- `fix/issue-<number>-<summary>`
- `design/issue-<number>-<summary>`
- `docs/issue-<number>-<summary>`

## Change Contract / Pre-flight

変更前にIssueで次を確定する。

- Goal
- In Scope / Out of Scope
- Planned Files
- Risk Level
- Validation
- Stop Conditions

AIは最初にRead-onlyでmain、Issue、関連設計書、関連test / workflowを確認する。Planned Files外の変更、Scope拡張、別問題の修正が必要になった場合は、その場で変更を広げず停止してHumanへ報告する。

調査と変更を分け、ついで修正を避け、目的達成に必要な最小差分を優先する。

## PR作成前

- Issueの受け入れ条件を確認
- 最新mainを取り込む
- lint・test・buildを実行
- 設計書、Security、SEO、データ、運用影響を確認
- Preview確認方法を用意

## Review Gate

通常PRを第一候補とする。CI、Preview、スマホ実機、人間承認、承認head SHAを記録してからMergeする。

## GitHub Actions 実行資源

CIは品質ゲートであると同時に、月次利用枠を消費する有限の実行資源として扱う。

### 実行前

- 同じ変更で `push` と `pull_request` が不要に二重起動しないか確認する
- 可能ならlint・test・buildをローカルまたは単一Jobで先に確認する
- 小さな修正を細切れcommitしすぎて同じCIを何度も起動しない
- scheduled workflowは必要な頻度か定期的に見直す
- 使われていない旧Workflowや重複Workflowを残さない
- Jobには用途に応じた `timeout-minutes` を設定し、無制限に近い長時間実行を避ける

### 失敗時

- 同一原因を修正しないまま連続rerunしない
- annotation・最初の根本エラー・Job logsを確認して原因仮説を立てる
- 一部Jobだけ失敗しており再実行可能な場合は、全Workflowではなくfailed jobだけのrerunを優先する
- 外部設定・Secrets・Bindings・権限起因の場合、コードを変えずに再実行すべきかを先に判断する
- 同じ失敗を繰り返す場合はrerunを止め、Issue/原因切り分けへ戻る

### 利用枠が逼迫した場合

- 80%到達時: 不要な定期実行、重複trigger、旧Workflow、長時間Jobを点検する
- 90%到達時: 必須CIとリリース関連を優先し、任意検証や頻繁な手動実行を抑える
- 残量とリセット日を確認し、期限のあるProduction Releaseに必要な実行枠を残す
- 品質ゲート自体は外さず、実行回数・対象・順序を最適化する

### CI失敗分類

CI失敗は次のどれかに分類してから対応する。

- **A: 今回の変更** — 現在の差分が直接原因
- **B: 古いtest / validation** — 現仕様とtest・検証条件がずれている
- **C: 環境・外部制約** — Actions quota、billing、権限、外部サービス、runner等
- **D: 既存問題** — 今回の差分以前から存在する問題
- **E: 未確定** — 証拠不足でまだ分類できない

分類前に、RepositoryがPublic / Privateのどちらか、runnerがstandard GitHub-hosted / larger / self-hostedのどれか、Workflow trigger、Jobが実際に開始したかを確認する。

Actions上限や外部制約だけを理由にGitHub作業全体を停止しない。設計、コード、文書、静的レビューなど制約に依存しない作業は継続できる。ただし依存するCI / Preview / Deployは **未検証** と記録し、必要なReview Gate / Merge Gateで停止する。

### 実装状態の表現

- **Implemented**: 変更は作成済み
- **CI Validated**: 必須CIが実行され成功
- **Blocked**: 外部制約または未解決問題で次Gateへ進めない
- **Production Verified**: Merge後のProduction確認まで完了

これらを混同しない。

## Public Repository Gate / Ruleset

RepositoryをPrivateからPublicへ変更する場合、visibility変更だけで完了としない。

GitHub Templateから作成したRepositoryには、Template RepositoryのSettings / Rulesetは引き継がれない。したがって、Public化するRepositoryごとにRulesetを作成する。

### Public化前

- `.github/workflows/fork-monitor.yml` がdefault branchへ反映済み
- RepositoryのIssuesが有効
- Secret、token、credential、個人情報、非公開資料、公開禁止Assetが履歴を含めて存在しないことを確認する

### Public化直後

Repository Settings → Rules → Rulesets でbranch ruleset `main protection` をHumanが作成する。

Ruleset作成は **Human operation** とする。管理権限を持つPAT / GitHub App / WorkflowへAdministration write権限を渡して自動作成しない。AIはGitHub UIでの設定手順案内と、作成後のRead-only API確認を担当する。

必須設定:

- Enforcement: `Active`
- Target: Default branch
- Bypass: なし
- Restrict deletions: ON
- Require a pull request before merging: ON
- Required approvals: 0
- Require conversation resolution before merging: ON
- Allowed merge methods: Merge / Squash
- Block force pushes: ON

PR用CIが存在するRepositoryでは追加で:

- Require status checks to pass: ON
- Required checksはRepository固有の実在checkを登録する
- 対象PRで常に生成されるcheckだけをRequiredにする
- Require branches to be up to date before merging: ON

Template Repository自身をPublic化する場合も同じRulesetを作成する。

### 完了確認

画面設定だけで完了扱いにしない。GitHub API等のRead-only確認で次を実測する。

- visibility = `public`
- default branch上にFork monitorが存在
- Ruleset `main protection` が存在
- enforcement = `active`
- default branch対象
- deletion禁止
- PR必須
- conversation resolution必須
- allowed merge methodsが意図どおり
- force push禁止
- bypassなし
- Required status checks採用時はcheck名とup-to-date設定が意図どおり

全項目確認後に **Public Repository Gate = Passed** と記録する。

## Branch保護が強制できない場合

GitHub画面でRulesetが強制されないと表示される場合、設定済みと扱わない。

private個人開発では、次を代替ゲートとする。

- AIはmainを直接変更しない
- 変更ごとにIssue、専用Branch、PRを作る
- CI成功後に人間が内容を確認する
- 承認対象のhead SHAを確認してからMergeする
- Mergeは明示的な人間承認後だけ行う
- Force pushとBranch削除を行わない

強制的なBranch保護が必要な場合は、repositoryのPublic化または対応するGitHubプラン・organizationへの移行を人間が判断する。

## Draft解除に失敗した場合

Git競合と決めつけない。CI、mergeable、Draft状態、解除API、base、保護ルール、権限を分けて確認する。

同一head SHAから非Draft PRを作り、元PR番号、承認head SHA、CI run、Preview run、レビュー結果を引き継ぐ。

## Merge後

main CI、Production Deploy、本番表示、主要回帰、Issue Closeを確認する。
