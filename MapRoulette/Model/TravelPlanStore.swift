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
            let decoded = try JSONDecoder().decode([TravelPlan].self, from: data)
            // 更新日時の新しい順で保持
            plans = decoded.sorted { $0.updatedAt > $1.updatedAt }
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
        // 更新したものを先頭へ
        plans.sort { $0.updatedAt > $1.updatedAt }
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
        plans.sort { $0.updatedAt > $1.updatedAt }
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

    /// 指定した項目が、いずれかのプランに含まれているか（追加ボタンの状態表示用）
    func plansContaining(name: String, category: PlanItemCategory) -> [TravelPlan] {
        plans.filter { plan in
            plan.items.contains { $0.name == name && $0.category == category }
        }
    }
}
