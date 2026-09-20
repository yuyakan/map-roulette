# 写真追加パイプライン（観光スポット / グルメ / 自然 / 祭り）

アプリ内の**実写写真**を追加するための道具と手順。写真の出番は2か所:

- 県詳細画面（`TourismDetailView`）最下部のフォトカルーセル（観光スポットのみ）
- 各詳細画面の**ヒーローヘッダー全面**（観光スポット / グルメ / 自然 / 祭り）

**お土産は対象外**。並ぶ品の大半が特定メーカーのブランド商品で、パッケージ写真は
著作権に触れるため、最初から写真を持たせない方針にしている
（`SouvenirPhoto` の実装だけ残っているが未使用）。

## 絶対に守る品質・ライセンス基準（最優先）

1. **ライセンスは CC0 / CC BY(バージョン不問) のみ**。
   - `CC BY-SA` / `GFDL` / `NC` / `ND` は**絶対に使わない**（`find_cc.py` が自動除外するが、最終責任は目視）。
   - CC0 を最優先。無ければ CC BY。
2. **必ず1枚ずつ人間（AI）が目視**して「本当にそのスポットか」を確認する。
   - キーワード検索は無関係な物（別スポット・駅・古写真・浮世絵・地図）を拾う。過去に五稜郭→五稜郭"駅"、中尊寺→"東大寺"金堂 等の誤マッチが実際に発生。
   - **横長カード(260×180)** とヘッダー全面なので、縦構図より横構図を優先。
   - 古写真・モノクロ・浮世絵・レリーフ地図は不採用（現代のカラー実写のみ）。
   - 手前に看板/バリケード/車が目立つ、被写体が小さい・分かりにくい物は不採用。
   - **店名ロゴ・商標・値札・メニュー表**が目立つ物は不採用（グルメで頻出。
     丼や器に店名が入っている写真、店内の品書きが主役の写真は使わない）。
   - **特定個人が主役**の写真は不採用（祭りで頻出。山車・灯籠・花火など
     構造物や全景が主役のものを選ぶ）。米軍撮影のPD写真は、祭りではなく
     参加する兵士が主役のものが多く使えない。
   - **施設の展示室・資料館の中で撮った写真**は、祭り本番の写真ではないので不採用
     （例: 立佞武多の館の館内、阿波おどり会館）。
3. **無理に埋めない**。基準を満たす写真が無い県・スポットは**保留**し、
   平凡な写真で妥協しない。カルーセルは写真ゼロの県では非表示になる（破綻しない設計）。
   ただし「候補が無い」と結論づけてよいのは**そのキーを実際に調べた後だけ**。
   人気・規模の上位だけ見て「このカテゴリは尽きた」と判断してはいけない
   （過去に実際にやって間違えた。PROGRESS.md 第6ラウンド参照）。
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

### 2. `add_photo.py [--カテゴリ] <キー> <Commonsファイル名>`
確定した1枚を取り込む。ライセンス再確認→SA等なら弾く→長辺1600pxにリサイズ
→ `Assets.xcassets/<カテゴリ>/<asset名>.imageset/` を生成→ `photo_credits.json` に
TASL レコードを追記（CC0でも記録。改変は "resized"）。

```
python3 add_photo.py            attraction_kegon_falls  "Kegon Falls (51988140443).jpg"
python3 add_photo.py --gourmet  gourmet_castella        "Castella 001.jpg"
python3 add_photo.py --nature   sea_tsunoshima_name     "Tsunoshima Bridge (32994549311).jpg"
python3 add_photo.py --festival aomori_nebuta_festival  "Aomori, Nebuta-matsuri 43.jpg"
```

キーと asset 名の対応（アプリ側 `Model/CategoryPhoto.swift` と必ず一致させる）:

| カテゴリ | キーの出どころ | 渡すキー | 生成される asset |
|---|---|---|---|
| 観光（既定） | `Model/TourismInfo.swift` の `nameKey` | `attraction_kegon_falls` | `Attractions/attraction_kegon_falls` |
| グルメ | `Model/Gourmet.swift` の `nameKey` | `gourmet_castella` | `Gourmet/gourmet_castella` |
| 自然 | `Views/Nature/NatureSpotMapView.swift` の `nameKey` | `sea_tsunoshima_name` | `Nature/nature_sea_tsunoshima` |
| 祭り | `ja.lproj` の `<キー>_name` | `aomori_nebuta_festival` | `Festivals/festival_aomori_nebuta_festival` |

- キーのタイポは「imageset は出来るが画面には一生出ない」無言の失敗になるため、
  スクリプトが取り込み前に元データ側の実在を検査して弾く。
