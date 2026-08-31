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

/// プラン詳細内の上タブ（旅程 / 費用）
private enum PlanDetailSection: Int, CaseIterable {
    case itinerary   // 旅程（既存の内容）
    case cost        // 費用（メンバー・金額一覧・合計）

    var title: String {
        switch self {
        case .itinerary: return NSLocalizedString("plan.section.itinerary", comment: "")
        case .cost:      return NSLocalizedString("plan.section.cost", comment: "")
        }
    }
}

struct PlanDetailView: View {
    let planID: UUID
    @ObservedObject private var store = TravelPlanStore.shared
    @State private var showingMapSheet = false
    @State private var showingMemoEditor = false
    @State private var showingCustomEditor = false
    @State private var titleDraft = ""
    @State private var memoDraft = ""
    @State private var section: PlanDetailSection = .itinerary

    private var plan: TravelPlan? {
        store.plans.first { $0.id == planID }
    }

    var body: some View {
        ZStack {
            // プラン詳細は白基調（旅程・費用タブ共通の最背面）。カードは影・グレーで区別する。
            PlanTheme.pageBackground.ignoresSafeArea()
            if let plan {
                // 切替帯は詳細画面の内側最上部に置く。帯の下でタブ内容を差し替える。
                VStack(spacing: 0) {
                    PlanDetailSectionBand(section: $section)
                    switch section {
                    case .itinerary:
                        content(for: plan)
                    case .cost:
                        PlanCostView(planID: planID)
                    }
                }
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
                    ShareLink(item: PlanShareFormatter.text(for: plan)) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(PlanTheme.primary)
                    }
                    .accessibilityLabel(NSLocalizedString("plan.share", comment: ""))
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
            // 地図 FAB は旅程タブのときだけ出す（費用タブでは隠す）。
            if section == .itinerary, let plan, !plan.mappableItems.isEmpty {
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
                } else if plan.itineraryItems.isEmpty {
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

            Divider()

            // 旅行済みトグル。ONにすると訪問済みマップの集計対象になる。
            Toggle(isOn: completedBinding(for: plan)) {
                Label(NSLocalizedString("plan.completed.toggle", comment: ""), systemImage: "checkmark.seal.fill")
                    .font(.subheadline.bold())
            }
            .tint(PlanTheme.primary)
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
            ForEach(plan.itineraryItems) { item in
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
                    plan: plan,
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

    private func completedBinding(for plan: TravelPlan) -> Binding<Bool> {
        Binding(
            get: { plan.isCompleted },
            set: { store.setCompleted($0, for: planID) }
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
                PlanTheme.pageBackground.ignoresSafeArea()
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

// MARK: - PlanDetailSectionBand
/// プラン詳細内の上タブ切替帯（旅程 / 費用）。
/// マイプランタブの PlanSectionBand と同じデザイン言語（文字＋ブランド下線）で統一する。
private struct PlanDetailSectionBand: View {
    @Binding var section: PlanDetailSection

    // 下線の左右インセット（セル幅からこの分だけ内側に縮める）
    private let underlineInset: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let count = CGFloat(PlanDetailSection.allCases.count)
            let cellWidth = geo.size.width / count
            let selectedIndex = CGFloat(section.rawValue)

            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    ForEach(PlanDetailSection.allCases, id: \.self) { item in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                section = item
                            }
                        } label: {
                            Text(item.title)
                                .font(.system(size: 15, weight: section == item ? .semibold : .regular))
                                .foregroundColor(section == item ? PlanTheme.primary : .gray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // 下線（常に1本。offset で選択セルの位置へ移動）
                Rectangle()
                    .fill(PlanTheme.brandGradient)
                    .frame(width: cellWidth - underlineInset * 2, height: 2)
                    .offset(x: selectedIndex * cellWidth + underlineInset)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(height: 44)
        // 背景は敷かず透明にして、画面全体の背景グラデーションを透けさせる。
    }
}

// MARK: - DayDropSection
/// 1 日分のドロップゾーン。カードをドロップするとその日に割り当てる。

private struct DayDropSection: View {
    let day: Int?           // nil は「未割当」
    let items: [PlanItem]
    let plan: TravelPlan    // 時間ブロックの参照に必要
    let store: TravelPlanStore
    let planID: UUID
    @State private var isTargeted = false
    @State private var showingCustomEditor = false
    @State private var editingBlock: TimeBlock?   // 時刻編集シートの対象

    private var title: String {
        if let day {
            return String(format: NSLocalizedString("plan.day.format", comment: ""), day)
        } else {
            return NSLocalizedString("plan.day.unassigned", comment: "")
        }
    }

    /// 実日（day != nil）では時間ブロックごとに分けて表示する。
    private var blockSections: [(block: TimeBlock?, items: [PlanItem])] {
        guard let day else { return [(nil, items)] }
        return plan.blockSections(forDay: day)
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

            if items.isEmpty && day == nil {
                Text(NSLocalizedString("plan.day.empty", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else if day == nil {
                // 未割当セクションはタイムライン無しのフラット表示
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
            } else {
                // 実日: 時間ブロックごとのタイムライン表示
                ForEach(blockSections, id: \.block?.id) { section in
                    TimelineBlockRow(
                        day: day!,
                        block: section.block,
                        items: section.items,
                        store: store,
                        planID: planID,
                        onEditBlock: { editingBlock = $0 }
                    )
                }

                // この日に時間ブロックを追加
                Button {
                    let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
                    store.addTimeBlock(toDay: day!, startHour: now.hour, startMinute: now.minute, in: planID)
                } label: {
                    Label(NSLocalizedString("plan.timeblock.add", comment: ""), systemImage: "clock.badge.plus")
                        .font(.caption.bold())
                        .foregroundColor(PlanTheme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(PlanTheme.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
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
        .sheet(item: $editingBlock) { block in
            TimeBlockEditor(block: block, store: store, planID: planID)
        }
    }
}

// MARK: - TimelineBlockRow
/// 1 つの時間ブロック行。左に時刻列＋接続線、右に項目カード群を並べる。
/// block == nil は「時間未割当」の受け皿（見出しは控えめ）。

private struct TimelineBlockRow: View {
    let day: Int
    let block: TimeBlock?
    let items: [PlanItem]
    let store: TravelPlanStore
    let planID: UUID
    let onEditBlock: (TimeBlock) -> Void
    @State private var isTargeted = false
    @State private var showingDeleteConfirm = false

    private var blockID: UUID? { block?.id }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            timeColumn
            content
        }
        .padding(.vertical, 4)
        // ブロック全体へのドロップ＝そのブロックの末尾へ移動。
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isTargeted ? PlanTheme.primary.opacity(0.06) : .clear)
        )
        // 透明な余白部分もドロップ判定に含める（空ブロックの判定領域を広げる）。
        .contentShape(Rectangle())
        .dropDestination(for: String.self) { droppedIDs, _ in
            guard let idString = droppedIDs.first, let uuid = UUID(uuidString: idString) else { return false }
            store.moveItem(uuid, toDay: day, block: blockID, before: nil, in: planID)
            return true
        } isTargeted: { targeted in
            withAnimation(.easeOut(duration: 0.12)) { isTargeted = targeted }
        }
        // ブロック削除の確認。所属項目は「時間未割当」へ戻る（削除されない）。
        .alert(NSLocalizedString("plan.timeblock.delete.confirm", comment: ""), isPresented: $showingDeleteConfirm) {
            Button(NSLocalizedString("common.cancel", comment: ""), role: .cancel) { }
            Button(NSLocalizedString("common.delete", comment: ""), role: .destructive) {
                if let blockID { store.removeTimeBlock(blockID, in: planID) }
            }
        } message: {
            Text(NSLocalizedString("plan.timeblock.delete.message", comment: ""))
        }
    }

    // MARK: - 左の時刻列（ドット＋接続線）

    private var timeColumn: some View {
        VStack(spacing: 0) {
            // 時刻を設定していないブロックはラベルを出さず、ドットと接続線だけにする。
            Group {
                if let label = block?.timeLabel {
                    Text(label)
                        .font(.caption.bold().monospacedDigit())
                        .foregroundColor(PlanTheme.primary)
                } else {
                    Color.clear.frame(height: 1)
                }
            }
            .frame(width: 46)

            Circle()
                .fill(block == nil ? Color.secondary.opacity(0.5) : PlanTheme.primary)
                .frame(width: 9, height: 9)
                .padding(.top, 4)

            // 下方向へ伸びる接続線（このブロックの高さいっぱい）
            Rectangle()
                .fill((block == nil ? Color.secondary.opacity(0.3) : PlanTheme.primary.opacity(0.35)))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
                .padding(.top, 2)
        }
        .frame(width: 52)
    }

    // MARK: - 右の内容（見出し＋項目カード）

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ブロック見出し（時刻編集ボタン付き）。時間未割当ブロック（block == nil）には
            // 見出しラベルを一切出さず、項目だけを並べる（時間指定なしでも自然に使えるように）。
            if let block {
                HStack(spacing: 10) {
                    if !block.title.isEmpty {
                        Text(block.title)
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                    }
                    Button {
                        onEditBlock(block)
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundColor(PlanTheme.primary)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    // 時間ブロックの削除。誤タップ防止に確認アラートを挟む。
                    Button {
                        showingDeleteConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(NSLocalizedString("plan.timeblock.delete", comment: ""))
                }
            }

            if items.isEmpty {
                // 空ブロックのドロップ受け皿。判定領域を広く取り、破線の枠で落とせる場所を明示する。
                Label(NSLocalizedString("plan.timeblock.empty", comment: ""), systemImage: "arrow.down.to.line")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(PlanTheme.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                    )
                    .contentShape(Rectangle())
            } else {
                ForEach(items) { item in
                    PlanItemCard(
                        item: item,
                        store: store,
                        planID: planID,
                        draggable: true,
                        onDrop: { droppedID in
                            store.moveItem(droppedID, toDay: day, block: blockID, before: item.id, in: planID)
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - TimeBlockEditor
/// 時間ブロックの開始時刻・見出しの編集シート。削除もここから行う。

private struct TimeBlockEditor: View {
    let store: TravelPlanStore
    let planID: UUID
    @Environment(\.dismiss) private var dismiss

    private let blockID: UUID
    private let dayNumber: Int
    @State private var hasTime: Bool
    @State private var time: Date
    @State private var title: String

    init(block: TimeBlock, store: TravelPlanStore, planID: UUID) {
        self.store = store
        self.planID = planID
        self.blockID = block.id
        self.dayNumber = block.dayNumber
        _hasTime = State(initialValue: block.hasTime)
        _title = State(initialValue: block.title)
        var comps = DateComponents()
        comps.hour = block.startHour ?? 9
        comps.minute = block.startMinute ?? 0
        _time = State(initialValue: Calendar.current.date(from: comps) ?? Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $hasTime) {
                            Label(NSLocalizedString("plan.timeblock.settime", comment: ""), systemImage: "clock")
                                .font(.subheadline.bold())
                        }
                        .tint(PlanTheme.primary)

                        if hasTime {
                            Divider()
                            DatePicker(
                                NSLocalizedString("plan.timeblock.starttime", comment: ""),
                                selection: $time,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .planCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("plan.timeblock.title.label", comment: ""))
                            .font(.caption.bold())
                            .foregroundColor(PlanTheme.primary)
                        TextField(NSLocalizedString("plan.timeblock.title.placeholder", comment: ""), text: $title)
                            .textFieldStyle(.plain)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .planCard()

                    Button(role: .destructive) {
                        store.removeTimeBlock(blockID, in: planID)
                        dismiss()
                    } label: {
                        Label(NSLocalizedString("plan.timeblock.delete", comment: ""), systemImage: "trash")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .foregroundColor(.red)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("plan.timeblock.edit", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.save", comment: "")) { save() }
                }
            }
        }
        .tint(PlanTheme.primary)
    }

    private func save() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let updated = TimeBlock(
            id: blockID,
            dayNumber: dayNumber,
            startHour: hasTime ? comps.hour : nil,
            startMinute: hasTime ? comps.minute : nil,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        store.updateTimeBlock(updated, in: planID)
        dismiss()
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
