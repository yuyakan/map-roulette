//
//  TripIntents.swift
//  MapRoulette
//
//  Siri・ショートカット・Spotlight から呼び出せる操作（App Intents / App Shortcuts）。
//
//  【何ができるか】
//  - ルーレットを回して行き先の県を答える（アプリは開かない）
//  - 指定した県の詳細を開く
//  - 近くのスポットを開く（種類で絞り込み可）
//  - 次の旅（進行中・計画中のプラン）を開く
//  - 旅行を計画する（プラン一覧を開く）
//
//  【構成】
//  画面を開く操作は AppRouter に「開いてほしい画面」を予約し、各タブがそれを受け取って開く。
//  見開き（Duo の内側画面・iPad 横向き）では各タブの detailCover 経由で右ページに出る。
//
//  【フレーズの言語】
//  開発言語が英語なので、コード上のフレーズ・文言は英語で書き、日本語は
//  ja.lproj の AppShortcuts.strings（フレーズ）と Localizable.strings（文言）で訳す。
//  ほかの言語では英語のフレーズで呼べる。
//

import AppIntents

// MARK: - 県

/// Siri に渡す「県」。話し言葉の県名（「京都」「きょうと」など）からも引けるようにする。
struct PrefectureEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Prefecture"
    static let defaultQuery = PrefectureQuery()

    /// Prefecture の rawValue（ローマ字）。
    let id: String

    var prefecture: Prefecture? { Prefecture(rawValue: id) }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(prefecture?.prefectureName ?? id)")
    }

    init(_ prefecture: Prefecture) {
        id = prefecture.rawValue
    }
}

struct PrefectureQuery: EntityStringQuery {
    @MainActor
    func entities(for identifiers: [String]) async throws -> [PrefectureEntity] {
        identifiers.compactMap(Prefecture.init(rawValue:)).map(PrefectureEntity.init)
    }

    /// 話した県名から探す。「京都府」「京都」「きょうと」「kyoto」のどれでも当たるよう、
    /// 都・道・府・県を外した形でも比べる。
    @MainActor
    func entities(matching string: String) async throws -> [PrefectureEntity] {
        let query = Self.normalize(string)
        guard !query.isEmpty else { return [] }
        return Prefecture.allCases
            .filter { prefecture in
                prefecture.searchKeywords.contains { Self.normalize($0).hasPrefix(query) || query.hasPrefix(Self.normalize($0)) }
            }
            .map(PrefectureEntity.init)
    }

    @MainActor
    func suggestedEntities() async throws -> [PrefectureEntity] {
        Prefecture.allCases.map(PrefectureEntity.init)
    }

    private static func normalize(_ text: String) -> String {
        var s = text.lowercased().trimmingCharacters(in: .whitespaces)
        for suffix in ["県", "府", "都", "道", "けん", "ふ", "と"] where s.count > suffix.count + 1 && s.hasSuffix(suffix) {
            s.removeLast(suffix.count)
            break
        }
        return s
    }
}

// MARK: - ルーレット

/// ルーレットを回して行き先の県を答える。アプリは開かず、Siri が結果を読み上げる。
/// 対象の県・重み付けは、アプリのルーレット設定（マップタブの歯車）と同じものを使う。
struct SpinRouletteIntent: AppIntent {
    static let title: LocalizedStringResource = "Spin the Roulette"
    static let description = IntentDescription("Picks a random prefecture for your next trip.")

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let displayMode = RouletteSettingsStore.loadDisplayMode()
        let available: Set<Prefecture> = displayMode == .onsen
            ? Set(Prefecture.prefecturesWithOnsen)
            : Set(Prefecture.allCases)
        var candidates = RouletteSettingsStore.loadEnabledPrefectures().intersection(available)
        if candidates.isEmpty { candidates = available }

