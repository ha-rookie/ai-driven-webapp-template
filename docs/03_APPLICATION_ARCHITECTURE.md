# Application Architecture

## 1. 文書目的

この文書は、アプリ内部の論理構成、Module責務、依存関係、状態、データ処理、エラー境界の正本とする。

システム外部との配置関係は `02_SYSTEM_ARCHITECTURE.md`、物理ファイル配置は `04_REPOSITORY_STRUCTURE.md` に分離する。

## 2. Logical Architecture

```text
Presentation / UI
      |
      v
Application / Use Case
      |
      v
Domain / Core Logic
      |
      v
Infrastructure / External I/O
```

この4層を必須とはしない。採用しない場合は実際の責務分割を記載する。

## 3. Component Responsibilities

| ID | Component | Responsibility | Inputs | Outputs | Must Not Do |
| --- | --- | --- | --- | --- | --- |
| APP-001 | CHANGE-ME | CHANGE-ME | CHANGE-ME | CHANGE-ME | CHANGE-ME |

「Must Not Do」を記載し、責務の肥大化を防ぐ。

## 4. Dependency Rules

- UIから外部APIを直接呼ぶか: CHANGE-ME
- Domain/CoreがDOMへ依存するか: CHANGE-ME
- InfrastructureがUI状態を持つか: CHANGE-ME
- Module間の循環依存: 禁止/CHANGE-ME
- 外部ライブラリ追加条件: CHANGE-ME

## 5. Routing / Screen Composition

| ID | Route/Screen | Purpose | Entry | Main Actions | Exit |
| --- | --- | --- | --- | --- | --- |
| UI-001 | CHANGE-ME | CHANGE-ME | CHANGE-ME | CHANGE-ME | CHANGE-ME |

画面の視覚詳細は `design/` を正本とし、ここでは役割と遷移だけを扱う。

## 6. State Management

| State | Scope | Source of Truth | Persistence | Reset Condition |
| --- | --- | --- | --- | --- |
| CHANGE-ME | UI/App/Server | CHANGE-ME | none/localStorage/server | CHANGE-ME |

- 永続化が必要な理由を明記する
- localStorage/Cookieへ個人識別情報を入れる場合はSecurity設計を更新する
- 初期値、壊れた保存値、schema version変更時の挙動を定義する
- 複数Persistence Backendを持つ場合、各Backendの役割、Production Source of Truth、選択条件、未設定時Default、未知値の扱いを明示する
- legacy / migration用Backendを残す場合、どの明示条件でのみ選択されるか、移行完了後に暗黙fallbackを許可するかを定義する
- Authentication / AuthorizationとBusiness Dataが別のSourceを参照し得る場合、同一User / resourceに対して矛盾したSource of Truthを選ばないInvariantを定義する

### Persistence Selection Invariant

複数Backendを切り替えるProjectでは、Repository / Adapter単体だけでなく、**どの実装を選択するかを決めるComposition Root**も設計・test対象とする。

例:

```text
explicit legacy marker -> legacy backend
current marker         -> current backend
marker missing         -> defined default
unknown marker         -> defined default or explicit error
```

`missing = legacy` のような暗黙fallbackは、移行後の新規Browser Context、standalone Web App、private mode、再インストール等で古いBackendを意図せず復活させる可能性がある。採用する場合は理由とRelease後の終了条件を明記する。

## 7. Runtime Sequence

```text
User Action
  -> UI validation
  -> Application use case
  -> Core calculation / data access
  -> Result
  -> UI render
```

主要ユースケースごとに必要ならSequenceを追加する。

## 8. Data Model

| ID | Model | Key Fields | Owner | Validation | Persistence |
| --- | --- | --- | --- | --- | --- |
| DATA-001 | CHANGE-ME | CHANGE-ME | CHANGE-ME | CHANGE-ME | CHANGE-ME |

DBを使わない場合も、JSON schemaやブラウザ内データ構造を記載する。

## 9. Interfaces

| ID | Interface | Direction | Request/Input | Response/Output | Error Contract |
| --- | --- | --- | --- | --- | --- |
| IF-001 | CHANGE-ME | In/Out/Internal | CHANGE-ME | CHANGE-ME | CHANGE-ME |

API、Pages Functions、Workers、静的JSON、外部リンクなどを含む。

## 10. Error Handling

- 入力不正: CHANGE-ME
- 外部I/O失敗: CHANGE-ME
- データ欠損: CHANGE-ME
- タイムアウト: CHANGE-ME
- Storage失敗: CHANGE-ME
- Analytics失敗: Core機能へ波及させない/CHANGE-ME

