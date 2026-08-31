//
//  MyPlansView.swift
//  MapRoulette
//
//  「マイプラン」タブ。保存した旅行プランの一覧を表示し、
//  新規作成・削除・詳細への遷移を行う。
//  iOS 標準の List 感をなくし、ブランド統一のカードベース UI で構成する。
//

import SwiftUI

/// マイプランタブ内の上タブ（一覧 / 訪問済み）
private enum MyPlansSection: Int, CaseIterable {
    case list       // プラン一覧
    case visited    // 訪問済みマップ

    var title: String {
        switch self {
        case .list:    return NSLocalizedString("plan.section.list", comment: "")
        case .visited: return NSLocalizedString("plan.section.visited", comment: "")
        }
    }
}

struct MyPlansView: View {
    @ObservedObject private var store = TravelPlanStore.shared
    @State private var showingNewPlanSheet = false
    @State private var newPlanTitle = ""
    @State private var editMode: EditMode = .inactive
    @State private var section: MyPlansSection = .list

    var body: some View {
        NavigationStack {
            // 切替帯は NavigationStack の内側最上部に置く。ここに置くことで
            // 一覧からの詳細プッシュ（NavigationLink）が壊れない。
            VStack(spacing: 0) {
                PlanSectionBand(section: $section)

                switch section {
                case .list:
                    if store.plans.isEmpty {
                        emptyState
                    } else {
                        planList
                    }
                case .visited:
                    VisitedMapView()
                }
            }
            // 背景グラデーションは切替帯も含めた画面全体の背後に敷き、
            // 帯自体は透明にして下の背景と馴染ませる（帯だけ白く浮くのを防ぐ）。
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PlanTheme.pageBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 並び替え用の編集トグル（一覧セクションで 2 件以上あるときだけ表示）。
                // ＋（新規作成）はツールバーに置かず、一覧の最後のカードの下に置く。
                // こうすることでタブ切替時に右上ボタンの有無で位置がずれるのを防ぐ。
                if section == .list && store.plans.count > 1 {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation {
                                editMode = editMode.isEditing ? .inactive : .active
                            }
                        } label: {
                            Text(editMode.isEditing
                                 ? NSLocalizedString("common.done", comment: "")
                                 : NSLocalizedString("common.edit", comment: ""))
                                .font(.headline)
                                .foregroundColor(PlanTheme.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewPlanSheet) {
                newPlanSheet
            }
        }
        .tint(PlanTheme.primary)
    }

    // MARK: - 空状態

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(PlanTheme.brandGradient)
                    .frame(width: 110, height: 110)
                    .shadow(color: PlanTheme.primary.opacity(0.3), radius: 16, x: 0, y: 8)
                Image(systemName: "suitcase.rolling.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
            }

            Text(NSLocalizedString("plan.empty.title", comment: ""))
                .font(.title3.bold())

            Text(NSLocalizedString("plan.empty.message", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                newPlanTitle = ""
                showingNewPlanSheet = true
            } label: {
                Label(NSLocalizedString("plan.create", comment: ""), systemImage: "plus.circle.fill")
            }
            .buttonStyle(PlanPrimaryButtonStyle())
            .fixedSize(horizontal: true, vertical: false)
            .padding(.top, 8)
        }
        .padding()
    }

    // MARK: - 一覧

