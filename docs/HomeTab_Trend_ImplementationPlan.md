# ホームタブ「トレンド機能」実装計画書

作成日: 2026-09-04
対象: MapRoulette iOS (SwiftUI)
目的: 5タブ目「ホーム」を新設し、その一機能として YouTube ベースのトレンド機能（人気カフェ/映えスポット/グルメの動画紹介）を **完全無料・YouTube規約準拠** で実装する。

---

## 0. 全体アーキテクチャ（完全無料・クレカ登録なし）

```
[GitHub Actions] プライベートrepo・cron 1日1回
   ・YouTube Data API v3 を検索（エリア × カテゴリ）
   ・動画ID/タイトル/サムネURL/チャンネル名を抽出
   ・Firestore に upsert + 古いドキュメント削除（30日ルール対応）
        ↓ サービスアカウントで書き込み
[Firestore（Spark・無料）] trends コレクションにキャッシュ
        ↓ アプリは読み取りのみ（ルールで write:false）
[iOSアプリ ホームタブ] Firestore を読んで一覧表示 → タップで公式埋め込み再生
```

- **Cloud Functions / Cloud Scheduler は使わない** → Blaze不要 → クレカ不要 → 実課金0円。
- バッチは GitHub Actions（プライベートrepo・月2000分無料枠）。1日1回・数分なので余裕で無料内。
- 課金トリガーになる要素を構成から一切排除している。

---

## 1. YouTube規約 遵守要件（本実装の絶対条件）

一次情報（YouTube API Services - Developer Policies）で確認した、必ず守る4点。

### 要件A: 保存データは「30日以内に更新 or 削除」
- 出典: *"must either delete or refresh the stored data" after 30 calendar days*
- 対象: 動画タイトル、チャンネル名、サムネイルURL 等すべてのメタデータ。
- 実装対応:
  - バッチは **1日1回全件を上書き更新**（=毎日refreshなので30日ルールを自動的にクリア）。
  - 各ドキュメントに `updatedAt` を必ず持たせる。
  - バッチ実行時、**`updatedAt` が閾値（例: 2日）より古いドキュメントは削除**する（更新が途絶えた場合の保険）。
  - アプリ側でも表示時に `updatedAt` が古すぎるデータは表示しないガードを入れる。

### 要件B: 動画は公式埋め込みプレイヤーで再生・ダウンロード全面禁止
- 出典: *"must not download, import, backup, cache, or store copies of YouTube audiovisual content"* / *"must not modify, build upon, or block any portion or functionality of a YouTube player"*
- 実装対応:
  - 再生は **YouTube公式の埋め込みプレイヤー**（`YouTubePlayerKit` もしくは公式 iframe を載せた `WKWebView`）のみ。
  - **保持してよいのは動画IDとサムネURLだけ**。動画本体・音声の保存/抽出は一切しない。
  - プレイヤーのUI（ボタン等）を隠す・改造する実装は禁止。

### 要件C: 広告はYouTubeデータ単独画面に出さない（本アプリはAdMob導入済み）
- 出典: *"must not sell advertising...on any page containing YouTube API Data unless other data...appears on the same page and offers enough independent value"* / *"must not charge users to watch content in an embedded YouTube player"*
- 実装対応:
  - **トレンド一覧は「ホームタブの一機能」として、MapRoulette独自コンテンツ（周辺スポット/県/グルメ等）と同一画面に共存**させ、独自価値を担保する。
  - **動画再生画面（埋め込みプレイヤーを表示する画面）には AdMob 広告を配置しない**。
  - トレンド視聴に対して課金しない（無料機能）。

### 要件D: YouTubeブランド表示・出典明記
- 出典: *"must make clear...that YouTube is the source...by displaying YouTube Brand Features"* / 誤認防止
- 実装対応:
  - トレンドカード/再生画面に **YouTubeロゴ・「YouTubeで見る」等の出典表記** を付ける（YouTube Branding Guidelines準拠）。
  - 「MapRoulette発のコンテンツ」と誤認させる表示にしない。

> 補足（クォータ）: `search.list` は 100ユニット/回、無料枠 10,000/日 = **1日100検索が上限**。バッチは安全域で `15エリア × 4カテゴリ = 60検索/日` 程度に設計。各検索で最大50件取得可能。

