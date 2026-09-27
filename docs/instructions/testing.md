# Testing Scoped Instruction

## Applies When

次のいずれかに該当する場合に適用する。

- test code / validation script / test commandを変更する
- CIのtest / lint / build条件を変更する
- Regression、acceptance criteria、Production smokeの検証方法を変更する
- IssueのValidationにtest変更が含まれる

## Scope Hints

主なpath例:

- `tests/**`
- `scripts/**` の検証script
- `.github/workflows/**` のtest / validation step
- `package.json` 等のtest command

Pathだけでなく作業意図で適用を判断する。

## Sources to Read

必要範囲で次を参照する。

- `docs/GIT_WORKFLOW.md`
- `docs/RISK_AWARE_CI.md`
- `docs/CONVERGENCE_GATE.md`
- `docs/RELEASE_EVIDENCE.md`
- 対応IssueのAcceptance Criteria / Validation
- 対象Requirement / Design

## Rules

- test成功とRequirement充足を同一視しない
- Acceptance Criteriaに対応するEvidenceを特定する
- changed files / Impact Flagsに応じた検証を選ぶ
- unknown / high-impact変更を軽いprofileへ推測で落とさない
- CI失敗時は原因分類を行い、未修正のままrerunを繰り返さない
- test自体を変更する場合、現仕様に合わせた正当な変更か、単なるpass目的の弱体化かを区別する
- 実行できなかったtestは未検証として記録する

## Do Not

- failing testを理由なくskip / delete / loosenしない
- testが通るようRequirementや期待値を暗黙変更しない
- CI quotaや外部障害をsuccessへ読み替えない
- docs-only変更に重いbrowser / runtime testを形式的に追加しない
- Project固有test commandをTemplate共通Instructionへ固定しない

## Validation / Evidence

最低限、次を残す。

- 実施したtest / lint / build / validation
- 未実施項目と理由
- CI run / local evidence等の参照
- Acceptance Criteriaとの対応
- Development Convergenceで未解決の検証がないか
