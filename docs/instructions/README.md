# Tool-neutral Scoped Instructions

## 1. 目的

`docs/instructions/` は、作業対象の領域に応じて**必要な制約・確認観点だけを追加で読むためのTool-neutralなScoped Instruction**を管理する。

Scoped Instructionは、`AGENTS.md` や `docs/HUMAN_AI_COLLABORATION.md` のGlobal Guardrailを分割・置換するものではない。また、Requirement、Architecture、Security基準、Release条件、Playbook等の新しいSource of Truthを作らない。

```text
Global Guardrails
      ↓
Issue Change Contract / Design Sources
      ↓
Tool-neutral Playbook（何をどの順序で進めるか）
      ↓
Scoped Instruction（その領域で何に注意するか）
      ↓
Tool-specific Adapter（将来・任意）
```

## 2. 責務分離

- `AGENTS.md` / `HUMAN_AI_COLLABORATION.md`: 全作業で守るGlobal Guardrail
- `docs/playbooks/`: feature / bugfix / release等の反復工程
- `docs/instructions/`: testing / security / UI等、対象領域にだけ適用する追加制約
- Design / Operation文書: RequirementやSecurity基準等の意味の正本
- Tool-specific Adapter: Tool syntaxや自動読込設定だけを持つ将来の任意層

Scoped Instructionが上位文書と矛盾する場合は上位を優先し、Instruction側を修正する。

## 3. 適用方法

作業開始時にIssueのPlanned Files、Impact Flags、作業内容から関連Instructionを選ぶ。

1. Global Guardrailと対象Playbookを読む
2. Issue / Designの正本を読む
3. 対象領域に該当するInstructionだけ追加で読む
4. 複数領域に跨る場合は必要なInstructionを併用する
5. 非該当Instructionを形式的に全件読み込まない

Pathは選択のヒントであり、唯一の判定条件ではない。例えば `README.md` の変更でもSecurity運用を変更するなら `security.md` を適用する。

## 4. 初期Instruction

| Instruction | 主な適用場面 | Path / Taskの例 |
| --- | --- | --- |
| `testing.md` | test、validation、CI、回帰確認 | `tests/**`, test command, validation script, CI test step |
| `security.md` | Security、Secrets、公開境界、Headers | Security config, secret handling, public exposure |
| `frontend-ui.md` | UI、画面、Asset、操作性 | `src/**`, `public/**`, `docs/design/**`, CSS / HTML / frontend component |
| `cloudflare-infrastructure.md` | Cloudflare Pages / Workers / Bindings / deploy | `wrangler.*`, `functions/**`, `workers/**`, deploy workflow |
| `documentation.md` | docs-only、README、設計文書 | `docs/**`, `README.md`, `AGENTS.md` |

## 5. Business Application Templateとの境界

このTemplateでは、次をScoped Instructionの標準実装領域にしない。

- Database設計・migration
- Transaction
- optimistic / exclusive locking
- idempotency
- ID / Password認証
- OAuth / OIDC / SAML
- RBAC / ABAC / resource authorization
- application audit log
- business-system observability

これらは将来の **AI-Driven Business Application Template** の主要差別化領域として扱う。

既存Templateで個別ProjectがDBやAuthを採用した場合はProject固有設計で扱えるが、この共通TemplateへBusiness Application標準を逆流させない。

## 6. Instruction共通フォーマット

各Instructionは最低限、次を持つ。

- Applies When
- Scope Hints
- Sources to Read
- Rules
- Do Not
- Validation / Evidence

具体的なRequirement値やProject固有URL、秘密値、DB schema等はInstructionへ固定しない。

## 7. Tool-specific Adapter

将来 `.github/instructions/`、Claude向けrule、Cursor rule等を追加する場合はAdapterとして扱う。

- Tool固有のglob / syntax / metadataはAdapter側に置く
- Ruleの意味は `docs/instructions/` を参照する
- Global Guardrailを弱めない
- AdapterがなくてもInstruction単体で読める
- 同一ルールを各Tool用fileへコピーして複数正本化しない

## 8. Context最小化

目的は「読む文書を減らすこと」そのものではなく、**必要な制約を落とさず、無関係な詳細を常時Contextへ入れないこと**である。

- documentation-only変更でfrontend / infrastructure詳細を必須読込しない
- Security影響がある作業ではsecurity instructionを省略しない
- Pathだけで判断できない場合はImpact Flagsと作業意図を優先する
- 不明な場合は軽い方へ推測せず、関連Instructionを追加で読む
