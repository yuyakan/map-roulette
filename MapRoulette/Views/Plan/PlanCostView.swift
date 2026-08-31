//
//  PlanCostView.swift
//  MapRoulette
//
//  プラン詳細の「費用」タブ。旅行メンバーの管理と、各項目の金額入力・合計表示を担う。
//  金額は PlanItem.cost（円・整数）に保存し、行内の数字入力でその場更新する。
//  メンバーがいれば合計を人数で割った 1 人あたりも表示する（割り勘）。
//

import SwiftUI

/// 費用タブ内のサブタブ（一覧 / 精算）
private enum CostSubtab: Int, CaseIterable {
    case list        // 費用一覧・合計
    case settlement  // 割り勘の精算（誰が誰にいくら）

    var title: String {
        switch self {
        case .list:       return NSLocalizedString("plan.cost.subtab.list", comment: "")
        case .settlement: return NSLocalizedString("plan.cost.subtab.settlement", comment: "")
        }
    }
}

struct PlanCostView: View {
    let planID: UUID
    @ObservedObject private var store = TravelPlanStore.shared

    /// メンバー編集シートの表示
    @State private var showingMembers = false
    /// 費用専用項目の追加シート
    @State private var showingExpenseEditor = false
    /// 費用タブ内のサブタブ（一覧 / 精算）
    @State private var subtab: CostSubtab = .list

    private var plan: TravelPlan? {
        store.plans.first { $0.id == planID }
    }

