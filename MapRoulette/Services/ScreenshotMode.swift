//
//  ScreenshotMode.swift
//  MapRoulette
//
//  App Store のスクリーンショット撮影専用のモード。
//
//  【なぜ要るか】
//  トレンド機能は他人の YouTube 動画のサムネ・タイトル・チャンネル名を表示する。
//  アプリ内でそれを出すことは規約上まったく問題ない（公式埋め込み・出典表記・
//  30日ルールをすべて満たしている）が、**App Store の販促素材**に他社コンテンツを
//  載せるのは話が別で、次の2点に触れる。
//   - Apple: 他社の商標・実在人物の顔が写る／第三者コンテンツがアプリの売りに見える
//   - YouTube: ブランド利用のガイドラインはアプリ内表示とプロモ素材で別の制約を課す
//  そこで撮影時だけサムネを自前のモック画像に差し替える。
//
//  【安全側の設計】
//  - 既定は必ず false。有効化は「起動引数」でしか行えない（UI もビルド設定も介さない）。
//  - #if DEBUG で囲ってあり、Release ビルドでは常に false に畳まれる。
//    → 誤って有効なまま App Store 用バイナリを作ることが構造的に起きない。
//
//  【使い方】
//  Xcode > Product > Scheme > Edit Scheme… > Run > Arguments >
//  "Arguments Passed On Launch" に次を追加してから実行する:
//
//      -MRScreenshotMode YES
//
//  撮影が終わったらチェックを外すだけでよい（コードは元に戻さなくてよい）。
//
//  モックは「実在の動画サムネに似せない」方針で作ってある（人物・ロゴ・文字なし、
//  幾何形状だけの抽象的な風景）。実在コンテンツの偽装は、避けようとしている
//  「誤解を与えるスクショ」そのものになるため。
//

import Foundation

enum ScreenshotMode {

    /// 撮影モードが有効か。Release では常に false。
    static var isEnabled: Bool {
        #if DEBUG
        return UserDefaults.standard.bool(forKey: "MRScreenshotMode")
        #else
        return false
        #endif
    }

    /// 差し替え用のモックサムネ Asset 名。棚（カテゴリ）ごとに母集団を分けてある。
    /// Assets.xcassets/MockThumbnails/ に対応する imageset がある。
    ///
    /// 【なぜ棚ごとに分けるか】
    /// 以前は全棚で 9 枚を共有していたため、「沖縄県のグルメ」に花火や鳥居が
    /// 並ぶことがあった。横に 8 枚前後見える iPad では中身と絵の不一致が露骨に出る。
    ///
    /// 【画像の出所】
    /// アプリ同梱写真のうち **CC0 / Public domain のものだけ**を切り出している
    /// （`tools/mock_thumbnails/build_from_bundled.py`）。App Store のスクショは
    /// アプリとは別の配布物で、アプリ内のクレジット画面はストアページの閲覧者に
    /// 届かないため、帰属表記が要る CC BY は使わない。
    private static let mockAssetsByShelf: [String: [String]] = [
        "gourmet": ["mock_gourmet_1", "mock_gourmet_2", "mock_gourmet_3", "mock_gourmet_4",
                    "mock_gourmet_5", "mock_gourmet_6", "mock_gourmet_7", "mock_gourmet_8"],
        "spot":    ["mock_spot_1", "mock_spot_2", "mock_spot_3", "mock_spot_4",
                    "mock_spot_5", "mock_spot_6", "mock_spot_7", "mock_spot_8"],
        "cafe":    ["mock_cafe_1", "mock_cafe_2", "mock_cafe_3",
                    "mock_cafe_4", "mock_cafe_5", "mock_cafe_6"],
    ]

    /// 棚が特定できないとき（Shorts 全画面など）に使う全体の母集団。
    private static let allMockAssets: [String] =
        mockAssetsByShelf.keys.sorted().flatMap { mockAssetsByShelf[$0] ?? [] }

    /// 棚のなかでの並び順に対応するモック Asset 名を返す。
    ///
    /// `position`（棚のなかで何番目のカードか）をそのまま使って先頭から順に配るので、
    /// **母集団を使い切るまで同じ絵が隣り合わない**。撮影のたびに並びが変わることも
    /// ないので、撮り直しても同じ絵柄になる。
    ///
    /// 【なぜハッシュをやめたか】
    /// 以前は URL の安定ハッシュで選んでいた。「同じ動画には常に同じ絵」にはなるが、
    /// 隣り合うカードが同じ絵を引く確率が素通しで、8 枚の母集団に対して iPad のように
    /// 8 枚前後が同時に見える画面では、同じ絵が並ぶのが普通に起きていた。
    /// スクショ用途では「並びが重複しない」ほうが優先なので、位置で配る方式にした。
    ///
    /// `shelf` に棚の categoryKey（spot / gourmet / cafe）を渡すと、その棚に
    /// ふさわしい絵だけから選ぶ。未知の棚・棚なしのときは全体から選ぶ。
    /// `position` を省いたとき（棚の外＝Shorts 全画面など）は URL のハッシュで選ぶ。
    static func mockAssetName(for urlString: String,
                              shelf: String? = nil,
                              position: Int? = nil) -> String {
        let pool = shelf.flatMap { mockAssetsByShelf[$0] } ?? allMockAssets
        guard let position else {
            return pool[stableIndex(of: urlString, count: pool.count)]
        }
        // 負値が来ても落ちないように正の剰余へ寄せる。
        let index = ((position % pool.count) + pool.count) % pool.count
        return pool[index]
    }

    // MARK: - タイトル / チャンネル名の差し替え
    //
    // サムネだけ隠しても、カードにはチャンネル名と動画タイトルが出る。
    // どちらも実在の投稿者の情報なのでスクショには写さない。

    private static let mockTitles = [
        "絶景スポットめぐり",
        "旅先のおすすめグルメ",
        "週末の小さな旅",
        "この街のいちばん好きな場所",
        "朝いちばんの景色",
        "夜まで楽しむ町歩き",
        "名湯でととのう休日",
        "季節の風景をたずねて",
        "地元で人気の一皿",
    ]

    private static let mockChannels = [
        "旅のしおり",
        "ぶらり日本",
        "週末トラベル",
        "にっぽん散歩",
        "旅と温泉",
        "季節めぐり",
    ]

    /// 撮影用のダミータイトル。動画 ID で決まるので毎回同じ文言になる。
    static func mockTitle(for videoId: String) -> String {
        mockTitles[stableIndex(of: videoId, count: mockTitles.count)]
    }

    /// 撮影用のダミーチャンネル名。実在のチャンネルを想起させない一般的な名前のみ。
    static func mockChannel(for videoId: String) -> String {
        mockChannels[stableIndex(of: videoId, count: mockChannels.count)]
    }

    /// djb2 ベースの安定ハッシュ。実行をまたいでも同じ値になる。
    private static func stableIndex(of key: String, count: Int) -> Int {
        var hash: UInt64 = 5381
        for byte in key.utf8 {
            hash = (hash &* 33) &+ UInt64(byte)
        }
        return Int(hash % UInt64(count))
    }
}
