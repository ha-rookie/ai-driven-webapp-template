# Evidence-derived Workflow Status

## 1. 目的

Workflow Statusは、新しいチャット・中断・Context喪失後に現在地を素早く把握するための **read-onlyなView / Cache** とする。

Status自体をSource of Truthにはしない。現在地の根拠はGitHub上のIssue / Branch / Pull Request / head SHA / CI / main / Production Evidenceであり、Statusがそれらと矛盾した場合はGitHub Evidenceを優先して再導出する。

```text
GitHub Evidence
  Issue / Branch / PR / SHA / CI / main / Production
                    ↓ derive
             Workflow Status
             authoritative: false
```

Workflow Statusが存在しなくても、`docs/HUMAN_AI_COLLABORATION.md` のGR-008に従って作業復帰できなければならない。

## 2. 非目的

Workflow Statusは次を目的としない。

- 手更新の `workflow-state.yml` を進捗正本にすること
- Issue / PR / mainより強い状態管理面を作ること
- 外部Databaseへ開発状態を保存すること
- Application runtime stateを管理すること
- AIの長期記憶を作ること
- CI / Preview / Production未実行を推測で成功へ変換すること
- Human approvalやConvergence Gateを自動代替すること

## 3. Evidenceの優先順位

Statusを導出・再確認するときは、少なくとも次を直接確認する。

1. Issue / Change Contract
2. Issue番号に対応するBranch
3. 対応Pull Requestとactual changed state
4. PR head SHAとCI / Check結果
5. main / merge state
6. Production Releaseがある場合はProduction Evidence / Release Convergence
7. 設計・運用上必要な場合のみNotion最終設計との同期状態

Issue本文の `Branch:` / `PR:` は探索を速くするTracking Hintとして利用できるが、実在するGitHub Branch / PRと照合する。

Workflow Statusそのものはこの優先順位の最下位に置く。Statusを見たことだけをEvidence確認済みとは扱わない。

## 4. Statusデータモデル

最小モデルは次の情報を持つ。

```json
{
  "schema_version": 1,
  "authoritative": false,
  "derived_at": "2026-09-27T00:00:00Z",
  "repository": "owner/repository",
  "issue": {
    "number": 123,
    "state": "open",
    "title": "...",
    "url": "..."
  },
  "branch": {
    "name": "feat/issue-123-example",
    "head_sha": "..."
  },
  "pull_request": {
    "number": 124,
    "state": "open",
    "url": "...",
    "mergeable": "MERGEABLE",
    "merged_at": null
  },
  "phase": "human-merge-gate",
  "current_human_gate": "merge-approval",
  "ci": {
    "status": "success",
    "checks": []
  },
  "reported": {
    "development_convergence": "Converged",
    "release_convergence": "Not Applicable"
  },
  "preview": {
    "state": "not-derived"
  },
  "production_verification": {
    "state": "not-yet-applicable"
  },
  "blocked_reason": null,
  "blocked_reasons": [],
  "unverified_checks": [],
  "conflicts": [],
  "evidence": []
}
```

`authoritative` は常に `false` とする。

`reported.development_convergence` / `reported.release_convergence` はPR本文等に記録された状態を表示するための補助情報であり、Status生成script自身がConvergence成立を証明したことを意味しない。Human Merge判断では、PRに記載された参照Evidenceを直接確認する。

## 5. Phase

代表的なphaseは次とする。

| Phase | 意味 |
| --- | --- |
| `change-contract` | Issueはあるが対応Branchを導出できない |
| `implementation` | BranchはあるがPRを導出できない |
| `ci-validation` | PRはopenだがCIがpending / not reported / unknown |
| `blocked` | CI failure、Evidence ambiguity等により次へ進めない |
| `development-convergence` | CIは成功したがDevelopment Convergenceがまだ成立したと扱えない |
| `human-merge-gate` | CI成功かつPR上でDevelopment ConvergenceがConvergedと報告され、Merge approval待ち |
| `pr-closed-unmerged` | PRがMergeされずclosed |
| `merged-production-unverified` | Merge済みだがProduction / Release Convergenceを確認できない |
| `merged-release-not-applicable` | Merge済みでRelease Convergenceが非該当と報告されている |
| `release-converged` | Release ConvergenceがConvergedと報告されている |
| `closed-without-derived-pr` | Issue closedだが対応PRを導出できず、追加確認が必要 |

