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
                    menu(for: plan)
                }
            }
        }
        .sheet(isPresented: $showingMapSheet) {
            if let plan { PlanMapView(plan: plan) }
        }
        .sheet(isPresented: $showingMemoEditor) {
            if let plan { memoEditor(for: plan) }
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

                if plan.items.isEmpty {
                    emptyHint
                } else if plan.groupingMode == .day {
                    dayGroups(for: plan)
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
                Text(NSLocalizedString("plan.dragdrop.hint", comment: ""))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        Text(NSLocalizedString("plan.detail.empty", comment: ""))
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .planCard()
    }

    // MARK: - フラット表示（日程分けなし）

    private func flatList(for plan: TravelPlan) -> some View {
        VStack(spacing: 12) {
            ForEach(plan.items) { item in
                PlanItemCard(item: item, store: store, planID: planID, draggable: false)
            }
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

    // MARK: - メニュー

    private func menu(for plan: TravelPlan) -> some View {
        Menu {
            if !plan.mappableItems.isEmpty {
                Button {
                    showingMapSheet = true
                } label: {
                    Label(NSLocalizedString("plan.showmap", comment: ""), systemImage: "map")
                }
            }
            Button {
                memoDraft = plan.memo
                showingMemoEditor = true
            } label: {
                Label(NSLocalizedString("plan.editmemo", comment: ""), systemImage: "square.and.pencil")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(PlanTheme.primary)
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

    // MARK: - メモ編集

    private func memoEditor(for plan: TravelPlan) -> some View {
        NavigationStack {
            ZStack {
                PlanTheme.backgroundGradient.ignoresSafeArea()
                VStack {
                    TextEditor(text: $memoDraft)
                        .frame(minHeight: 200)
                        .scrollContentBackground(.hidden)
                        .planCard()
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("plan.editmemo", comment: ""))
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
                Text("\(items.count)")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }

            if items.isEmpty {
                Text(NSLocalizedString("plan.day.empty", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else {
                ForEach(items) { item in
                    PlanItemCard(item: item, store: store, planID: planID, draggable: true)
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
        .dropDestination(for: String.self) { droppedIDs, _ in
            guard let idString = droppedIDs.first, let uuid = UUID(uuidString: idString) else { return false }
            store.assignDay(day, to: uuid, in: planID)
            return true
        } isTargeted: { targeted in
            withAnimation(.easeOut(duration: 0.15)) { isTargeted = targeted }
        }
    }
}

// MARK: - PlanItemCard

private struct PlanItemCard: View {
    let item: PlanItem
    let store: TravelPlanStore
    let planID: UUID
    let draggable: Bool
    @State private var showingDetail = false

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
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .modifier(PlanItemInteraction(draggable: draggable, payload: item.id.uuidString) {
            store.removeItem(item, from: planID)
        })
        .sheet(isPresented: $showingDetail) {
            PlanItemDetailRouter(item: item)
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

// MARK: - PlanMapView

private struct PlanMapView: View {
    let plan: TravelPlan
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion

    init(plan: TravelPlan) {
        self.plan = plan
        _region = State(initialValue: PlanMapView.regionFitting(plan.mappableItems))
    }

    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, annotationItems: plan.mappableItems) { item in
                MapAnnotation(coordinate: item.coordinate ?? region.center) {
                    VStack(spacing: 2) {
                        Image(systemName: item.category.icon)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Circle().fill(PlanTheme.color(for: item.category)))
                        Text(item.name)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .background(Color(.systemBackground).opacity(0.85))
                            .cornerRadius(4)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle(plan.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.close", comment: "")) { dismiss() }
                }
            }
        }
    }

    private static func regionFitting(_ items: [PlanItem]) -> MKCoordinateRegion {
        let coords = items.compactMap { $0.coordinate }
        guard let first = coords.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529),
                span: MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 18)
            )
        }
        var minLat = first.latitude, maxLat = first.latitude
        var minLon = first.longitude, maxLon = first.longitude
        for c in coords {
            minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
        }
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.4, 0.05),
            longitudeDelta: max((maxLon - minLon) * 1.4, 0.05)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}