        guard let result = WeightManager().selectRandomPrefecture(from: candidates) else {
            return .result(dialog: "Couldn't pick a destination. Please check the roulette settings.")
        }
        // ホームの「最近見た」に出して、あとでアプリから続きを見られるようにする。
        RecentPrefectureStore.shared.record(result)
        return .result(dialog: "Your next destination is \(result.prefectureName)!")
    }
}

// MARK: - 県を開く

struct OpenPrefectureIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Prefecture"
    static let description = IntentDescription("Opens the travel guide for a prefecture.")
    static let openAppWhenRun = true

    @Parameter(title: "Prefecture")
    var prefecture: PrefectureEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        if let target = prefecture.prefecture {
            AppRouter.shared.openPrefecture(target)
        }
        return .result()
    }
}

// MARK: - 近くのスポット

/// 近くのスポットの種類（近くタブの絞り込みと同じ）。
enum NearbyCategory: String, AppEnum {
    case tourism, onsen, nature

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Spot Type"
    static let caseDisplayRepresentations: [NearbyCategory: DisplayRepresentation] = [
        .tourism: "Sightseeing",
        .onsen: "Hot Springs",
        .nature: "Nature",
    ]

    var kind: NearbySpotKind {
        switch self {
        case .tourism: return .tourism
        case .onsen: return .onsen
        case .nature: return .nature
        }
    }
}

struct OpenNearbyIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Nearby Spots"
    static let description = IntentDescription("Shows sightseeing spots, hot springs and nature near you.")
    static let openAppWhenRun = true

    /// 省略したらすべての種類を出す。
    @Parameter(title: "Spot Type")
    var category: NearbyCategory?

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.openNearby(kind: category?.kind)
        return .result()
    }
}

// MARK: - プラン

/// 次の旅（進行中を優先、無ければ計画中）を開く。無ければプラン一覧を開く。
struct OpenNextTripIntent: AppIntent {
    static let title: LocalizedStringResource = "Show Next Trip"
    static let description = IntentDescription("Opens your ongoing or upcoming travel plan.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        if let plan = TravelPlanStore.shared.featuredPlan {
            AppRouter.shared.openPlan(plan.id)
            return .result(dialog: "Opening \(plan.title).")
        }
        AppRouter.shared.openMyPlans()
        return .result(dialog: "You have no upcoming trips yet.")
    }
}

/// 旅行を計画する（プラン一覧を開く）。
struct PlanTripIntent: AppIntent {
    static let title: LocalizedStringResource = "Plan a Trip"
    static let description = IntentDescription("Opens your travel plans.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.openMyPlans()
        return .result()
    }
}

// MARK: - Siri のフレーズ

/// インストール直後から Siri・ショートカット・Spotlight で使えるようにする登録。
struct TripShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SpinRouletteIntent(),
            phrases: [
                "Spin the roulette in \(.applicationName)",
                "Pick a destination in \(.applicationName)",
            ],
            shortTitle: "Spin the Roulette",
            systemImageName: "dial.medium"
        )
        AppShortcut(
            intent: OpenPrefectureIntent(),
            phrases: [
                "Open \(\.$prefecture) in \(.applicationName)",
                "Show \(\.$prefecture) in \(.applicationName)",
            ],
            shortTitle: "Open Prefecture",
            systemImageName: "map"
        )
        AppShortcut(
            intent: OpenNearbyIntent(),
            phrases: [
                "Find nearby \(\.$category) in \(.applicationName)",
                "Find nearby spots in \(.applicationName)",
            ],
            shortTitle: "Find Nearby Spots",
            systemImageName: "location"
        )
        AppShortcut(
            intent: OpenNextTripIntent(),
            phrases: [
                "Show my next trip in \(.applicationName)",
            ],
            shortTitle: "Show Next Trip",
            systemImageName: "airplane"
        )
        AppShortcut(
            intent: PlanTripIntent(),
            phrases: [
                "Plan a trip in \(.applicationName)",
            ],
            shortTitle: "Plan a Trip",
            systemImageName: "suitcase.rolling"
        )
    }
}
