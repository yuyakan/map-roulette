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
        migrateCompletedPlansToVisitedIfNeeded()
    }

    /// 訪問済みを保存ストア（VisitedPrefectureStore）へ移行する以前は、
    /// 訪問済み＝「旅行済みプランの県」を都度計算していた。移行後もその分が
    /// 失われないよう、初回だけ既存の完了プランの県を訪問済みへ流し込む。
    /// 一度きり（フラグで制御）。以降はユーザーが地図で外した県を復活させない（後勝ち維持）。
    private func migrateCompletedPlansToVisitedIfNeeded() {
        let flagKey = "visited.migratedFromCompletedPlans"
        guard !UserDefaults.standard.bool(forKey: flagKey) else { return }
        let prefsFromCompleted = plans.filter { $0.isCompleted }.flatMap { $0.prefectures }
        if !prefsFromCompleted.isEmpty {
            VisitedPrefectureStore.shared.markVisited(prefsFromCompleted)
        }
        UserDefaults.standard.set(true, forKey: flagKey)
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

    /// 費用専用項目（.expense）を追加する。タイトル・金額に加えて支払者・分担者も同時に設定する。
    /// 旅程・地図には出ない。タイトルが空なら何もしない。
    /// - splitMemberIDs: nil は「全員で均等」（既定・人数変動に追従）、配列は一部で割る。
    func addExpenseItem(title: String, cost: Int?, payerID: UUID? = nil, splitMemberIDs: [UUID]? = nil, to planID: UUID) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        var item = PlanItem(expenseTitle: trimmed, cost: cost)
        item.payerID = payerID
        item.splitMemberIDs = splitMemberIDs
        plans[index].items.append(item)
        plans[index].updatedAt = Date()
        persist()
    }

    func moveItem(in planID: UUID, from source: IndexSet, to destination: Int) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        plans[index].items.move(fromOffsets: source, toOffset: destination)
        plans[index].updatedAt = Date()
        persist()
    }

    // MARK: - 旅行メンバー

    /// メンバーを追加する（前後の空白を除去。空文字・同名の重複は追加しない）。
    func addMember(_ name: String, to planID: UUID) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        guard !plans[index].members.contains(where: { $0.name == trimmed }) else { return }
        plans[index].members.append(PlanMember(name: trimmed))
        plans[index].updatedAt = Date()
        persist()
    }

    /// 指定位置のメンバーを削除する。
    /// 削除メンバーを支払者に指定していた項目は支払者を未指定へ戻す。
    /// 分担者（splitMemberIDs）に含まれていた場合は effectiveSplitMemberIDs 側で除外されるため保存値はそのまま。
    func removeMembers(at offsets: IndexSet, in planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        let removedIDs = Set(offsets.map { plans[index].members[$0].id })
        plans[index].members.remove(atOffsets: offsets)
        for i in plans[index].items.indices {
            if let payer = plans[index].items[i].payerID, removedIDs.contains(payer) {
                plans[index].items[i].payerID = nil
            }
        }
        plans[index].updatedAt = Date()
        persist()
    }

    // MARK: - 表示モード・日程

    /// プランの進行状態（これから / 進行中 / 旅行済み）を設定する。
    /// 旅行済み（.completed）にした瞬間、そのプランの都道府県を訪問済みへ上書き（後勝ち）する。
    /// 旅行済みから外しても訪問済みからは自動で外さない（外したい県は地図タップで各自オフにする）。
    func setStatus(_ status: PlanStatus, for planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        guard plans[index].status != status else { return }
        plans[index].status = status
        plans[index].updatedAt = Date()
        persist()
        if status == .completed {
            VisitedPrefectureStore.shared.markVisited(plans[index].prefectures)
        }
    }

    /// 旧 API 互換。旅行済みトグル（true=.completed / false=.upcoming）。
    func setCompleted(_ completed: Bool, for planID: UUID) {
        setStatus(completed ? .completed : .upcoming, for: planID)
    }

    // MARK: - 行き先候補の県

    /// プランに「行き先候補」の県を追加する（重複は無視）。
    func addPrefecture(_ prefecture: Prefecture, to planID: UUID) {
        addPrefectures([prefecture], to: planID)
    }

    /// プランに複数の県をまとめて追加する（既にある県は無視・選択順を保つ）。
    func addPrefectures<S: Sequence>(_ prefectures: S, to planID: UUID) where S.Element == Prefecture {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        var existing = Set(plans[index].plannedPrefectures)
        var added = false
        for prefecture in prefectures where existing.insert(prefecture).inserted {
            plans[index].plannedPrefectures.append(prefecture)
            added = true
        }
        guard added else { return }
        plans[index].updatedAt = Date()
        persist()
    }

    /// プランから「行き先候補」の県を外す（項目由来の県には影響しない）。
    func removePrefecture(_ prefecture: Prefecture, from planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        guard plans[index].plannedPrefectures.contains(prefecture) else { return }
        plans[index].plannedPrefectures.removeAll { $0 == prefecture }
        plans[index].updatedAt = Date()
        persist()
    }

    /// 指定状態のプランのうち、最も最近更新された 1 件。
    private func latestPlan(with status: PlanStatus) -> TravelPlan? {
        plans.filter { $0.status == status }.max(by: { $0.updatedAt < $1.updatedAt })
    }

    /// 現在「進行中」のプラン（最も最近更新されたもの 1 件）。
    var ongoingPlan: TravelPlan? { latestPlan(with: .ongoing) }

    /// ホーム最上部の帯カードに出すプラン 1 件。
    /// 進行中を最優先し、無ければ計画中（どちらも最新更新のもの）。両方無ければ nil。
    var featuredPlan: TravelPlan? {
        ongoingPlan ?? latestPlan(with: .upcoming)
    }

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
        // 範囲外になった日の時間ブロックは削除する（先に ID を集めておく）
        let removedBlockIDs = Set(
            plans[index].timeBlocks.filter { $0.dayNumber > newCount }.map { $0.id }
        )
        plans[index].timeBlocks.removeAll { $0.dayNumber > newCount }
        // 範囲外になった項目の日割当は未割当(nil)へ戻し、消えたブロックへの参照も外す
        for i in plans[index].items.indices {
            if let day = plans[index].items[i].dayNumber, day > newCount {
                plans[index].items[i].dayNumber = nil
            }
            if let bID = plans[index].items[i].timeBlockID, removedBlockIDs.contains(bID) {
                plans[index].items[i].timeBlockID = nil
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

    // MARK: - 時間ブロック

    /// 指定した日に新しい時間ブロックを追加し、その ID を返す。
    @discardableResult
    func addTimeBlock(toDay day: Int, startHour: Int? = nil, startMinute: Int? = nil, title: String = "", in planID: UUID) -> UUID? {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return nil }
        let block = TimeBlock(dayNumber: day, startHour: startHour, startMinute: startMinute, title: title)
        plans[index].timeBlocks.append(block)
        plans[index].updatedAt = Date()
        persist()
        return block.id
    }

    /// 既存の時間ブロックを更新する（時刻・見出しの編集）。
    func updateTimeBlock(_ block: TimeBlock, in planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        guard let blockIndex = plans[index].timeBlocks.firstIndex(where: { $0.id == block.id }) else { return }
        plans[index].timeBlocks[blockIndex] = block
        plans[index].updatedAt = Date()
        persist()
    }

    /// 時間ブロックを削除する。所属していた項目は「ブロック未割当」（timeBlockID = nil）へ戻す。
    func removeTimeBlock(_ blockID: UUID, in planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        plans[index].timeBlocks.removeAll { $0.id == blockID }
        for i in plans[index].items.indices where plans[index].items[i].timeBlockID == blockID {
            plans[index].items[i].timeBlockID = nil
        }
        plans[index].updatedAt = Date()
        persist()
    }

    /// 項目を時間ブロックへ割り当てる（nil でブロック未割当へ戻す）。
    /// 割当先ブロックの日に合わせて項目の dayNumber も揃える。
    func assignBlock(_ blockID: UUID?, to itemID: UUID, in planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        guard let itemIndex = plans[index].items.firstIndex(where: { $0.id == itemID }) else { return }
        plans[index].items[itemIndex].timeBlockID = blockID
        if let blockID, let block = plans[index].timeBlocks.first(where: { $0.id == blockID }) {
            plans[index].items[itemIndex].dayNumber = block.dayNumber
        }
        plans[index].updatedAt = Date()
        persist()
    }

    /// 項目を、指定した日（day）の時間ブロック（blockID）へ移動し、
    /// そのブロック内の指定位置（targetID の直前）へ挿入する。
    /// targetID が nil ならそのブロックの末尾へ。日内並び替え・ブロック間移動を 1 操作で行う。
    /// - Note: blockID が nil（時間未割当ブロック）でも、この日に確実に属させるため day を必ず反映する。
    ///   別の日からドラッグしてきた項目でも正しくこの日へ移動できる。
    func moveItem(_ itemID: UUID, toDay day: Int, block blockID: UUID?, before targetID: UUID?, in planID: UUID) {
        guard let index = plans.firstIndex(where: { $0.id == planID }) else { return }
        guard itemID != targetID else { return }
        var items = plans[index].items
        guard let movingIndex = items.firstIndex(where: { $0.id == itemID }) else { return }

        var moving = items.remove(at: movingIndex)
        moving.timeBlockID = blockID
        // ブロックが実在すればその日を、なければ引数の day を採用する（未割当ブロックもこの日に属させる）
        if let blockID, let block = plans[index].timeBlocks.first(where: { $0.id == blockID }) {
            moving.dayNumber = block.dayNumber
        } else {
            moving.dayNumber = day
        }

        let insertAt: Int
        if let targetID, let t = items.firstIndex(where: { $0.id == targetID }) {
            insertAt = t
        } else if let lastInBlock = items.lastIndex(where: { $0.timeBlockID == blockID && $0.dayNumber == moving.dayNumber }) {
            insertAt = lastInBlock + 1
        } else {
            insertAt = items.count
        }
        items.insert(moving, at: insertAt)

        plans[index].items = items
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

    /// 指定した都道府県を含むプラン（訪問済みマップの県詳細で「紐づくプラン」を出すのに使う）。
    func plansContaining(prefecture: Prefecture) -> [TravelPlan] {
        plans.filter { $0.prefectures.contains(prefecture) }
    }

    // 訪問済み都道府県は VisitedPrefectureStore が唯一の情報源として保持する
    // （後勝ちで上書きするため、ここでプランから都度計算する派生値は持たない）。
}
