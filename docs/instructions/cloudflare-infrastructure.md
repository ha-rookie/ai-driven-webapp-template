# Cloudflare / Infrastructure Scoped Instruction

## Applies When

次のいずれかに該当する場合に適用する。

- Cloudflare Pages / Workers / Functions / Bindings / Variables / Secretsを変更する
- deploy workflow、domain、Preview / Production境界を変更する
- Runtime / Security / Secret / Infra Impact FlagがYesで、Cloudflare構成に関係する
- Production delivery pathやrollback方法を変更する

## Scope Hints

主なpath / task例:

- `wrangler.*`
- `functions/**`
- `workers/**`
- `.github/workflows/**` のCloudflare deploy
- `docs/workflow-templates/**`
- Cloudflare project / binding / domain設定

## Sources to Read

必要範囲で次を参照する。

- `docs/CLOUDFLARE_SETUP.md`
- `docs/02_SYSTEM_ARCHITECTURE.md`
- `docs/SECURITY_BASELINE.md`
- `docs/PRODUCTION_VERIFICATION.md`
- `docs/RISK_AWARE_CI.md`
- `docs/RELEASE_CHECKLIST.md`
- 対応Issue / ADR

## Rules

- Preview / ProductionのProject、Bindings、Secrets、Data境界を明示する
- Deploy成功とProduction Verifiedを分離する
- Secret値はRepositoryへcommitしない
- Cloudflareの現在仕様・Quota・設定値を推測で確定しない
- 変更前にrollback / recovery経路を確認する
- GitHub Actionsの実行枠や外部Quotaを有限資源として扱う
- Infrastructure変更はRisk上昇の可能性を確認する

## Do Not

- PreviewからProduction dataへ無断writeしない
- Deploy成功だけでRelease完了としない
- 外部Quota制約を理由に未実行checkをsuccess扱いしない
- Project固有のaccount ID / secret / domainをTemplate共通Instructionへ固定しない
- DB transaction、migration、business audit等をCloudflare一般ルールとして取り込まない

## Validation / Evidence

該当範囲で次を残す。

- deploy対象commit / environment
- binding / variable / secretの存在確認（値そのものは記録しない）
- Production Verification結果
- rollback先 / recovery方法
- 外部Quota・権限制約による未検証項目
