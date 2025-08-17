//
//  OnsenItem.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/26.
//

import Foundation
import SwiftUI

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
    
    var color: Color {
        switch self {
        case .scenic: return .blue
        case .historical: return .brown
        case .therapeutic: return .green
        case .resort: return .purple
        case .mountain: return .orange
        case .seaside: return .cyan
        case .ski: return .mint
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
