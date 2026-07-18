//
//  Gourmet.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/20.
//

import SwiftUI

// グルメ情報のデータ構造を拡張
struct GourmetItem: Identifiable {
    let id = UUID()
    /// グルメ名のローカライズキー（例: "gourmet_sapporo_miso_ramen"）。
    /// 表示名は `name` で表示言語に翻訳し、食べログ検索には `nameJa`（日本語名）を使う。
    let nameKey: String
    let description: String
    let category: FoodCategory
    let imageSymbol: String
    let price: String
    let bestSeason: String
    let popularity: Int // 1-5

    /// 画面表示用の名前（端末の表示言語に翻訳）。
    var name: String { NSLocalizedString(nameKey, comment: "") }

    /// 食べログ検索に渡す日本語のグルメ名。
    /// 食べログの店舗DBは日本語ベースで、翻訳語（英語等）ではほとんどヒットしないため、
    /// 表示言語に関わらず常に日本語名で検索する。
    var nameJa: String { LocalizedString.japanese(nameKey) }
}

/// 表示言語に依存せず特定言語の Localizable.strings を引くためのユーティリティ。
enum LocalizedString {
    /// 日本語（ja.lproj）の文字列を返す。日本語バンドルが無い等で引けない場合はキーをそのまま返す。
    static func japanese(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: "ja", ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}

enum FoodCategory: String, CaseIterable {
    case ramen = "food_category_ramen"
    case seafood = "food_category_seafood"
    case meat = "food_category_meat"
    case sweets = "food_category_sweets"
    case local = "food_category_local"
    case drinks = "food_category_drinks"
    case vegetables = "food_category_vegetables"
    
    /// カテゴリ色。白文字を載せても読めるよう、明度・彩度を手調整した値に統一している。
    /// （システム色の .yellow / .orange などは明るすぎて白文字が破綻するため使わない）
    var color: Color {
        switch self {
        case .ramen:      return Color(red: 0.93, green: 0.45, blue: 0.13) // オレンジ
        case .seafood:    return Color(red: 0.16, green: 0.50, blue: 0.85) // ブルー
        case .meat:       return Color(red: 0.84, green: 0.27, blue: 0.30) // レッド
        case .sweets:     return Color(red: 0.86, green: 0.35, blue: 0.58) // ピンク
        case .local:      return Color(red: 0.24, green: 0.62, blue: 0.40) // グリーン
        case .drinks:     return Color(red: 0.55, green: 0.38, blue: 0.78) // パープル
        case .vegetables: return Color(red: 0.82, green: 0.58, blue: 0.13) // 黄系→読めるアンバー
        }
    }
    
    var icon: String {
        switch self {
        case .ramen: return "bowl.fill"
        case .seafood: return "fish.fill"
        case .meat: return "flame.fill"
        case .sweets: return "birthday.cake.fill"
        case .local: return "house.fill"
        case .drinks: return "wineglass.fill"
        case .vegetables: return "leaf.fill"
        }
    }

