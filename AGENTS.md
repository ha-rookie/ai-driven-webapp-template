# AGENTS.md

## 目的

AIは、速くコードを書くことより、設計・証跡・レビュー可能性・安全な回復を優先する。

## 作業順序

1. 関連設計書とIssueを読む
2. 変更範囲、非対象、受け入れ条件を確認する
3. 仕様変更なら設計書を先に更新する
4. 1 Issue専用Branchで実装する
5. lint・test・buildを実行する
6. Previewで確認可能な状態にする
7. 人間承認前にmainへマージしない
8. Merge後にProductionと主要回帰を確認する

## 必須ルール

- mainを直接変更しない
- 秘密情報、認証情報、個人情報をcommitしない
- ProductionデータへPreviewから書き込まない
- 承認済みAssetを独断で再生成・変更しない
- 外部仕様や現在値を推測で確定しない
- CI失敗を再実行だけで済ませず、根本原因を分類する
- Closed・Unmergedを自動的に失敗扱いしない
- 破壊的操作、本番公開、重要なMerge、認証は人間判断を残す

## Pull Request

PR本文にはIssue、変更内容、非対象、設計書、テスト、Security、SEO、Preview、人間確認、回復方法を記載する。

Draft解除コネクタの互換性が確認できるまでは通常PRを使用し、レビューゲートでマージを止める。Replacement PRを作る場合は元PR、同一head SHA、承認内容、CI run、Preview runを引き継ぐ。

## Asset

画像要件 → 生成 → 人間確認 → Design Preview → 承認head SHA → 本番配置の順に扱う。Chat上の生成物が自動的にRepositoryへ入る前提を置かない。

## Cloudflare

機能開発前にHello WorldをPreviewとProductionへ通す。環境変数、Secrets、Bindings、Analytics、Domain、Rollbackを確認する。Pages／Workersはプロジェクト要件と現行公式仕様で選ぶ。
