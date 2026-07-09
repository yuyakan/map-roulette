# 県詳細フォトカルーセル — 写真追加パイプライン

都道府県詳細画面（`TourismDetailView`）最下部のフォトカルーセルに、
観光スポットの**実写写真**を追加するための道具と手順。

## 絶対に守る品質・ライセンス基準（最優先）

1. **ライセンスは CC0 / CC BY(バージョン不問) のみ**。
   - `CC BY-SA` / `GFDL` / `NC` / `ND` は**絶対に使わない**（`find_cc.py` が自動除外するが、最終責任は目視）。
   - CC0 を最優先。無ければ CC BY。
2. **必ず1枚ずつ人間（AI）が目視**して「本当にそのスポットか」を確認する。
   - キーワード検索は無関係な物（別スポット・駅・古写真・浮世絵・地図）を拾う。過去に五稜郭→五稜郭"駅"、中尊寺→"東大寺"金堂 等の誤マッチが実際に発生。
   - **横長カード(260×180)** なので、縦構図より横構図を優先。
   - 古写真・モノクロ・浮世絵・レリーフ地図は不採用（現代のカラー実写のみ）。
   - 手前に看板/バリケード/車が目立つ、被写体が小さい・分かりにくい物は不採用。
3. **無理に埋めない**。基準を満たす写真が無い県・スポットは**保留**し、
   平凡な写真で妥協しない。カルーセルは写真ゼロの県では非表示になる（破綻しない設計）。
4. Wikimedia のレート制限(HTTP 429)に注意。**画像取得の間に 15〜20 秒空ける**。
   User-Agent は必ず付ける（スクリプトは対応済み）。

## 道具

すべて Python3。カレントディレクトリはどこでもよい（絶対パス埋め込み済み）。

### 1. `find_cc.py "検索語" [件数]`
Commons を全文検索し、**CC0/CC BY のみ**に絞って候補を JSON で返す
（license/author/出典URL/直リンク/解像度つき、CC0優先・大サイズ順）。
```
python3 find_cc.py "Kegon Falls Nikko" 3
```

### 2. `add_photo.py <nameKey> <Commonsファイル名>`
確定した1枚を取り込む。ライセンス再確認→SA等なら弾く→長辺1600pxにリサイズ
→ `Assets.xcassets/Attractions/<nameKey>.imageset/` を生成→ `photo_credits.json` に
TASL レコードを追記（CC0でも記録。改変は "resized"）。
```
python3 add_photo.py attraction_kegon_falls "Kegon Falls (51988140443).jpg"
```
- `<nameKey>` は `Model/TourismInfo.swift` の `LocalizedAttractionLocation(nameKey: "...")` と厳密一致させること（カルーセルのキャプションになる県内スポット名に紐づく）。
- 429 が出たら時間を空けて再実行。

### 3. `gen_credits.py`
`photo_credits.json` から `Settings.bundle/PhotoCredits.plist` を丸ごと再生成。
**写真を追加したら必ず最後に1回実行**（iOS設定アプリの写真クレジット画面が更新される）。
CC BY は TASL(作品名/作者/出典/ライセンス+URL)＋"resized" を必須明記、CC0 は参考出典を併記。
```
python3 gen_credits.py
```

## 標準ワークフロー（1スポット）

```
1. python3 find_cc.py "<英語のスポット名 + 特徴語>" 3〜5
2. 有力候補の直リンクを curl か Python で取得し、sips で 600px に縮小して目視
   （取得間隔 15〜20秒。UA 必須）
3. 正しいスポット・横構図・現代カラー実写なら → add_photo.py で取り込み
   ダメなら別候補 or 別検索語。無ければ保留（無理に入れない）
4. 県が一区切りしたら gen_credits.py を実行
5. xcodebuild でビルド確認（下記）
```

## ビルド確認（必須）
```
cd /Users/uebetsunawayuuya/MapRoulette
xcodebuild -project MapRoulette.xcodeproj -scheme MapRoulette \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  -configuration Debug build 2>&1 | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED"
```
※ 本プロジェクトは PBXFileSystemSynchronizedRootGroup を使用。新規ファイル・
   imageset・plist はディスクに置くだけで自動的にビルド対象になる（手動登録不要）。
※ 編集中の SourceKit 診断（"Cannot find type ..." 等）はインデックス不整合の
   ノイズが多い。**真偽は必ず実ビルドで判定**する。

## 設計メモ
- `Model/AttractionPhoto.swift`: imageset名 == nameKey の規約。`image(for:)` /
  `photographedAttractions(in:)` を提供。写真の有無だけで表示制御。
- `Views/Tourism/TourismDetailView.swift`: `photoCarousel`（最下部）と
  `photoCard(for:)`（260×180＋スポット名キャプション）。
- ローカライズキー: `tourism_detail_photos`（見出し「写真」）は
  `Base/*.lproj/Localizable.strings` の6言語に追加済み。
- 設定アプリ導線: `Settings.bundle/Root.plist` に `PHOTO_CREDITS` の
  PSChildPaneSpecifier、`Root.strings`(ja/en) に文言を追加済み。

## リリース条件（重要）
CC BY を1枚でも使う版をリリースするなら、`PhotoCredits.plist` が最新であること
（= 写真追加後に `gen_credits.py` を実行済み）が**必須**。これで CC BY の帰属義務を
iOS設定アプリの一括表記で満たす（CC BY 4.0 legalcode 3(a)(2) の "reasonable manner" /
別リソースでの表示が認められることを一次確認済み）。CC0 のみなら表記自体は任意。
