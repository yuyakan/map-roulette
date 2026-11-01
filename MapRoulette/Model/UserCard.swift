//
//  UserCard.swift
//  MapRoulette
//
//  ユーザーが県詳細の各セクションへ自分で追加するカードのデータモデル。
//  名前・説明・表紙写真・URL・位置だけを持ち、どのセクションでも同じ形で扱う。
//

import SwiftUI
import UIKit
import CoreLocation

// MARK: - UserCardKind
/// カードを追加するセクションの種類。
enum UserCardKind: String, Codable, CaseIterable {
    case attraction
    case gourmet
    case cafe
    case souvenir
    case onsen
    case nature
    case festival
    case otherFestival

    /// プランへ追加したときの項目種別。
    var planCategory: PlanItemCategory {
        switch self {
        case .attraction:               return .attraction
        case .gourmet, .cafe:           return .gourmet
        case .souvenir:                 return .souvenir
        case .onsen:                    return .onsen
        case .nature:                   return .nature
        case .festival, .otherFestival: return .festival
        }
    }

    /// セクション見出しと揃えたアイコン。
    var icon: String {
        switch self {
        case .attraction:    return "location.circle.fill"
        case .gourmet:       return "fork.knife"
        case .cafe:          return "cup.and.saucer.fill"
        case .souvenir:      return "gift.fill"
        case .onsen:         return "thermometer.sun.fill"
        case .nature:        return "leaf.fill"
        case .festival:      return "party.popper.fill"
        case .otherFestival: return "snowflake"
        }
    }

    /// セクション見出しと揃えた基調色。
    var accent: Color {
        switch self {
        case .attraction, .cafe: return PlanTheme.primary
        case .gourmet:           return Color(red: 0.93, green: 0.45, blue: 0.13)
        case .souvenir:          return Color(red: 0.86, green: 0.35, blue: 0.58)
        case .onsen:             return Color(red: 0.13, green: 0.58, blue: 0.66)
        case .nature:            return Color(red: 0.20, green: 0.55, blue: 0.36)
        case .festival:          return Color(red: 0.55, green: 0.38, blue: 0.78)
        case .otherFestival:     return Color(red: 0.16, green: 0.50, blue: 0.85)
        }
    }

    /// 食べログ検索を出す種類か（店を探す対象のみ）。
    var isRestaurant: Bool {
        self == .gourmet || self == .cafe
    }
}

// MARK: - UserCard
/// ユーザーが作成した 1 枚のカード。
struct UserCard: Identifiable, Codable, Hashable {
    let id: UUID
    var prefectureRawValue: String   // Prefecture.rawValue
    let kind: UserCardKind
    var name: String
    var description: String
    var urlString: String?
    var photoFileName: String?       // 表紙写真（UserCardStore が保存）のファイル名
    var latitude: Double?            // 任意の位置（地図ピン）
    var longitude: Double?
    // 検索で選んだ地点名。ピンを動かすと nil になる（LocationPickerView の仕様）。
    var placeName: String?
    // 住所（検索選択時は placemark.title、ピン手動移動時は逆ジオコーディング結果）。表示用。
    var address: String?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        prefecture: Prefecture,
        kind: UserCardKind,
        name: String,
        description: String = "",
        urlString: String? = nil,
        photoFileName: String? = nil,
        coordinate: CLLocationCoordinate2D? = nil,
        placeName: String? = nil,
        address: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.prefectureRawValue = prefecture.rawValue
        self.kind = kind
        self.name = name
        self.description = description
        self.urlString = urlString
        self.photoFileName = photoFileName
        self.latitude = coordinate?.latitude
        self.longitude = coordinate?.longitude
        self.placeName = placeName
        self.address = address
        self.createdAt = createdAt
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var url: URL? {
        urlString.flatMap(Self.normalizedURL)
    }

    /// 入力された文字列を、開ける Web の URL にする。
    /// スキームを省いた入力（example.com）は https を補う。http(s) 以外は開かせない。
    static func normalizedURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains(" ") else { return nil }
        let withScheme = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard let url = URL(string: withScheme),
              let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https",
              let host = url.host, host.contains(".") else { return nil }
        return url
    }

    /// 観光地リストに並べるための変換。位置が無いカードは地図に出さないので、
    /// 座標は渡された既定値（県の中心）で埋める。
    func attractionItem(fallback: CLLocationCoordinate2D) -> LocalizedAttractionLocation {
        LocalizedAttractionLocation(nameKey: name, descriptionKey: description, coordinate: coordinate ?? fallback)
    }
}
