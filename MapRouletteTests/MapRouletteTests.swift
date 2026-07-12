//
//  MapRouletteTests.swift
//  MapRouletteTests
//
//  Created by 上別縄祐也 on 2025/07/06.
//

import Testing
import Foundation
import CoreLocation
@testable import MapRoulette

struct MapRouletteTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    /// 時間ブロック機能を追加する前のフォーマット（timeBlocks / timeBlockID 無し）の
    /// 保存データがクラッシュせずデコードでき、新フィールドが既定値になることを確認する。
    @Test func decodesLegacyPlanWithoutTimeBlocks() throws {
        let legacyJSON = """
        [
          {
            "id": "11111111-1111-1111-1111-111111111111",
            "title": "石川の旅",
            "memo": "",
            "groupingMode": "day",
            "dayCount": 2,
            "items": [
              {
                "id": "22222222-2222-2222-2222-222222222222",
                "category": "attraction",
                "prefectureRawValue": "ishikawa",
                "name": "金沢城",
                "dayNumber": 1
              },
              {
                "id": "33333333-3333-3333-3333-333333333333",
                "category": "hotel",
                "prefectureRawValue": "",
                "name": "ホテル日航",
                "customDetail": "2泊"
              }
            ],
            "createdAt": 731000000,
            "updatedAt": 731000000
          }
        ]
        """
        let data = Data(legacyJSON.utf8)
        let plans = try JSONDecoder().decode([TravelPlan].self, from: data)

        #expect(plans.count == 1)
        let plan = try #require(plans.first)
        // 新フィールドは既定値（空・nil）になる
        #expect(plan.timeBlocks.isEmpty)
        #expect(plan.items.allSatisfy { $0.timeBlockID == nil })
        // 既存フィールドは従来どおり読める
        #expect(plan.groupingMode == .day)
        #expect(plan.dayCount == 2)
        #expect(plan.items.count == 2)
    }

    /// 旧データでも blockSections が破綻せず、全項目が「ブロック未割当」に入ることを確認する。
    @Test func legacyPlanGroupsAllItemsAsUnassignedBlock() throws {
        let item = PlanItem(category: .attraction, prefecture: .ishikawa, name: "金沢城", dayNumber: 1)
        let plan = TravelPlan(title: "t", items: [item], groupingMode: .day, dayCount: 1)

        let sections = plan.blockSections(forDay: 1)
        // ブロックが無い日は nil セクションだけを返し、そこに全項目が入る
        #expect(sections.count == 1)
        #expect(sections.first?.block == nil)
        #expect(sections.first?.items.map { $0.id } == [item.id])
    }

    /// 時間ブロックの並びが開始時刻順（時刻なしは末尾）になることを確認する。
    @Test func timeBlocksSortByStartTime() throws {
        let noon = TimeBlock(dayNumber: 1, startHour: 12, startMinute: 0)
        let morning = TimeBlock(dayNumber: 1, startHour: 9, startMinute: 30)
        let untimed = TimeBlock(dayNumber: 1)
        let plan = TravelPlan(title: "t", groupingMode: .day, dayCount: 1,
                              timeBlocks: [noon, untimed, morning])

        let ordered = plan.timeBlocks(forDay: 1)
        #expect(ordered.map { $0.id } == [morning.id, noon.id, untimed.id])
    }

    /// 別の日から「時間未割当ブロック」へドロップしたとき、項目の dayNumber が
    /// 移動先の日へ更新され、複数枚を続けてその日に入れられることを確認する（報告バグの回帰防止）。
    @MainActor
    @Test func dropIntoUnassignedBlockUpdatesDayForMultipleItems() throws {
        let store = TravelPlanStore()
        // テストは共有ファイルに触れないよう、独自インスタンスの空プランで進める
        let plan = store.createPlan(title: "t")
        store.setGroupingMode(.day, for: plan.id)
        store.setDayCount(2, for: plan.id)

        var a = PlanItem(customCategory: .other, title: "A")
        a.dayNumber = 2
        var b = PlanItem(customCategory: .other, title: "B")
        b.dayNumber = 2
        store.addItem(a, to: plan.id)
        store.addItem(b, to: plan.id)

        // Day2 にある 2 項目を、Day1 の時間未割当ブロック（block=nil）へ順に移動
        store.moveItem(a.id, toDay: 1, block: nil, before: nil, in: plan.id)
        store.moveItem(b.id, toDay: 1, block: nil, before: nil, in: plan.id)

        let updated = try #require(store.plans.first { $0.id == plan.id })
        let day1 = updated.blockSections(forDay: 1)
        // Day1 の未割当ブロックに 2 項目とも入っている
        #expect(day1.count == 1)
        #expect(day1.first?.block == nil)
        #expect(Set(day1.first?.items.map { $0.id } ?? []) == [a.id, b.id])
        // どちらも dayNumber が 1 に更新されている
        #expect(updated.items.filter { $0.dayNumber == 1 }.count == 2)

        // テストで作ったプランは片付ける（テストホストのサンドボックスに残さない）
        store.deletePlan(plan)
    }

    // MARK: - 共有テキスト整形

    /// フラットモード: タイトル・メモ・各項目が 1 リストとして並ぶことを確認する。
    @Test func shareTextFlatIncludesTitleMemoAndItems() throws {
        let castle = PlanItem(category: .attraction, prefecture: .ishikawa, name: "金沢城")
        let hotel = PlanItem(customCategory: .hotel, title: "ホテル日航", detail: "2泊")
        let plan = TravelPlan(title: "石川の旅", memo: "冬に行く", items: [castle, hotel])

        let text = PlanShareFormatter.text(for: plan)

        #expect(text.contains("石川の旅"))
        #expect(text.contains("冬に行く"))
        // アプリ項目は都道府県が添えられる
        #expect(text.contains("金沢城"))
        #expect(text.contains("石川県"))
        // カスタム項目とそのメモ
        #expect(text.contains("ホテル日航"))
        #expect(text.contains("2泊"))
    }

    /// 日程モード: Day 見出しと時間ブロックの時刻ラベルで区切られることを確認する。
    @Test func shareTextDayModeSeparatesByDayAndTimeBlock() throws {
        var castle = PlanItem(category: .attraction, prefecture: .ishikawa, name: "金沢城")
        castle.dayNumber = 1
        let morning = TimeBlock(dayNumber: 1, startHour: 9, startMinute: 30, title: "午前")
        castle.timeBlockID = morning.id

        let plan = TravelPlan(
            title: "石川の旅",
            items: [castle],
            groupingMode: .day,
            dayCount: 2,
            timeBlocks: [morning]
        )

        let text = PlanShareFormatter.text(for: plan)

        // Day1 の見出しと時刻ラベルが出て、項目がその下に並ぶ
        #expect(text.contains("1日目"))
        #expect(text.contains("09:30"))
        #expect(text.contains("午前"))
        #expect(text.contains("金沢城"))
        // 項目の無い Day2 は見出しごと出さない
        #expect(!text.contains("2日目"))
    }

    /// 日程モード: 同じ日に時間指定ありの項目と時間未指定の項目が混在するとき、
    /// 時間未指定の項目が時間指定ブロックに続けて並ばず、「時間未定」見出しで区切られることを確認する。
    @Test func shareTextDayModeSeparatesUntimedItems() throws {
        // 時間指定ありブロックの項目
        var castle = PlanItem(category: .attraction, prefecture: .ishikawa, name: "金沢城")
        castle.dayNumber = 1
        let morning = TimeBlock(dayNumber: 1, startHour: 9, startMinute: 30)
        castle.timeBlockID = morning.id
        // 同じ日の時間未割当（timeBlockID = nil）項目
        var lunch = PlanItem(customCategory: .other, title: "近江町市場で昼食")
        lunch.dayNumber = 1

        let plan = TravelPlan(
            title: "石川の旅",
            items: [castle, lunch],
            groupingMode: .day,
            dayCount: 1,
            timeBlocks: [morning]
        )

        let text = PlanShareFormatter.text(for: plan)
        let untimedLabel = NSLocalizedString("plan.timeblock.untimed", comment: "")

        // 「時間未定」見出しが出て、両方の項目が含まれる
        #expect(text.contains(untimedLabel))
        #expect(text.contains("金沢城"))
        #expect(text.contains("近江町市場で昼食"))

        // 時間未指定の項目は「時間未定」見出しより後ろに置かれる（時間指定項目に続けて並ばない）
        let lines = text.components(separatedBy: "\n")
        let untimedHeaderIndex = try #require(lines.firstIndex { $0.contains(untimedLabel) })
        let lunchIndex = try #require(lines.firstIndex { $0.contains("近江町市場で昼食") })
        #expect(untimedHeaderIndex < lunchIndex)
    }

    /// フッター（アプリ署名）を出力しないことを確認する。
    @Test func shareTextHasNoFooter() throws {
        let hotel = PlanItem(customCategory: .hotel, title: "ホテル日航")
        let plan = TravelPlan(title: "石川の旅", items: [hotel])

        let text = PlanShareFormatter.text(for: plan)

        // 余計な署名は付かない（末尾は項目行）
        #expect(!text.contains("旅のしおり"))
        #expect(text.hasSuffix("ホテル日航"))
    }

    /// 位置情報を持つ項目には Apple Maps のリンク行が添えられ、
    /// 位置情報を持たない項目には付かないことを確認する。
    @Test func shareTextAddsMapLinkWhenLocationAvailable() throws {
        // 手動座標を持つカスタム項目（実データに依存せず確実に座標を持たせる）
        let located = PlanItem(
            customCategory: .hotel,
            title: "金沢のホテル",
            coordinate: CLLocationCoordinate2D(latitude: 36.5613, longitude: 136.6562)
        )
        // 座標を持たないカスタム項目
        let unlocated = PlanItem(customCategory: .other, title: "近江町市場で昼食")
        let plan = TravelPlan(title: "石川の旅", items: [located, unlocated])

        let text = PlanShareFormatter.text(for: plan)

        // 座標を持つ項目には maps.apple.com のリンクが付く
        #expect(text.contains("https://maps.apple.com/"))
        #expect(text.contains("ll=36.5613,136.6562"))
        // リンクは対象項目の直後に置かれる
        let lines = text.components(separatedBy: "\n")
        let hotelIndex = try #require(lines.firstIndex { $0.contains("金沢のホテル") })
        #expect(lines[hotelIndex + 1].contains("maps.apple.com"))

        // 座標を持たない項目のあとにはリンクが付かない
        let lunchIndex = try #require(lines.firstIndex { $0.contains("近江町市場で昼食") })
        let afterLunch = lunchIndex + 1 < lines.count ? lines[lunchIndex + 1] : ""
        #expect(!afterLunch.contains("maps.apple.com"))
    }
}
