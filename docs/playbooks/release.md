# Release Playbook

## Purpose

Merge済みの変更をProductionへ反映し、Deploy成功ではなくRelease完了までEvidenceで確認する。

正式Release前にUser Testを行うProjectでは、Release Candidate Gateを使って「User Testへ渡してよい状態」と「正式Releaseしてよい状態」を分離する。

## Preconditions

- 対象PRがHuman approval後にMerge済み
- Development Convergenceが成立している
- Release対象commit / merge commitを特定できる
- Runtime impactがある場合、ProjectのProduction経路・Rollback方法が定義されている

User Testを行う場合は追加で、candidateを確認するenvironment / URLと、User Test開始を止めるseverity基準を定義する。

## Evidence to Read

- `docs/HUMAN_AI_COLLABORATION.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/RELEASE_EVIDENCE.md`
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
8. User Testを行う場合は `Release Candidate Gate / User Test Ready` を確認し、通過したcandidateをbaselineとして固定する
9. User Testで得たfeedbackを最低限 defect / improvement に分類し、重大defectが見つかった場合はUser Test Readyを取り消してGateへ戻す
10. 正式Release判断へ進むcandidateについて、Production実態とmainの設計・運用を照合する
11. Design / Operation Meaningが変わった場合は必要なNotion最終設計同期を行う
12. 後日観測が必要な項目はRelease条件と分離し、別Issue / Taskへ切り出す
13. `docs/CONVERGENCE_GATE.md` に従いRelease Convergenceを確認する
14. Issue / PRへRelease Evidenceを記録し、完了条件を満たしたらCloseする

## Release Candidate Gate / User Test Ready

User Testは正式Releaseの代替ではなく、候補版を実利用に近い条件で評価するための独立Gateとして扱う。

### Gate Inputs

ProjectのRisk / Impactに応じて、少なくとも次を確認する。

- Development Convergence = `Converged`
- User Test対象commit / merge commitを一意に特定できる
- candidateを実際に使うenvironment / URLを特定できる
- 必要なCI / build / automated validationが成功している
- User Test対象environmentで代表的な主要flowを確認済み
- UI / Smartphone等、対象利用形態に必要な実機確認が完了している
- Authentication / Authorizationを持つ場合、その主要境界を確認済み
- shared data / mutationを持つ場合、data integrity / stale / concurrency等の主要Riskを確認済み
- PerformanceがUser Test成立条件になる場合、必要な代表測定を確認済み
- known blockerが0件

ProductionをUser Test対象にするProjectでは、Production VerificationをGate Inputに含める。Preview / Test等をUser Test対象にするProjectでは、そのenvironmentについて同等のcandidate Evidenceを残し、Production Verifiedと誤記しない。

### Severity

User Test開始可否を判断するため、known issueを少なくとも次のように分類する。

| Severity | Meaning | User Test Gate |
| --- | --- | --- |
| Blocker | 起動不能、主要flow継続不能、Security / Auth / Data Integrity上の重大Risk、data loss等 | 1件でもあれば開始しない |
| Major | 主要機能に大きな支障があるが、Scope限定または明確な回避策がある | Humanが影響と回避策を確認して判断 |
| Minor | 限定的な不具合で主要flowを妨げない | Known issueとして記録して開始可能 |
| Cosmetic | 見た目、文言、軽微なUX等で機能成立を妨げない | 原則開始可能 |

Severity名そのものはProjectに合わせて変更できるが、**User Test開始を止めるBlocker条件と known blocker = 0** は明示する。

### User Test Baseline

`User Test Ready` と判定した時点で、Testerが触った版を後から追跡できるようcandidate baselineを固定する。

利用例:

- immutable tag
- prerelease / release candidate record
- commit SHAを伴う配布記録
- Project固有のversion baseline

特定のversion名やSemantic VersioningはTemplateで固定しない。

Baselineには最低限、candidate commit / SHA、対象environment / URL、Gate結果、既知Issueを紐付ける。

User Test開始後にcandidateへ修正を加えた場合、既存baselineを静かに差し替えない。修正版を再検証し、必要なGateを通したうえで新しいbaselineとして識別できるようにする。

### Feedback Entry Point

Tester feedbackは受領時点で少なくとも次へ分ける。

- `defect`: 期待仕様、既存Requirement、設計、動作保証からの逸脱
- `improvement`: 現仕様は成立しているが、UX、使い勝手、機能、運用等の改善提案

判断できないfeedbackは無理にdefectへ寄せず、確認事項として保持してから分類する。

### Feedback Record

User Test feedbackは、発言そのものではなく再判定できるEvidenceとして最低限次を記録する。

- candidate baseline / commit SHA
- 実施したtask / flow
- task success / failure
- 迷った箇所、止まった箇所、質問
- observed behavior
- defect候補の場合はexpected behaviorまたは参照Requirement / Design
- `defect` / `improvement` / `question` / `unclassified` の一次分類
- severity
- 再現条件、screen、log、操作手順等の利用可能なEvidence
- `Project-specific` / `Cross-project candidate` のscope分類
- Runtime bug / UX / documentation / process / template gap の分類
- 次の対応先となるProject Issue / Template Issue / no actionの判断

