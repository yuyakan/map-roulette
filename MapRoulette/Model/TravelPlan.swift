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
    // 以下はユーザーが自由に追加するカスタム項目
    case hotel        // 宿泊
    case transport    // 駅・空港など（乗り場の地点。rawValue は互換のため transport を維持）
    case other        // その他メモ

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
        case .hotel:      return "bed.double.fill"
        case .transport:  return "tram.fill"
        case .other:      return "note.text"
        }
    }

    /// ユーザーが手動で追加するカスタム項目か（元データ参照を持たない）。
    var isCustom: Bool {
        switch self {
        case .hotel, .transport, .other: return true
        default: return false
        }
    }

    /// プランに手動追加できるカスタム種別の一覧。
    static var customCases: [PlanItemCategory] { [.hotel, .transport, .other] }

    /// ユーザーが手動で位置（customCoordinate）を持てるカテゴリか。
    /// - カスタム項目（ホテル・駅など）: 地図ピンで位置を指定する
    /// - グルメ・お土産: 元データに座標が無いので任意で店の位置を足せる
    /// - 観光・温泉・祭・自然: 元データに正確な座標があるため手動位置は持たせない
    var allowsUserCoordinate: Bool {
        switch self {
        case .hotel, .transport, .other, .gourmet, .souvenir: return true
        case .attraction, .onsen, .festival, .nature: return false
        }
    }
}

// MARK: - PlanItem
/// 1 つの旅行プランに含まれる 1 項目。
/// 元データ（AttractionLocation / GourmetItem / FixedOnsenItem / FestivalItem 等）から変換して生成する。
struct PlanItem: Identifiable, Codable, Hashable {
    let id: UUID
    var category: PlanItemCategory
    var prefectureRawValue: String   // Prefecture.rawValue。カスタム項目では空文字可。
    var name: String                 // アプリ項目: 元データを引くキー / カスタム項目: ユーザー入力のタイトル
    var dayNumber: Int?              // 日程グループ表示で「何日目か」。nil は未割当。
    var timeBlockID: UUID?           // 日程内の時間ブロックへの割当。nil はブロック未割当。

    // --- カスタム項目（hotel/transport/other）専用。アプリ項目では nil ---
    var customDetail: String?        // ユーザー入力のメモ
    var customLatitude: Double?      // 任意の位置（地図ピン）
    var customLongitude: Double?
    // 検索で選んだ地点名。設定時は経路案内で座標でなくこの名前を使う（ピンを動かすと nil）。
    var customPlaceName: String?
    // 住所（検索選択時は placemark.title、ピン手動移動時は逆ジオコーディング結果）。表示用。
    var customAddress: String?

    /// アプリ項目（既存データ参照）用のイニシャライザ
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

    /// カスタム項目（ユーザー入力）用のイニシャライザ
    init(
        id: UUID = UUID(),
        customCategory: PlanItemCategory,
        title: String,
        detail: String = "",
        coordinate: CLLocationCoordinate2D? = nil,
        dayNumber: Int? = nil
    ) {
        self.id = id
        self.category = customCategory
        self.prefectureRawValue = ""
        self.name = title
        self.customDetail = detail
        self.customLatitude = coordinate?.latitude
        self.customLongitude = coordinate?.longitude
        self.dayNumber = dayNumber
    }

    // 旧フォーマットとの後方互換（カスタム用フィールドは任意デコード）
    enum CodingKeys: String, CodingKey {
        case id, category, prefectureRawValue, name, dayNumber, timeBlockID
        case customDetail, customLatitude, customLongitude, customPlaceName, customAddress
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        category = try c.decode(PlanItemCategory.self, forKey: .category)
        prefectureRawValue = try c.decode(String.self, forKey: .prefectureRawValue)
        name = try c.decode(String.self, forKey: .name)
        dayNumber = try c.decodeIfPresent(Int.self, forKey: .dayNumber)
        timeBlockID = try c.decodeIfPresent(UUID.self, forKey: .timeBlockID)
        customDetail = try c.decodeIfPresent(String.self, forKey: .customDetail)
        customLatitude = try c.decodeIfPresent(Double.self, forKey: .customLatitude)
        customLongitude = try c.decodeIfPresent(Double.self, forKey: .customLongitude)
        customPlaceName = try c.decodeIfPresent(String.self, forKey: .customPlaceName)
        customAddress = try c.decodeIfPresent(String.self, forKey: .customAddress)
    }

    /// 表示用の住所。手動座標が有効なときのみ意味を持つ（customCoordinate と同じ条件）。
    var effectiveAddress: String? {
        guard customCoordinate != nil, let a = customAddress?.trimmingCharacters(in: .whitespacesAndNewlines), !a.isEmpty else { return nil }
        return a
    }

    var prefecture: Prefecture? {
        Prefecture(rawValue: prefectureRawValue)
    }

    /// 説明文。カスタム項目は保存値、アプリ項目は元データから引く。
    var detail: String? {
        if category.isCustom { return customDetail }
        guard let prefecture else { return nil }
        return PlanItemResolver.detail(category: category, prefecture: prefecture, name: name)
    }