「例外を握りつぶして正常値を返す」を標準にしない。

## 10.4 Authentication / Identity / Session Boundary

Authenticationを持つProjectでは、ProviderのLogin成功だけでApplication上の認証状態が成立したとみなさず、External Identity / Application User / Session / Persistenceの境界を設計する。

静的配信のみ、匿名利用のみ、Authenticationを持たないProjectへ一律に要求しない。

### Responsibility Separation

少なくとも次の責務を分ける。

| Concern | Responsibility |
| --- | --- |
| External Identity | 外部Providerが確認したidentityを表す |
| Application User | Application内部のactor / user stateを表す |
| Session | 認証済み状態を一定期間再利用するための状態を表す |
| Persistence | User / External Identity link / Session等のSource of Truthを保持する |

External Provider固有のsubject / claim / identifierを、そのままApplication Userの永続IDや業務上の正本へ固定するかは明示的に判断する。

### Authentication Resolution Sequence

必要に応じて次を別判定として扱う。

```text
External Authentication
  -> External Identity Resolution
  -> Application User Resolution
  -> User Validity / Required State Check
  -> Session Establishment / Continuation
  -> Authorized Application Action
```

以下を同一判定にしない。

- external authentication success
- application user resolution success
- session validity
- authorization success

`session valid != application user valid` を設計上の前提にする。

### Stale / Orphaned Session

次のような不整合時の期待動作を定義する。

- Sessionは署名・期限等の検証に成功するがApplication Userが存在しない
- Userがdisabled / deleted / unavailableになっている
- External Identity linkが削除・変更されている
- Environment / Persistence切替後にSessionだけが旧Source of Truthを参照している
- SessionとBusiness Dataで異なるUser / resource sourceを参照している

この場合はfail-safeを基本とし、authenticated扱いを継続しない。未認証相当へ戻す、Sessionを無効化する、再認証を要求する等、Projectに適した回復方針を定義する。

UI表示だけを未認証にし、API / Application内部では認証済みのまま残すような二重状態を作らない。

### Multiple External Identities

複数ProviderやProvider変更の可能性がある場合、Application UserとExternal Identityの対応関係を分離する。

必要に応じて以下を定義する。

- 1 Application Userに複数External Identityを紐付けるか
- link / unlink時に必要な本人確認
- Provider廃止・変更時のmigration方針
- 同一identityのduplicate linkをどう扱うか
- identity link変更後の既存Sessionを継続するか

特定ProviderのSDK / callback / claim名等はProject側で決定し、このTemplateでは固定しない。

### Authentication Boundary Testing

Authentication / Sessionを持つProjectでは、正常系Loginだけでなく必要に応じて以下を検証する。

- valid external identity + valid application user
- valid session + missing / invalid application user
- expired / revoked / stale session
- invalid / missing external identity mapping
- Provider / Persistence変更後の既存Session
- reject / recovery後に認証済み状態が残らないこと

具体的なCookie名、JWT / opaque session、HTTP status、middleware、Session Store、認証Provider等はProjectのTechnology / Architectureに合わせて決定する。

## 10.5 Authorization / Resource Scope Boundary

Authorizationを持つProjectでは、Authentication成立だけで操作可能とみなさず、**Actor / Role or Permission / Resource Scope / Operation** を分けて認可判断を設計する。

単一利用者で保護対象がない軽量Projectへ一律に要求しない。複数User、複数組織、複数Project、管理機能、所有者別Data等を扱う場合に適用を検討する。

### Authorization Decision Model

最低限、次の4要素を確認できる形にする。

| Concern | Meaning |
| --- | --- |
| Actor | 誰が操作しようとしているか |
| Role / Permission | そのActorにどの種類の操作が許可されるか |
| Resource Scope | どの組織・Project・Group・所有範囲等へ操作できるか |
| Operation | read / create / update / delete / approve / administer等、何をしようとしているか |

Roleだけで認可を完結させず、Resource Scopeを持つProjectでは「そのRoleがどの範囲に対して有効か」を別に確認する。

### Authentication and Authorization Separation

次を別判定として扱う。

```text
Authentication
  -> Actor Resolution
  -> Role / Permission Evaluation
  -> Resource Scope Evaluation
  -> Operation Decision
```

