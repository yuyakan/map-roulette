//
//  CustomPlanItemEditor.swift
//  MapRoulette
//
//  ユーザーが手動で追加する旅程項目（ホテル・移動手段・その他メモ）の
//  追加 / 編集フォームと、保存済み項目の表示画面。
//

import SwiftUI
import MapKit

// MARK: - 編集フォーム（追加・編集兼用）

struct CustomPlanItemEditor: View {
    let planID: UUID
    /// 編集対象。nil なら新規追加。
    let editing: PlanItem?
    /// 新規追加時に割り当てる日（日程セクションから追加した場合に指定）。
    let initialDay: Int?

    @ObservedObject private var store = TravelPlanStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var category: PlanItemCategory
    @State private var title: String
    @State private var detail: String
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var showingLocationPicker = false

    init(planID: UUID, editing: PlanItem? = nil, initialDay: Int? = nil) {
        self.planID = planID
        self.editing = editing
        self.initialDay = initialDay
        _category = State(initialValue: editing?.category ?? .hotel)
        _title = State(initialValue: editing?.name ?? "")
        _detail = State(initialValue: editing?.customDetail ?? "")
        _coordinate = State(initialValue: editing?.coordinate)
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        typeCard
                        titleCard
                        detailCard
                        locationCard
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
            .navigationTitle(NSLocalizedString(editing == nil ? "plan.custom.add" : "plan.custom.edit", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(coordinate: $coordinate)
            }
        }
        .tint(PlanTheme.primary)
    }

    // MARK: - 種類選択

    private var typeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("plan.custom.type", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            HStack(spacing: 10) {
                ForEach(PlanItemCategory.customCases, id: \.self) { c in
                    Button {
                        category = c
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: c.icon)
                                .font(.system(size: 18, weight: .semibold))
                            Text(c.localizedName)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(category == c ? PlanTheme.color(for: c).opacity(0.18) : Color(.tertiarySystemGroupedBackground))
                        )
                        .foregroundColor(category == c ? PlanTheme.color(for: c) : .secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(category == c ? PlanTheme.color(for: c) : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("plan.custom.title.label", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            TextField(NSLocalizedString("plan.custom.title.placeholder", comment: ""), text: $title)
                .textFieldStyle(.plain)
                .font(.title3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("plan.custom.detail.label", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            TextEditor(text: $detail)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var locationCard: some View {
        Button {
            showingLocationPicker = true
        } label: {
            HStack {
                Image(systemName: coordinate == nil ? "mappin.slash" : "mappin.circle.fill")
                    .foregroundColor(coordinate == nil ? .secondary : PlanTheme.primary)
                Text(coordinate == nil
                     ? NSLocalizedString("plan.custom.location.add", comment: "")
                     : NSLocalizedString("plan.custom.location.set", comment: ""))
                    .foregroundColor(.primary)
                Spacer()
                if coordinate != nil {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                }
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .planCard()
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let editing {
            var updated = editing
            updated.category = category
            updated.name = trimmed
            updated.customDetail = detail
            updated.customLatitude = coordinate?.latitude
            updated.customLongitude = coordinate?.longitude
            store.updateItem(updated, in: planID)
        } else {
            let item = PlanItem(
                customCategory: category,
                title: trimmed,
                detail: detail,
                coordinate: coordinate,
                dayNumber: initialDay
            )
            store.addItem(item, to: planID)
        }
        dismiss()
    }
}

// MARK: - 位置選択（地図中心をピンに）

struct LocationPickerView: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    @Environment(\.dismiss) private var dismiss

    private let initialCenter: CLLocationCoordinate2D
    @State private var cameraPosition: MapCameraPosition
    /// 地図の現在の中心（onMapCameraChange で更新）。これを保存する。
    @State private var currentCenter: CLLocationCoordinate2D
    @State private var searchText = ""
    @State private var results: [MKMapItem] = []
    @State private var isSearching = false

    init(coordinate: Binding<CLLocationCoordinate2D?>) {
        _coordinate = coordinate
        let center = coordinate.wrappedValue ?? CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
        self.initialCenter = center
        _currentCenter = State(initialValue: center)
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition)
                    .ignoresSafeArea(edges: .bottom)
                    .onMapCameraChange(frequency: .continuous) { context in
                        // ドラッグ・ズームで動いた地図の中心を常に追従
                        currentCenter = context.region.center
                    }

                // 画面中央に固定されたピン（地図を動かして位置を合わせる）
                VStack(spacing: 0) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white, PlanTheme.primary)
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    // ピンの先端が中心を指すよう、下に三角の足を出して上方向にオフセット
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 14))
                        .foregroundColor(PlanTheme.primary)
                        .offset(y: -6)
                }
                .offset(y: -20)
                .allowsHitTesting(false)

                // 検索（最前面・上部）
                VStack(spacing: 0) {
                    searchOverlay
                    Spacer()
                }
            }
            .navigationTitle(NSLocalizedString("plan.custom.location.pick", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.save", comment: "")) {
                        coordinate = currentCenter
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - 検索 UI（地図上部にオーバーレイ）

    private var searchOverlay: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField(NSLocalizedString("plan.custom.location.search", comment: ""), text: $searchText)
                    .submitLabel(.search)
                    .onSubmit { runSearch() }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        results = []
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 6, y: 2)

            if !results.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(results, id: \.self) { item in
                            Button {
                                select(item)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "—")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.primary)
                                    if let addr = item.placemark.title {
                                        Text(addr)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: 240)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                .padding(.top, 6)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func runSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { results = []; return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: currentCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        isSearching = true
        MKLocalSearch(request: request).start { response, _ in
            isSearching = false
            results = response?.mapItems ?? []
        }
    }

    private func select(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        currentCenter = coord
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
        results = []
        searchText = item.name ?? searchText
    }
}

// MARK: - 表示画面（保存済みカスタム項目）

struct CustomPlanItemView: View {
    let item: PlanItem
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false

    /// この項目が属するプランID（編集に必要）。store から逆引き。
    private var planID: UUID? {
        TravelPlanStore.shared.plans.first { $0.items.contains(where: { $0.id == item.id }) }?.id
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        header
                        if let detail = item.customDetail, !detail.isEmpty {
                            detailCard(detail)
                        }
                        if let coord = item.coordinate {
                            mapCard(coord)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.close", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if planID != nil {
                        Button(NSLocalizedString("common.edit", comment: "")) { showingEditor = true }
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                if let planID {
                    CustomPlanItemEditor(planID: planID, editing: item)
                }
            }
        }
        .tint(PlanTheme.primary)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(Circle().fill(PlanTheme.color(for: item.category)))
            Text(item.name).font(.title2.bold()).multilineTextAlignment(.center)
            Text(item.category.localizedName)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func detailCard(_ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(NSLocalizedString("plan.memo.label", comment: ""), systemImage: "note.text")
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            Text(detail).font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private func mapCard(_ coord: CLLocationCoordinate2D) -> some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))) {
            Marker(item.name, coordinate: coord)
                .tint(PlanTheme.primary)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous))
    }
}