### 要件E: Shorts（ショート動画）を主対象とする（方針A採用）
- 背景: 映えスポット/カフェ/グルメのトレンドは Shorts に多数投稿されており、短尺・縦型で閲覧UXが良い。本機能は **Shorts中心** で構成する。
- 規約上の位置づけ: Shorts は **専用リソースではなく「短尺・縦型の通常動画」**。よって要件A〜D（30日ルール・埋め込み再生・広告配置・ブランド表示）が**そのまま適用され、そのまま満たせる**。新たな規約リスクは増えない。
- 実装対応:
  - APIに「Shortsのみ」フィルタは無いため、**`videos.list` の `contentDetails.duration`（ISO 8601）で尺を判定**し、**60秒以下**の動画のみ採用する（Shorts判定）。
  - 再生UIは **縦型（9:16）に最適化**した埋め込みプレイヤーとする。
  - `videos.list` は 1ユニット/回のため、尺判定を足しても **クォータ予算（60検索/日）はそのまま維持**。

---

## 2. Firestore データ設計

コレクション `trends`、ドキュメントID = `{area}_{category}`（例: `tokyo_cafe`）。

```
trends (collection)
  └─ tokyo_cafe (document)
       ├─ area: "東京"
       ├─ areaKey: "tokyo"
       ├─ category: "カフェ"
       ├─ categoryKey: "cafe"
       ├─ updatedAt: <timestamp>          // 要件A: 30日ルールの起点
       └─ videos: [                       // メタデータのみ（動画本体は保持しない）・Shortsのみ
            {
              videoId: "abc123",
              title: "東京の映えカフェ5選",
              thumbnailUrl: "https://i.ytimg.com/vi/abc123/hqdefault.jpg",
              channelTitle: "..." ,
              publishedAt: "2026-08-01T...",
              durationSeconds: 42,          // 要件E: Shorts判定に使用（≤60秒のみ保存）
              isShort: true                 // 要件E: 縦型プレイヤー出し分け用フラグ
            }, ...
          ]
```

- **バッチは Shorts（`durationSeconds ≤ 60`）のみを `videos` に保存**する（要件E）。通常尺は保存しない。

- Firestoreには**軽量メタデータのみ**（画像・動画そのものは保存しない）。無料枠1GBを圧迫しない。
- セキュリティルール: `trends` は `read: true / write: false`（クライアントは読むだけ）。

---

## 3. バッチ（GitHub Actions）実装計画

### 3.0 リポジトリ分離（重要・セキュリティ）
- **本体 MapRoulette リポジトリは public** のため、バッチは **別の private 新規リポジトリ**（例: `maproulette-trend-batch`）に置く。
- 理由: サービスアカウントJSONは Firestore 書き込み権限を持つ強力な鍵。public repo ではコード/ログ/定義が全公開になり、設定ミス時の漏洩リスクが高い。Secrets自体は隠れるが、事故耐性のため private に分離する。
- コスト: private でも GitHub Actions 無料枠 2,000分/月。1日1回・数分なので月30〜90分程度で**実質無料**。
- アプリ(public)とバッチ(private)は GitHub 上で繋げる必要なし。**Firestore を介してデータだけが流れる**。

### 3.1 ディレクトリ構成（新規 private リポジトリ直下）
```
/trend-batch/
  ├─ fetch_trends.py            # メイン: YouTube検索 → Firestore upsert → 古doc削除
  ├─ areas_categories.json      # エリア×カテゴリ定義（60検索に収まる範囲）
  ├─ requirements.txt           # google-api-python-client, firebase-admin
  └─ README.md
/.github/workflows/
  └─ trend-batch.yml            # cron: 1日1回
```

### 3.2 バッチ処理ロジック（fetch_trends.py）
1. `areas_categories.json` を読み、エリア×カテゴリの組を列挙（≤60）。
2. 各組で YouTube `search.list`（`q=<エリア> <カテゴリ>`, `order=viewCount`, `type=video`, `maxResults` 適量）。
   - Shorts を拾いやすくするため `videoDuration=short`（4分未満）も併用してよい。ただし最終判定は次ステップの尺で行う。
