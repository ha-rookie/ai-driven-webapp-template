# Testing Scoped Instruction

## Applies When

次のいずれかに該当する場合に適用する。

- test code / validation script / test commandを変更する
- CIのtest / lint / build条件を変更する
- Regression、acceptance criteria、Production smokeの検証方法を変更する
- Concurrency / stale mutation / atomic updateの検証を設計・変更する
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
- `docs/03_APPLICATION_ARCHITECTURE.md`
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
- stale mutationを検証する場合、Read / View時に観測したfreshness evidenceを固定し、その後に別Client / Request等で状態を変更してから元の観測状態でMutationする
- Mutation直前に対象resourceを再readしてfreshness evidenceを最新化し、stale条件を消してからtestしない
- updateだけでなくdelete / finalize / approve / close等、古い状態を前提にするMutationへ同じ観点を適用する
- 複数resourceを変更するOperationでは、conflict / failure後にpartial writeが残らないことを確認する
- child mutationがparent aggregateの有効性へ影響する場合、parent側のfreshness / aggregate stateも期待どおり進むか確認する
- conflict検出だけでなく、その後のreload / retry / cancel等の期待Recoveryと最終Persistence状態を確認する

## Do Not

- failing testを理由なくskip / delete / loosenしない
- testが通るようRequirementや期待値を暗黙変更しない
- CI quotaや外部障害をsuccessへ読み替えない
- docs-only変更に重いbrowser / runtime testを形式的に追加しない
- Project固有test commandをTemplate共通Instructionへ固定しない
- stale testの直前に最新token / version相当を取り直し、競合検出を実質無効化しない
- 「最終的に最新値で更新できた」ことだけでstale mutation拒否を検証済みとしない

## Validation / Evidence

最低限、次を残す。

- 実施したtest / lint / build / validation
- 未実施項目と理由
- CI run / local evidence等の参照
- Acceptance Criteriaとの対応
- Development Convergenceで未解決の検証がないか

Concurrency / stale mutationを扱う場合は、必要に応じて次も残す。

- 最初に観測したstate / freshness evidence
- 競合を発生させた別操作
- 古い観測状態で実行したMutation
- expected conflict / reject結果
- failure後のresource / aggregate最終状態
- conflict後のUI / Application recovery結果
