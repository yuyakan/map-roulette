//
//  TrendSampleData.swift
//  MapRoulette
//
//  P1（ダミーデータ先行実装）用のトレンドサンプル。
//  P3 で Firestore 読み取り（TrendRepository）に差し替える。
//
//  ここに置く videoId は「公式埋め込みが有効な実在動画」を想定したプレースホルダ。
//  実運用のデータはバッチ（P2）が YouTube Data API から収集し Firestore に格納する。
//  サムネは videoId から YouTube 標準の hqdefault URL を生成している（要件B: サムネURLのみ保持）。
//

import Foundation

enum TrendSampleData {

    /// videoId から YouTube 標準サムネ URL を生成。
    private static func thumb(_ id: String) -> String {
        "https://i.ytimg.com/vi/\(id)/hqdefault.jpg"
    }

    private static func video(
        _ id: String,
        _ title: String,
        _ channel: String,
        _ seconds: Int
    ) -> TrendVideo {
        TrendVideo(
            videoId: id,
            title: title,
            thumbnailUrl: thumb(id),
            channelTitle: channel,
            publishedAt: "2026-08-15T09:00:00Z",
            durationSeconds: seconds,
            isShort: seconds <= 60
        )
    }

    /// ホームのトレンドセクションに並べるダミーグループ群（prefKey は Prefecture.rawValue）。
    static let groups: [TrendGroup] = [
        TrendGroup(
            prefKey: "tokyo",
            prefName: Prefecture.tokyo.prefectureName,
            category: NSLocalizedString("home.trend.category.cafe", comment: ""),
            categoryKey: "cafe",
            updatedAt: Date(),
            videos: [
                video("aqz-KE-bpKQ", "東京の映えカフェ 5選 ☕️", "Tokyo Cafe Hopping", 38),
                video("ScMzIvxBSi4", "隠れ家カフェで優雅な朝を", "Morning Latte", 47),
                video("V-_O7nl0Ii0", "渋谷の話題スイーツ", "Sweet Tokyo", 52),
                video("YE7VzlLtp-4", "ネオンなカフェ探訪", "Neon Eats", 29)
            ]
        ),
        TrendGroup(
            prefKey: "kyoto",
            prefName: Prefecture.kyoto.prefectureName,
            category: NSLocalizedString("home.trend.category.spot", comment: ""),
            categoryKey: "spot",
            updatedAt: Date(),
            videos: [
                video("hV8oGvHt9jA", "京都の映えスポット巡り 🍁", "Kyoto Walks", 41),
                video("e-ORhEE9VVg", "嵐山の絶景ショート", "Scenic Japan", 33),
                video("kXYiU_JCYtU", "夜の祇園さんぽ", "Gion Nights", 55),
                video("fJ9rUzIMcZQ", "伏見稲荷 千本鳥居", "Torii Trail", 44)
            ]
        ),
        TrendGroup(
            prefKey: "osaka",
            prefName: Prefecture.osaka.prefectureName,
            category: NSLocalizedString("home.trend.category.gourmet", comment: ""),
            categoryKey: "gourmet",
            updatedAt: Date(),
            videos: [
                video("RgKAFK5djSk", "大阪グルメ食べ歩き 🍜", "Osaka Bites", 49),
                video("OPf0YbXqDm0", "たこ焼き名店ランキング", "Takoyaki TV", 36),
                video("CevxZvSJLk8", "道頓堀ナイトフード", "Dotonbori Eats", 58),
                video("09R8_2nJtjg", "行列のできる串カツ", "Kushikatsu Life", 27)
            ]
        )
    ]
}
