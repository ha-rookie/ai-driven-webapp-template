# AI Driven Web App Template

AIと人間でWebアプリを継続開発するための標準テンプレートです。

コードの雛形だけでなく、設計、Issue、Branch、Pull Request、CI、Cloudflare、Asset、Security、SEO、リリース、振り返りまでを一つのGolden Pathとして管理します。

## 基本原則

1. 設計変更 → 設計書 → Issue → 実装 → テスト → Pull Request
2. 1 Issue・1 Branch・1 Pull Request
3. mainを直接変更しない
4. 通常PR＋人間承認ゲートを標準とする
5. Previewでスマホ確認してからProductionへ反映する
6. ProductionとPreviewのデータ・Bindingsを分離する
7. 失敗をKnown Issue、手順、テンプレート、CIへ順に昇格する

## Golden Path

アイデア → 企画 → 要件 → UI設計 → Issue → Branch → 実装 → CI → Preview → 人間レビュー → Merge → Production → SEO・Security・Analytics確認 → 振り返り

## 使い始めるとき

- `docs/00_PROJECT_OVERVIEW.md` のCHANGE-MEを置き換える
- 技術スタックとCloudflare Pages／Workersの採用理由を記録する
- CloudflareのHello World Deployを先に通す
- 必要なIssueをテンプレートから作る
- Release Checklistをプロジェクトに合わせて更新する

## 文書

- [Project Overview](docs/00_PROJECT_OVERVIEW.md)
- [Git Workflow](docs/GIT_WORKFLOW.md)
- [Asset Workflow](docs/ASSET_WORKFLOW.md)
- [Cloudflare Setup](docs/CLOUDFLARE_SETUP.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Release Checklist](docs/RELEASE_CHECKLIST.md)

## v0.1の位置づけ

朝マズメ潮ナビで得た実証結果を基にした初版です。別ジャンルのアプリで検証し、3〜5アプリで繰り返し有効だったものを標準へ昇格します。
