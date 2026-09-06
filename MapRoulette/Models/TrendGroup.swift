//
//  TrendGroup.swift
//  MapRoulette
//
//  ホームタブ「トレンド機能」の「エリア×カテゴリ」グループモデル。
//  Firestore の `trends/{area}_{category}` ドキュメントに 1:1 対応する（計画書 §2）。
//
//  要件A（30日ルール）: updatedAt を必ず持ち、アプリ側でも古すぎるデータは非表示にする。
//  P3 でその表示ガードを TrendRepository に実装する。P1 はモデル定義のみ。
//

import Foundation

/// 「エリア×カテゴリ」ごとの Shorts のまとまり。例: 東京 × カフェ。
struct TrendGroup: Identifiable, Codable, Hashable {
    /// エリア表示名（例: "東京"）。
    let area: String
    /// エリアキー（例: "tokyo"）。ドキュメント ID 構築に使用。
    let areaKey: String
    /// カテゴリ表示名（例: "カフェ"）。
    let category: String
    /// カテゴリキー（例: "cafe"）。ドキュメント ID 構築に使用。
    let categoryKey: String
    /// 最終更新時刻（要件A: 30日ルールの起点）。
    let updatedAt: Date
    /// このグループに属する Shorts 群（メタデータのみ）。
    let videos: [TrendVideo]

    /// Firestore のドキュメント ID と同じ規則（`{areaKey}_{categoryKey}`）。
    var id: String { "\(areaKey)_\(categoryKey)" }

    /// セクション見出し用の表示名（例: "東京のカフェ"）。
    var displayTitle: String {
        String(
            format: NSLocalizedString("home.trend.group.title", comment: "エリアのカテゴリ"),
            area, category
        )
    }
}
