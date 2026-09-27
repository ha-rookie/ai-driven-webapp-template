# Feature Development Playbook

## Purpose

新機能・既存機能改善を、Issue Change ContractからDevelopment Convergenceまで一貫して進める。

## Preconditions

- Project Bootstrapが完了している、または対象Projectが既に運用中
- 対応IssueにGoal / In Scope / Out of Scope / Planned Files / Risk / Impact / Validation / Stop Conditionsがある
- 仕様・設計の正本が特定できる

## Evidence to Read

- `docs/HUMAN_AI_COLLABORATION.md`
- `AGENTS.md`
- `docs/README.md`
- 対応Issue
- 関連Requirements / Architecture / Design / ADR / Traceability
- `docs/GIT_WORKFLOW.md`
- `docs/PLANNED_FILES_GUARD.md`
- `docs/CONVERGENCE_GATE.md`
- 関連test / workflow / existing implementation

## Steps

1. Read-onlyでmain、Issue、関連設計、既存実装、test、外部制約を確認する
2. IssueのScopeと現状Evidenceが一致することを確認する
3. Requirement / Design変更が必要なら、該当正本を実装より先に更新する
4. Materialな設計変更なら `design-change.md` を先に適用する
5. Issue番号を含む専用Branchを作成する
6. Planned Files内でMinimum Necessary Diffを実装する
7. Risk / Impactに応じたlint / test / build / static validationを実行する
8. 必要なPreviewを準備し、Toolで確認可能な範囲を検証する
9. PRを作成し、Issue、変更、非対象、Evidence、未検証を記録する
10. CI / Scope Guardを確認し、失敗時は原因分類して修正する
11. `docs/CONVERGENCE_GATE.md` に従いDevelopment Convergenceを確認する
12. `Converged` となったhead SHAをHuman Review対象として固定する
13. Human Merge approvalで停止する
14. Merge後にProduction Releaseがある場合は `release.md` へ進む

## Human Gates

- Material Design decision
- Scope拡張 / Risk上昇
- Binary Asset upload / 新規画像生成
- UI・Mobile・Sensor等の実機確認が必要な場合
- Merge approval
- Production / Publicの重要操作

## Stop Conditions

- Planned Files外の変更が必要
- Issue Goalでは説明できない別問題を発見
- 仕様が曖昧でAI推測が必要
- Security / Data / Architecture影響がIssue想定より拡大
- 必要な外部Capability / Quota / permissionが利用不能
- Development Convergenceに未解決矛盾が残る

## Validation

- Issueと実変更Scopeが一致
- 必要な設計更新が先行している
- Risk / Impactに必要な検証が実行済み
- 未実行checkを成功扱いしていない
- Scope Guard / CI結果をEvidenceとして確認
- Development Convergence = `Converged`

## Output / Evidence

- Branch / PR
- changed files
- lint / test / build / CI結果
- Preview / Human確認結果（該当時）
- Development Convergence結果
- Human Review対象head SHA
- unresolved / blocked事項
