# Release Evidence

## 1. 目的

Human Reviewで必要な証跡をGitHub ActionsのJob Summaryへ自動集約し、PR本文への手入力を減らす。

Release Evidenceは「Release済み」を意味しない。

CI中に生成されるEvidenceは、PR時点の実装・Scope・CI結果をまとめた **CI Evidence** であり、Production VerifiedやUser Test Readyとは分けて扱う。

## 2. CI Evidence

Risk-aware Project CIでは、既存の `CI Gate` Jobの最後に `$GITHUB_STEP_SUMMARY` へEvidenceを出力する。

新しいEvidence専用Jobは作らない。

記録する項目:

- Repository
- Pull Request番号 / URL
- Change Contract Issue番号
- Base SHA
- Head SHA
- Risk-aware profile
- Scope Guard result
- Classify result
- docs / design / runtime / strict validation result
- changed files
- Workflow run URL
- generated timestamp
- Production status

Production statusはPR CIでは必ず次のように扱う。

```text
Production: Not evaluated by this CI
```

CI成功だけでProduction Verifiedと記録しない。

## 3. Template Repository Evidence

Template Repository自身の `Repository validation` でも、同じ考え方でJob Summaryを生成する。

最低限:

- Repository
- PR
- Change Contract Issue
- Base SHA
- Head SHA
- Scope Guard
- changed files
- Repository validation result
- Workflow run URL
- generated timestamp
- Production: Not applicable / Not evaluated

## 4. Evidenceの役割

EvidenceはHuman Reviewを速くするための材料であり、Human判断を代替しない。

Evidenceがsuccessでも以下は別途必要になり得る。

- UI / Browser / Smartphone review
- Sensor実機確認
- Binary Asset確認
- Security review
- Merge approval
- Production deploy
- Production smoke
- Production上の主要回帰
- Release Candidate Gate / User Test Ready判断
- Analytics / Security Headers確認

## 5. Actions消費

Evidence生成のためだけにrunner/jobを追加しない。

既存Job内でJob Summaryを書くだけにする。

避けるもの:

- Evidence専用Workflow
- Evidence専用runner
- PR comment自動投稿のためのwrite permission
- artifact uploadをEvidenceの必須条件にすること

## 6. 権限

Evidenceはread-only情報から作る。

Project CI:

- contents: read
- issues: read
- pull-requests: read

PR / IssueをWorkflowから編集しない。

## 7. Human Review時の使い方

Human Reviewでは、PR本文とActions Job Summaryを合わせて確認する。

最低限:

1. Change Contract Issueが意図したものか
2. Head SHAが承認対象と一致するか
3. Scope Guardがsuccessか
4. selected profileが差分に対して妥当か
5. 必須validationがsuccessか
6. changed filesに違和感がないか
7. Production未確認をCI成功と混同していないか
8. User Testを行う場合、candidate baselineとGate結果が追跡可能か

## 8. 状態表現

状態は上位状態を推測せず、取得できたEvidenceだけで表現する。

- Implemented: 実装作成済み
- CI Validated: 必須CI success
- Development Converged: Development Convergence = `Converged`
- Blocked: 外部制約 / 未解決問題
- Production Verified: Merge後に対象Productionを実測済み
- User Test Ready: Release Candidate Gateを通過し、HumanがUser Test開始可と判断したcandidate
- Release Converged: 正式Release条件とRelease Convergenceを満たした状態

`User Test Ready` は `Release Converged` を意味しない。逆に、User Testを実施しないProjectでは `User Test Ready` を経由せず正式Releaseへ進んでよい。

## 9. Production Evidence

Production Verificationでは `docs/PRODUCTION_VERIFICATION.md` と `scripts/verify-production.sh` により、GitHub Actions Job SummaryへProduction Evidenceを出力する。

PR CI Evidenceとは別フェーズとして扱う。

- PR CI Evidence: Merge前のScope / SHA / CI結果
- Production Evidence: Merge後のProduction実レスポンス
- Human / Project-specific Evidence: Browser / Smartphone / Sensor / business flow / Analytics / GSC / external security diagnostics

Production Evidenceが生成されても、Project要件上必要なHuman / Project-specific確認が未完了ならRelease完了とは扱わない。

## 10. User Test Candidate Evidence

正式Release前にUser Testを行う場合、Release Candidate Gateの結果を既存Evidenceから組み立てて記録する。

最低限、次を追跡できるようにする。

- candidate commit / merge commit SHA
- User Test対象environment / URL
- Development Convergence結果
- CI / build / automated validation結果
- 必要なProductionまたはcandidate environment verification
- 実機 / Smartphone / Browser等のHuman確認
- Authentication / Authorization / Data Integrity / Performance等、Project Riskに応じた代表Evidence
- severity summary
- known blocker count
- Majorを残す場合のHuman判断と回避策
- User Test Ready判定
- candidate baseline ref（tag / prerelease / commit record等）
- known issues
- 判定日時 / Human decision

User Test Candidate Evidenceのためだけに新しいWorkflowや専用runnerを必須化しない。既存CI / Production / Human Evidenceへの参照と、Issue / PR / prerelease等の記録で構成してよい。

Baseline名やversion形式はProject固有とし、このTemplateでは固定しない。

User Test開始後にcandidateが変わった場合、旧baselineを静かに上書きせず、新candidateのSHAとGate結果を別に追跡できるようにする。

## 11. Gate Rollback Evidence

User Test中にBlocker相当または重大defectが見つかり `User Test Ready` を取り消した場合、少なくとも次を残す。

- 発見したdefect / Issue
- severity
- 影響したbaseline
- User Test停止 / 範囲制限の判断
- 修正candidate SHA
- 再実施したDevelopment Convergence / validation / environment verification
- 再判定したRelease Candidate Gate結果
- 新しいbaseline ref

過去baselineはTesterが実際に触った版のEvidenceとして保持し、現在candidateと混同しない。
