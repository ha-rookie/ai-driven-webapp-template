# Design Preview

## 1. 目的

UI・Interaction・レスポンシブ挙動を、Production実装前にブラウザとスマートフォンで確認する。

Design Previewはレビュー用の表示面であり、設計の正本はGitHub Repository内の `docs/design/`。

## 2. 標準構成

```text
docs/design/
  ├─ index.html
  ├─ _headers
  └─ ...

docs/design-public/
  ├─ index.html
  └─ _headers

templates/github-actions/
  └─ deploy-design-preview.yml
```

- `docs/design/`: 設計本文
- `docs/design-public/`: Design ProjectのProduction apexへ出す非公開placeholder
- `templates/github-actions/deploy-design-preview.yml`: 新規Appで有効化するWorkflow Template

## 3. URLモデル

Cloudflare Pages Design Project名を `CHANGE-ME-DESIGN-PROJECT` とする例。

| 用途 | Branch | URLイメージ |
| --- | --- | --- |
| PR Design Review | `pr-123` | `https://pr-123.CHANGE-ME-DESIGN-PROJECT.pages.dev/` |
| main最新設計 | `latest` | `https://latest.CHANGE-ME-DESIGN-PROJECT.pages.dev/` |
| 手動確認 | `manual-<run-id>` | Cloudflare deployment URL |
| Production apex | `main` | 設計本文ではなくplaceholderのみ |

Cloudflareが生成するhash付きDeployment URLは、その時点のスナップショットとして扱う。

## 4. 新規Appでの有効化

### Step 1: Design Project名を決める

例:

```text
<app-repository-name>-design
```

Production Application用Projectとは分ける。

### Step 2: GitHub Secretsを用意する

Repository Secrets:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

値はRepositoryへcommitしない。

API Tokenは必要最小限のCloudflare Pages deploy権限で作成する。

### Step 3: Workflow Templateをコピーする

```text
templates/github-actions/deploy-design-preview.yml
↓
.github/workflows/deploy-design-preview.yml
```

コピー後、以下を置換する。

```text
CHANGE-ME-DESIGN-PROJECT
```

### Step 4: Design Projectを作成する

WorkflowはProjectが無ければ作成を試みる構成にできるが、初回はCloudflare DashboardまたはWranglerでProjectを確認し、Project名・Production Branchを人間確認することを推奨する。

### Step 5: Design PRで確認する

`docs/design/**` を変更したPRでWorkflowが実行される。

確認:

- PR番号と `pr-<PR番号>` が一致
- noindex header
- スマホ表示
- Design ID / TBD
- Production ApplicationのFunctions/Workersが混入していない

### Step 6: main最新設計を確認する

Design PR Merge後、`latest` Branchへ設計本文をDeployする。

Production apexには `docs/design-public/` のplaceholderだけをDeployする。

## 5. Deploy Flow

```text
Design Branch / PR
      |
      v
GitHub Actions
      |
      +--> checkout
      |
      +--> Design deploy target決定
      |      PR    -> pr-N
      |      main  -> latest
      |      manual-> manual-run-id
      |
      +--> docs/design をDeploy
      |
      +--> main時だけ docs/design-public をmainへDeploy
      |
      v
Cloudflare Pages Design Project
```

## 6. Production Applicationとの分離

Design Previewへ以下を含めない。

- Production applicationの `functions/`
- Production applicationの `workers/`
- Production用 `wrangler.jsonc` / `wrangler.toml`
- Production Secrets
- Production Bindings
- Production Analytics write path
- Production Database access

Workflow Templateでは、Design siteに必要のないRuntime backendをDeploy sourceに含めない。

Design sourceを `docs/design/` に限定するため、原則としてRepository root全体をDesign Deployしない。

## 7. Security / Privacy

Design siteはProductionより情報が多い可能性がある。

最低限:

- `X-Robots-Tag: noindex, nofollow, noarchive`
- HTML `meta robots`
- `Referrer-Policy: no-referrer`
- `X-Content-Type-Options: nosniff`
- 不要な `geolocation/camera/microphone` を無効化
- Production apexはplaceholder
- Secretsや本番データをDesign HTMLへ書かない

Cloudflare Access等で保護できる場合は利用を検討するが、追加契約・カード登録をTemplateの必須条件にはしない。

noindexはAccess制御の代替ではない。

## 8. Review Gate

Design PRの人間承認時に確認する。

- [ ] Requirement / APP / UI Design IDが一致
- [ ] PR Design Previewをスマホで確認
- [ ] Error / Empty / Loading stateを確認
- [ ] Security / Privacy境界を確認
- [ ] TBDを勝手に確定していない
- [ ] 承認head SHAを記録
- [ ] Assetがある場合Asset Handoffを記録

重要なDesignは、承認済みDesign PR/SHAをImplementation Issueへ引き継ぐ。

## 9. Failure Handling

### Deploy失敗

- Cloudflare認証
- Project名
- Account ID
- API Token権限
- Workflow syntax
- Source path

を分けて確認する。

### URLが見えない

Cloudflare Deployment一覧とGitHub Actions Summaryを確認する。

### Production apexに設計本文が出た

重大な運用ミスとして扱う。

- placeholder deployを確認
- Design ProjectのProduction Branchを確認
- Workflow target branchを確認
- 必要なら直前正常Deploymentへrollback

## 10. App 2での実証

App 2ではこの手順を実際に使用し、以下を記録する。

- 初回設定で迷った点
- GitHub mobile/webだけで操作できたか
- Cloudflare Project作成手順
- PR Preview URLの再現性
- latest更新の再現性
- placeholder保護
- スマホレビューの使いやすさ

App 1とApp 2の両方で再現した問題だけを次のTemplate改善候補とする。
