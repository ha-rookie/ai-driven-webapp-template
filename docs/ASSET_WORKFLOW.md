# Asset Workflow

## 標準フロー

画像要件 → 生成/選定 → 人間確認 → Design Preview → スマホ確認 → 承認head SHA / hash → 正本確定 → 本番配置または生成 → CI → App Preview / Production

## 仕様として残すもの

用途、表示サイズ、元サイズ、縦横比、透過、背景、向き、余白、形式、圧縮、alt・aria、ファイル名、生成プロンプト、禁止要素。

## Assetの3分類

画像Assetは、保存方法ではなく**何を正本にするか**で分類する。

| 分類 | 正本 | 主な対象 | 更新方法 |
| --- | --- | --- | --- |
| 原本保存型 | 承認済みJPEG / PNG / WebP等 | 写真、イラスト、AI生成OGP、人間レビュー済みキービジュアル | 原本を差し替えて再承認 |
| ビルド時生成型 | SVG、生成スクリプト、デザイン定義 | favicon、Apple Touch Icon、PWA icon、maskable icon、サイズ違い派生物 | 元デザイン/生成ロジックを変更して再生成 |
| 同一Blob再利用型 | 1つのGit Blob | Design PreviewとProduction等で同一画像を使う場合 | 同一Blob SHAまたはhashで内容同一性を確認 |

### 原本保存型

完全一致が要件のAssetは、承認済み画像そのものを正本にする。

- アップロードが難しいという理由だけで「似た画像」を再生成しない
- AI生成画像でも、人間が採用した時点で原本を固定する
- 変更時はDesign Issueへ戻し、再承認する
- hashまたは承認head SHAをAsset Handoffへ残す

### ビルド時生成型

元デザインから同じ結果を決定的に再生成できるAssetは、生成元を正本にする。

- SVG / master image / design token /生成スクリプトを正本候補とする
- 派生PNG / ICOを1枚ずつ手編集しない
- CI / Preview / Deploy時に必要サイズを生成できるようにする
- 生成物だけ変更され、正本と不整合になる状態を避ける

代表例:

- favicon
- Apple Touch Icon
- 192x192 PWA icon
- 512x512 PWA icon
- 512x512 maskable icon

### 同一Blob再利用型

内容が完全に同じ画像を複数パスで使う場合、Gitでは同じBlob SHAを参照できる。

- パスが違っても内容同一性をhash / Blob SHAで確認できる
- Design用とProduction用で同じ原本を使う場合に有効
- 片方だけ差し替わった場合は別内容として扱う

## Assetのライフサイクル

```text
Source Asset
├─ 承認済みJPEG / PNG / WebP
└─ SVG / master image / 生成スクリプト / デザイン定義
      ↓
Build Artifact
├─ リサイズPNG
├─ ICO
├─ Apple Touch Icon
└─ maskable icon
      ↓
Deploy Artifact
└─ Cloudflare Pages等から配信される静的ファイル
```

原本・生成物・配信物を混同しない。

- 原本保存型 → Source Assetを更新する
- ビルド時生成型 → 生成元を更新する
- 派生成果物だけを手修正しない
- PreviewとProductionで別の画像生成経路を持たない

## OGP

OGPは共有時に表示されるため、通常のUI Assetとは別に契約を確認する。

最低限確認する項目:

- 採用画像が人間承認済み
- OGP用途に適した横長比率。1200x630は代表例で、同等比率の高解像度画像も可
- `og:image` のURLがProductionから取得できる
- metadataのwidth / heightを設定する場合、実画像寸法と一致する
- title / description / image / typeが意図どおり
- LINE等、実際に使う共有先でカード表示を確認できる場合は実機確認する
- cache更新が必要な場合、画像URLを安易に変えず原因を切り分ける

人間承認済みOGPは原本保存型を基本とし、アップロード都合だけで別画像へ再生成しない。

## favicon / App Icon / PWA Icon

同一モチーフから複数サイズへ展開できる場合はビルド時生成型を優先する。

推奨候補:

- favicon
- Apple Touch Icon 180x180
- PWA icon 192x192
- PWA icon 512x512
- maskable icon 512x512

各アプリの正式アイコンと、LitLink等の外部一覧用アイコンは別Assetとして扱える。外部掲載先固有のデザインルールをTemplateへ固定しない。

