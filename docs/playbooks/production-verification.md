# Production Verification Playbook

## Purpose

Production Deploy後に、実際のProductionが意図したApplication / commit / behaviorであることを確認する。Deploy操作そのものはこのPlaybookの責務に含めない。

## Preconditions

- stable Production URLを特定できる
- 対象deploy / commit / merge commitを特定できる
- Production Verificationの適用範囲をIssue Impact Flagsから判断できる

## Evidence to Read

- `docs/PRODUCTION_VERIFICATION.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/CONVERGENCE_GATE.md`
- 対応Issue / PR / merge commit
- Production deploy evidence
- Project固有の主要flow / API / device確認手順

## Steps

1. stable Production URLと対象commitを確認する
2. 共通scriptが利用可能なら `scripts/verify-production.sh` で機械検証を実行する
3. HTTPS / HTTP status / stable marker等の共通必須項目を確認する
4. Issue Impactに応じてSecurity Headers / OGP / Assets等のoptional machine checksを適用する
5. Runtime endpoint / API / Pages Functions / Workersがある場合はProject固有の実レスポンスを確認する
6. UI / Mobile / Sensor / Camera / Location等、人間・実機でしか確認できない項目を分離する
7. console / network / major user flow等のProject-specific regressionを必要範囲で確認する
8. 確認不能項目は理由と再確認条件を記録し、成功へ変換しない
9. Production EvidenceをIssue / PRへ残し、Release Playbookへ結果を返す

## Human Gates

- スマホ・実機操作
- 位置情報 / Sensor / Camera / Microphone等の実端末確認
- UI品質や業務flowの最終判断
- Security / Data異常を検出した際の継続・Rollback判断

## Stop Conditions

- stable Production URLが不明
- deploy対象commitを確認できない
- HTTP / marker等の必須machine checkが失敗
- Productionで重大なconsole / network / API errorを検出
- Preview / stagingをProductionとして誤認する可能性がある
- 必須実機確認ができずRelease判断に必要なEvidenceが不足

## Validation

- Production URLを実測している
- Deploy successだけでVerifiedとしていない
- 共通machine verificationとProject-specific / Human verificationを分離
- 未実行checkを成功扱いしていない
- Evidenceが対象commitと紐づいている

## Output / Evidence

- Production URL
- target commit / deploy record
- machine verification結果
- project-specific verification結果
- Human verification結果（該当時）
- failed / blocked / unverified項目
- Release Convergence判定に渡すEvidence
