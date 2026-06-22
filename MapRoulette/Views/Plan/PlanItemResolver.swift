//
//  PlanItemResolver.swift
//  MapRoulette
//
//  PlanItem（カテゴリ・県・name のみ保持）から元データを引き当て、
//  座標の取得と、対応する詳細画面への遷移を担う。
//  保存データを最小化し、表示は常に元データを参照する。
//

import SwiftUI
import CoreLocation

enum PlanItemResolver {

    // MARK: - 座標解決

    static func coordinate(category: PlanItemCategory, prefecture: Prefecture, name: String) -> CLLocationCoordinate2D? {
        switch category {
        case .attraction:
            return prefecture.tourismInfo.attractions.first { $0.name == name }?.coordinate
        case .onsen:
            return prefecture.onsenItems.first { $0.name == name }?.coordinate
        case .festival:
            // 祭・その他祭の両方を探す
            if let f = prefecture.festivalItems.first(where: { $0.name == name }) {
                return f.coordinate
            }
            return prefecture.otherFestivalItems.first { $0.name == name }?.coordinate
        case .nature:
            return NatureSpotDataRepository.shared.allFixedSpots.first { $0.name == name }?.coordinate
        case .gourmet, .souvenir:
            // グルメ・お土産は座標を持たない
            return nil
        case .hotel, .transport, .other:
            // カスタム項目は PlanItem 側で座標を保持するためここでは扱わない
            return nil
        }
    }

    // MARK: - 説明文（一覧カードの補足表示などに使う）

    static func detail(category: PlanItemCategory, prefecture: Prefecture, name: String) -> String? {
        switch category {
        case .attraction:
            return prefecture.tourismInfo.attractions.first { $0.name == name }?.description
        case .gourmet:
            return prefecture.gourmetItems.first { $0.name == name }?.description
        case .onsen:
            return prefecture.onsenItems.first { $0.name == name }?.description
        case .festival:
            if let f = prefecture.festivalItems.first(where: { $0.name == name }) { return f.description }
            return prefecture.otherFestivalItems.first { $0.name == name }?.description
        case .nature:
            return NatureSpotDataRepository.shared.allFixedSpots.first { $0.name == name }?.description
        case .souvenir:
            return prefecture.souvenirItems.first { $0.name == name }?.description
        case .hotel, .transport, .other:
            return nil
        }
    }
}

// MARK: - 詳細画面ルーター
/// PlanItem をタップしたときに開く、カテゴリ別の既存詳細画面。
/// 元データが見つからない場合は簡易フォールバックを表示する。
struct PlanItemDetailRouter: View {
    let item: PlanItem

    var body: some View {
        if item.category.isCustom {
            // カスタム項目は元データを持たないため、保存値を表示する専用画面へ
            CustomPlanItemView(item: item)
        } else if let prefecture = item.prefecture {
            // アプリ項目は元の詳細画面を PlanLocatableDetailView でラップし、
            // メモ・位置の追加バーを共通で付与する。
            switch item.category {
            case .attraction:
                if let attraction = prefecture.tourismInfo.attractions.first(where: { $0.name == item.name }) {
                    PlanLocatableDetailView(item: item) {
                        AttractionDetailView(attraction: attraction, prefecture: prefecture)
                    }
                } else { fallback }

            case .gourmet:
                if let g = prefecture.gourmetItems.first(where: { $0.name == item.name }) {
                    PlanLocatableDetailView(item: item) {
                        GourmetDetailView(item: g, prefecture: prefecture)
                    }
                } else { fallback }

            case .onsen:
                if let original = prefecture.onsenItems.first(where: { $0.name == item.name }),
                   let fixed = OnsenDataRepository.shared.getFixedOnsen(name: original.name, type: original.onsenType) {
                    PlanLocatableDetailView(item: item) {
                        OnsenDetailView(onsen: fixed)
                    }
                } else { fallback }

            case .festival:
                if let f = prefecture.festivalItems.first(where: { $0.name == item.name }) {
                    PlanLocatableDetailView(item: item) {
                        FestivalDetailView(item: f, prefecture: prefecture)
                    }
                } else if let o = prefecture.otherFestivalItems.first(where: { $0.name == item.name }) {
                    PlanLocatableDetailView(item: item) {
                        OtherFestivalDetailView(item: o, prefecture: prefecture)
                    }
                } else { fallback }

            case .nature:
                if let spot = NatureSpotDataRepository.shared.allFixedSpots.first(where: { $0.name == item.name }) {
                    PlanLocatableDetailView(item: item) {
                        NatureSpotDetailView(spot: spot)
                    }
                } else { fallback }

            case .souvenir:
                if let s = prefecture.souvenirItems.first(where: { $0.name == item.name }) {
                    PlanLocatableDetailView(item: item) {
                        SouvenirDetailView(item: s, prefecture: prefecture)
                    }
                } else { fallback }

            case .hotel, .transport, .other:
                CustomPlanItemView(item: item)
            }
        } else {
            fallback
        }
    }

