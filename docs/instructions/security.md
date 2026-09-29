# Security Scoped Instruction

## Applies When

次のいずれかに該当する場合に適用する。

- Security Header、公開範囲、秘密情報、外部公開境界を変更する
- Secrets / Variables / Bindingsの扱いを変更する
- Public Repository、Production、外部API接続等でSecurity影響がある
- Authentication / External Identity / Application User / Sessionの境界を設計・変更する
- Issueの `Security / Secret / Infra` Impact FlagがYes

## Scope Hints

主なpath / task例:

- Security config / headers
- `.github/workflows/**` のSecrets利用
- `wrangler.*`
- `functions/**`, `workers/**`
- Public / Private変更
- external API credential handling
- authentication / session / external identity design

## Sources to Read

必要範囲で次を参照する。

- `docs/SECURITY_BASELINE.md`
- `docs/HUMAN_AI_COLLABORATION.md`
- `docs/02_SYSTEM_ARCHITECTURE.md`
- `docs/03_APPLICATION_ARCHITECTURE.md`
- `docs/CLOUDFLARE_SETUP.md`
- `docs/PUBLIC_WEB_QUALITY.md`
- 対応Issue / ADR

## Rules

- 秘密値をRepositoryへcommitしない
- Secrets名・Binding名と実値を分離する
- 公開範囲変更は明示的なHuman Gateとして扱う
- Security Header等は設計だけでなくProduction実測が必要な場合を区別する
- 外部仕様や現在設定を推測で確定しない
- Security影響が増えた場合はRisk / Impact Flagsを見直す
- Project固有のSecurity要件はRequirement / Architecture側を正本にする
- Authentication成功とApplication User解決成功を同一判定にしない
- Sessionが有効でもApplication User / required persistence stateを解決できない場合は、fail-safeに未認証相当へ戻すかSessionを無効化する方針を定義する
- External Identity / Application User / Session / Persistenceの責務を分け、特定Provider固有claimをApplication Userの正本へ直結させない
- 複数ProviderやProvider変更を想定する場合、External IdentityとApplication Userの対応関係を明示する

## Do Not

- Security確認を「CIが通った」だけで完了扱いにしない
- credential / token / private key / passwordを例示目的でも実値で残さない
- PreviewからProduction秘密値やProductionデータへ無断接続しない
- 認証・認可方式の共通実装標準をこのInstructionへ追加しない
- Provider SDK、Cookie名、JWT library、middleware等の具体実装を旧Templateの必須標準にしない
- Business Application Template向けのRBAC / SAML / transaction / audit log等を既存Templateの必須機能へ広げない

## Validation / Evidence

該当範囲で次を確認する。

- secret exposureなし
- Security / Public範囲に対応する設計・Issue Evidence
- Authentication / Session変更時は、正常系に加えてinvalid / stale / orphaned stateの期待結果
- 必要なheader / Production smoke / external check
- 未検証項目と理由
- Human approvalが必要な変更では承認対象head SHA
