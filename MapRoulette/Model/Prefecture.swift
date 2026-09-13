//
//  Prefecture.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/19.
//

import SwiftUI
import MapKit

// 都道府県の形状を描画するShape
struct PrefectureShape: Shape {
    let points: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !points.isEmpty else { return path }
        
        // 最初の点に移動
        path.move(to: points[0])
        
        // 残りの点に線を引く
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        // パスを閉じる
        path.closeSubpath()
        
        return path
    }
}
public enum Prefecture: String, CaseIterable, Identifiable {
    public var id: String { rawValue }

    case hokkaido, aomori, iwate, akita, miyagi, yamagata, fukushima
    case ibaraki, chiba, tochigi, gunma, saitama, tokyo, kanagawa
    case niigata, nagano, yamanashi, shizuoka, aichi, mie, gifu
    case fukui, ishikawa, toyama, shiga, kyoto, hyogo, nara, wakayama, osaka
    case tottori, okayama, hiroshima, yamaguchi, shimane
    case kagawa, tokushima, kochi, ehime
    case fukuoka, oita, miyazaki, kagoshima, kumamoto, saga, nagasaki
    case okinawa
    
    var prefectureName: String {
        return NSLocalizedString("prefecture.\(self.rawValue)", comment: "Prefecture name")
    }
    
    /// 地方の分類キー（集計・グループ化用。ローカライズ前の安定した識別子）。
    var regionKey: String {
        switch self {
        case .hokkaido:
            return "hokkaido"
        case .aomori, .iwate, .akita, .miyagi, .yamagata, .fukushima:
            return "tohoku"
        case .ibaraki, .chiba, .tochigi, .gunma, .saitama, .tokyo, .kanagawa:
            return "kanto"
        case .niigata, .nagano, .yamanashi:
            return "koshinetsu"
        case .shizuoka, .aichi, .mie, .gifu:
            return "tokai"
        case .fukui, .ishikawa, .toyama:
            return "hokuriku"
        case .shiga, .kyoto, .hyogo, .nara, .wakayama, .osaka:
            return "kinki"
        case .tottori, .okayama, .hiroshima, .yamaguchi, .shimane:
            return "chugoku"
        case .kagawa, .tokushima, .kochi, .ehime:
            return "shikoku"
        case .fukuoka, .oita, .miyazaki, .kagoshima, .kumamoto, .saga, .nagasaki:
            return "kyushu"
        case .okinawa:
            return "okinawa"
        }
    }

    var region: String {
        return NSLocalizedString("region.\(regionKey)", comment: "Region name")
    }

    /// 検索用の平仮名読み（都道府県の「都・道・府・県」を除いた本体の読み）。
    /// 例: 東京 → "とうきょう" / 北海道 → "ほっかいどう"。
    /// 漢字表記だけでなく、平仮名入力でも県を絞り込めるようにするために使う。
    var hiraganaReading: String {
        switch self {
        case .hokkaido:  return "ほっかいどう"
        case .aomori:    return "あおもり"
        case .iwate:     return "いわて"
        case .akita:     return "あきた"
        case .miyagi:    return "みやぎ"
        case .yamagata:  return "やまがた"
        case .fukushima: return "ふくしま"
        case .ibaraki:   return "いばらき"
        case .chiba:     return "ちば"
        case .tochigi:   return "とちぎ"
        case .gunma:     return "ぐんま"
        case .saitama:   return "さいたま"
        case .tokyo:     return "とうきょう"
        case .kanagawa:  return "かながわ"
        case .niigata:   return "にいがた"
        case .nagano:    return "ながの"
        case .yamanashi: return "やまなし"
        case .shizuoka:  return "しずおか"
        case .aichi:     return "あいち"
        case .mie:       return "みえ"
        case .gifu:      return "ぎふ"
        case .fukui:     return "ふくい"
        case .ishikawa:  return "いしかわ"
        case .toyama:    return "とやま"
        case .shiga:     return "しが"
        case .kyoto:     return "きょうと"
        case .hyogo:     return "ひょうご"
        case .nara:      return "なら"
        case .wakayama:  return "わかやま"
        case .osaka:     return "おおさか"
        case .tottori:   return "とっとり"
        case .okayama:   return "おかやま"
        case .hiroshima: return "ひろしま"
        case .yamaguchi: return "やまぐち"
        case .shimane:   return "しまね"
        case .kagawa:    return "かがわ"
        case .tokushima: return "とくしま"
        case .kochi:     return "こうち"
        case .ehime:     return "えひめ"
        case .fukuoka:   return "ふくおか"
        case .oita:      return "おおいた"
        case .miyazaki:  return "みやざき"
        case .kagoshima: return "かごしま"
        case .kumamoto:  return "くまもと"
        case .saga:      return "さが"
        case .nagasaki:  return "ながさき"
        case .okinawa:   return "おきなわ"
        }
    }

