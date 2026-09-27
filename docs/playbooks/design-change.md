# Design Change Playbook

## Purpose

Architecture、画面構造、Data、外部IF、Security、運用等の意味が変わる変更を、実装より先に正本へ反映し、必要なHuman Design decisionを残す。

## Preconditions

- 変更理由と対象領域が説明できる
- 対応IssueにScope / Risk / Impact / Validation / Stop Conditionsがある
- 更新対象となる正本設計書を特定できる

## Evidence to Read

- `docs/HUMAN_AI_COLLABORATION.md`
- `AGENTS.md`
- 対応Issue
- `docs/README.md`
- `docs/05_DESIGN_MANAGEMENT.md`
- 関連Requirement / Architecture / Application Architecture / Visual Design / ADR / Traceability
- `docs/CONVERGENCE_GATE.md`
- 現在の実装・test（設計との乖離確認用）

## Steps

1. Read-onlyで現在の設計正本、実装、Issue Goalを確認する
2. 変更がSmall ChangeかMaterial Changeかを判定する
3. 更新すべきSource of Truthを特定し、同じ事実を複数文書へコピーしない
4. 代替案がある重要判断はADRへ理由・採否を残す
5. Requirement変更がある場合はRequirement / Traceabilityを更新する
6. UI認識差が出る場合はVisual Design / Design Previewを用意する
7. Material Changeでは必要なHuman Design reviewを受け、承認対象SHA / Design IDを固定する
8. 同一Issueで実装可能なSmall Changeなら、承認済み設計に続けて実装する
9. 分離が必要なMaterial Changeでは、Implementation Issueへ承認Design PR / SHA / Design IDを引き継ぐ
10. 実装後はDevelopment Convergenceで設計と実装の整合を確認する

## Human Gates

- Architecture、認証、課金、Data schema、外部IF等の重要判断
- UI構造・Visual方向性で人間判断が必要な場合
- Scope拡張 / Risk上昇
- 既存Human decisionを変更する場合
- Design PR / Merge approval（分離する場合）

## Stop Conditions

- 正本設計書が特定できない
- 複数案からAIだけで重要判断を確定する必要がある
- Requirementと変更要求が矛盾する
- Planned Files外の設計書更新が必要
- Business Application固有の認証・認可・DB標準をTemplateへ持ち込む必要がある

## Validation

- 変更理由と影響範囲が追跡可能
- Requirement / Design / ADR / Traceabilityの責務が重複していない
- 実装前に必要な設計が更新されている
- Human decisionが必要な箇所は承認Evidenceがある
- 実装後はDevelopment Convergenceで整合を確認

## Output / Evidence

- 更新したDesign source / Design ID
- ADR（該当時）
- Human approval / approval SHA（該当時）
- Design Preview（該当時）
- Implementation Issueへのhandoff情報（分離時）
- Development Convergence結果（実装まで同一変更で行う場合）