Testerの氏名、連絡先等の個人情報をTemplate backflowのためにRepositoryへ保持する必要はない。必要な場合もProject側の適切な管理場所で扱い、Templateへは匿名化した技術的Evidenceだけを還流する。

### Feedback Triage

Feedbackは次の順序で整理する。

1. **Outcome** — taskが成功したか、失敗したか、迷いながら成功したか
2. **Type** — defect / improvement / question / unclassified
3. **Severity** — Blocker / Major / Minor / Cosmetic等、Projectのseverity基準
4. **Scope** — Project-specificか、他Projectにも成立し得るCross-project candidateか
5. **Layer** — Runtime bug / UX / documentation / process / template gap
6. **Action** — Project Issue、Template Issue候補、追加Evidence待ち、no action

`Cross-project candidate` はTemplate採用済みを意味しない。Templateへ戻す前の候補分類に留める。

### Project Fix と Template Backflow

Projectを直すIssueと、Templateの共通ルールを直すIssueは分離する。

Project Issueでは、実際にTesterが触った画面・flow・data・Runtimeの修正を扱う。Template Issueでは、Project固有名称やUIを持ち込まず、複数Projectで再利用できる設計原則、workflow、guardrail、checklist、test観点等へ一般化する。

Templateへ還流する候補は、少なくとも次のいずれかをEvidenceで説明できる場合に検討する。

- 同種の問題が複数のProject / flow / testerで再現した
- 原因がProject固有実装ではなく共通workflow / design gapにある
- 再発防止の判断基準やcheckを他Projectでも適用できる
- 一度標準化すると将来の判断コストや事故Riskを横断的に下げられる

単発の好み、質問、再現性の弱い指摘、Project固有制約だけではTemplate標準へ昇格しない。Evidenceが弱い場合はProject側で観測を続け、必要なら追加User Testや別Projectでの再現を待つ。

Templateへ戻す場合は、新しいTemplate IssueとしてSource / Lesson LearnedとProject側Evidenceへの参照を残す。Project IssueとTemplate Issueを1つのScopeへ混ぜない。

### User Test Lessons Learned

User Test完了時は、feedback件数そのものではなく、今後再利用できる判断を整理する。

- Project固有のdefect / improvementはProject Issueとして追跡する
- 共通化候補はEvidenceを確認してTemplate Issueへ分離する
- documentation不足は該当正本へ戻す
- process / collaboration gapはworkflow / guardrailの正本へ戻す
- template gapは具体実装ではなく共通原則として還流する
- 一度きりの弱いEvidenceはLessons Learned候補として保持し、即標準化しない

Notion等の横断知識基盤を使う場合は、Template Issue / mainへ反映済みの確定知識と、まだ仮説段階のfeedbackを分けて記録する。Notion自体を必須正本にはしない。

### Gate Rollback

User Test中にBlocker相当、またはUser Test継続が不適切な重大defectが見つかった場合は、`User Test Ready` を継続扱いしない。

1. 影響範囲に応じてUser Testを停止または対象flowを停止する
2. defectとしてIssue化し、原因と修正Scopeを明確にする
3. 修正後にDevelopment Convergenceと影響範囲のValidationを再確認する
4. 必要なProduction / environment / Human Evidenceを再取得する
5. Release Candidate Gateを再判定する
6. 通過した修正版を新しいbaselineとして固定する

過去baselineは「そのTesterが何を見たか」のEvidenceとして保持し、現在candidateと混同しない。

## Human Gates

- Production Deploy / Public化等、RepositoryルールでHuman approvalが必要な操作
- User Test Readyの最終判断
- Major issueをKnown issueとして残したままUser Testを開始する判断
- 実機確認
- Security / Data / High Risk releaseの最終判断
- Rollbackまたは破壊的復旧操作

## Stop Conditions

- Release対象commitを一意に特定できない
- User Test対象candidate / baselineを一意に特定できない
- Production binding / secret / targetが不明
- Deploy結果しかなく必要なenvironment Evidenceがない
- Productionでmainと異なる挙動を確認
- Security / Data / major regressionを検出
- known blockerが残っている
- 必須Human確認が未完了
- 外部Quota / permissionで必須Verificationができない

## Validation

正式Releaseでは:

- Deploy対象commitとProductionが一致
- Production Verification成功
- Impactに応じた実機・主要flow確認済み
- Release Checklistの適用項目が完了
- 未確認項目を成功扱いしていない
- Release Convergence = `Converged`

User Test開始では:

- Development Convergence = `Converged`
- User Test対象candidateを一意に特定
- 必要なenvironment / Human / Risk Evidenceが揃っている
- known blocker = 0
- `User Test Ready` のHuman判断を記録
- baselineをtag / prerelease / commit等で追跡可能

`User Test Ready` は正式Release完了やRelease Convergenceを意味しない。

## Output / Evidence

- Production URLまたはUser Test対象environment / URL
- deploy run / deployment record
- target commit / merge commit
- Production smoke / machine verification（該当時）
- Human / project-specific verification
- Release Candidate Gate / User Test Ready結果（該当時）
- severity summary / known blocker count（該当時）
- User Test baseline ref（該当時）
- design sync結果
- Release Convergence
- rollback target
- follow-up Issue / Task（該当時）