    /// 検索でヒット判定に使う文字列群（表示名・平仮名読み・ローマ字）。
    /// rawValue はもともとローマ字（例: "kanagawa"）なので、そのまま英字入力にも対応する。
    var searchKeywords: [String] {
        [prefectureName, hiraganaReading, rawValue]
    }
}

/// 地方（都道府県を束ねる単位）。訪問済みマップの地方別集計に使う。
/// 並び順は北から南（地図・リストの見た目に合わせる）。
/// ※ OnsenMapView の `Region`（8 分類・粗い）とは粒度が違うため別型にしている。
enum JapanRegion: String, CaseIterable {
    case hokkaido, tohoku, kanto, koshinetsu, hokuriku, tokai, kinki, chugoku, shikoku, kyushu, okinawa

    /// ローカライズ済みの地方名（既存の region.* キーを再利用）。
    var localizedName: String {
        NSLocalizedString("region.\(rawValue)", comment: "Region name")
    }

    /// この地方に属する都道府県（Prefecture.allCases の登場順を保つ）。
    var prefectures: [Prefecture] {
        Prefecture.allCases.filter { $0.regionKey == rawValue }
    }
}

// 都道府県の座標データを含むextension（完全版）
extension Prefecture {
    var points: [CGPoint] {
        switch self {
        case .hokkaido:
            return [
                CGPoint(x: 382, y: 8), CGPoint(x: 390, y: 15), CGPoint(x: 398, y: 25),
                CGPoint(x: 406, y: 35), CGPoint(x: 414, y: 45), CGPoint(x: 425, y: 52),
                CGPoint(x: 437, y: 58), CGPoint(x: 450, y: 64), CGPoint(x: 458, y: 57),
                CGPoint(x: 466, y: 51), CGPoint(x: 464, y: 60), CGPoint(x: 461, y: 69),
                CGPoint(x: 463, y: 76), CGPoint(x: 466, y: 83), CGPoint(x: 472, y: 82),
                CGPoint(x: 479, y: 81), CGPoint(x: 475, y: 88), CGPoint(x: 465, y: 92),
                CGPoint(x: 450, y: 96), CGPoint(x: 442, y: 96), CGPoint(x: 434, y: 96),
                CGPoint(x: 426, y: 104), CGPoint(x: 419, y: 112), CGPoint(x: 416, y: 121),
                CGPoint(x: 413, y: 131), CGPoint(x: 394, y: 118), CGPoint(x: 384, y: 111),
                CGPoint(x: 374, y: 105), CGPoint(x: 365, y: 111), CGPoint(x: 356, y: 117),
                CGPoint(x: 352, y: 110), CGPoint(x: 348, y: 104), CGPoint(x: 348, y: 107),
                CGPoint(x: 343, y: 113), CGPoint(x: 338, y: 119), CGPoint(x: 341, y: 120),
                CGPoint(x: 345, y: 121), CGPoint(x: 352, y: 127), CGPoint(x: 360, y: 134),
                CGPoint(x: 358, y: 136), CGPoint(x: 356, y: 139), CGPoint(x: 353, y: 137),
                CGPoint(x: 350, y: 136), CGPoint(x: 348, y: 138), CGPoint(x: 346, y: 140),
                CGPoint(x: 340, y: 144), CGPoint(x: 334, y: 149), CGPoint(x: 335, y: 138),
                CGPoint(x: 336, y: 127), CGPoint(x: 331, y: 123), CGPoint(x: 327, y: 119),
                CGPoint(x: 329, y: 112), CGPoint(x: 331, y: 106), CGPoint(x: 338, y: 100),
                CGPoint(x: 345, y: 95), CGPoint(x: 343, y: 89), CGPoint(x: 342, y: 83),
                CGPoint(x: 344, y: 82), CGPoint(x: 347, y: 81), CGPoint(x: 358, y: 83),
                CGPoint(x: 369, y: 85), CGPoint(x: 367, y: 76), CGPoint(x: 365, y: 68),
                CGPoint(x: 368, y: 61), CGPoint(x: 372, y: 55), CGPoint(x: 375, y: 45),
                CGPoint(x: 378, y: 36), CGPoint(x: 375, y: 24), CGPoint(x: 372, y: 13),
                CGPoint(x: 375, y: 13), CGPoint(x: 378, y: 14)
            ]
        case .aomori:
            return [
                CGPoint(x: 356, y: 145), CGPoint(x: 362, y: 151), CGPoint(x: 371, y: 150),
                CGPoint(x: 369, y: 172), CGPoint(x: 373, y: 179), CGPoint(x: 357, y: 184),
                CGPoint(x: 358, y: 182), CGPoint(x: 352, y: 178), CGPoint(x: 345, y: 181),
                CGPoint(x: 332, y: 180), CGPoint(x: 331, y: 172), CGPoint(x: 339, y: 168),
                CGPoint(x: 341, y: 154), CGPoint(x: 344, y: 155), CGPoint(x: 349, y: 154),
                CGPoint(x: 351, y: 168), CGPoint(x: 353, y: 165), CGPoint(x: 355, y: 162),
                CGPoint(x: 362, y: 166), CGPoint(x: 363, y: 153), CGPoint(x: 352, y: 156)
            ]
        case .iwate:
            return [
               CGPoint(x: 357, y: 184), CGPoint(x: 373, y: 179), CGPoint(x: 379, y: 184),
               CGPoint(x: 384, y: 206), CGPoint(x: 378, y: 225), CGPoint(x: 374, y: 230),
               CGPoint(x: 370, y: 232), CGPoint(x: 364, y: 232), CGPoint(x: 360, y: 231),
               CGPoint(x: 353, y: 231), CGPoint(x: 349, y: 214), CGPoint(x: 353, y: 200)
           ]
        case .akita:
            return [
                CGPoint(x: 332, y: 180), CGPoint(x: 345, y: 181), CGPoint(x: 352, y: 178),
                CGPoint(x: 358, y: 182), CGPoint(x: 357, y: 184), CGPoint(x: 353, y: 200),
                CGPoint(x: 349, y: 214), CGPoint(x: 353, y: 231), CGPoint(x: 346, y: 231),
                CGPoint(x: 341, y: 225), CGPoint(x: 328, y: 225), CGPoint(x: 334, y: 207),
                CGPoint(x: 332, y: 198), CGPoint(x: 325, y: 200), CGPoint(x: 323, y: 196),
                CGPoint(x: 329, y: 193)
            ]
        case .miyagi:
           return [
               CGPoint(x: 374, y: 232), CGPoint(x: 368, y: 236), CGPoint(x: 369, y: 251),
               CGPoint(x: 363, y: 247), CGPoint(x: 359, y: 249), CGPoint(x: 356, y: 253),
               CGPoint(x: 356, y: 263), CGPoint(x: 351, y: 267), CGPoint(x: 340, y: 261),
               CGPoint(x: 340, y: 258), CGPoint(x: 346, y: 249), CGPoint(x: 346, y: 239),
               CGPoint(x: 348, y: 235), CGPoint(x: 346, y: 231), CGPoint(x: 360, y: 231),
               CGPoint(x: 364, y: 232)
           ]
        case .yamagata:
            return [
                CGPoint(x: 328, y: 225), CGPoint(x: 341, y: 225), CGPoint(x: 346, y: 231),
                CGPoint(x: 348, y: 235), CGPoint(x: 346, y: 239), CGPoint(x: 346, y: 249),
                CGPoint(x: 340, y: 258), CGPoint(x: 340, y: 261), CGPoint(x: 338, y: 267),
                CGPoint(x: 329, y: 266), CGPoint(x: 326, y: 266), CGPoint(x: 325, y: 261),
                CGPoint(x: 328, y: 249), CGPoint(x: 322, y: 242), CGPoint(x: 328, y: 230)
            ]
        case .fukushima:
            return [
                CGPoint(x: 356, y: 263), CGPoint(x: 358, y: 273), CGPoint(x: 355, y: 292),
                CGPoint(x: 347, y: 296), CGPoint(x: 346, y: 297), CGPoint(x: 340, y: 296),
                CGPoint(x: 337, y: 294), CGPoint(x: 337, y: 290), CGPoint(x: 329, y: 286),
                CGPoint(x: 321, y: 292), CGPoint(x: 313, y: 292), CGPoint(x: 312, y: 277),
                CGPoint(x: 321, y: 275), CGPoint(x: 326, y: 266), CGPoint(x: 329, y: 266),
                CGPoint(x: 338, y: 267), CGPoint(x: 340, y: 261), CGPoint(x: 351, y: 267)
            ]
        case .ibaraki:
            return [
                CGPoint(x: 340, y: 296), CGPoint(x: 346, y: 297), CGPoint(x: 347, y: 296),
                CGPoint(x: 355, y: 292), CGPoint(x: 345, y: 315), CGPoint(x: 353, y: 331),
                CGPoint(x: 344, y: 325), CGPoint(x: 338, y: 327), CGPoint(x: 326, y: 320),
                CGPoint(x: 323, y: 317), CGPoint(x: 329, y: 312), CGPoint(x: 338, y: 308)
            ]
        case .chiba:
            return [
                CGPoint(x: 326, y: 320), CGPoint(x: 338, y: 327), CGPoint(x: 344, y: 325),
                CGPoint(x: 353, y: 331), CGPoint(x: 343, y: 335), CGPoint(x: 343, y: 347),
                CGPoint(x: 327, y: 355), CGPoint(x: 327, y: 343), CGPoint(x: 334, y: 338),
                CGPoint(x: 333, y: 333), CGPoint(x: 329, y: 334), CGPoint(x: 328, y: 327)
            ]
        case .tochigi:
            return [
                CGPoint(x: 321, y: 292), CGPoint(x: 329, y: 286), CGPoint(x: 337, y: 290),
                CGPoint(x: 337, y: 294), CGPoint(x: 340, y: 296), CGPoint(x: 338, y: 308),
                CGPoint(x: 329, y: 312), CGPoint(x: 323, y: 317), CGPoint(x: 321, y: 317),
                CGPoint(x: 317, y: 311), CGPoint(x: 318, y: 304), CGPoint(x: 314, y: 302)
            ]
        case .gunma:
            return [
                CGPoint(x: 300, y: 321), CGPoint(x: 297, y: 319), CGPoint(x: 298, y: 309),
                CGPoint(x: 292, y: 306), CGPoint(x: 303, y: 297), CGPoint(x: 308, y: 291),
                CGPoint(x: 313, y: 292), CGPoint(x: 321, y: 292), CGPoint(x: 314, y: 302),
                CGPoint(x: 318, y: 304), CGPoint(x: 317, y: 311), CGPoint(x: 321, y: 317),
                CGPoint(x: 311, y: 313), CGPoint(x: 308, y: 317)
            ]
        case .saitama:
            return [
                CGPoint(x: 300, y: 321), CGPoint(x: 308, y: 317), CGPoint(x: 311, y: 313),
                CGPoint(x: 321, y: 317), CGPoint(x: 323, y: 317), CGPoint(x: 326, y: 320),
                CGPoint(x: 328, y: 327), CGPoint(x: 317, y: 329), CGPoint(x: 310, y: 326),
                CGPoint(x: 306, y: 327), CGPoint(x: 297, y: 323)
            ]
        case .tokyo:
            return [
                CGPoint(x: 306, y: 327), CGPoint(x: 310, y: 326), CGPoint(x: 317, y: 329),
                CGPoint(x: 328, y: 327), CGPoint(x: 329, y: 334), CGPoint(x: 327, y: 335),
                CGPoint(x: 320, y: 334), CGPoint(x: 320, y: 335), CGPoint(x: 312, y: 332)
            ]
        case .kanagawa:
            return [
                CGPoint(x: 312, y: 332), CGPoint(x: 320, y: 335), CGPoint(x: 320, y: 334),
                CGPoint(x: 327, y: 335), CGPoint(x: 324, y: 342), CGPoint(x: 326, y: 346),
                CGPoint(x: 322, y: 349), CGPoint(x: 321, y: 345), CGPoint(x: 312, y: 345),
                CGPoint(x: 308, y: 350), CGPoint(x: 308, y: 343), CGPoint(x: 305, y: 341),
                CGPoint(x: 310, y: 334)
            ]
        case .niigata:
            return [
                CGPoint(x: 322, y: 242), CGPoint(x: 328, y: 249), CGPoint(x: 325, y: 261),
                CGPoint(x: 326, y: 266), CGPoint(x: 321, y: 275), CGPoint(x: 312, y: 277),
                CGPoint(x: 313, y: 292), CGPoint(x: 308, y: 291), CGPoint(x: 303, y: 297),
                CGPoint(x: 292, y: 306), CGPoint(x: 295, y: 292), CGPoint(x: 285, y: 296),
                CGPoint(x: 280, y: 294), CGPoint(x: 276, y: 297), CGPoint(x: 274, y: 291),
                CGPoint(x: 292, y: 282), CGPoint(x: 302, y: 266), CGPoint(x: 313, y: 259)
            ]
        case .nagano:
            return [
                CGPoint(x: 273, y: 309), CGPoint(x: 276, y: 297), CGPoint(x: 280, y: 294),
                CGPoint(x: 285, y: 296), CGPoint(x: 295, y: 292), CGPoint(x: 292, y: 306),
                CGPoint(x: 298, y: 309), CGPoint(x: 297, y: 319), CGPoint(x: 300, y: 321),
                CGPoint(x: 297, y: 323), CGPoint(x: 292, y: 324), CGPoint(x: 288, y: 326),
                CGPoint(x: 288, y: 336), CGPoint(x: 284, y: 340), CGPoint(x: 276, y: 347),
                CGPoint(x: 270, y: 345), CGPoint(x: 269, y: 333), CGPoint(x: 265, y: 326),
                CGPoint(x: 271, y: 323), CGPoint(x: 272, y: 310)
            ]
        case .yamanashi:
            return [
                CGPoint(x: 288, y: 336), CGPoint(x: 288, y: 326), CGPoint(x: 292, y: 324),
                CGPoint(x: 297, y: 323), CGPoint(x: 306, y: 327), CGPoint(x: 312, y: 332),
                CGPoint(x: 310, y: 334), CGPoint(x: 297, y: 342), CGPoint(x: 294, y: 345),
                CGPoint(x: 292, y: 347), CGPoint(x: 289, y: 341)
            ]
        case .shizuoka:
            return [
                CGPoint(x: 310, y: 334), CGPoint(x: 305, y: 341), CGPoint(x: 308, y: 343),
                CGPoint(x: 308, y: 350), CGPoint(x: 311, y: 355), CGPoint(x: 304, y: 365),
                CGPoint(x: 300, y: 362), CGPoint(x: 300, y: 354), CGPoint(x: 305, y: 351),
                CGPoint(x: 297, y: 349), CGPoint(x: 284, y: 365), CGPoint(x: 270, y: 364),
                CGPoint(x: 268, y: 358), CGPoint(x: 276, y: 347), CGPoint(x: 284, y: 340),
                CGPoint(x: 288, y: 336), CGPoint(x: 289, y: 341), CGPoint(x: 292, y: 347),
                CGPoint(x: 294, y: 345), CGPoint(x: 297, y: 342)
            ]
        case .aichi:
            return [
                CGPoint(x: 270, y: 345), CGPoint(x: 276, y: 347), CGPoint(x: 268, y: 358),
                CGPoint(x: 270, y: 364), CGPoint(x: 258, y: 366), CGPoint(x: 265, y: 361),
                CGPoint(x: 259, y: 360), CGPoint(x: 256, y: 359), CGPoint(x: 257, y: 363),
                CGPoint(x: 252, y: 360), CGPoint(x: 253, y: 353), CGPoint(x: 250, y: 351),
                CGPoint(x: 249, y: 347), CGPoint(x: 251, y: 342), CGPoint(x: 255, y: 341),
                CGPoint(x: 262, y: 344)
            ]
        case .mie:
            return [
                CGPoint(x: 249, y: 347), CGPoint(x: 250, y: 351), CGPoint(x: 244, y: 363),
                CGPoint(x: 254, y: 369), CGPoint(x: 253, y: 375), CGPoint(x: 240, y: 378),
                CGPoint(x: 239, y: 383), CGPoint(x: 231, y: 391), CGPoint(x: 228, y: 387),
                CGPoint(x: 234, y: 381), CGPoint(x: 233, y: 372), CGPoint(x: 237, y: 370),
                CGPoint(x: 232, y: 361), CGPoint(x: 234, y: 360), CGPoint(x: 244, y: 347),
                CGPoint(x: 242, y: 346)
            ]
        case .gifu:
            return [
                CGPoint(x: 272, y: 310), CGPoint(x: 271, y: 323), CGPoint(x: 265, y: 326),
                CGPoint(x: 269, y: 333), CGPoint(x: 270, y: 345), CGPoint(x: 262, y: 344),
                CGPoint(x: 255, y: 341), CGPoint(x: 251, y: 342), CGPoint(x: 249, y: 347),
                CGPoint(x: 242, y: 346), CGPoint(x: 239, y: 333), CGPoint(x: 242, y: 330),
                CGPoint(x: 251, y: 327), CGPoint(x: 249, y: 321), CGPoint(x: 250, y: 317),
                CGPoint(x: 252, y: 310), CGPoint(x: 258, y: 313), CGPoint(x: 261, y: 309)
            ]
        case .fukui:
            return [
                CGPoint(x: 238, y: 313), CGPoint(x: 244, y: 317), CGPoint(x: 250, y: 317),
                CGPoint(x: 249, y: 321), CGPoint(x: 251, y: 327), CGPoint(x: 242, y: 330),
                CGPoint(x: 239, y: 333), CGPoint(x: 228, y: 338), CGPoint(x: 225, y: 343),
                CGPoint(x: 222, y: 343), CGPoint(x: 215, y: 339), CGPoint(x: 222, y: 337),
                CGPoint(x: 233, y: 330), CGPoint(x: 228, y: 323)
            ]
        case .ishikawa:
            return [
                CGPoint(x: 238, y: 313), CGPoint(x: 255, y: 290), CGPoint(x: 249, y: 282),
                CGPoint(x: 265, y: 274), CGPoint(x: 264, y: 281), CGPoint(x: 258, y: 284),
                CGPoint(x: 258, y: 291), CGPoint(x: 254, y: 296), CGPoint(x: 252, y: 310),
                CGPoint(x: 250, y: 317), CGPoint(x: 244, y: 317)
            ]
        case .toyama:
            return [
                CGPoint(x: 258, y: 291), CGPoint(x: 258, y: 297), CGPoint(x: 266, y: 298),
                CGPoint(x: 266, y: 293), CGPoint(x: 274, y: 291), CGPoint(x: 276, y: 297),
                CGPoint(x: 272, y: 310), CGPoint(x: 261, y: 309), CGPoint(x: 258, y: 313),
                CGPoint(x: 252, y: 310), CGPoint(x: 254, y: 296)
            ]
        case .shiga:
            return [
                CGPoint(x: 225, y: 343), CGPoint(x: 228, y: 338), CGPoint(x: 239, y: 333),
                CGPoint(x: 242, y: 346), CGPoint(x: 244, y: 347), CGPoint(x: 234, y: 360),
                CGPoint(x: 229, y: 353)
            ]
        case .kyoto:
            return [
                CGPoint(x: 215, y: 339), CGPoint(x: 222, y: 343), CGPoint(x: 225, y: 343),
                CGPoint(x: 229, y: 353), CGPoint(x: 234, y: 360), CGPoint(x: 232, y: 361),
                CGPoint(x: 225, y: 360), CGPoint(x: 225, y: 355), CGPoint(x: 217, y: 349),
                CGPoint(x: 204, y: 342), CGPoint(x: 208, y: 337), CGPoint(x: 203, y: 334),
                CGPoint(x: 211, y: 329), CGPoint(x: 215, y: 332), CGPoint(x: 214, y: 336)
            ]
        case .hyogo:
            return [
                CGPoint(x: 190, y: 334), CGPoint(x: 203, y: 334), CGPoint(x: 208, y: 337),
                CGPoint(x: 204, y: 342), CGPoint(x: 217, y: 349), CGPoint(x: 225, y: 355),
                CGPoint(x: 218, y: 362), CGPoint(x: 212, y: 362), CGPoint(x: 205, y: 365),
                CGPoint(x: 198, y: 360), CGPoint(x: 186, y: 360), CGPoint(x: 192, y: 345),
                CGPoint(x: 194, y: 343)
            ]
        case .nara:
            return [
                CGPoint(x: 232, y: 361), CGPoint(x: 237, y: 370), CGPoint(x: 233, y: 372),
                CGPoint(x: 234, y: 381), CGPoint(x: 228, y: 387), CGPoint(x: 225, y: 387),
                CGPoint(x: 220, y: 381), CGPoint(x: 225, y: 376), CGPoint(x: 225, y: 372),
                CGPoint(x: 225, y: 360)
            ]
        case .wakayama:
            return [
                CGPoint(x: 211, y: 372), CGPoint(x: 225, y: 372), CGPoint(x: 225, y: 376),
                CGPoint(x: 220, y: 381), CGPoint(x: 225, y: 387), CGPoint(x: 228, y: 387),
                CGPoint(x: 231, y: 391), CGPoint(x: 225, y: 401), CGPoint(x: 216, y: 397),
                CGPoint(x: 217, y: 390), CGPoint(x: 209, y: 385), CGPoint(x: 209, y: 374)
            ]
        case .osaka:
            return [
                CGPoint(x: 225, y: 355), CGPoint(x: 225, y: 360), CGPoint(x: 225, y: 372),
                CGPoint(x: 211, y: 372), CGPoint(x: 217, y: 366), CGPoint(x: 218, y: 362)
            ]
        case .tottori:
            return [
                CGPoint(x: 165, y: 340), CGPoint(x: 170, y: 337), CGPoint(x: 182, y: 338),
                CGPoint(x: 190, y: 334), CGPoint(x: 194, y: 343), CGPoint(x: 192, y: 345),
                CGPoint(x: 185, y: 346), CGPoint(x: 178, y: 345), CGPoint(x: 170, y: 343),
                CGPoint(x: 164, y: 351), CGPoint(x: 159, y: 349), CGPoint(x: 164, y: 342)
            ]
        case .okayama:
            return [
                CGPoint(x: 192, y: 345), CGPoint(x: 186, y: 360), CGPoint(x: 177, y: 370),
                CGPoint(x: 169, y: 368), CGPoint(x: 165, y: 358), CGPoint(x: 164, y: 351),
                CGPoint(x: 170, y: 343), CGPoint(x: 178, y: 345), CGPoint(x: 185, y: 346)
            ]
        case .hiroshima:
            return [
                CGPoint(x: 159, y: 349), CGPoint(x: 164, y: 351), CGPoint(x: 165, y: 358),
                CGPoint(x: 169, y: 368), CGPoint(x: 166, y: 369), CGPoint(x: 145, y: 377),
                CGPoint(x: 142, y: 371), CGPoint(x: 139, y: 377), CGPoint(x: 136, y: 374),
                CGPoint(x: 133, y: 370), CGPoint(x: 138, y: 360), CGPoint(x: 147, y: 357),
                CGPoint(x: 152, y: 350)
            ]
        case .yamaguchi:
            return [
                CGPoint(x: 133, y: 370), CGPoint(x: 136, y: 374), CGPoint(x: 139, y: 377),
                CGPoint(x: 138, y: 376), CGPoint(x: 137, y: 383), CGPoint(x: 131, y: 388),
                CGPoint(x: 124, y: 381), CGPoint(x: 112, y: 385), CGPoint(x: 104, y: 384),
                CGPoint(x: 106, y: 370), CGPoint(x: 114, y: 372), CGPoint(x: 123, y: 363),
                CGPoint(x: 123, y: 369), CGPoint(x: 129, y: 374)
            ]
        case .shimane:
            return [
                CGPoint(x: 123, y: 363), CGPoint(x: 147, y: 343), CGPoint(x: 163, y: 335),
                CGPoint(x: 164, y: 338), CGPoint(x: 165, y: 340), CGPoint(x: 164, y: 342),
                CGPoint(x: 159, y: 349), CGPoint(x: 152, y: 350), CGPoint(x: 147, y: 357),
                CGPoint(x: 138, y: 360), CGPoint(x: 133, y: 370), CGPoint(x: 129, y: 374),
                CGPoint(x: 123, y: 369)
            ]
        case .kagawa:
            return [
                CGPoint(x: 172, y: 382), CGPoint(x: 171, y: 375), CGPoint(x: 184, y: 373),
                CGPoint(x: 187, y: 375), CGPoint(x: 194, y: 377), CGPoint(x: 182, y: 380),
                CGPoint(x: 174, y: 384)
            ]
        case .tokushima:
            return [
                CGPoint(x: 194, y: 377), CGPoint(x: 197, y: 377), CGPoint(x: 200, y: 389),
                CGPoint(x: 189, y: 397), CGPoint(x: 188, y: 398), CGPoint(x: 181, y: 390),
                CGPoint(x: 173, y: 388), CGPoint(x: 174, y: 384), CGPoint(x: 182, y: 380)
            ]
        case .kochi:
            return [
                CGPoint(x: 173, y: 388), CGPoint(x: 181, y: 390), CGPoint(x: 188, y: 398),
                CGPoint(x: 186, y: 406), CGPoint(x: 178, y: 399), CGPoint(x: 167, y: 400),
                CGPoint(x: 151, y: 421), CGPoint(x: 146, y: 415), CGPoint(x: 154, y: 400),
                CGPoint(x: 162, y: 390)
            ]
        case .ehime:
            return [
                CGPoint(x: 172, y: 382), CGPoint(x: 174, y: 384), CGPoint(x: 173, y: 388),
                CGPoint(x: 162, y: 390), CGPoint(x: 154, y: 400), CGPoint(x: 146, y: 415),
                CGPoint(x: 143, y: 417), CGPoint(x: 143, y: 404), CGPoint(x: 132, y: 403),
                CGPoint(x: 148, y: 393), CGPoint(x: 155, y: 380), CGPoint(x: 158, y: 385)
            ]
        case .fukuoka:
            return [
                CGPoint(x: 111, y: 397), CGPoint(x: 103, y: 401), CGPoint(x: 104, y: 410),
                CGPoint(x: 93, y: 413), CGPoint(x: 91, y: 411), CGPoint(x: 88, y: 407),
                CGPoint(x: 95, y: 401), CGPoint(x: 83, y: 398), CGPoint(x: 103, y: 385),
                CGPoint(x: 105, y: 391)
            ]
        case .oita:
            return [
                CGPoint(x: 111, y: 397), CGPoint(x: 122, y: 393), CGPoint(x: 127, y: 398),
                CGPoint(x: 118, y: 405), CGPoint(x: 130, y: 407), CGPoint(x: 133, y: 416),
                CGPoint(x: 129, y: 421), CGPoint(x: 114, y: 418), CGPoint(x: 110, y: 409),
                CGPoint(x: 108, y: 408), CGPoint(x: 108, y: 412), CGPoint(x: 104, y: 410),
                CGPoint(x: 103, y: 401)
            ]
        case .miyazaki:
            return [
                CGPoint(x: 114, y: 418), CGPoint(x: 129, y: 421), CGPoint(x: 124, y: 425),
                CGPoint(x: 119, y: 437), CGPoint(x: 114, y: 462), CGPoint(x: 110, y: 457),
                CGPoint(x: 111, y: 455), CGPoint(x: 104, y: 450), CGPoint(x: 100, y: 442),
                CGPoint(x: 110, y: 436), CGPoint(x: 107, y: 428)
            ]
        case .kagoshima:
            return [
                CGPoint(x: 100, y: 442), CGPoint(x: 104, y: 450), CGPoint(x: 111, y: 455),
                CGPoint(x: 110, y: 457), CGPoint(x: 98, y: 472), CGPoint(x: 98, y: 456),
                CGPoint(x: 101, y: 456), CGPoint(x: 101, y: 450), CGPoint(x: 97, y: 450),
                CGPoint(x: 94, y: 462), CGPoint(x: 98, y: 467), CGPoint(x: 83, y: 462),
                CGPoint(x: 90, y: 458), CGPoint(x: 85, y: 450), CGPoint(x: 84, y: 436),
                CGPoint(x: 88, y: 437), CGPoint(x: 95, y: 437)
            ]
        case .kumamoto:
            return [
                CGPoint(x: 93, y: 413), CGPoint(x: 104, y: 410), CGPoint(x: 108, y: 412),
                CGPoint(x: 108, y: 408), CGPoint(x: 110, y: 409), CGPoint(x: 114, y: 418),
                CGPoint(x: 107, y: 428), CGPoint(x: 110, y: 436), CGPoint(x: 100, y: 442),
                CGPoint(x: 95, y: 437), CGPoint(x: 88, y: 437), CGPoint(x: 89, y: 428),
                CGPoint(x: 95, y: 420), CGPoint(x: 96, y: 414)
            ]
        case .saga:
            return [
                CGPoint(x: 76, y: 402), CGPoint(x: 78, y: 397), CGPoint(x: 83, y: 398),
                CGPoint(x: 95, y: 401), CGPoint(x: 88, y: 407), CGPoint(x: 85, y: 415)
            ]
        case .nagasaki:
            return [
                CGPoint(x: 76, y: 402), CGPoint(x: 85, y: 415), CGPoint(x: 83, y: 418),
                CGPoint(x: 83, y: 419), CGPoint(x: 85, y: 420), CGPoint(x: 91, y: 421),
                CGPoint(x: 86, y: 426), CGPoint(x: 85, y: 422), CGPoint(x: 76, y: 425),
                CGPoint(x: 76, y: 420), CGPoint(x: 72, y: 410), CGPoint(x: 69, y: 406),
                CGPoint(x: 72, y: 402)
            ]
        case .okinawa:
            return [
                CGPoint(x: 52, y: 469), CGPoint(x: 52, y: 473), CGPoint(x: 38, y: 481),
                CGPoint(x: 36, y: 490), CGPoint(x: 32, y: 491), CGPoint(x: 31, y: 489),
                CGPoint(x: 34, y: 481), CGPoint(x: 42, y: 477), CGPoint(x: 39, y: 474),
                CGPoint(x: 39, y: 473), CGPoint(x: 42, y: 472), CGPoint(x: 43, y: 475),
                CGPoint(x: 50, y: 468)
            ]
        }
    }
    
    var okinawaLinePoints: [CGPoint] {
        if self != .okinawa {
            return []
        }
        return [CGPoint(x: 21, y: 456), CGPoint(x: 62, y: 456), CGPoint(x: 62, y: 496)]
    }
}