    /// 元データが見つからないときの簡易表示。
    private var fallback: some View {
        VStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.largeTitle)
                .foregroundColor(PlanTheme.primary)
            Text(item.name).font(.headline)
            Text(NSLocalizedString("plan.item.notfound", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - 位置を足せる詳細ラッパー（グルメ・お土産用）
/// 元の詳細画面を表示しつつ、下部に「メモ」「位置」の追加バーを重ねる。
/// メモは customDetail、位置は customCoordinate として保存され、
/// プラン項目ごとのユーザー入力を保持する。
private struct PlanLocatableDetailView<Content: View>: View {
    let item: PlanItem
    @ViewBuilder let content: () -> Content

    @ObservedObject private var store = TravelPlanStore.shared
    @State private var pickerSession: LocationPickSession?
    @State private var pickedCoordinate: CLLocationCoordinate2D?
    @State private var pickedPlaceName: String?
    @State private var pickedAddress: String?
    @State private var showingMemoEditor = false
    @State private var memoDraft = ""

    /// store から最新の項目を取得（保存後の反映のため）
    private var currentItem: PlanItem? {
        for plan in store.plans {
            if let found = plan.items.first(where: { $0.id == item.id }) { return found }
        }
        return item
    }

    private var planID: UUID? {
        store.plans.first { $0.items.contains(where: { $0.id == item.id }) }?.id
    }

    var body: some View {
        content()
            // 下部フローティングバーと最下部コンテンツが重ならないよう余白を確保
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 72)
            }
            .overlay(alignment: .bottom) { actionBar }
            .sheet(item: $pickerSession) { _ in
                LocationPickerView(coordinate: $pickedCoordinate, placeName: $pickedPlaceName, address: $pickedAddress)
                    .onDisappear { saveLocation() }
            }
            .sheet(isPresented: $showingMemoEditor) { memoEditor }
    }

    /// 位置追加ボタンを出すか。元データに座標を持たないグルメ・お土産のみ。
    /// （観光・温泉・祭・自然は元データに正確な座標があるため allowsUserCoordinate が false）
    private var allowsLocation: Bool {
        item.category.allowsUserCoordinate && !item.category.isCustom
    }

    // 下部のメモ・位置アクションバー
    private var actionBar: some View {
        let hasMemo = !(currentItem?.customDetail?.isEmpty ?? true)
        let hasLocation = currentItem?.customCoordinate != nil
        return HStack(spacing: 10) {
            Button {
                memoDraft = currentItem?.customDetail ?? ""
                showingMemoEditor = true
            } label: {
                Label(NSLocalizedString(hasMemo ? "plan.item.editmemo" : "plan.item.addmemo", comment: ""),
                      systemImage: "note.text")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(PlanTheme.primary.opacity(0.15)))
                    .foregroundColor(PlanTheme.primary)
            }
            if allowsLocation {
                Button {
                    pickedCoordinate = currentItem?.customCoordinate
                    pickedPlaceName = currentItem?.customPlaceName
                    pickedAddress = currentItem?.customAddress
                    pickerSession = LocationPickSession(coordinate: currentItem?.customCoordinate)
                } label: {
                    Label(NSLocalizedString(hasLocation ? "plan.locatable.change" : "plan.locatable.add", comment: ""),
                          systemImage: hasLocation ? "mappin.circle.fill" : "mappin.and.ellipse")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(PlanTheme.primary.opacity(0.15)))
                        .foregroundColor(PlanTheme.primary)
                }
            }
        }
        .lineLimit(1)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private var memoEditor: some View {
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
            .navigationTitle(NSLocalizedString("plan.item.memo", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { showingMemoEditor = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.save", comment: "")) {
                        saveMemo()
                        showingMemoEditor = false
                    }
                }
            }
        }
    }

    private func saveMemo() {
        guard let planID, var updated = currentItem else { return }
        let trimmed = memoDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.customDetail = trimmed.isEmpty ? nil : memoDraft
        store.updateItem(updated, in: planID)
    }

    private func saveLocation() {
        guard let planID, var updated = currentItem else { return }
        updated.customLatitude = pickedCoordinate?.latitude
        updated.customLongitude = pickedCoordinate?.longitude
        updated.customPlaceName = pickedCoordinate == nil ? nil : pickedPlaceName
        updated.customAddress = pickedCoordinate == nil ? nil : pickedAddress
        store.updateItem(updated, in: planID)
    }
}

/// 位置選択シートの提示用セッション（item ベースで確実に座標を渡すため）。
private struct LocationPickSession: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D?
}
