//
//  TripIntentsTests.swift
//  MapRouletteTests
//
//  Siri・ショートカットの操作（AppIntents/TripIntents.swift）が、
//  話した県名から正しい県を引けること、正しい画面を開くよう依頼することを確認する。
//

import Testing
@testable import MapRoulette

@MainActor
struct TripIntentsTests {

    /// 「京都府」「京都」「きょうと」「kyoto」のどの言い方でも京都府が引ける。
    @Test(arguments: ["京都府", "京都", "きょうと", "kyoto", "Kyoto"])
    func prefectureQueryMatchesSpokenNames(_ spoken: String) async throws {
        let results = try await PrefectureQuery().entities(matching: spoken)
        #expect(results.map(\.id).contains(Prefecture.kyoto.rawValue))
    }

    /// 「東京」で東京都だけが引ける（「京都」などを誤って含めない）。
    @Test func prefectureQueryIsNotTooLoose() async throws {
        let results = try await PrefectureQuery().entities(matching: "東京")
        #expect(results.map(\.id) == [Prefecture.tokyo.rawValue])
    }

    /// 県を開く: ホームタブに切り替え、その県を開くよう予約する。
    @Test func openPrefectureRoutesToHome() async throws {
        let intent = OpenPrefectureIntent()
        intent.prefecture = PrefectureEntity(.okinawa)
        _ = try await intent.perform()
        #expect(AppRouter.shared.selectedTab == 2)
        #expect(AppRouter.shared.pendingPrefecture == .okinawa)
        AppRouter.shared.pendingPrefecture = nil
    }

    /// 近くのスポット: 近くタブに切り替え、種類（省略時はすべて）で絞り込むよう予約する。
    @Test func openNearbyRoutesWithFilter() async throws {
        let intent = OpenNearbyIntent()
        intent.category = .onsen
        _ = try await intent.perform()
        #expect(AppRouter.shared.selectedTab == 1)
        #expect(AppRouter.shared.pendingNearby == .init(kind: .onsen))

        intent.category = nil
        _ = try await intent.perform()
        #expect(AppRouter.shared.pendingNearby == .init(kind: nil))
        AppRouter.shared.pendingNearby = nil
    }

    /// 旅行を計画: マイプランタブに切り替える（新規作成シートは開かない）。
    @Test func planTripOpensPlans() async throws {
        _ = try await PlanTripIntent().perform()
        #expect(AppRouter.shared.selectedTab == 4)
        #expect(AppRouter.shared.pendingNewPlan == false)
    }

    /// ルーレット: 行き先を決め、ホームの「最近見た」の先頭に入れる。
    @Test func spinRouletteRecordsDestination() async throws {
        _ = try await SpinRouletteIntent().perform()
        #expect(RecentPrefectureStore.shared.recents.first != nil)
    }
}
