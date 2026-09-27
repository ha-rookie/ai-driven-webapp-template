# Tool-neutral Playbooks

## 1. 目的

`docs/playbooks/` は、AI製品やIDEに依存しない**反復可能な作業手順**を管理する。

Playbookは、Requirement、Architecture、Security基準、Git運用、Release条件等の新しいSource of Truthを作らない。各Playbookは既存の正本を読み、決められた順序で作業し、Human Gate / Stop Condition / Validation / Evidenceを漏らさないための実行ガイドである。

```text
Global Guardrails / Design Sources / Issue Change Contract
                         ↓
                 Tool-neutral Playbook
                         ↓
        Tool-specific adapter（将来・任意）
```

Tool固有のSkill、Command、Ruleを追加する場合も、手順の意味はPlaybookを参照し、同じ手順を複製して別の正本にしない。

## 2. 優先順位

Playbookは上位ルールを上書きしない。

1. Security / 明示されたHuman承認境界
2. `docs/HUMAN_AI_COLLABORATION.md`
3. Repositoryの必須規約 / `AGENTS.md`
4. Issue Change Contract
5. 関連するDesign / Operationの正本
6. Playbook
7. Tool固有adapter / convenience command

矛盾した場合は上位を優先し、Playbook側を修正する。

## 3. Playbook一覧

| Playbook | 使用する場面 | 主な正本 |
| --- | --- | --- |
| `feature-development.md` | 新機能・既存機能改善 | Requirements / Architecture / Git Workflow / Convergence Gate |
| `bugfix.md` | 不具合の原因特定と修正 | Issue / Troubleshooting / Tests / Git Workflow |
| `design-change.md` | Architecture・UI構造・Data・外部IF等の設計変更 | Design Management / ADR / Design docs |
| `release.md` | Merge後のProduction Release完了まで | Release Checklist / Production Verification / Convergence Gate |
| `production-verification.md` | Deploy後のProduction実測 | Production Verification / Project-specific checks |

## 4. 共通フォーマット

各Playbookは最低限、次を持つ。

- Purpose
- Preconditions
- Evidence to Read
- Steps
- Human Gates
- Stop Conditions
- Validation
- Output / Evidence

Playbook内へApplication固有のURL、秘密値、業務ルール、認証方式、DB schema等を固定しない。Project固有事項はIssue / Project design / Project testへ残す。

## 5. 選択ルール

- 新機能・通常改善 → `feature-development.md`
- 障害・不具合・回帰 → `bugfix.md`
- 先に設計合意が必要な変更 → `design-change.md`
- Merge済み変更をProductionへ反映 → `release.md`
- Productionが意図した状態かだけを再確認 → `production-verification.md`

一つの作業で複数Playbookを順番に使ってよい。例: `design-change` → `feature-development` → `release`。

## 6. Tool-specific Adapter

将来 `.github/skills/`、Claude commands、Cursor rules等を追加する場合はAdapterとして扱う。

- AdapterはPlaybookへの入口・Tool syntax・利用可能Toolの対応だけを持つ
- Human GateやStop Conditionを省略しない
- Playbookと異なる工程を独自に正本化しない
- Adapterが使えない環境でもPlaybook単体で実行可能にする

## 7. 完了の考え方

Playbookを最後まで実行したこと自体は完了Evidenceではない。

- Development完了判定: `docs/CONVERGENCE_GATE.md`
- Production Release完了判定: `docs/RELEASE_CHECKLIST.md` とRelease Convergence
- 未実行check: `Blocked` / `Pending` / 未検証として残す

手順実行と結果検証を分離する。
