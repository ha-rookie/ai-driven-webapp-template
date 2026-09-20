# Git Workflow

## 原則

1 Issue・1 Branch・1 Pull Requestを基本とし、mainは直接変更しない。

## Branch命名

- `feat/issue-<number>-<summary>`
- `fix/issue-<number>-<summary>`
- `design/issue-<number>-<summary>`
- `docs/issue-<number>-<summary>`

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