- authenticatedであることをauthorization successとみなさない
- 管理系Roleであっても、Project要件にないcross-scope操作を暗黙許可しない
- Resource ownership / membership等が必要な場合、対象resourceとの関係を判定する
- deny / allowのDefaultと例外条件を明示する

### UI Boundary vs Enforcement Boundary

UIでButton / Menu / Routeを非表示にすることは、認可保証の代替にしない。

Server / API / protected actionを持つ場合、直接RequestやUI迂回でも同じAuthorization Ruleが適用される境界を定義する。

UI側の表示制御はUXの責務、操作可否の最終判定はSystem側のSecurity Boundaryとして分ける。

### Own-scope / Cross-scope Operations

Resource Scopeを持つ場合、少なくとも以下を区別する。

- own resource / own scopeへの操作
- membershipを持つscopeへの操作
- scope外resourceへの操作
- cross-scope管理操作
- role / membership変更等のprivileged operation

cross-scopeやprivileged operationを許可する場合は、誰に・どの条件で・どの範囲まで許可するかを明示する。

### Administrative Operation Evidence

権限変更、membership変更、scope横断操作等の高Risk操作を持つ場合、必要に応じてactor、対象scope / resource、operation、結果を後から追跡できるEvidence / Audit境界を設計する。

具体的なAudit StoreやLog製品はProject側で決定し、このTemplateでは固定しない。

### Authorization Boundary Testing

Authorizationを持つProjectでは、正常系だけでなく必要に応じて以下を検証する。

- allowed actor + allowed operation + allowed scope
- authenticatedだがinsufficient role / permission
- valid roleだがresource scope外
- own-scopeは成功しcross-scopeは拒否されること
- direct API / protected actionでUI表示制御を迂回しても拒否されること
- role / membership変更による意図しないprivilege escalationがないこと
- reject後にresource / stateが部分変更されていないこと

System Admin / Group Admin / Member等のRole名、RBAC / ABAC / ReBAC library、HTTP status、middleware等の具体実装はProject側で決定し、このTemplateでは固定しない。

## 10.6 Runtime / Data Integrity

server-side state / data mutation、共有Data Store、複数clientからの更新等を持つProjectでは、必要に応じて以下を設計する。静的配信のみ、または単一端末内で完結する軽量Projectへ一律に要求しない。

### Trust Boundary

- Client / UI validationだけをData Integrityの保証境界にしない
- Server / APIを持つ場合、必要なresource relation、scope、ownershipをどこで再検証するか決める
- UI上で操作不能であることを、Security / Integrity上の禁止根拠にしない

### State Transition

- mutableなEntityに状態がある場合、許可する状態遷移と禁止する逆遷移を明示する
- finalized / approved / closed等の確定状態で、何をread-onlyとするか決める
- UI制御だけでなく、Systemとして遷移制約を保証する境界を定義する

### Atomicity

- 1 User Actionで複数resource / recordを変更する場合、一部成功を許容するか定義する
- 一部成功を許容しない場合、failure後に期待する状態を明示する
- Success responseを返す条件と、途中失敗時の回復方針を設計する

### Concurrency

- 同一resourceへ複数client / requestが同時操作する可能性を確認する
- lost update、duplicate create、stale operation等を許容するか、検出・拒否・再試行等で扱うか決める
- 具体的なlock方式、version方式、HTTP status等はProjectのTechnology / Architectureに合わせて決定する

#### Mutation Boundary / Observed State

Concurrencyを検出するProjectでは、単に最新状態をMutation直前に読むのではなく、**Userが操作判断をした時点で観測した状態と、その後のMutationを結び付ける境界**を設計する。

典型的な流れは次のとおり。

```text
Read / View
  -> observed concurrency token or equivalent evidence
  -> Human decision / editing / confirmation
  -> Mutation request with the originally observed evidence
  -> Conditional mutation
  -> Success or Conflict
```

- Read / View時に得たfreshness evidenceを、Human操作からMutationまで保持する
- Mutation直前に同じresourceを再readしてfreshness evidenceを差し替え、stale状態を見えなくしない
- updateだけでなくdelete / finalize / approve / close等、古い状態を前提に行うMutation全般を対象にする
- 「最新値を取得できたこと」と「Userが見た状態がまだ有効であること」を同一視しない

具体的なcolumn名、ETag、timestamp、lock方式、HTTP precondition等はProject側で決定し、このTemplateでは固定しない。

#### Aggregate / Parent-Child Consistency

child resourceのMutationがparent aggregateの有効性・集計・確定可否・freshnessへ影響する場合、parent側の競合判定根拠も同じAtomic operation内で更新すべきか検討する。