    var body: some View {
        ScrollView {
            if let plan {
                VStack(spacing: 16) {
                    membersSummaryRow(for: plan)

                    // 一覧 / 精算 のサブタブ切替（Picker）
                    Picker("", selection: $subtab) {
                        ForEach(CostSubtab.allCases, id: \.self) { tab in
                            Text(tab.title).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch subtab {
                    case .list:
                        totalCard(for: plan)
                        costList(for: plan)
                    case .settlement:
                        SettlementSection(plan: plan)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
        }
        .sheet(isPresented: $showingMembers) {
            MemberEditorSheet(planID: planID)
        }
        .sheet(isPresented: $showingExpenseEditor) {
            if let plan {
                ExpenseItemEditor(planID: planID, plan: plan)
            }
        }
    }

    // MARK: - メンバー（1 行サマリー・タップで編集シート）

    private func membersSummaryRow(for plan: TravelPlan) -> some View {
        Button {
            showingMembers = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(PlanTheme.primary)
                // メンバーがいれば「名前・名前 (N人)」、居なければ追加を促す
                if plan.members.isEmpty {
                    Text(NSLocalizedString("plan.members.add", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(PlanTheme.primary)
                } else {
                    Text(plan.members.map(\.name).joined(separator: "・"))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(String(format: NSLocalizedString("plan.members.count.format", comment: ""), plan.members.count))
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 6)
                Image(systemName: "chevron.right")
                    .font(.caption2.bold())
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 合計カード

    private func totalCard(for plan: TravelPlan) -> some View {
        HStack {
            Text(NSLocalizedString("plan.cost.total", comment: ""))
                .font(.subheadline.bold())
                .foregroundColor(.white.opacity(0.95))
            Spacer()
            Text(CurrencyFormat.string(plan.totalCost))
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                .fill(PlanTheme.brandGradient)
        )
        .shadow(color: PlanTheme.primary.opacity(0.3), radius: 10, x: 0, y: 4)
    }

    // MARK: - 費用一覧（費用専用アイテムの金額入力）

    private func costList(for plan: TravelPlan) -> some View {
        VStack(spacing: 12) {
            let items = plan.costItems
            if items.isEmpty {
                Text(NSLocalizedString("plan.cost.empty", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .planCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        CostRow(item: item, plan: plan, planID: planID, store: store)
                        if index < items.count - 1 {
                            Divider().padding(.leading, 48)
                        }
                    }
                }
                .planCard(padding: 8)
            }

            // 費用項目を追加（場所・旅程を持たない出費）
            Button {
                showingExpenseEditor = true
            } label: {
                Label(NSLocalizedString("plan.expense.add", comment: ""), systemImage: "plus")
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
    }
}

// MARK: - CostRow
/// 費用一覧の 1 行（費用専用アイテム）。表示専用で、タップすると統一エディタを開く。
/// アイコン＋名前（＋割り勘の要約）と金額を並べ、行末に削除ボタンを置く。
private struct CostRow: View {
    let item: PlanItem
    let plan: TravelPlan       // 支払者・分担者の名前解決に必要
    let planID: UUID
    let store: TravelPlanStore

    /// 統一編集シート
    @State private var showingEditor = false

    /// 支払者名（設定済みのときだけ）。未設定・メンバー不在なら nil で何も出さない。
    private var payerName: String? {
        item.payerID.flatMap { plan.memberName(for: $0) }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Circle().fill(PlanTheme.color(for: item.category)))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .lineLimit(1)
                // 支払者が設定済みのときだけ、その名前を控えめに表示
                if let payerName {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle")
                        Text(payerName).lineLimit(1)
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 8)

            // 金額（表示専用。未入力は「—」）
            Text(item.cost.map { CurrencyFormat.string($0) } ?? "—")
                .font(.subheadline.bold().monospacedDigit())
                .foregroundColor(item.cost == nil ? .secondary : .primary)

            Image(systemName: "chevron.right")
                .font(.caption2.bold())
                .foregroundColor(.secondary.opacity(0.5))

            // 費用項目の削除（費用タブでのみ管理するため常設）
            Button {
                store.removeItem(item, from: planID)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { showingEditor = true }
        .sheet(isPresented: $showingEditor) {
            ExpenseItemEditor(planID: planID, plan: plan, editing: item)
        }
    }
}

// MARK: - ExpenseItemEditor
/// 費用専用項目（.expense）の統一編集シート。新規追加・既存編集を兼ねる。
/// タイトル・金額・支払者・分担者をまとめて入力し、「保存」で確定する。
private struct ExpenseItemEditor: View {
    let planID: UUID
    let plan: TravelPlan
    /// 編集対象。nil なら新規追加。
    let editing: PlanItem?

    @ObservedObject private var store = TravelPlanStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var amountText: String
    @State private var payerID: UUID?
    /// 選択中の分担者 ID。初期値は実効分担者（新規・未設定なら全員）。
    @State private var selectedSharers: Set<UUID>

    init(planID: UUID, plan: TravelPlan, editing: PlanItem? = nil) {
        self.planID = planID
        self.plan = plan
        self.editing = editing
        _title = State(initialValue: editing?.name ?? "")
        _amountText = State(initialValue: editing?.cost.map(String.init) ?? "")
        _payerID = State(initialValue: editing?.payerID)
        if let editing {
            _selectedSharers = State(initialValue: Set(plan.effectiveSplitMemberIDs(for: editing)))
        } else {
            // 新規は既定で全員が分担
            _selectedSharers = State(initialValue: Set(plan.members.map(\.id)))
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var amountValue: Int? {
        amountText.isEmpty ? nil : Int(amountText)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        titleCard
                        amountCard
                        // メンバーが居るときだけ割り勘（支払者・分担）を出す
                        if !plan.members.isEmpty {
                            payerCard
                            sharersCard
                        }
                        Button {
                            save()
                        } label: {
                            Text(NSLocalizedString("common.save", comment: ""))
                        }
                        .buttonStyle(PlanPrimaryButtonStyle())
                        .disabled(!canSave)
                        .opacity(canSave ? 1 : 0.5)
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString(editing == nil ? "plan.expense.add" : "plan.expense.edit", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
            }
        }
        .tint(PlanTheme.primary)
    }

    // 項目名
    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("plan.custom.title.label", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            TextField(NSLocalizedString("plan.expense.title.placeholder", comment: ""), text: $title)
                .textFieldStyle(.plain)
                .font(.title3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // 金額
    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("plan.section.cost", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            HStack(spacing: 4) {
                Text(CurrencyFormat.symbol)
                    .font(.title3)
                    .foregroundColor(.secondary)
                TextField("0", text: $amountText)
                    .keyboardType(.numberPad)
                    .font(.title3.monospacedDigit())
                    .onChange(of: amountText) { _, newValue in
                        let digits = newValue.filter(\.isNumber)
                        if digits != newValue { amountText = digits }
                    }
            }
            // 1 人あたりの負担額（切り捨て・端数は支払者）
            if let cost = amountValue, !selectedSharers.isEmpty {
                Text(String(format: NSLocalizedString("plan.split.perhead.format", comment: ""),
                            CurrencyFormat.string(cost / selectedSharers.count),
                            selectedSharers.count))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // 支払者ピッカー（1 人選択・未指定可）
    private var payerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("plan.split.payer.label", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            FlowLayout(spacing: 8) {
                ForEach(plan.members) { member in
                    let selected = payerID == member.id
                    Button {
                        // 同じ人を再タップで未指定に戻す
                        payerID = selected ? nil : member.id
                    } label: {
                        Text(member.name)
                            .font(.caption.bold())
                            .foregroundColor(selected ? .white : PlanTheme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(selected ? PlanTheme.primary : PlanTheme.primary.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // 分担者チェックリスト
    private var sharersCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(NSLocalizedString("plan.split.sharers.label", comment: ""))
                    .font(.caption.bold())
                    .foregroundColor(PlanTheme.primary)
                Spacer()
                // 全員選択 / 全解除のトグル
                Button {
                    if selectedSharers.count == plan.members.count {
                        selectedSharers.removeAll()
                    } else {
                        selectedSharers = Set(plan.members.map(\.id))
                    }
                } label: {
                    Text(selectedSharers.count == plan.members.count
                         ? NSLocalizedString("plan.split.selectnone", comment: "")
                         : NSLocalizedString("plan.split.selectall", comment: ""))
                        .font(.caption.bold())
                }
                .buttonStyle(.plain)
            }

            ForEach(plan.members) { member in
                Button {
                    if selectedSharers.contains(member.id) {
                        selectedSharers.remove(member.id)
                    } else {
                        selectedSharers.insert(member.id)
                    }
                } label: {
                    HStack {
                        Image(systemName: selectedSharers.contains(member.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedSharers.contains(member.id) ? PlanTheme.primary : .secondary.opacity(0.5))
                        Text(member.name)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    /// 分担者選択を保存値へ変換。全員選択なら nil（全員均等・人数変動追従）、一部なら登場順の ID 配列。
    private func resolvedSplitMemberIDs() -> [UUID]? {
        let allIDs = Set(plan.members.map(\.id))
        if selectedSharers == allIDs { return nil }
        return plan.members.map(\.id).filter { selectedSharers.contains($0) }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let split = resolvedSplitMemberIDs()
        if let editing {
            // 既存項目を丸ごと更新
            var updated = editing
            updated.name = trimmed
            updated.cost = amountValue
            updated.payerID = payerID
            updated.splitMemberIDs = split
            store.updateItem(updated, in: planID)
        } else {
            store.addExpenseItem(title: trimmed, cost: amountValue, payerID: payerID, splitMemberIDs: split, to: planID)
        }
        dismiss()
    }
}

// MARK: - SettlementSection
/// 精算サブタブの中身。各メンバーの収支と「誰が誰にいくら払うか」を表示する。
private struct SettlementSection: View {
    let plan: TravelPlan

    private var result: (balances: [MemberBalance], transfers: [SettlementTransfer]) {
        SettlementCalculator.settle(for: plan)
    }

    var body: some View {
        if plan.members.isEmpty {
            hint(NSLocalizedString("plan.members.empty", comment: ""))
        } else if !SettlementCalculator.hasSettlementData(for: plan) {
            hint(NSLocalizedString("plan.settlement.empty", comment: ""))
        } else {
            let r = result
            VStack(spacing: 16) {
                balancesCard(r.balances)
                transfersCard(r.transfers)
            }
        }
    }

    private func hint(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .planCard()
    }

    // 各メンバーの収支（+ 受け取る / − 支払う）
    private func balancesCard(_ balances: [MemberBalance]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(NSLocalizedString("plan.settlement.balances", comment: ""), systemImage: "arrow.left.arrow.right")
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            ForEach(balances) { b in
                HStack {
                    Text(b.name)
                        .font(.subheadline.bold())
                    Spacer()
                    Text(balanceText(b.balance))
                        .font(.subheadline.bold().monospacedDigit())
                        .foregroundColor(balanceColor(b.balance))
                }
                .padding(.vertical, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // 送金リスト（A → B ¥X）
    private func transfersCard(_ transfers: [SettlementTransfer]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(NSLocalizedString("plan.settlement.transfers", comment: ""), systemImage: "yensign.arrow.circlepath")
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            if transfers.isEmpty {
                Text(NSLocalizedString("plan.settlement.even", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(transfers) { t in
                    HStack(spacing: 8) {
                        Text(t.fromName)
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                        Image(systemName: "arrow.right")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        Text(t.toName)
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                        Spacer()
                        Text(CurrencyFormat.string(t.amount))
                            .font(.subheadline.bold().monospacedDigit())
                            .foregroundColor(PlanTheme.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    /// 収支の符号付き表示。受け取り「+¥X」／支払い「−¥X」／ゼロは「¥0」。
    private func balanceText(_ balance: Int) -> String {
        if balance > 0 { return "+" + CurrencyFormat.string(balance) }
        if balance < 0 { return "−" + CurrencyFormat.string(-balance) }
        return CurrencyFormat.string(0)
    }

    private func balanceColor(_ balance: Int) -> Color {
        if balance > 0 { return Color(red: 0.20, green: 0.60, blue: 0.35) }   // 受け取り＝緑
        if balance < 0 { return PlanTheme.accent }                            // 支払い＝コーラル
        return .secondary
    }
}

// MARK: - MemberEditorSheet
/// メンバーの追加・削除を行うシート。費用タブの 1 行サマリーをタップして開く。
private struct MemberEditorSheet: View {
    let planID: UUID
    @ObservedObject private var store = TravelPlanStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var newMemberName = ""
    @FocusState private var fieldFocused: Bool

    private var plan: TravelPlan? {
        store.plans.first { $0.id == planID }
    }

    private var canAdd: Bool {
        !newMemberName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        if let plan {
                            if plan.members.isEmpty {
                                Text(NSLocalizedString("plan.members.empty", comment: ""))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .planCard()
                            } else {
                                MemberChipsFlow(members: plan.members) { index in
                                    store.removeMembers(at: IndexSet(integer: index), in: planID)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .planCard()
                            }
                        }

                        // 追加フィールド（確定後も開いたままで連続追加）
                        HStack(spacing: 10) {
                            Image(systemName: "person.badge.plus")
                                .foregroundColor(.secondary)
                            TextField(NSLocalizedString("plan.members.placeholder", comment: ""), text: $newMemberName)
                                .textFieldStyle(.plain)
                                .submitLabel(.done)
                                .focused($fieldFocused)
                                .onSubmit { add() }
                            Button {
                                add()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(canAdd ? PlanTheme.primary : .secondary.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                            .disabled(!canAdd)
                        }
                        .planCard()

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString("plan.members.label", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.done", comment: "")) { dismiss() }
                }
            }
        }
        .tint(PlanTheme.primary)
    }

    private func add() {
        guard canAdd else { return }
        store.addMember(newMemberName, to: planID)
        newMemberName = ""
        fieldFocused = true
    }
}

// MARK: - MemberChipsFlow
/// メンバーを折り返しで横並びに表示するチップ群。各チップの✕で削除。
private struct MemberChipsFlow: View {
    let members: [PlanMember]
    let onDelete: (Int) -> Void

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text(member.name)
                        .font(.caption.bold())
                        .lineLimit(1)
                    Button {
                        onDelete(index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
                .foregroundColor(PlanTheme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(PlanTheme.primary.opacity(0.12))
                )
            }
        }
    }
}

// MARK: - FlowLayout
/// 子ビューを左詰めで並べ、幅が足りなくなったら折り返す簡易レイアウト（iOS 16+ Layout）。
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                totalWidth = max(totalWidth, rowWidth)
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += (rowWidth > 0 ? spacing : 0) + size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        totalHeight += rowHeight
        totalWidth = max(totalWidth, rowWidth)
        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - CurrencyFormat
/// 金額（Int）をロケール通貨で整形する。保存は素の整数、表示だけ通貨記号を付ける。
enum CurrencyFormat {
    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.maximumFractionDigits = 0     // 円想定で小数は出さない
        f.minimumFractionDigits = 0
        return f
    }()

    /// "¥1,000" のような通貨表示。整形に失敗したら記号＋数値で代替。
    static func string(_ value: Int) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "\(symbol)\(value)"
    }

    /// 現在ロケールの通貨記号（行内入力欄のプレフィックス用）。
    static var symbol: String {
        formatter.currencySymbol ?? "¥"
    }
}