    private var planList: some View {
        // 並び替え（.onMove）対応のため List を使い、見た目はカード UI を維持する
        // （区切り線・行背景・標準余白を消し、各行をカードとして描画）。
        List {
            ForEach(store.plans) { plan in
                ZStack {
                    // 編集モード中は遷移を無効化（並び替え操作に集中させる）
                    if !editMode.isEditing {
                        NavigationLink {
                            PlanDetailView(planID: plan.id)
                        } label: { EmptyView() }
                        .opacity(0)
                    }
                    PlanCardView(plan: plan)
                        .contentShape(RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous))
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .contextMenu {
                    Button(role: .destructive) {
                        store.deletePlan(plan)
                    } label: {
                        Label(NSLocalizedString("common.delete", comment: ""), systemImage: "trash")
                    }
                }
            }
            .onMove { source, destination in
                store.movePlans(from: source, to: destination)
            }
            .onDelete { offsets in
                store.deletePlans(at: offsets)
            }

            // 新規プラン追加（最後のカードの下）。編集（並び替え）中は隠す。
            if !editMode.isEditing {
                addPlanRow
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $editMode)
    }

    /// 一覧の末尾に置く「新規プラン追加」行。破線枠のカード風ボタン。
    private var addPlanRow: some View {
        Button {
            newPlanTitle = ""
            showingNewPlanSheet = true
        } label: {
            Label(NSLocalizedString("plan.create", comment: ""), systemImage: "plus")
                .font(.subheadline.bold())
                .foregroundColor(PlanTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                        .strokeBorder(PlanTheme.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 新規作成シート

    private var newPlanSheet: some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("plan.title.label", comment: ""))
                            .font(.subheadline.bold())
                            .foregroundColor(.secondary)
                        TextField(NSLocalizedString("plan.title.placeholder", comment: ""), text: $newPlanTitle)
                            .textFieldStyle(.plain)
                            .font(.title3)
                            .planCard()
                    }

                    Button {
                        createPlan()
                    } label: {
                        Text(NSLocalizedString("common.create", comment: ""))
                    }
                    .buttonStyle(PlanPrimaryButtonStyle())

                    Spacer()
                }
                .padding()
                .padding(.top, 8)
            }
            .navigationTitle(NSLocalizedString("plan.create", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        showingNewPlanSheet = false
                    }
                }
            }
        }
        .presentationDetents([.height(280)])
    }

    private func createPlan() {
        let title = newPlanTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        store.createPlan(title: title.isEmpty
                         ? NSLocalizedString("plan.untitled", comment: "")
                         : title)
        showingNewPlanSheet = false
    }
}

// MARK: - PlanSectionBand
/// マイプランタブ内の上タブ切替帯（一覧 / 訪問済み）。
/// 統合マップタブの MapModeBand と同じデザイン言語（文字＋ブランド下線）で統一する。
private struct PlanSectionBand: View {
    @Binding var section: MyPlansSection

    // 下線の左右インセット（セル幅からこの分だけ内側に縮める）
    private let underlineInset: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let count = CGFloat(MyPlansSection.allCases.count)
            let cellWidth = geo.size.width / count
            let selectedIndex = CGFloat(section.rawValue)

            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    ForEach(MyPlansSection.allCases, id: \.self) { item in
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

// MARK: - PlanCardView

private struct PlanCardView: View {
    let plan: TravelPlan

    /// プラン内の代表カテゴリ（最大4種）をアイコン表示。費用専用アイテムは旅程の見た目に出さない。
    private var categoryIcons: [PlanItemCategory] {
        var seen = Set<PlanItemCategory>()
        var result: [PlanItemCategory] = []
        for item in plan.itineraryItems where seen.insert(item.category).inserted {
            result.append(item.category)
        }
        return Array(result.prefix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 上部：ブランドグラデーションのヘッダー
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .lineLimit(2)
                        // 旅行済みプランには「済」バッジを付ける
                        if plan.isCompleted {
                            Label(NSLocalizedString("plan.badge.completed", comment: ""),
                                  systemImage: "checkmark.seal.fill")
                                .labelStyle(.titleAndIcon)
                                .font(.caption2.bold())
                                .foregroundColor(PlanTheme.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(.white))
                        }
                    }
                    Text(String(format: NSLocalizedString("plan.itemcount.format", comment: ""), plan.itineraryItems.count))
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.bold())
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(18)
            .background(PlanTheme.brandGradient)

            // 下部：カテゴリアイコン or プレースホルダ
            HStack(spacing: 10) {
                if categoryIcons.isEmpty {
                    Text(NSLocalizedString("plan.card.empty", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(categoryIcons, id: \.self) { category in
                        Image(systemName: category.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(PlanTheme.color(for: category)))
                    }
                    if plan.groupingMode == .day {
                        Spacer()
                        Label(String(format: NSLocalizedString("plan.daycount.short", comment: ""), plan.dayCount),
                              systemImage: "calendar")
                            .font(.caption.bold())
                            .foregroundColor(PlanTheme.primary)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous))
        .shadow(color: PlanTheme.cardShadow, radius: 10, x: 0, y: 4)
    }
}