- childだけ更新され、parentが古い状態のまま「変更なし」と見える構造を作らない
- parent / childをまたぐInvariantがある場合、どのMutationを1つのAtomic boundaryとして扱うか明示する
- parent側のfreshness evidenceを進める場合は、child writeと分離してpartial successにならないようにする

「必ずparent versionを持つ」等のData Modelは固定せず、aggregateとして何を同時に有効状態へ進める必要があるかを判断する。

#### Conflict Recovery

Conflictを検出した場合のUI / Application状態を定義する。

- stale mutationを成功扱いしない
- conflict後に古いlocal stateを自動上書き保存しない
- 最新状態の再取得、再入力、差分確認、操作中止等、Projectに適した回復導線を定義する
- conflict後にresource / aggregateが部分変更されていないことを確認する

#### Mutation Boundary Audit

重要なMutationごとに、必要に応じて次を確認する。

| Viewpoint | Question |
| --- | --- |
| Observed state | User / Clientはどの状態を見て操作を決めたか |
| Freshness evidence | その観測状態をMutationまでどう保持するか |
| Mutation | update / delete / finalize等、何を変更するか |
| Atomic group | 同時に成功・失敗すべきresourceは何か |
| Conflict behavior | stale時に何を拒否し、どの状態へ戻すか |
| Aggregate impact | child変更がparentの有効性へ影響するか |

このrefinementは #84 で定義したRuntime IntegrityのConcurrency / Atomicity原則を具体化するものであり、別のConcurrency実装標準を作るものではない。

### Invariant Enforcement

- 重要なInvariantごとに、UI / Application / API / Data Store等のどこで保証するか明示する
- concurrent requestでも破れてはいけないInvariantは、client-side validationだけに依存しない
- Application validationとData Store constraintの両方がある場合、それぞれの責務を分ける

このSectionは設計時の判断観点を定義する。optimistic locking、transaction、DB constraint、具体的なerror code等の実装方式をこのTemplateで固定しない。

## 11. PWA / Offline

- PWA採用: Yes / No / TBD
- Service Worker: CHANGE-ME
- Cache対象: CHANGE-ME
- Cacheしない対象: CHANGE-ME
- 更新戦略: CHANGE-ME
- Offline時の縮退: CHANGE-ME

## 12. Analytics

- Page view: CHANGE-ME
- Custom event: CHANGE-ME
- User identifier: 原則作らない/CHANGE-ME
- Failure isolation: CHANGE-ME

## 13. Security Boundaries

- Sanitization / validation: CHANGE-ME
- Secrets access layer: CHANGE-ME
- CSP impact: CHANGE-ME
- Dangerous operations: CHANGE-ME
- Human approval points: CHANGE-ME

## 14. Test Architecture

| Layer | Test Type | Main Targets |
| --- | --- | --- |
| Core | Unit | Pure logic / calculations |
| Application | Unit/Integration | Use cases / state |
| Infrastructure | Integration | API / storage / bindings |
| UI | Regression/E2E | Main flows / mobile |
| Security | Static/Regression | CSP / headers / input |
| Release | Manual | Preview / smartphone / secret mode |

実際の技術スタックに合わせて調整する。

### High-risk Boundary Testing

Security、Authorization、Data Integrity、Concurrency等の重要な境界を持つProjectでは、正常系だけでなく拒否・競合・失敗後状態も検証対象にする。静的配信のみ、または該当境界を持たない軽量Projectへ一律に要求しない。

最低限の検討観点:

- **Positive case**: 許可された操作が期待どおり成功する
- **Reject case**: 未認証、権限不足、invalid operation、resource / scope boundary違反等が拒否される
- **Concurrency / stale case**: 同時操作や古い状態からの操作を許容するか、検出・拒否・再試行等の方針どおりに扱える
- **Failure-after-state**: 失敗・拒否後にdataやstateが意図せず部分変更されていない
- **Composition selection case**: 複数Adapter / Repository / ProviderをRuntime選択する場合、current / legacy / missing / unknown等の主要条件で意図した実装が選ばれる

UI上で操作できないことや、正常系E2Eが成功することだけをSecurity / Integrityのtest evidenceとしない。

具体的なHTTP status、認証provider、test harness、DB fixture、mock方式等はProjectのTechnology / Architectureに合わせて決定し、このTemplateでは固定しない。

## 15. 未決事項

- TBD-APP-001: CHANGE-ME
