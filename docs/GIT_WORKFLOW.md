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

## Public Repository Gate

RepositoryをPrivateからPublicへ変更する操作はHigh Riskとして扱い、単なるvisibility変更ではなく次のGateを完了して初めて「Public化完了」とする。

### Public化前 Gate

Publicへ変更する前に、default branchのmainへ次を反映済みにする。

- `.github/workflows/fork-monitor.yml` が存在する
- Workflow triggerが `fork` である
- Workflow権限は `contents: read` と `issues: write` の必要最小限である
- Fork検知時にSource、Fork URL、Fork owner、Created atをIssueへ記録する
- RepositoryのIssuesが有効である
- Secret、token、credential、個人情報、非公開資料、公開禁止Assetが履歴を含めて存在しないことを別のSecurity確認で確認する

Fork monitorはコピー防止ではない。GitHub上のForkイベントを観測するためのものであり、`git clone`、ZIP download、手動コピーを完全に検知・防止するものではない。

### Public化直後 Gate

Public化後は、他の変更・Merge・Production releaseへ進む前にRuleset `main protection` を作成する。

必須設定:

- Enforcement: `Active`
- Target: default branch
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
- Required checkは対象PRで常に生成されるcheckだけを指定する。path filter等で実行されない可能性があるcheckを直接Requiredにしない
- Require branches to be up to date before merging: ON

Ruleset名やRequired check名をテンプレートから推測しない。実際のRepository / Workflow / Check RunをRead-onlyで確認して設定する。

### 完了確認

画面で設定しただけではGate Passedとしない。GitHub API等のRead-only確認で最低限次を実測する。

- Repository visibilityが `public`
- default branch上に `.github/workflows/fork-monitor.yml` が存在する
- Ruleset `main protection` が存在する
- `enforcement = active`
- default branchが対象
- deletion禁止
- PR必須
- conversation resolution必須
- allowed merge methodsが意図どおり
- force push禁止
- bypassなし
- Required status checks採用時はcheck名とup-to-date設定が意図どおり

全項目を確認して初めて **Public Repository Gate = Passed** と記録する。

Public化後にRuleset未設定が判明した場合は、通常開発を継続せずGate修復を優先する。ただしRepositoryをPrivateへ戻すかどうかはHuman decisionとする。

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
