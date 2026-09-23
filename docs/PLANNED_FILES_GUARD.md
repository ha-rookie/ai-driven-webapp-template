# Planned Files Guard

## 1. 目的

IssueのChange Contractで宣言した `Planned Files` とPull Requestの実変更fileを自動比較し、Scope外変更をHuman Review前に検知する。

このGuardはAIの変更範囲を機械的に監視するためのものであり、Scope拡張を自動承認する仕組みではない。

## 2. Source of Truth

比較元はPR本文ではなく、PRが `Closes #<Issue>` / `Fixes #<Issue>` / `Resolves #<Issue>` で参照する **同一RepositoryのIssue本文** とする。

1 PR = 1 Change Contract Issueを標準とする。

- closing keywordでIssueを解決できない → fail
- closing Issueが0件 → fail
- closing Issueが複数 → fail
- Issue本文にPlanned Files sectionがない → fail
- Planned Filesが空 / TBD → fail

PR本文だけを書き換えてScope Guardをbypassしない。

## 3. Planned Files記法

Issue本文に次のHeadingを置く。

```markdown
## Planned Files

- docs/GIT_WORKFLOW.md
- docs/**
- public/assets/**
```

Issue Formの場合は `### Planned Files` でもよい。

### exact path

```text
docs/GIT_WORKFLOW.md
```

そのfileだけを許可する。

### directory / glob

```text
docs/**
public/assets/**
.github/ISSUE_TEMPLATE/*.yml
```

Bash globとして照合する。

### annotation

末尾に次のannotationを付けてもよい。

```text
docs/NEW_STANDARD.md (new)
README.md (modified)
old/path.md (deleted)
new/path.md (renamed)
```

Guardは既知annotationを除去してpathとして評価する。

## 4. 禁止記法

次はfailする。

- `TBD`
- `CHANGE-ME`
- absolute path
- `..` を含むpath
- `*` 単独
- `**` 単独
- Repository全体を実質無制限に許可するpattern

目的は「何でも変更できるPlanned Files」を作ることではない。

## 5. 実変更file

GitHub Pull Request Files APIから取得する。

- added
- modified
- deleted
- renamed

renameでは `filename` だけでなく `previous_filename` もScope対象として照合する。

これにより、予定外のfileを別pathへ移動してScope外変更を隠すことを防ぐ。

## 6. Scope mismatch

1件でもPlanned Filesに一致しないpathがあればfailする。

```text
Unplanned file: src/unexpected.js
```

その場合：

1. ついで修正なら変更を戻す
2. Goal達成に本当に必要なら作業を停止
3. HumanへScope拡張理由を説明
4. 承認された場合のみIssueのPlanned Filesを更新
5. CIを再実行

PR本文の「予定外変更: 承認済み」だけではGuardを通過させない。

## 7. 権限

Scope Guardはread-onlyで動作する。

必要権限:

- `contents: read`
- `issues: read`
- `pull-requests: read`

IssueやPRをWorkflowから自動編集しない。

`pull_request_target` は使用しない。

## 8. Risk-aware CIとの統合

`docs/workflow-templates/risk-aware-ci.yml` のProject CIへ `Scope Guard` Jobとして統合する。

PR時:

```text
Scope Guard ───────────┐
Classify changes ─────┼─ conditional validation ─→ CI Gate
                      └────────────────────────────→ CI Gate
```

`CI Gate` はScope Guardのsuccessを必須にする。

manual `workflow_dispatch` はPR Change Contractが存在しないためScope Guardをskipし、選択したforce profileの検証だけを実行する。

## 9. Human Gateとの関係

Scope Guardがsuccessでも、次を意味しない。

- Scope内容そのものが妥当
- 実装が正しい
- UIが適切
- Security判断が正しい
- Mergeしてよい

Human Merge approvalは維持する。

## 10. 既存Project

既存Projectへ一括backportしない。

Risk-aware CIを採用または更新する際に、Issue TemplateのPlanned Files記法とセットで導入する。