3. 得られた videoId 群を **`videos.list`（`part=contentDetails,snippet`）でまとめて取得**し、`contentDetails.duration`（ISO 8601）を秒数に変換。
4. **要件E: `durationSeconds ≤ 60` の Shorts のみを採用**（縦型判定含め `isShort=true` を付与）。通常尺は捨てる。
5. 採用分からメタデータ（videoId/title/thumbnailUrl/channelTitle/publishedAt/durationSeconds/isShort）を抽出。
6. `trends/{area}_{category}` に **`updatedAt=now` 付きで上書き（set）**。
7. **`updatedAt` が閾値より古い or 未定義のドキュメントを削除**（要件A保険）。
8. ログ出力（検索件数・Shorts採用件数・書込件数・削除件数）。

> クォータ: `search.list`（100/回）は据え置き60回/日。`videos.list`（1/回）は数百回程度でも無料枠 10,000 に対し微小。合計でも余裕で無料枠内。

### 3.3 GitHub Actions workflow（trend-batch.yml）
- `on: schedule: cron`（1日1回）+ `workflow_dispatch`（手動実行可）。
- Secrets を環境変数に注入して `fetch_trends.py` を実行。
- 使用 Secrets:
  - `YOUTUBE_API_KEY`（STEP 1で発行）
  - `FIREBASE_SERVICE_ACCOUNT`（STEP 3のJSONを丸ごと）

---

## 4. iOSアプリ実装計画

### 4.1 依存追加（SPM）
- `firebase-ios-sdk` から **`FirebaseFirestore` のみ**追加（全部は入れない）。
- 埋め込み再生用に **`YouTubePlayerKit`**（または公式iframe + `WKWebView` の自前ラッパー）を追加。

### 4.2 タブ追加（ContentView.swift）
現状は独自 `CustomTabBar` + `switch selectedTab`（0〜3の4タブ）。**5タブ目 case 4 = ホーム** を追加。

- `ContentView` の `switch` に `case 4: HomeView()` を追加。
- `CustomTabBar` に `TabBarItem`（icon: `house` 等, title: `NSLocalizedString("tab.home", ...)`）を追加。
- ローカライズキー `tab.home` を **全12言語**の `Localizable.strings` に追記（既存の `tab.map` 等と同じ作法）。

### 4.3 新規ファイル構成（案）
```
MapRoulette/Views/Home/
  ├─ HomeView.swift                 # 5タブ目ルート。トレンド + 他の独自機能を縦に配置
  ├─ TrendSectionView.swift         # ホーム内のトレンドセクション（縦型サムネの横スクロール）
  ├─ ShortsFeedView.swift           # 要件E: Shorts全画面フィード（縦スワイプで次動画・TikTok風）
  ├─ YouTubeShortPlayerView.swift   # 公式埋め込みプレイヤーの縦型(9:16)ラッパー（再生画面・広告なし）
  └─ Components/
       └─ TrendCard.swift           # 縦型サムネ + タイトル + YouTube出典表記（要件D）
MapRoulette/Services/
  ├─ FirebaseBootstrap.swift        # FirebaseApp.configure()（App起動時）
  └─ TrendRepository.swift          # Firestore `trends` 読み取り + updatedAtガード（要件A）
MapRoulette/Models/
  └─ TrendVideo.swift / TrendGroup.swift  # デコード用モデル
```

### 4.4 起動時初期化（MapRouletteApp.swift）
- `GoogleService-Info.plist` を追加した上で、起動時に `FirebaseApp.configure()` を呼ぶ（Splash表示のタイミングと衝突しないよう `init` or `.onAppear` 冒頭で1回）。

### 4.5 規約対応のUI実装ポイント（再掲・実装で必ず反映）
- **要件C**: ホーム/セクションに広告を出す場合は独自コンテンツを併設。`YouTubeShortPlayerView`・`ShortsFeedView`（再生画面）には広告を置かない。
- **要件D**: `TrendCard` と再生画面に YouTubeロゴ/「YouTubeで見る」を表示。
- **要件A**: `TrendRepository` で `updatedAt` が古すぎるデータは非表示。
- **要件B**: 再生は必ず埋め込みプレイヤー。ダウンロードボタン等は作らない。
- **要件E（Shorts/縦型）**: プレイヤー領域は 9:16。`ShortsFeedView` は縦スワイプで次のShortsへ。`isShort` を尊重し縦型で表示。埋め込みプレイヤーの機能（ボタン等）は隠さない（要件Bと両立）。

---

## 5. シークレット/秘匿情報の扱い

