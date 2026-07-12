//
//  PlanShareFormatter.swift
//  MapRoulette
//
//  旅行プランを共有用のプレーンテキストに整形する。
//  日程モードでは Day / 時間ブロックで区切り、フラットモードでは
//  1 リストとして並べる。iOS 標準の共有シート（ShareLink）に渡して
//  SNS・メモ・メールなどへ書き出せるようにするための整形ロジック。
//

import Foundation
import CoreLocation

enum PlanShareFormatter {

    /// プランを共有用テキストに整形して返す。
    static func text(for plan: TravelPlan) -> String {
        var lines: [String] = []

        // タイトル
        let title = plan.title.trimmingCharacters(in: .whitespacesAndNewlines)
        lines.append(title.isEmpty ? NSLocalizedString("plan.untitled", comment: "") : title)

        // メモ（あれば）
        let memo = plan.memo.trimmingCharacters(in: .whitespacesAndNewlines)
        if !memo.isEmpty {
            lines.append("")
            lines.append(memo)
        }

        if plan.groupingMode == .day {
            appendDayGrouped(plan, into: &lines)
        } else {
            appendFlat(plan.items, into: &lines)
        }

        // 連続する空行を 1 つに畳んで整える
        return collapseBlankLines(lines).joined(separator: "\n")
    }

    // MARK: - 日程モード

    private static func appendDayGrouped(_ plan: TravelPlan, into lines: inout [String]) {
        for group in plan.itemsByDay {
            // 項目が 1 つも無い日（未割当セクション含む）は見出しごと出さない
            if group.items.isEmpty { continue }

            lines.append("")
            if let day = group.day {
                lines.append("──── " + String(format: NSLocalizedString("plan.day.format", comment: ""), day) + " ────")
            } else {
                lines.append("──── " + NSLocalizedString("plan.day.unassigned", comment: "") + " ────")
            }

            guard let day = group.day else {
                // 未割当はタイムライン無しでフラットに並べる
                appendItems(group.items, into: &lines)
                continue
            }

            // 実日は時間ブロックごとに区切る。各ブロックの手前に見出し行を必ず出して、
            // 時間指定ありのブロックと時間未指定の項目が続けて並ばないようにする。
            for section in plan.blockSections(forDay: day) {
                if section.items.isEmpty { continue }
                lines.append("[\(blockHeader(for: section.block))]")
                appendItems(section.items, into: &lines)
            }
        }
    }

    /// 時間ブロックの見出し文字列。時刻・見出しがあればそれを、
    /// どちらも無い／ブロック自体が未割当なら「時間未定」ラベルを返す。
    private static func blockHeader(for block: TimeBlock?) -> String {
        guard let block else {
            return NSLocalizedString("plan.timeblock.untimed", comment: "")
        }
        var header = ""
        if let label = block.timeLabel { header += label }
        let blockTitle = block.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !blockTitle.isEmpty {
            header += header.isEmpty ? blockTitle : " " + blockTitle
        }
        return header.isEmpty ? NSLocalizedString("plan.timeblock.untimed", comment: "") : header
    }

    // MARK: - フラットモード

    private static func appendFlat(_ items: [PlanItem], into lines: inout [String]) {
        guard !items.isEmpty else { return }
        lines.append("")
        appendItems(items, into: &lines)
    }

    // MARK: - 項目 1 件ずつの行

    private static func appendItems(_ items: [PlanItem], into lines: inout [String]) {
        for item in items {
            lines.append(line(for: item))
            // メモ・住所は次の行にインデントして添える
            if let memo = item.customDetail?.trimmingCharacters(in: .whitespacesAndNewlines), !memo.isEmpty {
                lines.append("    " + memo)
            }
            if let address = item.effectiveAddress {
                lines.append("    " + address)
            }
            // 位置情報があれば Apple Maps のリンクを添える。SNS 等では URL 文字列が
            // そのままタップ可能なリンクとして認識される。
            if let url = mapURL(for: item) {
                lines.append("    " + url)
            }
        }
    }

    /// 位置情報を持つ項目の Apple Maps URL 文字列。座標が無ければ nil（ピンが立たず精度が乏しいため）。
    /// - `ll` : ピンの座標。手動座標・元データ座標のいずれか。
    /// - `q`  : 地図上に表示するラベル（検索選択された地点名があればそちら、無ければ項目名）。
    private static func mapURL(for item: PlanItem) -> String? {
        guard let coordinate = item.coordinate else { return nil }
        let label = (item.effectivePlaceName ?? item.name).trimmingCharacters(in: .whitespacesAndNewlines)

        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        components.path = "/"
        var query = [URLQueryItem(name: "ll", value: "\(coordinate.latitude),\(coordinate.longitude)")]
        if !label.isEmpty {
            query.insert(URLQueryItem(name: "q", value: label), at: 0)
        }
        components.queryItems = query
        return components.url?.absoluteString
    }

    /// 1 項目の見出し行。「・カテゴリアイコン 名前（都道府県）」形式。
    private static func line(for item: PlanItem) -> String {
        var text = "・" + item.emojiPrefix + item.name
        // アプリ項目は都道府県を添える（カスタム項目は付けない）
        if !item.category.isCustom, let pref = item.prefecture {
            text += "（\(pref.prefectureName)）"
        }
        return text
    }

    // MARK: - 整形ユーティリティ

    /// 連続する空行を 1 行に畳み、先頭・末尾の空行を落とす。
    private static func collapseBlankLines(_ lines: [String]) -> [String] {
        var result: [String] = []
        for line in lines {
            let isBlank = line.trimmingCharacters(in: .whitespaces).isEmpty
            if isBlank, result.last?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
                continue
            }
            result.append(line)
        }
        while result.last?.trimmingCharacters(in: .whitespaces).isEmpty ?? false {
            result.removeLast()
        }
        return result
    }
}

// MARK: - カテゴリ絵文字

private extension PlanItem {
    /// 共有テキストで見分けやすいよう、カテゴリごとの絵文字を頭に付ける。
    var emojiPrefix: String {
        switch category {
        case .attraction: return "📍"
        case .gourmet:    return "🍴"
        case .onsen:      return "♨️"
        case .festival:   return "🎆"
        case .nature:     return "🌿"
        case .souvenir:   return "🎁"
        case .hotel:      return "🏨"
        case .transport:  return "🚉"
        case .other:      return "📝"
        }
    }
}
