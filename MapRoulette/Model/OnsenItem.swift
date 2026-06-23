//
//  OnsenItem.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/26.
//

import Foundation
import SwiftUI
import CoreLocation

// MARK: - OnsenType
enum OnsenType: String, CaseIterable {
    case scenic
    case historical
    case therapeutic
    case resort
    case mountain
    case seaside
    case ski
    
    var localizedName: String {
        NSLocalizedString("onsen_type.\(self.rawValue)", comment: "")
    }

    /// カード上のタグ表示用の短縮名。英語で "Scenic Hot Spring" のような長い名称が
    /// 半分幅のカードで省略されるのを避けるため、温泉セクション内では "Scenic" のように短くする。
    /// （フィルター・詳細・地図・設定では localizedName をそのまま使う）
    var tagName: String {
        NSLocalizedString("onsen_type_tag.\(self.rawValue)", comment: "")
    }

    /// 温泉タイプ色。白文字を載せても読めるよう明度・彩度を手調整した値に統一。
    /// （システム色の .cyan / .mint / .orange などは明るすぎて白文字が破綻するため使わない）
    var color: Color {
        switch self {
        case .scenic:      return Color(red: 0.16, green: 0.50, blue: 0.85) // ブルー
        case .historical:  return Color(red: 0.60, green: 0.42, blue: 0.28) // ブラウン
        case .therapeutic: return Color(red: 0.24, green: 0.62, blue: 0.40) // グリーン
        case .resort:      return Color(red: 0.55, green: 0.38, blue: 0.78) // パープル
        case .mountain:    return Color(red: 0.85, green: 0.45, blue: 0.20) // オレンジ
        case .seaside:     return Color(red: 0.13, green: 0.58, blue: 0.66) // ティール
        case .ski:         return Color(red: 0.22, green: 0.64, blue: 0.58) // ミント系
        }
    }
    
    var icon: String {
        switch self {
        case .scenic: return "mountain.2.fill"
        case .historical: return "building.columns.fill"
        case .therapeutic: return "heart.fill"
        case .resort: return "star.fill"
        case .mountain: return "tree.fill"
        case .seaside: return "water.waves"
        case .ski: return "snow"
        }
    }
}

// MARK: - OnsenItem
struct OnsenItem: Identifiable {
    let id = UUID()
    let nameKey: String       // ex: "onsen.noboribetsu"
    let descriptionKey: String // ex: "onsen.noboribetsu.desc"
    let imageSymbol: String
    let onsenType: OnsenType
    let popularity: Int // 1-5
    
    var name: String {
        NSLocalizedString(nameKey, comment: "")
    }

    var description: String {
        NSLocalizedString(descriptionKey, comment: "")
    }

    /// 温泉地の位置情報。nameKey を元に OnsenCoordinates から解決する。
    var coordinate: CLLocationCoordinate2D? {
        OnsenCoordinates.byNameKey[nameKey]
    }
}

