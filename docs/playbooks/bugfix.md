# Bugfix Playbook

## Purpose

不具合を、症状だけの修正ではなくEvidenceに基づく原因特定・最小修正・回帰確認まで一貫して進める。

## Preconditions

- Bug Issueまたは同等のChange Contractがある
- 症状、期待動作、再現条件または観測Evidenceが整理されている
- Planned Files / Risk / Impact / Validation / Stop Conditionsが定義されている

## Evidence to Read

- `docs/HUMAN_AI_COLLABORATION.md`
- `AGENTS.md`
- 対応Issue
- 関連Requirement / Design / ADR
- 現在の実装と関連test
- `docs/TROUBLESHOOTING.md`
- `docs/GIT_WORKFLOW.md`
- `docs/CONVERGENCE_GATE.md`
- 利用可能なlog / error / CI Evidence

## Steps

1. Read-onlyで症状、再現条件、期待動作、直近変更を確認する
2. 「仕様どおりだが期待と違う」のか「仕様から逸脱したdefect」なのかを分ける
3. 原因仮説を立て、Evidenceで確認する。推測だけで修正へ入らない
4. 仕様変更が必要ならBugfixとして押し込まず、必要なDesign / Requirement変更を明示する
5. Issue番号を含む専用Branchを作る
6. 可能なら失敗を再現するtest / validationを先に固定する
7. Planned Files内で原因に対するMinimum Necessary Fixを行う
8. 再現test、関連回帰、Risk / Impactに必要な検証を実行する
9. PRへ原因、修正内容、非対象、再現Evidence、回帰Evidenceを記録する
10. CI / Scope Guardを確認する
11. Development Convergenceを確認する
12. `Converged` となったhead SHAをHuman Review対象として固定する
13. Human Merge approvalで停止する
14. Merge後にProduction Releaseがある場合は `release.md` へ進む

## Human Gates

- Bugfixの範囲を超える仕様変更
- Security / Data loss / Production incident等でRiskが上昇
- Scope拡張
- 実機でしか再現・確認できない問題
- Merge approval
- Productionの緊急・破壊的操作

## Stop Conditions

- 根本原因を特定できず試行錯誤的変更になる
- Planned Files外の変更が必要
- 既存仕様と期待動作が矛盾する
- 別問題を同じPRへ混ぜる必要が出た
- 再現不能かつ十分な代替Evidenceもない
- 外部制約により必須検証ができない

## Validation

- 修正前の症状または原因をEvidenceで説明できる
- 修正後に対象症状が解消
- 関連回帰がない
- 仕様変更の有無を明示
- 未実行checkを成功扱いしていない
- Development Convergence = `Converged`

## Output / Evidence

- 原因分類 / root cause
- 再現Evidence
- 修正差分
- regression test / validation結果
- CI結果
- Development Convergence
- Human Review対象head SHA
- Known Issue / Troubleshootingへ昇格すべき知見（該当時）
