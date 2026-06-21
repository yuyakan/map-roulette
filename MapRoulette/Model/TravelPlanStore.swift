//
//  TravelPlanStore.swift
//  MapRoulette
//
//  旅行プランの永続化ストア。
//  Documents ディレクトリ内の JSON ファイルに保存・読み込みする。
//

import Foundation
import SwiftUI
import Combine
import CoreLocation

@MainActor
final class TravelPlanStore: ObservableObject {
    static let shared = TravelPlanStore()

    @Published private(set) var plans: [TravelPlan] = []

    private let fileName = "travel_plans.json"

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    // MARK: - 読み込み / 保存

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            plans = []
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            // 保存された配列の順序＝ユーザーが並べた表示順。ここでは並べ替えない。
            // （旧データは更新日時降順で保存されているので、それがそのまま初期順になる）
            plans = try JSONDecoder().decode([TravelPlan].self, from: data)
        } catch {
            print("TravelPlanStore load error: \(error)")
            plans = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(plans)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("TravelPlanStore persist error: \(error)")
        }
    }

    // MARK: - プラン CRUD

    @discardableResult
    func createPlan(title: String, memo: String = "") -> TravelPlan {
        let plan = TravelPlan(title: title, memo: memo)
        plans.insert(plan, at: 0)
        persist()
        return plan
    }

    func updatePlan(_ plan: TravelPlan) {
        guard let index = plans.firstIndex(where: { $0.id == plan.id }) else { return }
        var updated = plan
        updated.updatedAt = Date()
        plans[index] = updated
        // 表示順はユーザーの手動並びを維持する（更新で先頭へ繰り上げない）
        persist()
    }

    func deletePlan(_ plan: TravelPlan) {
        plans.removeAll { $0.id == plan.id }
        persist()
    }

    func deletePlans(at offsets: IndexSet) {
        plans.remove(atOffsets: offsets)
        persist()
    }

    /// プラン一覧をユーザー操作で並び替える。並べた順序がそのまま保存される。
    func movePlans(from source: IndexSet, to destination: Int) {
        plans.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    // MARK: - 項目操作

    /// 指定プランに項目を追加する。
    /// アプリ項目は同一プラン内の重複（同名・同種別）を防ぐが、
    /// カスタム項目（ホテル等）は同名でも別物として常に追加する。
    func addItem(_ item: PlanItem, to planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        if !item.category.isCustom {
            let alreadyExists = plans[index].items.contains {
                $0.name == item.name && $0.category == item.category
            }
            guard !alreadyExists else { return }
        }
        plans[index].items.append(item)
        plans[index].updatedAt = Date()
        // 表示順はユーザーの手動並びを維持する
        persist()
    }

    /// 既存の項目を内容ごと更新する（カスタム項目の編集に使う）。
    func updateItem(_ item: PlanItem, in planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        guard let itemIndex = plans[index].items.firstIndex(where: { $0.id == item.id }) else { return }
        plans[index].items[itemIndex] = item
        plans[index].updatedAt = Date()
        persist()
    }

    func removeItem(_ item: PlanItem, from planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        plans[index].items.removeAll { $0.id == item.id }
        plans[index].updatedAt = Date()
        persist()
    }

    func moveItem(in planID: UUID, from source: IndexSet, to destination: Int) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        plans[index].items.move(fromOffsets: source, toOffset: destination)
        plans[index].updatedAt = Date()
        persist()
    }

    // MARK: - 表示モード・日程

    /// 表示の区切り方（都道府県/日程）を切り替える。
    func setGroupingMode(_ mode: PlanGroupingMode, for planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        plans[index].groupingMode = mode
        plans[index].updatedAt = Date()
        persist()
    }

    /// 日程モードの日数を設定する（最低 1）。
    func setDayCount(_ count: Int, for planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        let newCount = max(1, count)
        plans[index].dayCount = newCount
        // 範囲外になった項目の日割当は未割当(nil)へ戻す
        for i in plans[index].items.indices {
            if let day = plans[index].items[i].dayNumber, day > newCount {
                plans[index].items[i].dayNumber = nil
            }
        }
        plans[index].updatedAt = Date()
        persist()
    }

    /// 指定項目を何日目に割り当てるか設定する（nil で未割当に戻す）。
    func assignDay(_ day: Int?, to itemID: UUID, in planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        guard let itemIndex = plans[index].items.firstIndex(where: { $0.id == itemID }) else { return }
        plans[index].items[itemIndex].dayNumber = day
        plans[index].updatedAt = Date()
        persist()
    }

    /// 項目を指定の日へ移動し、その日の中の指定位置（targetID の直前）へ挿入する。
    /// targetID が nil の場合はその日の末尾へ。日またぎ移動と日内並び替えを 1 操作で行う。
    /// itemsByDay の順序は items 配列の順序に依存するため、グローバル配列上で再配置する。
    func moveItem(_ itemID: UUID, toDay day: Int?, before targetID: UUID?, in planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        guard itemID != targetID else { return }
        var items = plans[index].items
        guard let movingIndex = items.firstIndex(where: { $0.id == itemID }) else { return }

        var moving = items.remove(at: movingIndex)
        moving.dayNumber = day

        // 挿入位置を決める。targetID 指定があればその直前、無ければその日の最後の項目の直後。
        let insertAt: Int
        if let targetID, let t = items.firstIndex(where: { $0.id == targetID }) {
            insertAt = t
        } else if let lastInDay = items.lastIndex(where: { effectiveDay($0, dayCount: plans[index].dayCount) == day }) {
            insertAt = lastInDay + 1
        } else {
            insertAt = items.count
        }
        items.insert(moving, at: insertAt)

        plans[index].items = items
        plans[index].updatedAt = Date()
        persist()
    }

    /// itemsByDay と同じ判定で、項目が実際に属する日（範囲外は未割当 nil）を返す。
    private func effectiveDay(_ item: PlanItem, dayCount: Int) -> Int? {
        guard let day = item.dayNumber, day >= 1, day <= dayCount else { return nil }
        return day
    }

    /// 指定した項目が、いずれかのプランに含まれているか（追加ボタンの状態表示用）
    func plansContaining(name: String, category: PlanItemCategory) -> [TravelPlan] {
        plans.filter { plan in
            plan.items.contains { $0.name == name && $0.category == category }
        }
    }
}