    /// カード上のタグ表示用の短縮名。英語で "Vegetables & Fruits" のような長い名称が
    /// 半分幅のカードで省略されるのを避けるため、タグでは短くする。
    /// （フィルター・詳細画面では rawValue.localized をそのまま使う）
    var tagName: String {
        NSLocalizedString("\(rawValue)_tag", comment: "")
    }
}

extension Prefecture {
    var gourmetItems: [GourmetItem] {
        switch self {
        case .hokkaido:
            return [
                GourmetItem(nameKey: "gourmet_genghis_khan", description: NSLocalizedString("gourmet_genghis_khan_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_seafood_bowl", description: NSLocalizedString("gourmet_seafood_bowl_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_soup_curry", description: NSLocalizedString("gourmet_soup_curry_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "1,200-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_yubari_melon", description: NSLocalizedString("gourmet_yubari_melon_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_shiroi_koibito", description: NSLocalizedString("gourmet_shiroi_koibito_desc", comment: ""), category: .sweets, imageSymbol: "heart.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_sapporo_miso_ramen", description: NSLocalizedString("gourmet_sapporo_miso_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_zangi", description: NSLocalizedString("gourmet_zangi_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .kyoto:
            return [
                GourmetItem(nameKey: "gourmet_yudofu", description: NSLocalizedString("gourmet_yudofu_desc", comment: ""), category: .local, imageSymbol: "rectangle.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kyoto_kaiseki", description: NSLocalizedString("gourmet_kyoto_kaiseki_desc", comment: ""), category: .local, imageSymbol: "fish.fill", price: "10,000-50,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_matcha_sweets", description: NSLocalizedString("gourmet_matcha_sweets_desc", comment: ""), category: .sweets, imageSymbol: "leaf.fill", price: "500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_obanzai", description: NSLocalizedString("gourmet_obanzai_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kyoto_pickles", description: NSLocalizedString("gourmet_kyoto_pickles_desc", comment: ""), category: .vegetables, imageSymbol: "leaf.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_nishin_soba", description: NSLocalizedString("gourmet_nishin_soba_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "900-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kyoto_yuba", description: NSLocalizedString("gourmet_kyoto_yuba_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "1,500-4,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .hyogo:
            return [
                GourmetItem(nameKey: "gourmet_kobe_beef", description: NSLocalizedString("gourmet_kobe_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "5,000-50,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_akashiyaki", description: NSLocalizedString("gourmet_akashiyaki_desc", comment: ""), category: .seafood, imageSymbol: "circle.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_ikanago", description: NSLocalizedString("gourmet_ikanago_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_spring", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_banshu_ramen", description: NSLocalizedString("gourmet_banshu_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_awaji_onion", description: NSLocalizedString("gourmet_awaji_onion_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_spring_summer", comment: ""), popularity: 4)
            ]
        case .nara:
            return [
                GourmetItem(nameKey: "gourmet_kakinoha_sushi", description: NSLocalizedString("gourmet_kakinoha_sushi_desc", comment: ""), category: .seafood, imageSymbol: "leaf.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_miwa_somen", description: NSLocalizedString("gourmet_miwa_somen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_narazuke", description: NSLocalizedString("gourmet_narazuke_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_yamato_beef", description: NSLocalizedString("gourmet_yamato_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_kuzukiri", description: NSLocalizedString("gourmet_kuzukiri_desc", comment: ""), category: .sweets, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_asuka_nabe", description: NSLocalizedString("gourmet_asuka_nabe_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_chagayu", description: NSLocalizedString("gourmet_chagayu_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .wakayama:
            return [
                GourmetItem(nameKey: "gourmet_umeboshi", description: NSLocalizedString("gourmet_umeboshi_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_wakayama_ramen", description: NSLocalizedString("gourmet_wakayama_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_tuna", description: NSLocalizedString("gourmet_tuna_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_persimmon", description: NSLocalizedString("gourmet_persimmon_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "200-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_kishu_kinzanji_miso", description: NSLocalizedString("gourmet_kishu_kinzanji_miso_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .osaka:
            return [
                GourmetItem(nameKey: "gourmet_takoyaki", description: NSLocalizedString("gourmet_takoyaki_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "500-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_okonomiyaki", description: NSLocalizedString("gourmet_okonomiyaki_desc", comment: ""), category: .local, imageSymbol: "circle.grid.3x3.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_kushikatsu", description: NSLocalizedString("gourmet_kushikatsu_desc", comment: ""), category: .meat, imageSymbol: "minus.rectangle.fill", price: "100-300円/本", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_ikayaki", description: NSLocalizedString("gourmet_ikayaki_desc", comment: ""), category: .seafood, imageSymbol: "oval.fill", price: "400-600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_butaman", description: NSLocalizedString("gourmet_butaman_desc", comment: ""), category: .local, imageSymbol: "circle.hexagonpath.fill", price: "200-400円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_niku_sui", description: NSLocalizedString("gourmet_niku_sui_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_doteyaki", description: NSLocalizedString("gourmet_doteyaki_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3)
            ]
        case .tottori:
            return [
                GourmetItem(nameKey: "gourmet_matsuba_crab", description: NSLocalizedString("gourmet_matsuba_crab_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_nijisseiki_pear", description: NSLocalizedString("gourmet_nijisseiki_pear_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-1,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_sakaiminato_seafood", description: NSLocalizedString("gourmet_sakaiminato_seafood_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_tofu_chikuwa", description: NSLocalizedString("gourmet_tofu_chikuwa_desc", comment: ""), category: .local, imageSymbol: "minus.rectangle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_gyu_kotsu_ramen", description: NSLocalizedString("gourmet_gyu_kotsu_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .okayama:
            return [
                GourmetItem(nameKey: "gourmet_white_peach", description: NSLocalizedString("gourmet_white_peach_desc", comment: ""), category: .vegetables, imageSymbol: "heart.fill", price: "500-3,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_muscat", description: NSLocalizedString("gourmet_muscat_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_summer_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kibidango", description: NSLocalizedString("gourmet_kibidango_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_mamakari", description: NSLocalizedString("gourmet_mamakari_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_demi_katsu_don", description: NSLocalizedString("gourmet_demi_katsu_don_desc", comment: ""), category: .meat, imageSymbol: "bowl.fill", price: "1,000-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .hiroshima:
            return [
                GourmetItem(nameKey: "gourmet_okonomiyaki_hiroshima", description: NSLocalizedString("gourmet_okonomiyaki_hiroshima_desc", comment: ""), category: .local, imageSymbol: "circle.grid.3x3.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_oyster", description: NSLocalizedString("gourmet_oyster_desc", comment: ""), category: .seafood, imageSymbol: "oval.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_momiji_manju", description: NSLocalizedString("gourmet_momiji_manju_desc", comment: ""), category: .sweets, imageSymbol: "leaf.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_hiroshima_tsukemen", description: NSLocalizedString("gourmet_hiroshima_tsukemen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_anago_meshi", description: NSLocalizedString("gourmet_anago_meshi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_shirunashi_tantanmen", description: NSLocalizedString("gourmet_shirunashi_tantanmen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_gansu", description: NSLocalizedString("gourmet_gansu_desc", comment: ""), category: .seafood, imageSymbol: "circle.fill", price: "300-700円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .yamaguchi:
            return [
                GourmetItem(nameKey: "gourmet_fugu", description: NSLocalizedString("gourmet_fugu_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_kawara_soba", description: NSLocalizedString("gourmet_kawara_soba_desc", comment: ""), category: .ramen, imageSymbol: "rectangle.fill", price: "1,200-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_iwakuni_lotus_root", description: NSLocalizedString("gourmet_iwakuni_lotus_root_desc", comment: ""), category: .vegetables, imageSymbol: "circle.grid.3x3.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_shimonoseki_whale", description: NSLocalizedString("gourmet_shimonoseki_whale_desc", comment: ""), category: .meat, imageSymbol: "fish.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 2),
                GourmetItem(nameKey: "gourmet_natsumikan", description: NSLocalizedString("gourmet_natsumikan_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "200-600円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .shimane:
            return [
                GourmetItem(nameKey: "gourmet_izumo_soba", description: NSLocalizedString("gourmet_izumo_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_shinjiko_shijimi", description: NSLocalizedString("gourmet_shinjiko_shijimi_desc", comment: ""), category: .seafood, imageSymbol: "oval.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_nodoguro_shimane", description: NSLocalizedString("gourmet_nodoguro_shimane_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_matsue_wagashi", description: NSLocalizedString("gourmet_matsue_wagashi_desc", comment: ""), category: .sweets, imageSymbol: "heart.fill", price: "300-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_wariko_soba", description: NSLocalizedString("gourmet_wariko_soba_desc", comment: ""), category: .ramen, imageSymbol: "circle.fill", price: "1,000-1,800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .kagawa:
            return [
                GourmetItem(nameKey: "gourmet_sanuki_udon", description: NSLocalizedString("gourmet_sanuki_udon_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "200-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_olive", description: NSLocalizedString("gourmet_olive_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "800-3,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_honetsuki_dori", description: NSLocalizedString("gourmet_honetsuki_dori_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_wasanbon", description: NSLocalizedString("gourmet_wasanbon_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_shodoshima_somen", description: NSLocalizedString("gourmet_shodoshima_somen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .tokushima:
            return [
                GourmetItem(nameKey: "gourmet_awa_odori_chicken", description: NSLocalizedString("gourmet_awa_odori_chicken_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_tarai_udon", description: NSLocalizedString("gourmet_tarai_udon_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_sudachi", description: NSLocalizedString("gourmet_sudachi_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_naruto_kintoki", description: NSLocalizedString("gourmet_naruto_kintoki_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_handa_somen", description: NSLocalizedString("gourmet_handa_somen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-1,200円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .kochi:
            return [
                GourmetItem(nameKey: "gourmet_katsuo_tataki", description: NSLocalizedString("gourmet_katsuo_tataki_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_sawachi_cuisine", description: NSLocalizedString("gourmet_sawachi_cuisine_desc", comment: ""), category: .local, imageSymbol: "fish.fill", price: "3,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_tosa_sake", description: NSLocalizedString("gourmet_tosa_sake_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_yuzu", description: NSLocalizedString("gourmet_yuzu_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_tosa_buntan", description: NSLocalizedString("gourmet_tosa_buntan_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_spring", comment: ""), popularity: 3)
            ]
        case .ehime:
            return [
                GourmetItem(nameKey: "gourmet_mikan", description: NSLocalizedString("gourmet_mikan_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-1,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_jakoten", description: NSLocalizedString("gourmet_jakoten_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_tai_meshi", description: NSLocalizedString("gourmet_tai_meshi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_iyokan", description: NSLocalizedString("gourmet_iyokan_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_winter_spring", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_botchan_dango", description: NSLocalizedString("gourmet_botchan_dango_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "300-600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .fukuoka:
            return [
                GourmetItem(nameKey: "gourmet_hakata_ramen", description: NSLocalizedString("gourmet_hakata_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_motsu_nabe", description: NSLocalizedString("gourmet_motsu_nabe_desc", comment: ""), category: .meat, imageSymbol: "bowl.fill", price: "2,000-4,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_karashi_mentaiko", description: NSLocalizedString("gourmet_karashi_mentaiko_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_mizutaki", description: NSLocalizedString("gourmet_mizutaki_desc", comment: ""), category: .meat, imageSymbol: "bowl.fill", price: "2,500-5,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_hakata_torimon", description: NSLocalizedString("gourmet_hakata_torimon_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "1,000-2,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_gobo_ten_udon", description: NSLocalizedString("gourmet_gobo_ten_udon_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-900円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_goma_saba", description: NSLocalizedString("gourmet_goma_saba_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "700-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .oita:
            return [
                GourmetItem(nameKey: "gourmet_seki_saba_aji", description: NSLocalizedString("gourmet_seki_saba_aji_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_toriten", description: NSLocalizedString("gourmet_toriten_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_dango_soup", description: NSLocalizedString("gourmet_dango_soup_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_bungo_beef", description: NSLocalizedString("gourmet_bungo_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kabosu", description: NSLocalizedString("gourmet_kabosu_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4)
            ]
        case .miyazaki:
            return [
                GourmetItem(nameKey: "gourmet_miyazaki_beef", description: NSLocalizedString("gourmet_miyazaki_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-15,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_chicken_nanban", description: NSLocalizedString("gourmet_chicken_nanban_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_hiyajiru", description: NSLocalizedString("gourmet_hiyajiru_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "600-1,200円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_miyazaki_mango", description: NSLocalizedString("gourmet_miyazaki_mango_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_miyazaki_shochu", description: NSLocalizedString("gourmet_miyazaki_shochu_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .kagoshima:
            return [
                GourmetItem(nameKey: "gourmet_kurobuta", description: NSLocalizedString("gourmet_kurobuta_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_satsuma_imo", description: NSLocalizedString("gourmet_satsuma_imo_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "200-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kagoshima_shochu", description: NSLocalizedString("gourmet_kagoshima_shochu_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_kibinago", description: NSLocalizedString("gourmet_kibinago_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_shirokuma", description: NSLocalizedString("gourmet_shirokuma_desc", comment: ""), category: .sweets, imageSymbol: "snowflake", price: "500-1,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4)
            ]
        case .kumamoto:
            return [
                GourmetItem(nameKey: "gourmet_basashi", description: NSLocalizedString("gourmet_basashi_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_dago_soup", description: NSLocalizedString("gourmet_dago_soup_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_taipien", description: NSLocalizedString("gourmet_taipien_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_karashi_renkon", description: NSLocalizedString("gourmet_karashi_renkon_desc", comment: ""), category: .vegetables, imageSymbol: "circle.grid.3x3.fill", price: "500-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_ikinari_dango", description: NSLocalizedString("gourmet_ikinari_dango_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "200-400円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .saga:
            return [
                GourmetItem(nameKey: "gourmet_saga_beef", description: NSLocalizedString("gourmet_saga_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-12,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_yobuko_ika", description: NSLocalizedString("gourmet_yobuko_ika_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_gabai_manju", description: NSLocalizedString("gourmet_gabai_manju_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_marubolo", description: NSLocalizedString("gourmet_marubolo_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_onsen_yudofu", description: NSLocalizedString("gourmet_onsen_yudofu_desc", comment: ""), category: .local, imageSymbol: "rectangle.fill", price: "1,200-2,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .nagasaki:
            return [
                GourmetItem(nameKey: "gourmet_champon", description: NSLocalizedString("gourmet_champon_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_sara_udon", description: NSLocalizedString("gourmet_sara_udon_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_castella", description: NSLocalizedString("gourmet_castella_desc", comment: ""), category: .sweets, imageSymbol: "rectangle.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_sasebo_burger", description: NSLocalizedString("gourmet_sasebo_burger_desc", comment: ""), category: .local, imageSymbol: "circle.hexagonpath.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kakuni_manju", description: NSLocalizedString("gourmet_kakuni_manju_desc", comment: ""), category: .meat, imageSymbol: "circle.fill", price: "300-600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_turkish_rice", description: NSLocalizedString("gourmet_turkish_rice_desc", comment: ""), category: .local, imageSymbol: "fork.knife", price: "900-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_hatoshi", description: NSLocalizedString("gourmet_hatoshi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "300-600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .okinawa:
            return [
                GourmetItem(nameKey: "gourmet_goya_chanpuru", description: NSLocalizedString("gourmet_goya_chanpuru_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_soki_soba", description: NSLocalizedString("gourmet_soki_soba_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_sata_andagi", description: NSLocalizedString("gourmet_sata_andagi_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_umi_budo", description: NSLocalizedString("gourmet_umi_budo_desc", comment: ""), category: .seafood, imageSymbol: "circle.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_awamori", description: NSLocalizedString("gourmet_awamori_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_taco_rice", description: NSLocalizedString("gourmet_taco_rice_desc", comment: ""), category: .local, imageSymbol: "fork.knife", price: "600-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_rafute", description: NSLocalizedString("gourmet_rafute_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .aomori:
            return [
                GourmetItem(nameKey: "gourmet_aomori_apple", description: NSLocalizedString("gourmet_aomori_apple_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "100-500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_oma_tuna", description: NSLocalizedString("gourmet_oma_tuna_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "5,000-20,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_senbei_soup", description: NSLocalizedString("gourmet_senbei_soup_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-800円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_tsugaru_soba", description: NSLocalizedString("gourmet_tsugaru_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_ichigo_ni", description: NSLocalizedString("gourmet_ichigo_ni_desc", comment: ""), category: .seafood, imageSymbol: "bowl.fill", price: "2,000-4,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4)
            ]
        case .iwate:
            return [
                GourmetItem(nameKey: "gourmet_wanko_soba", description: NSLocalizedString("gourmet_wanko_soba_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "2,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_morioka_cold_noodles", description: NSLocalizedString("gourmet_morioka_cold_noodles_desc", comment: ""), category: .ramen, imageSymbol: "snowflake", price: "800-1,200円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_maezawa_beef", description: NSLocalizedString("gourmet_maezawa_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_nanbu_senbei", description: NSLocalizedString("gourmet_nanbu_senbei_desc", comment: ""), category: .sweets, imageSymbol: "circle.grid.3x3.fill", price: "300-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_gangetsu", description: NSLocalizedString("gourmet_gangetsu_desc", comment: ""), category: .sweets, imageSymbol: "moon.fill", price: "150-300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .akita:
            return [
                GourmetItem(nameKey: "gourmet_kiritanpo", description: NSLocalizedString("gourmet_kiritanpo_desc", comment: ""), category: .local, imageSymbol: "minus.rectangle.fill", price: "1,500-2,500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_hinai_chicken", description: NSLocalizedString("gourmet_hinai_chicken_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "2,000-4,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_inaniwa_udon", description: NSLocalizedString("gourmet_inaniwa_udon_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_akita_komachi", description: NSLocalizedString("gourmet_akita_komachi_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "2,000-4,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_babahera_ice", description: NSLocalizedString("gourmet_babahera_ice_desc", comment: ""), category: .sweets, imageSymbol: "snowflake", price: "200-300円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .miyagi:
            return [
                GourmetItem(nameKey: "gourmet_beef_tongue", description: NSLocalizedString("gourmet_beef_tongue_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_sasukamaboko", description: NSLocalizedString("gourmet_sasukamaboko_desc", comment: ""), category: .seafood, imageSymbol: "leaf.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_zunda_mochi", description: NSLocalizedString("gourmet_zunda_mochi_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "300-600円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_seri_nabe", description: NSLocalizedString("gourmet_seri_nabe_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "2,000-3,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_shiroishi_somen", description: NSLocalizedString("gourmet_shiroishi_somen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_harako_meshi", description: NSLocalizedString("gourmet_harako_meshi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,200-2,500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_aburafu_don", description: NSLocalizedString("gourmet_aburafu_don_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .yamagata:
            return [
                GourmetItem(nameKey: "gourmet_cherry", description: NSLocalizedString("gourmet_cherry_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_yonezawa_beef", description: NSLocalizedString("gourmet_yonezawa_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "5,000-15,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_imoni", description: NSLocalizedString("gourmet_imoni_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_tama_konnyaku", description: NSLocalizedString("gourmet_tama_konnyaku_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "100-200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_cold_ramen", description: NSLocalizedString("gourmet_cold_ramen_desc", comment: ""), category: .ramen, imageSymbol: "snowflake", price: "700-1,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .fukushima:
            return [
                GourmetItem(nameKey: "gourmet_kitakata_ramen", description: NSLocalizedString("gourmet_kitakata_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_aizu_chicken", description: NSLocalizedString("gourmet_aizu_chicken_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_mamadooru", description: NSLocalizedString("gourmet_mamadooru_desc", comment: ""), category: .sweets, imageSymbol: "heart.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_fukushima_peach", description: NSLocalizedString("gourmet_fukushima_peach_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_shirakawa_ramen", description: NSLocalizedString("gourmet_shirakawa_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "600-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .ibaraki:
            return [
                GourmetItem(nameKey: "gourmet_natto", description: NSLocalizedString("gourmet_natto_desc", comment: ""), category: .local, imageSymbol: "oval.fill", price: "100-300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_anko_nabe", description: NSLocalizedString("gourmet_anko_nabe_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-8,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_hitachi_beef", description: NSLocalizedString("gourmet_hitachi_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-6,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_ibaraki_melon", description: NSLocalizedString("gourmet_ibaraki_melon_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_dried_sweet_potato", description: NSLocalizedString("gourmet_dried_sweet_potato_desc", comment: ""), category: .sweets, imageSymbol: "leaf.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3)
            ]
        case .chiba:
            return [
                GourmetItem(nameKey: "gourmet_peanuts", description: NSLocalizedString("gourmet_peanuts_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_loquat", description: NSLocalizedString("gourmet_loquat_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "200-500円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_namerou", description: NSLocalizedString("gourmet_namerou_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_katsuura_tantanmen", description: NSLocalizedString("gourmet_katsuura_tantanmen_desc", comment: ""), category: .ramen, imageSymbol: "flame.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_boso_seafood", description: NSLocalizedString("gourmet_boso_seafood_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_futomaki_sushi", description: NSLocalizedString("gourmet_futomaki_sushi_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_hakarime_don", description: NSLocalizedString("gourmet_hakarime_don_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,200-2,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .tochigi:
            return [
                GourmetItem(nameKey: "gourmet_utsunomiya_gyoza", description: NSLocalizedString("gourmet_utsunomiya_gyoza_desc", comment: ""), category: .local, imageSymbol: "circle.hexagonpath.fill", price: "300-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_yuba", description: NSLocalizedString("gourmet_yuba_desc", comment: ""), category: .local, imageSymbol: "rectangle.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_tochiotome", description: NSLocalizedString("gourmet_tochiotome_desc", comment: ""), category: .vegetables, imageSymbol: "heart.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_winter_spring", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_shimotsukare", description: NSLocalizedString("gourmet_shimotsukare_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "300-600円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 2),
                GourmetItem(nameKey: "gourmet_lemon_milk", description: NSLocalizedString("gourmet_lemon_milk_desc", comment: ""), category: .drinks, imageSymbol: "drop.fill", price: "150-200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .gunma:
            return [
                GourmetItem(nameKey: "gourmet_yaki_manju", description: NSLocalizedString("gourmet_yaki_manju_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "100-200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_shimonita_negi", description: NSLocalizedString("gourmet_shimonita_negi_desc", comment: ""), category: .vegetables, imageSymbol: "minus.rectangle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_konnyaku", description: NSLocalizedString("gourmet_konnyaku_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_mizusawa_udon", description: NSLocalizedString("gourmet_mizusawa_udon_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_daruma_bento", description: NSLocalizedString("gourmet_daruma_bento_desc", comment: ""), category: .local, imageSymbol: "oval.fill", price: "1,000-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .saitama:
            return [
                GourmetItem(nameKey: "gourmet_kawagoe_sweet_potato", description: NSLocalizedString("gourmet_kawagoe_sweet_potato_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_chichibu_soba", description: NSLocalizedString("gourmet_chichibu_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_soka_senbei", description: NSLocalizedString("gourmet_soka_senbei_desc", comment: ""), category: .sweets, imageSymbol: "circle.grid.3x3.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_gokaho", description: NSLocalizedString("gourmet_gokaho_desc", comment: ""), category: .sweets, imageSymbol: "rectangle.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 2),
                GourmetItem(nameKey: "gourmet_iga_manju", description: NSLocalizedString("gourmet_iga_manju_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "150-300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 2)
            ]
        case .tokyo:
            return [
                GourmetItem(nameKey: "gourmet_edomae_sushi", description: NSLocalizedString("gourmet_edomae_sushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-30,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_monjayaki", description: NSLocalizedString("gourmet_monjayaki_desc", comment: ""), category: .local, imageSymbol: "circle.grid.3x3.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_fukagawa_don", description: NSLocalizedString("gourmet_fukagawa_don_desc", comment: ""), category: .seafood, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_imagawayaki", description: NSLocalizedString("gourmet_imagawayaki_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "100-200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_tsukudani", description: NSLocalizedString("gourmet_tsukudani_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_chanko_nabe", description: NSLocalizedString("gourmet_chanko_nabe_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_edomae_tempura", description: NSLocalizedString("gourmet_edomae_tempura_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .kanagawa:
            return [
                GourmetItem(nameKey: "gourmet_shumai", description: NSLocalizedString("gourmet_shumai_desc", comment: ""), category: .local, imageSymbol: "circle.hexagonpath.fill", price: "600-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_kamakura_vegetables", description: NSLocalizedString("gourmet_kamakura_vegetables_desc", comment: ""), category: .vegetables, imageSymbol: "leaf.fill", price: "200-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_shonan_shirasu", description: NSLocalizedString("gourmet_shonan_shirasu_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_spring_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_iekei_ramen", description: NSLocalizedString("gourmet_iekei_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_yokohama_chinatown_gourmet", description: NSLocalizedString("gourmet_yokohama_chinatown_gourmet_desc", comment: ""), category: .local, imageSymbol: "flame.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_sanma_men", description: NSLocalizedString("gourmet_sanma_men_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_yokosuka_navy_curry", description: NSLocalizedString("gourmet_yokosuka_navy_curry_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "900-1,600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .niigata:
            return [
                GourmetItem(nameKey: "gourmet_niigata_rice", description: NSLocalizedString("gourmet_niigata_rice_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_noppe", description: NSLocalizedString("gourmet_noppe_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_hegi_soba", description: NSLocalizedString("gourmet_hegi_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_niigata_salmon", description: NSLocalizedString("gourmet_niigata_salmon_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_sake", description: NSLocalizedString("gourmet_sake_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5)
            ]
        case .nagano:
            return [
                GourmetItem(nameKey: "gourmet_shinshu_soba", description: NSLocalizedString("gourmet_shinshu_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_oyaki", description: NSLocalizedString("gourmet_oyaki_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "200-400円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_nozawana", description: NSLocalizedString("gourmet_nozawana_desc", comment: ""), category: .vegetables, imageSymbol: "leaf.fill", price: "300-800円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_shinshu_apple", description: NSLocalizedString("gourmet_shinshu_apple_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "200-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_shinshu_miso", description: NSLocalizedString("gourmet_shinshu_miso_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_shinshu_salmon", description: NSLocalizedString("gourmet_shinshu_salmon_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_nagano_gohei_mochi", description: NSLocalizedString("gourmet_nagano_gohei_mochi_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "300-600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .yamanashi:
            return [
                GourmetItem(nameKey: "gourmet_hoto", description: NSLocalizedString("gourmet_hoto_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_shingen_mochi", description: NSLocalizedString("gourmet_shingen_mochi_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_yamanashi_grape", description: NSLocalizedString("gourmet_yamanashi_grape_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "800-3,000円", bestSeason: NSLocalizedString("season_summer_autumn", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_yamanashi_peach", description: NSLocalizedString("gourmet_yamanashi_peach_desc", comment: ""), category: .vegetables, imageSymbol: "heart.fill", price: "300-1,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_koshu_wine", description: NSLocalizedString("gourmet_koshu_wine_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .shizuoka:
            return [
                GourmetItem(nameKey: "gourmet_shizuoka_tea", description: NSLocalizedString("gourmet_shizuoka_tea_desc", comment: ""), category: .drinks, imageSymbol: "leaf.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_unagi", description: NSLocalizedString("gourmet_unagi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_wasabi", description: NSLocalizedString("gourmet_wasabi_desc", comment: ""), category: .vegetables, imageSymbol: "leaf.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_sakura_ebi", description: NSLocalizedString("gourmet_sakura_ebi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_spring_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kuro_hanpen", description: NSLocalizedString("gourmet_kuro_hanpen_desc", comment: ""), category: .seafood, imageSymbol: "oval.fill", price: "100-300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_shizuoka_oden", description: NSLocalizedString("gourmet_shizuoka_oden_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_fujinomiya_yakisoba", description: NSLocalizedString("gourmet_fujinomiya_yakisoba_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-900円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .aichi:
            return [
                GourmetItem(nameKey: "gourmet_miso_katsu", description: NSLocalizedString("gourmet_miso_katsu_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_hitsumabushi", description: NSLocalizedString("gourmet_hitsumabushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_tebasaki", description: NSLocalizedString("gourmet_tebasaki_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "600-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kishimen", description: NSLocalizedString("gourmet_kishimen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_taiwan_ramen", description: NSLocalizedString("gourmet_taiwan_ramen_desc", comment: ""), category: .ramen, imageSymbol: "flame.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_miso_nikomi_udon", description: NSLocalizedString("gourmet_miso_nikomi_udon_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "900-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_ankake_spa", description: NSLocalizedString("gourmet_ankake_spa_desc", comment: ""), category: .local, imageSymbol: "fork.knife", price: "800-1,300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .mie:
            return [
                GourmetItem(nameKey: "gourmet_ise_ebi", description: NSLocalizedString("gourmet_ise_ebi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-15,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_matsusaka_beef", description: NSLocalizedString("gourmet_matsusaka_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_akafuku", description: NSLocalizedString("gourmet_akafuku_desc", comment: ""), category: .sweets, imageSymbol: "heart.fill", price: "200-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_tekone_sushi", description: NSLocalizedString("gourmet_tekone_sushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_iga_beef", description: NSLocalizedString("gourmet_iga_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .gifu:
            return [
                GourmetItem(nameKey: "gourmet_hida_beef", description: NSLocalizedString("gourmet_hida_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-15,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_hoba_miso", description: NSLocalizedString("gourmet_hoba_miso_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_gohei_mochi", description: NSLocalizedString("gourmet_gohei_mochi_desc", comment: ""), category: .local, imageSymbol: "oval.fill", price: "200-400円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_ayu_shioyaki", description: NSLocalizedString("gourmet_ayu_shioyaki_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_kuri_kinton", description: NSLocalizedString("gourmet_kuri_kinton_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 3)
            ]
        case .fukui:
            return [
                GourmetItem(nameKey: "gourmet_echizen_crab", description: NSLocalizedString("gourmet_echizen_crab_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_echizen_soba", description: NSLocalizedString("gourmet_echizen_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_sauce_katsu_don", description: NSLocalizedString("gourmet_sauce_katsu_don_desc", comment: ""), category: .meat, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_habutae_mochi", description: NSLocalizedString("gourmet_habutae_mochi_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_wakasa_beef", description: NSLocalizedString("gourmet_wakasa_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .ishikawa:
            return [
                GourmetItem(nameKey: "gourmet_kaga_cuisine", description: NSLocalizedString("gourmet_kaga_cuisine_desc", comment: ""), category: .local, imageSymbol: "fish.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_kanazawa_curry", description: NSLocalizedString("gourmet_kanazawa_curry_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_noto_beef", description: NSLocalizedString("gourmet_noto_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_jibuni", description: NSLocalizedString("gourmet_jibuni_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_nodoguro", description: NSLocalizedString("gourmet_nodoguro_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_hanton_rice", description: NSLocalizedString("gourmet_hanton_rice_desc", comment: ""), category: .local, imageSymbol: "fork.knife", price: "900-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_kanazawa_oden", description: NSLocalizedString("gourmet_kanazawa_oden_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3)
            ]
        case .toyama:
            return [
                GourmetItem(nameKey: "gourmet_shiro_ebi", description: NSLocalizedString("gourmet_shiro_ebi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_spring_summer", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_hotaru_ika", description: NSLocalizedString("gourmet_hotaru_ika_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_spring", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_masu_sushi", description: NSLocalizedString("gourmet_masu_sushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,200-2,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(nameKey: "gourmet_toyama_black_ramen", description: NSLocalizedString("gourmet_toyama_black_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_himi_beef", description: NSLocalizedString("gourmet_himi_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .shiga:
            return [
                GourmetItem(nameKey: "gourmet_omi_beef", description: NSLocalizedString("gourmet_omi_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-15,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(nameKey: "gourmet_funa_sushi", description: NSLocalizedString("gourmet_funa_sushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 2),
                GourmetItem(nameKey: "gourmet_aka_konnyaku", description: NSLocalizedString("gourmet_aka_konnyaku_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_shigaraki_pottery", description: NSLocalizedString("gourmet_shigaraki_pottery_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "1,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(nameKey: "gourmet_lake_fish_cuisine", description: NSLocalizedString("gourmet_lake_fish_cuisine_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        }
    }
}