Phaseは作業を進めるためのNavigation情報であり、Release ChecklistやConvergence Gateの代替ではない。

## 6. Human Gate / Blocked / Unverified

Statusは単純なstep番号ではなく、次を分けて表現する。

- `current_human_gate`: 現在明確に待っているHuman承認
- `blocked_reason` / `blocked_reasons`: CI失敗、複数Branch等、次工程へ進めない理由
- `unverified_checks`: Evidence不足・自動導出対象外・未実行の確認
- `conflicts`: IssueのTracking Hintと実在Evidenceの不一致等

`blocked` / `unverified` / `conflict` を成功状態へ丸めない。

## 7. Stale / Conflict

`derived_at` は生成時刻であり、Statusの鮮度保証ではない。

次のいずれかではStatusを再生成する。

- Branch head SHAが変わった
- PRがopen / closed / mergedへ変わった
- CI結果が変わった
- IssueのBranch / PR Trackingが更新された
- Humanから認識不一致を指摘された
- Statusと直接GitHub Evidenceが矛盾する

Conflict時はStatusを修正して辻褄を合わせるのではなく、GitHub Evidenceを確認して再生成する。

Branch / PR候補が複数あり一意に決められない場合、AIは推測せず `blocked` / `conflicts` として扱い、Issue Trackingまたは直接Evidenceで解消する。

## 8. 再開時の使い方

Workflow StatusはGR-008を高速化するNavigation Hintとして使う。

1. 既知のIssue番号がある場合、必要ならStatusをread-onlyで導出する
2. Statusに出たIssue / Branch / PR / SHAへ直接アクセスする
3. 直接EvidenceとStatusが一致することを確認する
4. 一致しなければStatusを破棄して再生成する
5. main / Merge状態を確認する
6. 設計・運用上必要な場合だけNotion、作業データが必要な場合だけGoogle Drive、原典確認時だけBoxへ進む

Statusが生成できない環境でも、GR-008の直接Evidence確認へ戻れば作業継続できる。

## 9. 生成script

`scripts/derive-workflow-status.sh` はIssue番号を受け取り、GitHubをread-onlyで参照してJSONをstdoutへ出力する。

```bash
scripts/derive-workflow-status.sh 93
```

または:

```bash
ISSUE_NUMBER=93 scripts/derive-workflow-status.sh
```

別Repositoryを明示する場合:

```bash
REPOSITORY=owner/repository scripts/derive-workflow-status.sh 93
```

必要コマンド:

- GitHub CLI `gh`
- `jq`
- GitHub read access

scriptは次を行わない。

- Issue / PRの更新
- Branchの作成・変更
- commit / push
- Status fileのcommit
- Human approvalの記録
- CI rerun
- Deploy

出力を一時保存することはできるが、生成JSONを手更新の正本としてRepositoryへcommitしない。必要なときに再生成する。

## 10. 自動導出しないもの

すべての情報を無理に自動判定しない。

特に次はProjectごとの差が大きいため、Evidenceがない場合は `not-derived` / `unverified` とする。

- Previewの妥当性
- スマホ実機確認
- Business flow確認
- Production VerificationのProject固有項目
- Human reviewの質的判断
- Notion設計同期の意味的整合

未導出をAI推論で埋めない。

## 11. External Capability / Quota

GitHub API / `gh` / permission等が利用できない場合、Status生成を必須Gateにしない。

- Status生成失敗をApplication failureと混同しない
- 直接Evidenceを利用できる別Tool / ConnectorがあればGR-008で復帰する
- CI / Preview / Production等の本来必要なEvidenceがQuota等で実行できない場合はGR-007に従い未検証として残す

Workflow Statusの利便性のために既存Human GateやEvidence要件を弱めない。