    /// ユーザーが手動で追加した座標。位置を持てるカテゴリ以外では無視する
    /// （観光・温泉等は元データの正確な座標を常に優先するため、過去データが残っていても無効化）。
    var customCoordinate: CLLocationCoordinate2D? {
        guard category.allowsUserCoordinate,
              let lat = customLatitude, let lng = customLongitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    /// 座標。手動追加した座標（許可カテゴリのみ）を優先し、無ければ元データから引く。
    var coordinate: CLLocationCoordinate2D? {
        if let custom = customCoordinate { return custom }
        if category.isCustom { return nil }
        guard let prefecture else { return nil }
        return PlanItemResolver.coordinate(category: category, prefecture: prefecture, name: name)
    }

    /// 経路案内で使う、検索選択された地点名。手動座標が有効なときのみ意味を持つ
    /// （customCoordinate と同じく、許可カテゴリ以外では無視）。
    var effectivePlaceName: String? {
        guard customCoordinate != nil, let n = customPlaceName, !n.isEmpty else { return nil }
        return n
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

// MARK: - TimeBlock
/// 日程モードで、1 日の中を時間帯で区切るブロック。
/// 任意の開始時刻（時・分のみ）と見出しを持ち、この中に複数の PlanItem を入れる。
/// どの日のブロックかは dayNumber で持ち、項目側は timeBlockID で所属を指す。
struct TimeBlock: Identifiable, Codable, Hashable {
    let id: UUID
    var dayNumber: Int          // このブロックが属する日（1 始まり）
    var startHour: Int?         // 開始「時」。nil は時間未設定ブロック。
    var startMinute: Int?       // 開始「分」。
    var title: String           // 任意の見出し（"午前" 等）。空でも可。

    init(
        id: UUID = UUID(),
        dayNumber: Int,
        startHour: Int? = nil,
        startMinute: Int? = nil,
        title: String = ""
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.startHour = startHour
        self.startMinute = startMinute
        self.title = title
    }

    enum CodingKeys: String, CodingKey {
        case id, dayNumber, startHour, startMinute, title
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        dayNumber = try c.decode(Int.self, forKey: .dayNumber)
        startHour = try c.decodeIfPresent(Int.self, forKey: .startHour)
        startMinute = try c.decodeIfPresent(Int.self, forKey: .startMinute)
        title = try c.decodeIfPresent(String.self, forKey: .title) ?? ""
    }

    /// 開始時刻を持つか（時が設定されていれば時刻ありとみなす）。
    var hasTime: Bool { startHour != nil }

    /// "09:05" 形式の時刻ラベル。時刻未設定なら nil。
    var timeLabel: String? {
        guard let h = startHour else { return nil }
        return String(format: "%02d:%02d", h, startMinute ?? 0)
    }

    /// ソート用の分換算（時刻なしは末尾へ回すため大きな値）。
    var sortKey: Int {
        guard let h = startHour else { return Int.max }
        return h * 60 + (startMinute ?? 0)
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
    var timeBlocks: [TimeBlock]         // 日程内の時間ブロック定義（日程モードで使用）
    var isCompleted: Bool               // 旅行済みか（訪問済みマップの集計対象になる）
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        memo: String = "",
        items: [PlanItem] = [],
        groupingMode: PlanGroupingMode = .flat,
        dayCount: Int = 1,
        timeBlocks: [TimeBlock] = [],
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.memo = memo
        self.items = items
        self.groupingMode = groupingMode
        self.dayCount = max(1, dayCount)
        self.timeBlocks = timeBlocks
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // 古い保存データ（groupingMode / dayCount / timeBlocks / isCompleted 無し）との後方互換
    enum CodingKeys: String, CodingKey {
        case id, title, memo, items, groupingMode, dayCount, timeBlocks, isCompleted, createdAt, updatedAt
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
        timeBlocks = try c.decodeIfPresent([TimeBlock].self, forKey: .timeBlocks) ?? []
        // 旧データは isCompleted を持たないため未完了扱い
        isCompleted = try c.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
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

    /// 指定した日の時間ブロック（開始時刻順・時刻なしは末尾）。
    func timeBlocks(forDay day: Int) -> [TimeBlock] {
        timeBlocks
            .filter { $0.dayNumber == day }
            .sorted { a, b in
                if a.sortKey != b.sortKey { return a.sortKey < b.sortKey }
                return a.id.uuidString < b.id.uuidString   // 同時刻は安定順
            }
    }

    /// 指定した日の項目を「時間ブロックごと」に分けて返す。
    /// - blockID が現存ブロックを指す項目は、そのブロックへ。
    /// - block が nil（未割当）／存在しないブロックを指す項目は、末尾の「ブロック未割当」へ。
    /// 各ブロック内および未割当内の項目順は items 配列の順序（手動並び）を保つ。
    func blockSections(forDay day: Int) -> [(block: TimeBlock?, items: [PlanItem])] {
        let dayItems = items.filter { $0.dayNumber == day }
        let blocks = timeBlocks(forDay: day)
        let validIDs = Set(blocks.map { $0.id })

        var result: [(block: TimeBlock?, items: [PlanItem])] = []
        for block in blocks {
            let blockItems = dayItems.filter { $0.timeBlockID == block.id }
            result.append((block, blockItems))
        }
        let unassigned = dayItems.filter { $0.timeBlockID == nil || !validIDs.contains($0.timeBlockID!) }
        // ブロックが 1 つも無い日は「未割当」見出しを出さず、項目だけを nil セクションで返す。
        if !unassigned.isEmpty || blocks.isEmpty {
            result.append((nil, unassigned))
        }
        return result
    }

    /// 指定した日の項目を「訪問順」に一列で返す。
    /// 時間ブロックを開始時刻順に並べ、各ブロック内は手動並び、時刻なし・未割当は末尾。
    /// リスト表示（blockSections）と同じ順序なので、地図の経路もリストと一致する。
    func orderedItems(forDay day: Int) -> [PlanItem] {
        blockSections(forDay: day).flatMap { $0.items }
    }
}
