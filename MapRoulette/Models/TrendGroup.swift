//
//  TrendGroup.swift
//  MapRoulette
//
//  ホームタブ「トレンド機能」の「都道府県×カテゴリ」グループモデル。
//  Firestore の trends_bundle/group{A|B} の groups[] 要素に対応する
//  （計画書 docs/HomeTab_Renewal_Plan.md §2.4）。
//
//  要件A（30日ルール）: updatedAt を必ず持ち、アプリ側でも古すぎるデータは非表示にする。
//  prefKey は iOS 側 Prefecture.rawValue と一致（県ルックアップの結合キー）。
//

import Foundation

/// 「都道府県×カテゴリ」ごとの Shorts のまとまり。例: 東京 × カフェ。
struct TrendGroup: Identifiable, Codable, Hashable {
    /// 都道府県キー（例: "tokyo"）。iOS 側 Prefecture.rawValue と一致（県ルックアップの結合キー）。
    let prefKey: String
    /// 都道府県表示名（例: "東京都"）。
    let prefName: String
    /// カテゴリ表示名（例: "カフェ"）。
    let category: String
    /// カテゴリキー（例: "cafe"）。
    let categoryKey: String
    /// 最終更新時刻（要件A: 30日ルールの起点）。
    let updatedAt: Date
    /// このグループに属する Shorts 群（メタデータのみ）。
    let videos: [TrendVideo]

    /// 一意な識別子（`{prefKey}_{categoryKey}`）。
    var id: String { "\(prefKey)_\(categoryKey)" }

    /// この県に対応する Prefecture（無効な prefKey なら nil）。
    var prefecture: Prefecture? { Prefecture(rawValue: prefKey) }

    /// 画面に出すカテゴリ名。
    ///
    /// Firestore の `category`（バッチが書いた文字列）はそのまま使わず、`categoryKey` から
    /// アプリ側のローカライズ文言を引く。理由は 2 つ:
    ///  - バッチの文言に表示が引きずられない（文言を変えたいときアプリ側だけで直せる）。
    ///  - 日本語以外の端末でも各言語の文言が出る（Firestore の値は日本語固定のため）。
    /// 未知の categoryKey（バッチがカテゴリを増やした場合）は Firestore の値にフォールバックする。
    var categoryName: String {
        let key = "home.trend.category.\(categoryKey)"
        let localized = NSLocalizedString(key, comment: "トレンドのカテゴリ名")
        // NSLocalizedString は未定義キーだとキー文字列をそのまま返す。
        return localized == key ? category : localized
    }

    /// セクション見出し用の表示名（例: "東京都のカフェ"）。
    var displayTitle: String {
        String(
            format: NSLocalizedString("home.trend.group.title", comment: "県のカテゴリ"),
            prefName, categoryName
        )
    }
}
