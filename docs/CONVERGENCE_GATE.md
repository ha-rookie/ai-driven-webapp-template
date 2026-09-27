# Convergence Gate

## 1. 目的

Convergence Gateは、`実装した`、`testが通った`、`Deployした` と **Requirement / Design / Implementation / Test / Evidence / Productionが整合している** ことを分離して判定する。

このGateは新しい仕様のSource of Truthを作らない。既存のRequirement、Design、Issue Change Contract、Pull Request、CI Evidence、Production Evidenceを照合し、矛盾・未確認・未反映を残したまま完了扱いしないための確認面である。

```text
Implementation complete != Converged
CI success != Converged
Deploy success != Release Converged
```

## 2. Source of Truth

Convergence判定では、次の既存Evidenceを参照する。

- Requirement: `docs/01_REQUIREMENTS.md`
- Architecture / Design: `docs/02_SYSTEM_ARCHITECTURE.md`、`docs/03_APPLICATION_ARCHITECTURE.md`、`docs/design/`、`docs/adr/`
- Traceability: `docs/06_REQUIREMENTS_TRACEABILITY.md`
- Change Contract: 対応Issue
- Implementation: 対応Branch / Pull Requestの実変更
- Validation: lint / test / build / Preview / CI Evidence
- Production: `docs/PRODUCTION_VERIFICATION.md` に基づくProduction Evidence
- Release condition: `docs/RELEASE_CHECKLIST.md`

Convergence結果そのものを仕様正本として扱わない。矛盾が見つかった場合は、誤っている側の正本・実装・test・Evidenceを修正する。

## 3. 2段階のConvergence

### 3.1 Development Convergence

Human Merge approval前に確認する。

最低限、次を確認する。

1. IssueのGoal / In Scope / Out of Scopeが最新のRequirement / Designと矛盾していない
2. Planned Filesと実変更fileが一致し、Scope外変更がない
3. Design変更が必要な場合、実装より先に対応する正本が更新されている
4. Requirement / Designに対応する実装が存在する
5. 受け入れ条件に対応するValidation / Evidenceが存在する
6. 必要なlint / test / build / Preview等が実行済みで、未実行項目を成功扱いしていない
7. 既知の矛盾・未解決事項・Stop Conditionが残っていない

Development Convergenceが成立しても、Productionでの正しさを証明したことにはならない。

### 3.2 Release Convergence

Production Releaseがある変更では、Merge / Deploy後に確認する。

Development Convergenceに加えて、次を確認する。

1. 対象main / merge commitがProductionへ配信されている
2. Production Verificationが該当範囲で成功している
3. 必要な実機・主要ユーザーフロー・外部IF等の確認が完了している
4. Production実態とRequirement / Design / Operationが矛盾していない
5. 設計・仕様・運用変更がある場合、mainおよび必要なNotion最終設計が同期されている
6. 未完了の後日観測はRelease完了条件と分離され、別Issue / Taskとして追跡されている

Production Releaseが存在しないdocs-only等の変更では、Release Convergenceを `Not Applicable` としてよい。

## 4. 判定結果

各Gateは、Scopeを明記して次のいずれかで記録する。

- `Converged`: 適用対象Evidenceが揃い、既知の矛盾・未確認がない
- `Not Converged`: 既知の不整合または未反映があり、修正が必要
- `Blocked`: 外部Quota、権限、障害、Human Gate等により必要Evidenceを取得できない
- `Pending`: 後工程でのみ取得可能なEvidenceを待っている。Production前のRelease Convergence等
- `Not Applicable`: その変更にはGate自体が適用されない

`Blocked` / `Pending` / `Not Applicable` を `Converged` に読み替えない。

## 5. Development Convergence確認表

| 観点 | 照合するEvidence | 失敗例 |
| --- | --- | --- |
| Requirement | Requirement / Issue Goal | 実装した機能がRequirementにない |
| Scope | Planned Files / PR changed files | ついで修正が混在 |
| Design | Architecture / Design / ADR | 実装だけ変わり設計が古い |
| Implementation | Design / changed files | Designの一部が未実装 |
| Test | Acceptance criteria / tests | testは通るが受け入れ条件を検証していない |
| Evidence | CI / Preview / Human確認 | 未実行を成功として記録 |
| Open items | Issue / PR / Stop report | 未解決事項を暗黙に無視 |

## 6. Release Convergence確認表

| 観点 | 照合するEvidence | 失敗例 |
| --- | --- | --- |
| Deploy target | main / merge commit / deploy | 古いcommitがProduction |
| Production | Production Evidence | Deploy成功だがHTTP / marker確認失敗 |
| User flow | 実機 / Project-specific check | 自動smokeだけで業務動作を推測 |
| Public quality | Security / SEO / Asset等 | Issue Impact Flagsの確認漏れ |
| Design sync | main / Notion | Production実態と設計が不一致 |
| Remaining work | follow-up Issue / Task | 後日観測をRelease失敗と混同、または未追跡 |

## 7. Human Gateとの関係

Convergence GateはHuman承認を置き換えない。

- Development Convergence `Converged` → Human Merge approvalへ進める条件の一つ
- Human approval済みでも、head SHAが変わった場合は対象Evidenceを再確認する
- Release Convergence `Converged` → Release完了判定の一つ
- High Risk、Security、UI / Sensor / Asset等のHuman確認はImpact Flagsに従い別Gateとして維持する

## 8. External Capability / Quota

必要なCI、Preview、Deploy、Production smoke等がQuota・権限・障害で実行できない場合は `Blocked` とする。

- 未実行checkをpassとして補完しない
- static review等で代替できる範囲と、代替できないEvidenceを分ける
- 制限解除後に必要な再検証を明記する
- GR-007のSTOP Gateを優先する

## 9. Pull Requestへの記録

PRでは最低限、次を記載する。

```text
Development Convergence: Converged / Not Converged / Blocked
Evidence:
Unresolved:
Release Convergence: Pending / Not Applicable / ...
```

Production Release後はRelease Convergenceを更新する。PR本文を唯一のSource of Truthにはせず、Evidenceへの参照面として扱う。

## 10. 完了条件

### Merge前

- Development Convergenceが `Converged`
- 必要なHuman Gateを通過
- review対象head SHAが確定

### Release完了前

Production Releaseがある場合:

- Development Convergenceが成立済み
- Production Verificationと必要な実機確認が完了
- Release Convergenceが `Converged`
- Release Checklistの適用項目が完了

Production Releaseがない変更では、IssueのValidationを満たし、Development Convergenceが成立していればRelease Convergenceは `Not Applicable` とできる。

## 11. 非目的

Convergence Gateは次を目的としない。

- GitHub Spec Kit等の外部framework導入
- 全仕様の自動生成・自動判定
- 新しいRequirement / Designの正本作成
- Human reviewの自動代替
- 未確認事項をAI推論で閉じること
