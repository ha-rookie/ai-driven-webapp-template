# Documentation Scoped Instruction

## Applies When

次のいずれかに該当する場合に適用する。

- `docs/**`、`README.md`、`AGENTS.md` 等の文書を変更する
- Requirement / Architecture / Operation / process documentationを更新する
- docs-only変更としてRuntimeへ直接影響しない

## Scope Hints

主なpath例:

- `docs/**`
- `README.md`
- `AGENTS.md`
- `.github/ISSUE_TEMPLATE/**` / PR Templateの説明文

## Sources to Read

必要範囲で次を参照する。

- `docs/README.md`
- `docs/05_DESIGN_MANAGEMENT.md`
- `docs/04_REPOSITORY_STRUCTURE.md`
- `docs/CONVERGENCE_GATE.md`
- 対応Issue
- 変更対象の担当文書

## Rules

- 同じ事実を複数文書へコピーして複数正本化しない
- 担当外文書からはlink / design ID / path参照を優先する
- docs-only変更でもIssue Change Contract、Planned Files、CI Evidenceを省略しない
- Runtime変更がない場合はProduction Verificationを形式的に要求しない
- 文書に書いた未実行操作を「実施済み」と表現しない
- 現在値・外部仕様・Quota等は必要ならEvidenceで確認する
- Template共通原則とProject固有事項を分離する

## Do Not

- Chat上だけで確定仕様を残さない
- 文書を整える目的でRequirementの意味を暗黙変更しない
- READMEを全仕様の正本にしない
- Tool固有syntaxをTool-neutralなPlaybook / Instructionの意味として固定しない
- docs-onlyという理由だけでScope Guard / Human Merge Gateを省略しない

## Validation / Evidence

最低限、次を確認する。

- link / path参照の整合
- 同じ事実の重複正本化がない
- Planned Files内の変更だけである
- Repository validation
- Development Convergence
- Runtime / Production確認が非該当なら、その理由が明確
