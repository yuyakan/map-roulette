//
//  PlanDetailView.swift
//  MapRoulette
//
//  旅行プランの詳細画面。ブランド統一のカードベース UI。
//  「日程ごとに分ける」トグルで表示を切り替え、
//  日程モードではカードをドラッグ&ドロップして各 Day に割り当てる。
//

import SwiftUI
import MapKit
import UniformTypeIdentifiers

struct PlanDetailView: View {
    let planID: UUID
    @ObservedObject private var store = TravelPlanStore.shared
    @State private var showingMapSheet = false
    @State private var showingMemoEditor = false
    @State private var showingCustomEditor = false
    @State private var titleDraft = ""
    @State private var memoDraft = ""

    private var plan: TravelPlan? {
        store.plans.first { $0.id == planID }
    }

    var body: some View {
        ZStack {
            PlanTheme.backgroundGradient.ignoresSafeArea()
            if let plan {
                content(for: plan)
            } else {
                Text(NSLocalizedString("plan.notfound", comment: ""))
                    .foregroundColor(.secondary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let plan {
                ToolbarItem(placement: .principal) {
                    Text(plan.title).font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        startEditing(plan)
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(PlanTheme.primary)
                    }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if let plan, !plan.mappableItems.isEmpty {
                Button {
                    showingMapSheet = true
                } label: {
                    Image(systemName: "map.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(PlanTheme.brandGradient))
                        .shadow(color: PlanTheme.primary.opacity(0.4), radius: 10, x: 0, y: 4)
                }
                .accessibilityLabel(NSLocalizedString("plan.showmap", comment: ""))
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingMapSheet) {
            if let plan { PlanMapView(plan: plan) }
        }
        .sheet(isPresented: $showingMemoEditor) {
            if let plan { memoEditor(for: plan) }
        }
        .sheet(isPresented: $showingCustomEditor) {
            CustomPlanItemEditor(planID: planID)
        }
        .tint(PlanTheme.primary)
    }

    // MARK: - 本体

    @ViewBuilder
    private func content(for plan: TravelPlan) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                controlCard(for: plan)

                if !plan.memo.isEmpty {
                    memoCard(plan.memo)
                }

                if plan.groupingMode == .day {
                    // 日程モードでは項目が空でも各 Day のセクションを表示し、
                    // その日に直接ホテル・移動などを追加できるようにする。
                    dayGroups(for: plan)
                } else if plan.items.isEmpty {
                    emptyHint
                } else {
                    flatList(for: plan)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - コントロールカード（日程トグル・日数）

    private func controlCard(for plan: TravelPlan) -> some View {
        VStack(spacing: 14) {
            Toggle(isOn: dayModeBinding(for: plan)) {
                Label(NSLocalizedString("plan.grouping.day.toggle", comment: ""), systemImage: "calendar")
                    .font(.subheadline.bold())
            }
            .tint(PlanTheme.primary)

            if plan.groupingMode == .day {
                Divider()
                HStack {
                    Text(String(format: NSLocalizedString("plan.daycount.format", comment: ""), plan.dayCount))
                        .font(.subheadline)
                    Spacer()
                    Stepper("", value: dayCountBinding(for: plan), in: 1...30)
                        .labelsHidden()
                }
            }
        }
        .planCard()
    }

    private func memoCard(_ memo: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(NSLocalizedString("plan.memo.label", comment: ""), systemImage: "note.text")
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            Text(memo).font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var emptyHint: some View {
        VStack(spacing: 14) {
            Text(NSLocalizedString("plan.detail.empty", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // 項目が 1 つも無くてもホテル・移動などのカスタム項目は追加できる
            addCustomButton
        }
        .planCard()
    }

    /// ホテル・移動などのカスタム項目を追加するボタン（フラット表示・空状態で共用）。
    private var addCustomButton: some View {
        Button {
            showingCustomEditor = true
        } label: {
            Label(NSLocalizedString("plan.day.addcustom", comment: ""), systemImage: "plus")
                .font(.subheadline.bold())
                .foregroundColor(PlanTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(PlanTheme.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - フラット表示（日程分けなし）

    private func flatList(for plan: TravelPlan) -> some View {
        VStack(spacing: 12) {
            ForEach(plan.items) { item in
                PlanItemCard(item: item, store: store, planID: planID, draggable: false)
            }

            // ホテル・移動などのカスタム項目を追加
            addCustomButton
        }
    }

    // MARK: - 日程グループ（ドラッグ&ドロップ）

    private func dayGroups(for plan: TravelPlan) -> some View {
        VStack(spacing: 16) {
            ForEach(plan.itemsByDay, id: \.day) { group in
                DayDropSection(
                    day: group.day,
                    items: group.items,
                    store: store,
                    planID: planID
                )
            }
        }
    }

    // MARK: - Bindings

    private func dayModeBinding(for plan: TravelPlan) -> Binding<Bool> {
        Binding(
            get: { plan.groupingMode == .day },
            set: { store.setGroupingMode($0 ? .day : .flat, for: planID) }
        )
    }

    private func dayCountBinding(for plan: TravelPlan) -> Binding<Int> {
        Binding(
            get: { plan.dayCount },
            set: { store.setDayCount($0, for: planID) }
        )
    }

    // MARK: - タイトル・メモ編集

    private func startEditing(_ plan: TravelPlan) {
        titleDraft = plan.title
        memoDraft = plan.memo
        showingMemoEditor = true
    }

    private func memoEditor(for plan: TravelPlan) -> some View {
        NavigationStack {
            ZStack {
                PlanTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 16) {
                    // タイトル
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("plan.title.label", comment: ""))
                            .font(.caption.bold())
                            .foregroundColor(PlanTheme.primary)
                        TextField(NSLocalizedString("plan.title.placeholder", comment: ""), text: $titleDraft)
                            .textFieldStyle(.plain)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .planCard()

                    // メモ
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("plan.memo.label", comment: ""))
                            .font(.caption.bold())
                            .foregroundColor(PlanTheme.primary)
                        TextEditor(text: $memoDraft)
                            .frame(minHeight: 160)
                            .scrollContentBackground(.hidden)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .planCard()

                    Spacer()
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("plan.edit", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        showingMemoEditor = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.save", comment: "")) {
                        var updated = plan
                        let trimmed = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty { updated.title = trimmed }
                        updated.memo = memoDraft
                        store.updatePlan(updated)
                        showingMemoEditor = false
                    }
                }
            }
        }
    }
}

// MARK: - DayDropSection
/// 1 日分のドロップゾーン。カードをドロップするとその日に割り当てる。

private struct DayDropSection: View {
    let day: Int?           // nil は「未割当」
    let items: [PlanItem]
    let store: TravelPlanStore
    let planID: UUID
    @State private var isTargeted = false
    @State private var showingCustomEditor = false

    private var title: String {
        if let day {
            return String(format: NSLocalizedString("plan.day.format", comment: ""), day)
        } else {
            return NSLocalizedString("plan.day.unassigned", comment: "")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(day == nil ? .secondary : PlanTheme.primary)
                Spacer()
                // この日にカスタム項目（ホテル・移動など）を追加。「未割当」には出さない。
                if day != nil {
                    Button {
                        showingCustomEditor = true
                    } label: {
                        Label(NSLocalizedString("plan.day.addcustom", comment: ""), systemImage: "plus")
                            .font(.caption.bold())
                            .foregroundColor(PlanTheme.primary)
                    }
                    .buttonStyle(.plain)
                }
            }

            if items.isEmpty {
                Text(NSLocalizedString("plan.day.empty", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else {
                // カード間に挿入用のドロップ受け口を挟む。
                // 各カードへドロップ＝そのカードの直前へ挿入（同じ日なら並び替え、別の日なら移動）。
                ForEach(items) { item in
                    PlanItemCard(
                        item: item,
                        store: store,
                        planID: planID,
                        draggable: true,
                        onDrop: { droppedID in
                            store.moveItem(droppedID, toDay: day, before: item.id, in: planID)
                        }
                    )
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                        .strokeBorder(
                            isTargeted ? PlanTheme.primary : Color.clear,
                            style: StrokeStyle(lineWidth: 2, dash: [6])
                        )
                )
        )
        .shadow(color: PlanTheme.cardShadow, radius: 8, x: 0, y: 3)
        // セクション全体へのドロップは「その日の末尾へ移動」。カードへの個別ドロップが
        // 優先されるため、ここに来るのはカードの隙間や空き領域に落とした場合のみ。
        .dropDestination(for: String.self) { droppedIDs, _ in
            guard let idString = droppedIDs.first, let uuid = UUID(uuidString: idString) else { return false }
            store.moveItem(uuid, toDay: day, before: nil, in: planID)
            return true
        } isTargeted: { targeted in
            withAnimation(.easeOut(duration: 0.15)) { isTargeted = targeted }
        }
        .sheet(isPresented: $showingCustomEditor) {
            CustomPlanItemEditor(planID: planID, initialDay: day)
        }
    }
}

// MARK: - PlanItemCard

private struct PlanItemCard: View {
    let item: PlanItem
    let store: TravelPlanStore
    let planID: UUID
    let draggable: Bool
    /// このカードへドロップされたときの処理（ドロップ元の項目 ID を渡す）。日程モードのみ。
    var onDrop: ((UUID) -> Void)? = nil
    @State private var showingDetail = false
    @State private var isDropTargeted = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(PlanTheme.color(for: item.category)))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .lineLimit(1)
                if let memo = item.customDetail?.trimmingCharacters(in: .whitespacesAndNewlines), !memo.isEmpty {
                    // メモがあれば 1 行で表示（カスタム・アプリ項目とも共通）
                    Label(memo, systemImage: "note.text")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else if !item.category.isCustom {
                    HStack(spacing: 6) {
                        Text(item.category.localizedName)
                        if let pref = item.prefecture {
                            Text("·")
                            Text(pref.prefectureName)
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            if draggable {
                // 日程モードでは削除を明示ボタンに（長押しは contextMenu と競合してドラッグを妨げるため付けない）
                Button {
                    store.removeItem(item, from: planID)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)

                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(PlanTheme.primary.opacity(0.7))
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(draggable ? Color(.tertiarySystemGroupedBackground) : Color(.secondarySystemGroupedBackground))
        )
        // ドロップ先がこのカードのとき、直前に挿入されることを示す青い線を上端に表示。
        .overlay(alignment: .top) {
            if isDropTargeted {
                Capsule()
                    .fill(PlanTheme.primary)
                    .frame(height: 3)
                    .padding(.horizontal, 4)
                    .offset(y: -6)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .modifier(PlanItemInteraction(draggable: draggable, payload: item.id.uuidString) {
            store.removeItem(item, from: planID)
        })
        // 日程モードでは各カードがドロップ先になり、ここへ落とすと「この項目の直前」へ挿入される。
        .modifier(PlanItemDropTarget(enabled: draggable && onDrop != nil, isTargeted: $isDropTargeted) { droppedID in
            onDrop?(droppedID)
        })
        .sheet(isPresented: $showingDetail) {
            PlanItemDetailRouter(item: item)
        }
    }
}

/// 日程モードでカードを個別のドロップ先にする修飾子。
/// onDrop が無いフラット表示などでは何もしない。
private struct PlanItemDropTarget: ViewModifier {
    let enabled: Bool
    @Binding var isTargeted: Bool
    let onDrop: (UUID) -> Void

    func body(content: Content) -> some View {
        if enabled {
            content.dropDestination(for: String.self) { droppedIDs, _ in
                guard let idString = droppedIDs.first, let uuid = UUID(uuidString: idString) else { return false }
                onDrop(uuid)
                return true
            } isTargeted: { targeted in
                withAnimation(.easeOut(duration: 0.12)) { isTargeted = targeted }
            }
        } else {
            content
        }
    }
}

/// 長押しジェスチャの競合を避けるための修飾子。
/// - draggable=true（日程モード）: .draggable のみ。削除はカード上の明示ボタンで行う。
/// - draggable=false（フラット表示）: .contextMenu（長押しで削除）のみ。
private struct PlanItemInteraction: ViewModifier {
    let draggable: Bool
    let payload: String
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        if draggable {
            content.draggable(payload)
        } else {
            content.contextMenu {
                Button(role: .destructive, action: onDelete) {
                    Label(NSLocalizedString("common.delete", comment: ""), systemImage: "trash")
                }
            }
        }
    }
}

// PlanMapView は PlanMapView.swift に移動（日程色分け・ルート線・日フィルタ対応）
