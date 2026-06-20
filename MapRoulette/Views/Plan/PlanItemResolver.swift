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
        }
    }
}

// MARK: - 詳細画面ルーター
/// PlanItem をタップしたときに開く、カテゴリ別の既存詳細画面。
/// 元データが見つからない場合は簡易フォールバックを表示する。
struct PlanItemDetailRouter: View {
    let item: PlanItem

    var body: some View {
        if let prefecture = item.prefecture {
            switch item.category {
            case .attraction:
                if let attraction = prefecture.tourismInfo.attractions.first(where: { $0.name == item.name }) {
                    AttractionDetailView(attraction: attraction, prefecture: prefecture)
                } else { fallback }

            case .gourmet:
                if let g = prefecture.gourmetItems.first(where: { $0.name == item.name }) {
                    GourmetDetailView(item: g, prefecture: prefecture)
                } else { fallback }

            case .onsen:
                if let original = prefecture.onsenItems.first(where: { $0.name == item.name }),
                   let fixed = OnsenDataRepository.shared.getFixedOnsen(name: original.name, type: original.onsenType) {
                    OnsenDetailView2(onsen: fixed)
                } else { fallback }

            case .festival:
                if let f = prefecture.festivalItems.first(where: { $0.name == item.name }) {
                    FestivalDetailView(item: f, prefecture: prefecture)
                } else if let o = prefecture.otherFestivalItems.first(where: { $0.name == item.name }) {
                    OtherFestivalDetailView(item: o, prefecture: prefecture)
                } else { fallback }

            case .nature:
                if let spot = NatureSpotDataRepository.shared.allFixedSpots.first(where: { $0.name == item.name }) {
                    NatureSpotDetailView(spot: spot)
                } else { fallback }

            case .souvenir:
                if let s = prefecture.souvenirItems.first(where: { $0.name == item.name }) {
                    SouvenirDetailView(item: s, prefecture: prefecture)
                } else { fallback }
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