// MARK: - Onsen Coordinates (Model層の単一の真実の源)
// 温泉地の座標データ。旅行プラン機能・地図表示の双方がここを参照する。
enum OnsenCoordinates {
    /// nameKey（例: "onsen.noboribetsu"）→ 座標
    static let byNameKey: [String: CLLocationCoordinate2D] = [
        // 北海道
        "onsen.noboribetsu": CLLocationCoordinate2D(latitude: 42.4919, longitude: 141.1539),
        "onsen.toyako": CLLocationCoordinate2D(latitude: 42.5968, longitude: 140.7524),
        "onsen.jozankei": CLLocationCoordinate2D(latitude: 42.9621, longitude: 141.1621),
        "onsen.yunokawa": CLLocationCoordinate2D(latitude: 41.7774, longitude: 140.7886),

        // 東北
        "onsen.nyuto": CLLocationCoordinate2D(latitude: 39.7372, longitude: 140.7372),
        "onsen.ginzan": CLLocationCoordinate2D(latitude: 38.5398, longitude: 140.5098),
        "onsen.zao": CLLocationCoordinate2D(latitude: 38.1495, longitude: 140.4495),
        "onsen.hanamaki": CLLocationCoordinate2D(latitude: 39.3778, longitude: 141.1048),
        "onsen.naruko": CLLocationCoordinate2D(latitude: 38.7299, longitude: 140.7299),
        "onsen.iizaka": CLLocationCoordinate2D(latitude: 37.8267, longitude: 140.4267),

        // 関東
        "onsen.hakone": CLLocationCoordinate2D(latitude: 35.2043, longitude: 139.0235),
        "onsen.kusatsu": CLLocationCoordinate2D(latitude: 36.6228, longitude: 138.5989),
        "onsen.ikaho": CLLocationCoordinate2D(latitude: 36.4895, longitude: 138.9095),
        "onsen.atami": CLLocationCoordinate2D(latitude: 35.1042, longitude: 139.0731),
        "onsen.shuzenji": CLLocationCoordinate2D(latitude: 34.9679, longitude: 138.9279),
        "onsen.atagawa": CLLocationCoordinate2D(latitude: 34.8164, longitude: 139.0764),
        "onsen.isawa": CLLocationCoordinate2D(latitude: 35.6536, longitude: 138.6336),

        // 中部
        "onsen.nozawa": CLLocationCoordinate2D(latitude: 36.9144, longitude: 138.4444),
        "onsen.kamisuwa": CLLocationCoordinate2D(latitude: 36.0461, longitude: 138.1161),
        "onsen.gero": CLLocationCoordinate2D(latitude: 35.8080, longitude: 137.2480),
        "onsen.unazuki": CLLocationCoordinate2D(latitude: 36.8033, longitude: 137.5833),

        // 北陸
        "onsen.yamanaka": CLLocationCoordinate2D(latitude: 36.2889, longitude: 136.3689),
        "onsen.wakura": CLLocationCoordinate2D(latitude: 37.1169, longitude: 136.9269),
        "onsen.yamashiro": CLLocationCoordinate2D(latitude: 36.2981, longitude: 136.3681),
        "onsen.katayamazu": CLLocationCoordinate2D(latitude: 36.3200, longitude: 136.3500),

        // 関西
        "onsen.arima": CLLocationCoordinate2D(latitude: 34.7974, longitude: 135.2574),
        "onsen.kinosaki": CLLocationCoordinate2D(latitude: 35.6076, longitude: 134.8076),
        "onsen.yumura": CLLocationCoordinate2D(latitude: 35.4883, longitude: 134.6183),
        "onsen.shirahama": CLLocationCoordinate2D(latitude: 33.6886, longitude: 135.3386),
        "onsen.katsuura": CLLocationCoordinate2D(latitude: 33.6767, longitude: 135.8867),

        // 中国
        "onsen.misasa": CLLocationCoordinate2D(latitude: 35.4036, longitude: 133.8936),
        "onsen.tamatsukuri": CLLocationCoordinate2D(latitude: 35.4230, longitude: 132.8730),

        // 四国
        "onsen.dogo": CLLocationCoordinate2D(latitude: 33.8518, longitude: 132.7818),

        // 九州
        "onsen.beppu": CLLocationCoordinate2D(latitude: 33.2695, longitude: 131.4895),
        "onsen.yufuin": CLLocationCoordinate2D(latitude: 33.2667, longitude: 131.3567),
        "onsen.ibusuki": CLLocationCoordinate2D(latitude: 31.2513, longitude: 130.6413),
        "onsen.kurokawa": CLLocationCoordinate2D(latitude: 33.0600, longitude: 131.1000),
        "onsen.unzen": CLLocationCoordinate2D(latitude: 32.7600, longitude: 130.2900),
        "onsen.ureshino": CLLocationCoordinate2D(latitude: 33.1056, longitude: 129.9956),
        "onsen.takeo": CLLocationCoordinate2D(latitude: 33.1936, longitude: 129.9936)
    ]
}

