//
//  TravelPlan.swift
//  MapRoulette
//
//  旅行プラン機能のデータモデル。
//  観光スポット・グルメ・温泉・祭など、アプリ内の各種情報を
//  共通の PlanItem に変換して 1 つの旅行プランに保存する。
//

import Foundation
import CoreLocation

// MARK: - Prefecture 逆引き
extension Prefecture {
    /// 座標に最も近い都道府県を返す（各県の地域中心座標との距離で判定）。
    /// 注意: 県境付近では誤判定しうる。元データが属する県が確定できる場合はそちらを使うこと。
    static func nearest(to coordinate: CLLocationCoordinate2D) -> Prefecture {
        let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return Prefecture.allCases.min(by: { a, b in
            let ca = a.tourismInfo.region
            let cb = b.tourismInfo.region
            let da = CLLocation(latitude: ca.latitude, longitude: ca.longitude).distance(from: target)
            let db = CLLocation(latitude: cb.latitude, longitude: cb.longitude).distance(from: target)
            return da < db
        }) ?? .tokyo
    }

    /// 指定名の温泉が属する都道府県を、全県の onsenItems から確定的に特定する。
    static func containingOnsen(named name: String) -> Prefecture? {
        Prefecture.allCases.first { pref in
            pref.onsenItems.contains { $0.name == name }
        }
    }

}

// MARK: - PlanItemCategory
/// プラン項目の種別。元データのどのカテゴリ由来かを表す。
enum PlanItemCategory: String, Codable, CaseIterable {
    case attraction   // 観光スポット
    case gourmet      // グルメ
    case onsen        // 温泉
    case festival     // 祭・イベント
    case nature       // 自然スポット
    case souvenir     // お土産（買うものリスト）

    var localizedName: String {
        NSLocalizedString("plan.category.\(rawValue)", comment: "")
    }

    /// SF Symbol アイコン名（既存タブと整合）
    var icon: String {
        switch self {
        case .attraction: return "mappin.and.ellipse"
        case .gourmet:    return "fork.knife"
        case .onsen:      return "thermometer.sun.fill"
        case .festival:   return "sparkles"
        case .nature:     return "leaf.fill"
        case .souvenir:   return "gift.fill"
        }
    }
}

// MARK: - PlanItem
/// 1 つの旅行プランに含まれる 1 項目。
/// 元データ（AttractionLocation / GourmetItem / FixedOnsenItem / FestivalItem 等）から変換して生成する。
struct PlanItem: Identifiable, Codable, Hashable {
    let id: UUID
    var category: PlanItemCategory
    var prefectureRawValue: String   // Prefecture.rawValue（Codable のため文字列で保持）
    var name: String                 // 元データを引くためのキー（県内で一意な表示名）
    // 日程グループ表示で「何日目か」。nil は未割当。ユーザーが手動で設定する。
    var dayNumber: Int?

    init(
        id: UUID = UUID(),
        category: PlanItemCategory,
        prefecture: Prefecture,
        name: String,
        dayNumber: Int? = nil
    ) {
        self.id = id
        self.category = category
        self.prefectureRawValue = prefecture.rawValue
        self.name = name
        self.dayNumber = dayNumber
    }

    // 旧フォーマット（detail / latitude / longitude を含む）との後方互換のためのデコード
    enum CodingKeys: String, CodingKey {
        case id, category, prefectureRawValue, name, dayNumber
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        category = try c.decode(PlanItemCategory.self, forKey: .category)
        prefectureRawValue = try c.decode(String.self, forKey: .prefectureRawValue)
        name = try c.decode(String.self, forKey: .name)
        dayNumber = try c.decodeIfPresent(Int.self, forKey: .dayNumber)
    }

    var prefecture: Prefecture? {
        Prefecture(rawValue: prefectureRawValue)
    }

    /// 座標は元データから引く（保存せず、カテゴリ・県・name で参照）。
    var coordinate: CLLocationCoordinate2D? {
        guard let prefecture else { return nil }
        return PlanItemResolver.coordinate(category: category, prefecture: prefecture, name: name)
    }
}

// MARK: - PlanGroupingMode
/// プラン詳細での項目の区切り方。プランごとに保存される。
enum PlanGroupingMode: String, Codable, CaseIterable {
    case flat   // 日程分けなし（フラットな 1 リスト・デフォルト）
    case day    // 日程（Day1/Day2…）ごとに分ける

    var localizedName: String {
        NSLocalizedString("plan.grouping.\(rawValue)", comment: "")
    }
}

// MARK: - TravelPlan
/// 1 つの旅行プラン（旅のしおり）。順序を持つ PlanItem のリストを保持する。
struct TravelPlan: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var memo: String
    var items: [PlanItem]
    var groupingMode: PlanGroupingMode  // 表示の区切り方（プランごとに保存）
    var dayCount: Int                   // 日程モードでの日数（最低 1）
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        memo: String = "",
        items: [PlanItem] = [],
        groupingMode: PlanGroupingMode = .flat,
        dayCount: Int = 1,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.memo = memo
        self.items = items
        self.groupingMode = groupingMode
        self.dayCount = max(1, dayCount)
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // 古い保存データ（groupingMode / dayCount 無し）との後方互換
    enum CodingKeys: String, CodingKey {
        case id, title, memo, items, groupingMode, dayCount, createdAt, updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        memo = try c.decode(String.self, forKey: .memo)
        items = try c.decode([PlanItem].self, forKey: .items)
        // 旧データの "prefecture" など未知の値は .flat に倒す
        groupingMode = (try? c.decodeIfPresent(PlanGroupingMode.self, forKey: .groupingMode)) ?? .flat
        dayCount = max(1, try c.decodeIfPresent(Int.self, forKey: .dayCount) ?? 1)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try c.decode(Date.self, forKey: .updatedAt)
    }

    /// プランに含まれる都道府県（重複なし・登場順）
    var prefectures: [Prefecture] {
        var seen = Set<String>()
        var result: [Prefecture] = []
        for item in items {
            guard seen.insert(item.prefectureRawValue).inserted,
                  let pref = item.prefecture else { continue }
            result.append(pref)
        }
        return result
    }

    /// 座標を持つ項目だけを抽出（地図表示用）
    var mappableItems: [PlanItem] {
        items.filter { $0.coordinate != nil }
    }

    // MARK: - グループ表示用ヘルパー

    /// 日程ごとにグループ化した項目。day が nil の項目は「未割当」として nil キーに入る。
    /// 戻り値は (day: Int? , items) の配列で、1日目→dayCount→未割当(nil) の順。
    var itemsByDay: [(day: Int?, items: [PlanItem])] {
        var result: [(day: Int?, items: [PlanItem])] = []
        for day in 1...max(1, dayCount) {
            let dayItems = items.filter { $0.dayNumber == day }
            result.append((day, dayItems))
        }
        let unassigned = items.filter { $0.dayNumber == nil || ($0.dayNumber ?? 0) > dayCount || ($0.dayNumber ?? 1) < 1 }
        if !unassigned.isEmpty {
            result.append((nil, unassigned))
        }
        return result
    }
}