## 保存

- `assets/prompts/`: 再生成用プロンプト
- `assets/`: 原本または生成元を置く候補。プロジェクト構成に合わせて変更可
- `docs/design/assets/`: レビュー中
- `public/assets/`: 承認済み本番Asset
- `public/icons/`: 配信用アイコンの候補

正本の場所はProject OverviewまたはAsset設計に明記する。

## ChatGPTからGitHubへバイナリ画像を渡す場合

承認済みJPEG / PNG等をGitHubへ登録するときは、**利用中のConnector/APIがbinaryを安全に扱えるかを先に確認する**。Git Blob + Base64直接輸送を固定の第一候補にはしない。

Connectorでbinary登録を扱えない場合、人間の担当は原則として**確定済みpathへのfile uploadだけ**とする。

### 人間uploadが必要な場合の標準フロー

1. AIが対象repository / branchを確認する
2. AIが配置directory / filename / extensionを確定する
3. AIが可能なら必要なdirectory / branchを作成する
4. AIが人間へupload対象fileと配置先だけを提示する
5. 人間がbinary fileをuploadする
6. AIがGitHub上のfile、path、size等を再確認する
7. AIがcode / docs / test / PR作業を継続する

人間にdirectory作成、branch作成、code編集等まで依頼しない。既にAssetが準備済みなら、技術的理由がない限り再作成を求めない。

### Git Blob + Base64を利用する場合

Connector/APIが対応し、完全なbyte列を安全に輸送できる場合の選択肢として利用できる。

```text
原本画像
↓
Base64化（輸送用）
↓
Git Blob作成
↓
Blob SHA確認
↓
Tree
↓
Commit
↓
Branch ref
↓
GitHub上の画像
↓
CI / Preview / Production
```

### 原則

- Base64は保存形式ではなく輸送形式として使う
- Base64分割ファイルを恒久的にRepositoryへ残さない
- create_blobが成功しても、期待する画像と同一とは即断しない
- Blob SHA、最終ファイル、サイズ、寸法、形式、Previewを確認する
- 直接輸送に制約がある場合のみGoogle Drive等のクラウドストレージ中継を代替候補とする
- 中継を使った場合も原本とGitHub上の成果物の同一性を確認する
- 「Base64が長い」「GitHub APIだから」だけで失敗原因を決めつけない

### 失敗時の切り分け

1. 元画像は正常か
2. バイト数・hashは確定しているか
3. Base64全文は欠損していないか
4. create_blobへ渡した内容は同一か
5. 返却Blob SHAは想定どおりか
6. Treeのpath / mode / type / shaは正しいか
7. CommitのTreeは正しいか
8. Branch refは新Commitを指しているか
9. GitHub上の最終ファイルは正常か
10. Preview / Productionで正常配信されるか

## 実装Issueへの引き継ぎ

Design承認後、実装Issueの `Asset Handoff` に固定情報を残す。

最低限、以下を引き継ぐ。

- Asset分類（原本保存 / ビルド時生成 / 同一Blob再利用）
- 正本
- 元Design Issue/PR
- 承認済みAsset一覧
- Asset配置場所
- file hash または承認head SHA
- 承認Preview
- 生成Assetの場合は生成スクリプト/元デザイン

Assetを使わないIssueは `該当なし` とする。

承認済みAssetは、実装側が再生成、色変更、トリミング、差し替えをしない。変更が必要ならDesign Issueへ戻し、再承認後に新しいhashまたはhead SHAを実装Issueへ引き継ぐ。

## 承認後

実装側は承認済みAssetまたは承認済み生成元を再利用する。独断で再生成、色変更、トリミング、差し替えをしない。変更が必要ならDesign Issueへ戻す。

## テスト

共通:

- ファイル欠落
- 形式 / MIME type
- サイズ
- 幅・高さ
- 透過
- 参照パス
- cache
- スマホ
- 小サイズ
- 背景とのコントラスト
- PWA対象範囲
- 正本と生成物の整合

用途固有:

- OGP: 比率、実寸、metadata、Production配信、共有カード
- favicon: ブラウザタブでの判別
- Apple Touch Icon: 180x180とホーム画面表示
- PWA icon: 192 / 512、manifest参照、maskable余白
