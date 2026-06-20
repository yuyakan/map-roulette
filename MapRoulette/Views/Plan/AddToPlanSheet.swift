//
//  AddToPlanSheet.swift
//  MapRoulette
//
//  任意の情報（観光・グルメ・温泉・祭・お土産）をプランに追加するためのシート。
//  既存プランを選ぶか、新規プランを作成して追加できる。
//  マイプランと統一した PlanTheme ベースのカード UI で構成する。
//

import SwiftUI
import CoreLocation

struct AddToPlanSheet: View {
    /// 追加したい項目（呼び出し側で生成して渡す）
    let item: PlanItem

    @ObservedObject private var store = TravelPlanStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var newPlanTitle = ""
    @State private var showingNewPlanField = false

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        itemPreviewCard
                        newPlanCard
                        if !store.plans.isEmpty {
                            existingPlansCard
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString("plan.addto.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
            }
        }
        .tint(PlanTheme.primary)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - 追加対象のプレビュー

    private var itemPreviewCard: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(PlanTheme.color(for: item.category)))
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
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
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - 新規プラン作成

    private var newPlanCard: some View {
        VStack(spacing: 12) {
            if showingNewPlanField {
                TextField(NSLocalizedString("plan.title.placeholder", comment: ""), text: $newPlanTitle)
                    .textFieldStyle(.plain)
                    .font(.title3)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
                Button {
                    createAndAdd()
                } label: {
                    Text(NSLocalizedString("plan.create.andadd", comment: ""))
                }
                .buttonStyle(PlanPrimaryButtonStyle())
                .disabled(newPlanTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(newPlanTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            } else {
                Button {
                    withAnimation { showingNewPlanField = true }
                } label: {
                    Label(NSLocalizedString("plan.create.andadd", comment: ""), systemImage: "plus.circle.fill")
                }
                .buttonStyle(PlanPrimaryButtonStyle())
            }
        }
        .planCard()
    }

    // MARK: - 既存プラン一覧

    private var existingPlansCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("plan.select.existing", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)

            ForEach(store.plans) { plan in
                let contained = planContainsItem(plan)
                Button {
                    store.addItem(item, to: plan.id)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "suitcase.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(PlanTheme.brandGradient))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(plan.title)
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Text(String(format: NSLocalizedString("plan.itemcount.format", comment: ""), plan.items.count))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: contained ? "checkmark.circle.fill" : "plus.circle")
                            .font(.title3)
                            .foregroundColor(contained ? .green : PlanTheme.primary)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
                }
                .buttonStyle(.plain)
                .disabled(contained)
                .opacity(contained ? 0.6 : 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - ロジック

    private func planContainsItem(_ plan: TravelPlan) -> Bool {
        plan.items.contains { $0.name == item.name && $0.category == item.category }
    }

    private func createAndAdd() {
        let title = newPlanTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        let plan = store.createPlan(title: title)
        store.addItem(item, to: plan.id)
        dismiss()
    }
}

// MARK: - 便利な追加ボタン

/// 詳細画面に置く「＋プランに追加」ボタン。
/// 項目の生成クロージャを渡すだけで、シート表示まで面倒を見る。
/// compact = true のときはアイコンのみの小型表示（カード内などの省スペース用）。
struct AddToPlanButton: View {
    var compact: Bool = false
    let makeItem: () -> PlanItem
    @State private var showingSheet = false

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            if compact {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white, PlanTheme.primary)
            } else {
                Label(NSLocalizedString("plan.add.button", comment: ""), systemImage: "plus.circle.fill")
            }
        }
        .modifier(AddButtonStyle(compact: compact))
        .sheet(isPresented: $showingSheet) {
            AddToPlanSheet(item: makeItem())
        }
    }
}

/// compact のときはプレーン、通常時はブランドのグラデーションボタンに。
private struct AddButtonStyle: ViewModifier {
    let compact: Bool
    func body(content: Content) -> some View {
        if compact {
            content.buttonStyle(.plain)
        } else {
            content.buttonStyle(PlanPrimaryButtonStyle())
        }
    }
}