// MARK: - Prefecture Extension
extension Prefecture {
    var onsenItems: [OnsenItem] {
        switch self {
        case .hokkaido:
            return [
                OnsenItem(nameKey: "onsen.noboribetsu", descriptionKey: "onsen.noboribetsu.desc", imageSymbol: "flame.fill", onsenType: .therapeutic, popularity: 5),
                OnsenItem(nameKey: "onsen.toyako", descriptionKey: "onsen.toyako.desc", imageSymbol: "lake.fill", onsenType: .scenic, popularity: 4),
                OnsenItem(nameKey: "onsen.jozankei", descriptionKey: "onsen.jozankei.desc", imageSymbol: "tree.fill", onsenType: .mountain, popularity: 4),
                OnsenItem(nameKey: "onsen.yunokawa", descriptionKey: "onsen.yunokawa.desc", imageSymbol: "building.2.fill", onsenType: .resort, popularity: 3)
            ]
        case .akita:
            return [
                OnsenItem(nameKey: "onsen.nyuto", descriptionKey: "onsen.nyuto.desc", imageSymbol: "tree.fill", onsenType: .mountain, popularity: 5)
            ]
        case .yamagata:
            return [
                OnsenItem(nameKey: "onsen.ginzan", descriptionKey: "onsen.ginzan.desc", imageSymbol: "building.columns.fill", onsenType: .historical, popularity: 5),
                OnsenItem(nameKey: "onsen.zao", descriptionKey: "onsen.zao.desc", imageSymbol: "snow", onsenType: .ski, popularity: 4)
            ]
        case .iwate:
            return [
                OnsenItem(nameKey: "onsen.hanamaki", descriptionKey: "onsen.hanamaki.desc", imageSymbol: "book.fill", onsenType: .historical, popularity: 3)
            ]
        case .miyagi:
            return [
                OnsenItem(nameKey: "onsen.naruko", descriptionKey: "onsen.naruko.desc", imageSymbol: "leaf.fill", onsenType: .scenic, popularity: 4)
            ]
        case .fukushima:
            return [
                OnsenItem(nameKey: "onsen.iizaka", descriptionKey: "onsen.iizaka.desc", imageSymbol: "building.columns.fill", onsenType: .historical, popularity: 3)
            ]
        case .kanagawa:
            return [
                OnsenItem(nameKey: "onsen.hakone", descriptionKey: "onsen.hakone.desc", imageSymbol: "mountain.2.fill", onsenType: .scenic, popularity: 5)
            ]
        case .gunma:
            return [
                OnsenItem(nameKey: "onsen.kusatsu", descriptionKey: "onsen.kusatsu.desc", imageSymbol: "heart.fill", onsenType: .therapeutic, popularity: 5),
                OnsenItem(nameKey: "onsen.ikaho", descriptionKey: "onsen.ikaho.desc", imageSymbol: "building.columns.fill", onsenType: .historical, popularity: 4)
            ]
        case .shizuoka:
            return [
                OnsenItem(nameKey: "onsen.atami", descriptionKey: "onsen.atami.desc", imageSymbol: "water.waves", onsenType: .seaside, popularity: 4),
                OnsenItem(nameKey: "onsen.shuzenji", descriptionKey: "onsen.shuzenji.desc", imageSymbol: "book.fill", onsenType: .historical, popularity: 3),
                OnsenItem(nameKey: "onsen.atagawa", descriptionKey: "onsen.atagawa.desc", imageSymbol: "water.waves", onsenType: .seaside, popularity: 3)
            ]
        case .yamanashi:
            return [
                OnsenItem(nameKey: "onsen.isawa", descriptionKey: "onsen.isawa.desc", imageSymbol: "grapes.fill", onsenType: .resort, popularity: 3)
            ]
        case .nagano:
            return [
                OnsenItem(nameKey: "onsen.nozawa", descriptionKey: "onsen.nozawa.desc", imageSymbol: "snow", onsenType: .ski, popularity: 4),
                OnsenItem(nameKey: "onsen.kamisuwa", descriptionKey: "onsen.kamisuwa.desc", imageSymbol: "lake.fill", onsenType: .scenic, popularity: 3)
            ]
        case .gifu:
            return [
                OnsenItem(nameKey: "onsen.gero", descriptionKey: "onsen.gero.desc", imageSymbol: "sparkles", onsenType: .therapeutic, popularity: 5)
            ]
        case .ishikawa:
            return [
                OnsenItem(nameKey: "onsen.yamanaka", descriptionKey: "onsen.yamanaka.desc", imageSymbol: "book.fill", onsenType: .historical, popularity: 4),
                OnsenItem(nameKey: "onsen.wakura", descriptionKey: "onsen.wakura.desc", imageSymbol: "water.waves", onsenType: .seaside, popularity: 4),
                OnsenItem(nameKey: "onsen.yamashiro", descriptionKey: "onsen.yamashiro.desc", imageSymbol: "building.2.fill", onsenType: .resort, popularity: 3),
                OnsenItem(nameKey: "onsen.katayamazu", descriptionKey: "onsen.katayamazu.desc", imageSymbol: "lake.fill", onsenType: .scenic, popularity: 3)
            ]
        case .toyama:
            return [
                OnsenItem(nameKey: "onsen.unazuki", descriptionKey: "onsen.unazuki.desc", imageSymbol: "mountain.2.fill", onsenType: .scenic, popularity: 4)
            ]
        case .hyogo:
            return [
                OnsenItem(nameKey: "onsen.arima", descriptionKey: "onsen.arima.desc", imageSymbol: "building.columns.fill", onsenType: .historical, popularity: 5),
                OnsenItem(nameKey: "onsen.kinosaki", descriptionKey: "onsen.kinosaki.desc", imageSymbol: "building.columns.fill", onsenType: .historical, popularity: 4),
                OnsenItem(nameKey: "onsen.yumura", descriptionKey: "onsen.yumura.desc", imageSymbol: "building.columns.fill", onsenType: .historical, popularity: 3)
            ]
        case .wakayama:
            return [
                OnsenItem(nameKey: "onsen.shirahama", descriptionKey: "onsen.shirahama.desc", imageSymbol: "water.waves", onsenType: .seaside, popularity: 4),
                OnsenItem(nameKey: "onsen.katsuura", descriptionKey: "onsen.katsuura.desc", imageSymbol: "cave.fill", onsenType: .seaside, popularity: 3)
            ]
        case .tottori:
            return [
                OnsenItem(nameKey: "onsen.misasa", descriptionKey: "onsen.misasa.desc", imageSymbol: "heart.fill", onsenType: .therapeutic, popularity: 4)
            ]
        case .shimane:
            return [
                OnsenItem(nameKey: "onsen.tamatsukuri", descriptionKey: "onsen.tamatsukuri.desc", imageSymbol: "sparkles", onsenType: .therapeutic, popularity: 4)
            ]
        case .ehime:
            return [
                OnsenItem(nameKey: "onsen.dogo", descriptionKey: "onsen.dogo.desc", imageSymbol: "building.columns.fill", onsenType: .historical, popularity: 5)
            ]
        case .oita:
            return [
                OnsenItem(nameKey: "onsen.beppu", descriptionKey: "onsen.beppu.desc", imageSymbol: "flame.fill", onsenType: .therapeutic, popularity: 5),
                OnsenItem(nameKey: "onsen.yufuin", descriptionKey: "onsen.yufuin.desc", imageSymbol: "mountain.2.fill", onsenType: .resort, popularity: 5)
            ]
        case .kagoshima:
            return [
                OnsenItem(nameKey: "onsen.ibusuki", descriptionKey: "onsen.ibusuki.desc", imageSymbol: "thermometer.sun.fill", onsenType: .resort, popularity: 4)
            ]
        case .kumamoto:
            return [
                OnsenItem(nameKey: "onsen.kurokawa", descriptionKey: "onsen.kurokawa.desc", imageSymbol: "tree.fill", onsenType: .mountain, popularity: 5)
            ]
        case .nagasaki:
            return [
                OnsenItem(nameKey: "onsen.unzen", descriptionKey: "onsen.unzen.desc", imageSymbol: "mountain.2.fill", onsenType: .mountain, popularity: 4)
            ]
        case .saga:
            return [
                OnsenItem(nameKey: "onsen.ureshino", descriptionKey: "onsen.ureshino.desc", imageSymbol: "sparkles", onsenType: .therapeutic, popularity: 3),
                OnsenItem(nameKey: "onsen.takeo", descriptionKey: "onsen.takeo.desc", imageSymbol: "building.columns.fill", onsenType: .historical, popularity: 3)
            ]
        default:
            return []
        }
    }
}
