# Release Playbook

## Purpose

Merge済みの変更をProductionへ反映し、Deploy成功ではなくRelease完了までEvidenceで確認する。

## Preconditions

- 対象PRがHuman approval後にMerge済み
- Development Convergenceが成立している
- Release対象commit / merge commitを特定できる
- Runtime impactがある場合、ProjectのProduction経路・Rollback方法が定義されている

## Evidence to Read

- `docs/HUMAN_AI_COLLABORATION.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/PRODUCTION_VERIFICATION.md`
- `docs/CONVERGENCE_GATE.md`
- 対応Issue / PR / merge commit
- Production deploy workflow / Cloudflare設定（該当時）
- Project固有の実機・business flow確認手順

## Steps

1. Release対象main / merge commitと変更Impactを確認する
2. `docs/RELEASE_CHECKLIST.md` から該当Sectionだけを選ぶ
3. Production / Publicの重要操作にHuman Gateが必要なら承認を確認する
4. 対象commitをProductionへDeployする
5. Deploy結果とstable Production URLを記録する
6. `production-verification.md` に従いProductionを実測する
7. UI / Mobile / Sensor / External API等、Impactに応じたHuman / Project-specific確認を実施する
8. Production実態とmainの設計・運用を照合する
9. Design / Operation Meaningが変わった場合は必要なNotion最終設計同期を行う
10. 後日観測が必要な項目はRelease条件と分離し、別Issue / Taskへ切り出す
11. `docs/CONVERGENCE_GATE.md` に従いRelease Convergenceを確認する
12. Issue / PRへRelease Evidenceを記録し、完了条件を満たしたらCloseする

## Human Gates

- Production Deploy / Public化等、RepositoryルールでHuman approvalが必要な操作
- 実機確認
- Security / Data / High Risk releaseの最終判断
- Rollbackまたは破壊的復旧操作

## Stop Conditions

- Release対象commitを一意に特定できない
- Production binding / secret / targetが不明
- Deploy結果しかなくProduction Evidenceがない
- Productionでmainと異なる挙動を確認
- Security / Data / major regressionを検出
- 必須Human確認が未完了
- 外部Quota / permissionで必須Verificationができない

## Validation

- Deploy対象commitとProductionが一致
- Production Verification成功
- Impactに応じた実機・主要flow確認済み
- Release Checklistの適用項目が完了
- 未確認項目を成功扱いしていない
- Release Convergence = `Converged`

## Output / Evidence

- Production URL
- deploy run / deployment record
- target commit / merge commit
- Production smoke / machine verification
- Human / project-specific verification
- design sync結果
- Release Convergence
- rollback target
- follow-up Issue / Task（該当時）
