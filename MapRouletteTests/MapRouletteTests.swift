//
//  MapRouletteTests.swift
//  MapRouletteTests
//
//  Created by 上別縄祐也 on 2025/07/06.
//

import Testing
import Foundation
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
}