- 既存 `.gitignore` に `secretConfig.swift` があり秘匿の作法あり。
- 追加で **`GoogleService-Info.plist` を `.gitignore` に追加**（公開repoでなくても慣習として）。
- YouTube APIキー・サービスアカウントJSONは **GitHub Secrets のみ**に置き、コード/repoに直書きしない。
- サービスアカウントJSONは端末ダウンロード後、Secrets登録したらローカルからも削除推奨。

---

## 6. 実装フェーズ（順序）

| フェーズ | 内容 | 実施者 |
|---|---|---|
| P0 | 事前準備（APIキー/Firebase/サービスアカウント/SDK） | **ユーザー**（本書 §7） |
| P1 | アプリUI: 5タブ目 + ホーム + トレンドUI（**ダミーデータで先行実装可**） | Claude |
| P2 | バッチ: fetch_trends.py + workflow + 定義JSON | Claude |
| P3 | 接続: Firestore読み取り結線・実データ表示・規約UI（出典/広告制御） | Claude |
| P4 | 検証: 30日ルール/埋め込み再生/広告非配置/ブランド表示の最終チェック | Claude + ユーザー |

- P1 は Firebase接続前でも着手可能（ダミーデータ）。準備と並行できる。

---

## 7. ユーザーが実施する事前準備手順（P0）

> これらはブラウザ/Xcode操作が必要でClaudeが代行不可。詰まったら画面状況を共有。

### STEP 1: YouTube Data API キー発行（Google Cloud）
1. https://console.cloud.google.com/ でプロジェクト作成（例: `MapRoulette-Trends`）。
2. 「APIとサービス」→「ライブラリ」→ **YouTube Data API v3** を有効化。
3. 「認証情報」→「認証情報を作成」→ **APIキー** を発行しコピー。
4. キーの制限で **YouTube Data API v3 のみ** に限定。
5. → このキーはバッチ専用（アプリには入れない）。

### STEP 2: Firebaseプロジェクト作成 + Firestore
1. https://console.firebase.google.com/ →「プロジェクトを追加」→ STEP1のGCloudプロジェクトを選択。
2. プランは **Spark（無料）のまま**。Blazeにしない。
3. 「Firestore Database」→ データベース作成 → **本番モード** / ロケーション `asia-northeast1`。
4. ルールを以下に設定:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /trends/{doc} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

### STEP 3: サービスアカウントJSON発行
1. Firebase「プロジェクトの設定」→「サービス アカウント」→「新しい秘密鍵の生成」。
2. ダウンロードされたJSONは **gitにコミットしない**（後でGitHub Secretsに登録）。

### STEP 4: iOSアプリにFirebase追加（Xcode）
1. Firebaseコンソールで iOS アプリ登録、Bundle ID = **`com.kanbe1365.MapRoulette`**。
2. `GoogleService-Info.plist` をダウンロードし Xcode プロジェクトに追加。
3. SPMで `https://github.com/firebase/firebase-ios-sdk` を追加 → **`FirebaseFirestore` のみ**。

### STEP 5: バッチ用 private リポジトリ作成 + GitHub Secrets 登録
> 本体 MapRoulette は public のため、バッチは**別の private 新規リポジトリ**に置く（§3.0 参照）。
1. GitHub で **private の新規リポジトリ**を作成（例: `maproulette-trend-batch`）。中身は空でOK（コードはP2でClaudeが用意）。
2. その新規repo → Settings → Secrets and variables → Actions。
3. 追加:
   - `YOUTUBE_API_KEY` = STEP1のキー
   - `FIREBASE_SERVICE_ACCOUNT` = STEP3のJSON全文

---

## 8. 完了の定義（Definition of Done）

- [ ] 5タブ目「ホーム」が表示され、トレンドセクションが実データで表示される。
- [ ] 動画タップで**公式埋め込みプレイヤー**が再生される（DL手段なし）。
- [ ] 表示される動画が **Shorts（≤60秒）のみ**で、**縦型プレイヤー**で再生される（要件E）。
- [ ] 保存データが毎日更新され、古いドキュメントが削除される（30日ルール）。
- [ ] トレンド再生画面に広告がなく、一覧は独自コンテンツと共存している（広告ルール）。
- [ ] YouTube出典/ブランド表記が表示されている。
- [ ] 課金が一切発生していない（Spark維持・GitHub Actions無料枠内）。
