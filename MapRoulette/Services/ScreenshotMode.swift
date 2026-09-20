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

    /// 差し替え用のモックサムネ Asset 名。
    /// Assets.xcassets/MockThumbnails/ に対応する imageset がある。
    private static let mockAssets = [
        "mock_trend_cafe",
        "mock_trend_gourmet",
        "mock_trend_mountain",
        "mock_trend_sea",
        "mock_trend_night",
        "mock_trend_festival",
        "mock_trend_onsen",
        "mock_trend_torii",
        "mock_trend_sakura",
    ]

    /// 元のサムネ URL に対応するモック Asset 名を返す。
    ///
    /// URL の安定ハッシュで選ぶので、**同じ動画には常に同じ絵**が割り当たる。
    /// 撮影し直しても並びが変わらず、スクロールしても絵が入れ替わらない。
    /// （`hashValue` は実行ごとに変わるので使えない。）
    static func mockAssetName(for urlString: String) -> String {
        mockAssets[stableIndex(of: urlString, count: mockAssets.count)]
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
