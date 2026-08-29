//
//  NearbySpot.swift
//  MapRoulette
//
//  「近くのスポット」タブ用の統一スポットモデル。
//  観光地・温泉・自然の3種を1つの型に畳み、現在地（または手動選択した
//  地域）からの距離順に並べられるようにする。詳細画面へは元データを
//  保持しておき、種類ごとの既存 Detail ビューへ fullScreenCover で飛ばす。
//

import SwiftUI
import CoreLocation

/// 近くのスポットの種類。上部の種類切替タブと絞り込みに使う。
enum NearbySpotKind: Int, CaseIterable, Identifiable {
    case tourism   // 観光地
    case onsen     // 温泉
    case nature    // 自然

    var id: Int { rawValue }

    /// 切替タブ用ラベル（既存のタブ用キーを再利用）。
    var title: String {
        switch self {
        case .tourism: return NSLocalizedString("nearby.filter.tourism", comment: "")
        case .onsen:   return NSLocalizedString("tab.onsen", comment: "")
        case .nature:  return NSLocalizedString("tab.nature", comment: "")
        }
    }

    /// 地図ピン／リストの基調色。
    var color: Color {
        switch self {
        case .tourism: return PlanTheme.primary
        case .onsen:   return Color(red: 0.9, green: 0.35, blue: 0.35)
        case .nature:  return Color(red: 0.2, green: 0.6, blue: 0.4)
        }
    }

    /// 地図ピン／リストのアイコン。
    var icon: String {
        switch self {
        case .tourism: return "camera.fill"
        case .onsen:   return "drop.fill"
        case .nature:  return "leaf.fill"
        }
    }
}

/// 詳細画面へ遷移するための元データ参照。種類ごとに必要な値だけ保持する。
enum NearbySpotSource {
    case tourism(attraction: LocalizedAttractionLocation, prefecture: Prefecture)
    case onsen(FixedOnsenItem)
    case nature(FixedNatureSpotItem)
}

/// 3種を畳んだ統一スポット。距離順表示と地図ピン用。
struct NearbySpot: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let kind: NearbySpotKind
    let source: NearbySpotSource

    /// 基準点からの距離（m）。基準点が決まってから計算して詰める。
    var distanceMeters: CLLocationDistance?

    var color: Color { kind.color }
    var icon: String { kind.icon }
}

// MARK: - データ収集

enum NearbySpotRepository {
    /// アプリ内の全スポット（観光・温泉・自然）を統一モデルで返す。
    /// 距離はまだ入っていない（基準点が決まってから calculateDistances で詰める）。
    static func allSpots() -> [NearbySpot] {
        var result: [NearbySpot] = []

        // 観光地: 47都道府県 × 各県の attractions
        for prefecture in Prefecture.allCases {
            for attraction in prefecture.tourismInfo.attractions {
                result.append(
                    NearbySpot(
                        id: "tourism_\(prefecture.rawValue)_\(attraction.id)",
                        name: attraction.name,
                        coordinate: attraction.coordinate,
                        kind: .tourism,
                        source: .tourism(attraction: attraction, prefecture: prefecture),
                        distanceMeters: nil
                    )
                )
            }
        }

        // 温泉
        for onsen in OnsenDataRepository.shared.allFixedOnsens {
            result.append(
                NearbySpot(
                    id: "onsen_\(onsen.id)",
                    name: onsen.name,
                    coordinate: onsen.coordinate,
                    kind: .onsen,
                    source: .onsen(onsen),
                    distanceMeters: nil
                )
            )
        }

        // 自然
        for spot in NatureSpotDataRepository.shared.allFixedSpots {
            result.append(
                NearbySpot(
                    id: "nature_\(spot.id)",
                    name: spot.name,
                    coordinate: spot.coordinate,
                    kind: .nature,
                    source: .nature(spot),
                    distanceMeters: nil
                )
            )
        }

        return result
    }

    /// 基準点から各スポットまでの距離を詰め、近い順に並べ替えて返す。
    static func sortedByDistance(_ spots: [NearbySpot], from origin: CLLocationCoordinate2D) -> [NearbySpot] {
        let originLocation = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        return spots
            .map { spot -> NearbySpot in
                var copy = spot
                let spotLocation = CLLocation(latitude: spot.coordinate.latitude, longitude: spot.coordinate.longitude)
                copy.distanceMeters = originLocation.distance(from: spotLocation)
                return copy
            }
            .sorted { ($0.distanceMeters ?? .greatestFiniteMagnitude) < ($1.distanceMeters ?? .greatestFiniteMagnitude) }
    }
}

// MARK: - 距離の表示整形

extension CLLocationDistance {
    /// 距離を「1.2 km」「850 m」のような表示にする。
    var nearbyDisplayString: String {
        if self >= 1000 {
            let km = self / 1000
            return String(format: NSLocalizedString("nearby.distance.km", comment: ""), km)
        } else {
            return String(format: NSLocalizedString("nearby.distance.m", comment: ""), self)
        }
    }
}
