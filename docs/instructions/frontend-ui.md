# Frontend / UI Scoped Instruction

## Applies When

次のいずれかに該当する場合に適用する。

- 画面構造、表示、操作、CSS、frontend componentを変更する
- Asset、OGP、favicon、PWA icon等の視覚要素を変更する
- UI / Mobile / Sensor Impact FlagがYes
- Design PreviewやHuman実機確認が必要な変更

## Scope Hints

主なpath / task例:

- `src/**` のUI component
- `public/**`
- CSS / HTML / frontend template
- `docs/design/**`
- Asset配置や参照

## Sources to Read

必要範囲で次を参照する。

- `docs/design/`
- `docs/DESIGN_PREVIEW.md`
- `docs/ASSET_WORKFLOW.md`
- `docs/PUBLIC_WEB_QUALITY.md`
- `docs/01_REQUIREMENTS.md`
- 対応Issue / approved Design Evidence

## Rules

- UI変更はRequirement / approved Designと対応させる
- Assetは承認済みsource / hash / head SHA等の引き継ぎを守る
- 色だけに依存しない、focus / disabled / wrapping等の基本状態を確認する
- Mobile / Sensor影響がある場合は自動testだけで実機動作を推測しない
- OGP / favicon等はmetadataと実体の整合を確認する
- Previewが必要かはImpact FlagsとRiskで判断し、非該当変更へ形式的に要求しない

## Do Not

- 承認済みAssetを独断で再生成・差し替えしない
- Chat上の画像をRepositoryへ自動配置されたものとして扱わない
- Design変更を実装だけで確定しない
- Project固有UIルールをTemplate共通Instructionへ固定しない
- Business Application向け共通Component libraryや管理画面標準をこのInstructionへ拡張しない

## Validation / Evidence

該当範囲で次を残す。

- Preview / screenshot / human review等のEvidence
- 対象viewport / device / browser
- UI / Assetの主要回帰
- 未確認項目と理由
- 承認対象head SHA