- 祭りだけはデータ側が安定キーを持たない（`name` がローカライズ済み文字列）。
  アプリは**表示名からローカライズキーを逆引き**して asset を決めるので、
  渡すのは `_name` を除いたキー接頭辞。
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

## 大量に残っているときの進め方（全件調査）

数百件を一気に当たるときは、**収集を自動化して候補を貯めてから、まとめて目視**する
のが速い（目視だけは自動化できない）。

1. 未取得キーを全部列挙する（Assets の imageset 名と元データのキーを突き合わせる）
2. 各キーについて「日本語名」「キー由来の英語 + Japan」の2語で `find_cc.py` 相当の
   検索をかけ、ライセンス・比率・解像度で足切りして候補を JSON に貯める。
   ファイル名の正規表現で `map|chart|ukiyo|museum|station|USMC|19\d\d` 等を弾くと
   目視の件数がかなり減る。レート制限があるので放置前提（420件で1〜2時間）
3. 候補が出たものを 8 件ずつプレビューして目視 → 採用分だけ `add_photo.py`

実績（2026-09-19 第6ラウンド）: 420件を収集 → 候補253件 → 目視して61件採用（24%）。

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
- `Model/CategoryPhoto.swift`: グルメ / 自然 / 祭り の同名の仕組み
  （`GourmetPhoto` / `NaturePhoto` / `FestivalPhoto`）。祭りだけは
  表示名→ローカライズキーの逆引き索引を内部に持つ（全12言語対応）。
- `Views/Tourism/TourismDetailView.swift`: `photoCarousel`（最下部）と
  `photoCard(for:)`（260×180＋スポット名キャプション）。観光スポットのみ。
- ヒーローヘッダー: `AttractionDetailView` / `GourmetDetailView` /
  `NatureSpotDetailView` / `FestivalDetailView` / `OtherFestivalDetailView` /
  `IntegratedFestivalDetailView` の `header` は全て同じ形
  （`titleBlock` を `photo` 背景＋暗幕の上に載せ、写真が無ければ
  背景を持たず最背面の基調色を透かす）。**写真があるときはカテゴリアイコンの丸を
  出さない**（写真自体が主役になるため）。
- ローカライズキー: `tourism_detail_photos`（見出し「写真」）は
  `Base/*.lproj/Localizable.strings` の6言語に追加済み。
- 設定アプリ導線: `Settings.bundle/Root.plist` に `PHOTO_CREDITS` の
  PSChildPaneSpecifier、`Root.strings`(ja/en) に文言を追加済み。

## リリース条件（重要）
CC BY を1枚でも使う版をリリースするなら、`PhotoCredits.plist` が最新であること
（= 写真追加後に `gen_credits.py` を実行済み）が**必須**。これで CC BY の帰属義務を
iOS設定アプリの一括表記で満たす（CC BY 4.0 legalcode 3(a)(2) の "reasonable manner" /
別リソースでの表示が認められることを一次確認済み）。CC0 のみなら表記自体は任意。

### リリース前チェック: 台帳と同梱画像の突き合わせ（必須）
`add_photo.py` を通さずに手で置いた imageset は**台帳に載らない**＝出所不明のまま
配布されることになる。実際に 2026-09-13 のコミット `9843ade` で14枚が素通りし、
その中に CC BY-SA が3枚混入していた（パイプラインなら弾かれていたもの）。
**リリース前に必ず下記を実行し、両方向とも (none) であることを確認する。**

```
cd /Users/uebetsunawayuuya/MapRoulette/MapRoulette && python3 -c "
import json,os
led=json.load(open('photo_credits.json'))
exp=set()
for x in led:
    k=x['nameKey']; c=x.get('category','attraction')
    if c=='attraction': exp.add(('Attractions', k.replace('.','_')))
    elif c=='gourmet': exp.add(('Gourmet',k))
    elif c=='nature': exp.add(('Nature','nature_'+k.replace('_name','')))
    elif c=='festival': exp.add(('Festivals','festival_'+k))
disk={(d,n[:-9]) for d in ['Attractions','Gourmet','Nature','Festivals']
      for n in os.listdir('Assets.xcassets/'+d) if n.endswith('.imageset')}
print('on disk, NOT in ledger:', sorted(disk-exp) or '(none)')
print('in ledger, NOT on disk:', sorted(exp-disk) or '(none)')
"
```

### 出所不明の画像を後から特定する方法
EXIF の **カメラ機種 + DateTime** は Commons 側にもそのまま残っているので、
これを照合すれば元ファイルを一意に特定できる（リサイズしても EXIF は保持される）。
`beach.*` のようにドット区切りのキーは、`nameKey` に**ドット形のまま**記録する
（`gen_credits.py` は ja.lproj をこのキーで引くため。アセット名は別系統で解決される）。
