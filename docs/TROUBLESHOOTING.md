# Troubleshooting

## 記録項目

事象、影響、工程、再現条件、原因、確認順、暫定回避、恒久対策、復旧、Issue・PR・CI run、証跡、標準への反映先。

## Draft PRを解除できない

Draft解除APIを疑う。CIとmergeableが正常なら、同一head SHAから通常PRを作り、レビュー証跡を引き継ぐ。

## CI失敗

Workflow、最初の根本エラー、lint、test、build、静的データ、外部設定、Binding、権限の順で確認する。

## Preview Deploy失敗

BuildとDeployを分ける。出力先、変数、Secrets、Bindings、Cloudflare側機能、Production依存を確認する。

## AI画像をRepositoryへ渡せない

採用画像を人間がファイルとして確定し、所定場所へ配置する。プロンプトと仕様も保存し、commit後にCIとPreviewを行う。

## Closed・Unmerged

技術失敗、Draft引き継ぎ、不採用、重複、実験終了を分類する。

## 知識の昇格

Known Issue → 手順 → テンプレート → CIの順に、同じ失敗を考えなくても済む仕組みへ変える。
