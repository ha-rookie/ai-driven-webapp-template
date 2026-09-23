# Risk-aware CI

## 1. 目的

GitHub Actionsを品質Gateとして維持したまま、変更内容に応じて必要なJobだけを実行し、不要なActions消費を減らす。

Risk-aware CIは「Low Riskだから検証しない」という仕組みではない。

- Workflow自体はPRごとに起動する
- 最初にchanged filesを軽量に分類する
- 分類結果に応じて重いJobだけ条件実行する
- unknown pathは安全側のstrictへ倒す
- 最後のCI Gateは常に生成する
- PR時はIssueのPlanned Filesと実変更fileをScope Guardで照合する

## 2. Profile

### docs

Documentation / governanceだけの変更。

代表:

- docs/**（docs/design/**を除く）
- README.md
- CHANGELOG.md
- AGENTS.md
- .github/ISSUE_TEMPLATE/**
- .github/PULL_REQUEST_TEMPLATE.md

Runtime test / build / Previewを原則要求しない。

### design

Visual Design / Design Previewに関係する変更。

代表:

- docs/design/**
- docs/design-public/**

Application runtime CIは原則不要。

ただしDesign Preview、Browser / Smartphone Human Reviewは別Gateとして必要になり得る。

### runtime

Application runtime / build / testへ影響する変更。

代表:

- src/**
- public/**
- tests/**
- scripts/**
- package.json
- lock files
- build config

Project固有のlint / test / buildを実行する。

### strict

CI / Infrastructure / server-side / deployment / unknown変更。

代表:

- .github/workflows/**
- wrangler.*
- functions/**
- workers/**
- migrations/**
- schema / database関連
- classifierが認識しないpath

runtime validationに加え、Project固有のstrict validationを実行する。

unknown pathをdocsやruntimeへ楽観的に分類しない。

## 3. Profile優先順位

複数種類のfileが同じPRに含まれる場合は、重い側へ寄せる。

```text
strict > runtime > design > docs
```

例:

- README + src/app.js → runtime
- docs/design/index.html + wrangler.jsonc → strict
- docsだけ → docs
- 未知のroot file → strict

## 3.5 Scope Guard

Project CIでは、Risk profile判定より前にIssue Change Contractの `Planned Files` と実変更fileを照合する。

詳細は `docs/PLANNED_FILES_GUARD.md` を正本とする。

- PR本文のclosing keywordから同一RepositoryのIssueを1件だけ解決
- GitHub Pull Request Files APIで実変更fileを取得
- renameはprevious filenameも確認
- Scope外fileが1件でもあればfail
- Scope拡張はIssueのPlanned FilesをHuman承認後に更新して再実行
- PR本文だけのbypassは作らない
- `pull_request_target` は使わずread-only権限で動かす

## 4. CI Gate

conditional jobそのものをRequired Checkにすると、そのjobがskipされたPRでRequired Checkが生成されない可能性がある。

そのためProject CIでは最後に常時実行される `CI Gate` を置く。

```text
Scope Guard ──────────┐
Classify ──────────────┼─ docs validation
├─ design validation
├─ runtime validation
└─ strict validation
        ↓
      CI Gate
```

CI Gateは以下を確認する。

- PR時はScope Guardがsuccess
- workflow_dispatch時はScope Guardがskipped
- Classifyがsuccess
- 実行対象Jobがsuccess
- 非対象Jobのskippedはfailure扱いしない
- failure / cancelledはfail

Project CI側のRuleset Required Checkは原則 `CI Gate` を登録する。

Repository標準の `Repository validation` を別Workflowとして維持する場合は、それもRequired Checkに含める。

## 5. Template Workflow

Template:

`docs/workflow-templates/risk-aware-ci.yml`

新規Projectでは、Application CI方針が決まった時点で次へコピーする。

`.github/workflows/project-ci.yml`

コピー後、以下のCHANGE-ME commandをProject固有に置き換える。

- docs validation
- design validation
- runtime validation
- strict validation

不要なvalidationは `echo "not required"` 等で明示し、空欄のままにしない。

## 6. Actions節約の考え方

Actionsを減らす優先順位:

1. 不要なWorkflow二重起動をなくす
2. heavy jobをchanged filesでskipする
3. 同一原因のrerunを避ける
4. timeoutを設定する
5. docs-onlyでinstall / build / browser test / deploy previewを動かさない

「CIを実行しない」こと自体を目的にしない。

## 7. Impact Flagsとの関係

GitHub IssueのImpact Flagsとchanged files分類は役割が違う。

- Impact Flags: Change Contract上の設計判断
- changed files: 実際の差分から機械判定

両者が矛盾する場合、軽い方へ自動補正しない。

例:

IssueではRuntime = Noだがsrc/**が変更されている

→ runtime以上を実行し、Scope mismatchとしてReview対象にする。

Risk-aware CI単独でPlanned Files整合性までは判定しない。Planned Files自動比較は別標準として扱う。

## 8. Human Gate

Risk-aware CIで削らないもの:

- Human Merge approval
- UI / Smartphone Review
- Sensor実機確認
- Binary Asset handoff
- Production / Publicの重要操作
- Security / Auth / Dataの重要判断

CI ProfileはHuman Gateを置き換えない。

## 9. 導入条件

Project Bootstrap完了後、次が分かった段階で有効化する。

- package manager / runtime
- lint command
- test command
- build command
- strict時に追加する確認
- Previewが必要なfile領域

初期PoCでcommand未確定なら、先にArchitectureを決める。placeholderのままactive workflowへコピーしない。

## 10. 今後の拡張

次候補:

- CI result / changed files / SHAのRelease Evidence自動生成
- Production Verification共通化
