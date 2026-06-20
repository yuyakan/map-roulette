//
//  MyPlansView.swift
//  MapRoulette
//
//  「マイプラン」タブ。保存した旅行プランの一覧を表示し、
//  新規作成・削除・詳細への遷移を行う。
//  iOS 標準の List 感をなくし、ブランド統一のカードベース UI で構成する。
//

import SwiftUI

struct MyPlansView: View {
    @ObservedObject private var store = TravelPlanStore.shared
    @State private var showingNewPlanSheet = false
    @State private var newPlanTitle = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.backgroundGradient.ignoresSafeArea()

                if store.plans.isEmpty {
                    emptyState
                } else {
                    planList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        newPlanTitle = ""
                        showingNewPlanSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(PlanTheme.primary)
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
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(store.plans) { plan in
                    NavigationLink {
                        PlanDetailView(planID: plan.id)
                    } label: {
                        PlanCardView(plan: plan)
                            .contentShape(RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            store.deletePlan(plan)
                        } label: {
                            Label(NSLocalizedString("common.delete", comment: ""), systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    // MARK: - 新規作成シート

    private var newPlanSheet: some View {
        NavigationStack {
            ZStack {
                PlanTheme.backgroundGradient.ignoresSafeArea()
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

// MARK: - PlanCardView

private struct PlanCardView: View {
    let plan: TravelPlan

    /// プラン内の代表カテゴリ（最大4種）をアイコン表示
    private var categoryIcons: [PlanItemCategory] {
        var seen = Set<PlanItemCategory>()
        var result: [PlanItemCategory] = []
        for item in plan.items where seen.insert(item.category).inserted {
            result.append(item.category)
        }
        return Array(result.prefix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 上部：ブランドグラデーションのヘッダー
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.title)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text(String(format: NSLocalizedString("plan.itemcount.format", comment: ""), plan.items.count))
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
