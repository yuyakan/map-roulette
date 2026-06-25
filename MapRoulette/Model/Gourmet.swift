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
    let name: String
    let description: String
    let category: FoodCategory
    let imageSymbol: String
    let price: String
    let bestSeason: String
    let popularity: Int // 1-5
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
                GourmetItem(name: NSLocalizedString("gourmet_genghis_khan", comment: ""), description: NSLocalizedString("gourmet_genghis_khan_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_seafood_bowl", comment: ""), description: NSLocalizedString("gourmet_seafood_bowl_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_soup_curry", comment: ""), description: NSLocalizedString("gourmet_soup_curry_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "1,200-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_yubari_melon", comment: ""), description: NSLocalizedString("gourmet_yubari_melon_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_shiroi_koibito", comment: ""), description: NSLocalizedString("gourmet_shiroi_koibito_desc", comment: ""), category: .sweets, imageSymbol: "heart.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_sapporo_miso_ramen", comment: ""), description: NSLocalizedString("gourmet_sapporo_miso_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_zangi", comment: ""), description: NSLocalizedString("gourmet_zangi_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .kyoto:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_yudofu", comment: ""), description: NSLocalizedString("gourmet_yudofu_desc", comment: ""), category: .local, imageSymbol: "rectangle.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kyoto_kaiseki", comment: ""), description: NSLocalizedString("gourmet_kyoto_kaiseki_desc", comment: ""), category: .local, imageSymbol: "fish.fill", price: "10,000-50,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_matcha_sweets", comment: ""), description: NSLocalizedString("gourmet_matcha_sweets_desc", comment: ""), category: .sweets, imageSymbol: "leaf.fill", price: "500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_obanzai", comment: ""), description: NSLocalizedString("gourmet_obanzai_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kyoto_pickles", comment: ""), description: NSLocalizedString("gourmet_kyoto_pickles_desc", comment: ""), category: .vegetables, imageSymbol: "leaf.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_nishin_soba", comment: ""), description: NSLocalizedString("gourmet_nishin_soba_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "900-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kyoto_yuba", comment: ""), description: NSLocalizedString("gourmet_kyoto_yuba_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "1,500-4,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .hyogo:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_kobe_beef", comment: ""), description: NSLocalizedString("gourmet_kobe_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "5,000-50,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_akashiyaki", comment: ""), description: NSLocalizedString("gourmet_akashiyaki_desc", comment: ""), category: .seafood, imageSymbol: "circle.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_ikanago", comment: ""), description: NSLocalizedString("gourmet_ikanago_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_spring", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_banshu_ramen", comment: ""), description: NSLocalizedString("gourmet_banshu_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_awaji_onion", comment: ""), description: NSLocalizedString("gourmet_awaji_onion_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_spring_summer", comment: ""), popularity: 4)
            ]
        case .nara:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_kakinoha_sushi", comment: ""), description: NSLocalizedString("gourmet_kakinoha_sushi_desc", comment: ""), category: .seafood, imageSymbol: "leaf.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_miwa_somen", comment: ""), description: NSLocalizedString("gourmet_miwa_somen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_narazuke", comment: ""), description: NSLocalizedString("gourmet_narazuke_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_yamato_beef", comment: ""), description: NSLocalizedString("gourmet_yamato_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_kuzukiri", comment: ""), description: NSLocalizedString("gourmet_kuzukiri_desc", comment: ""), category: .sweets, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .wakayama:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_umeboshi", comment: ""), description: NSLocalizedString("gourmet_umeboshi_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_wakayama_ramen", comment: ""), description: NSLocalizedString("gourmet_wakayama_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_tuna", comment: ""), description: NSLocalizedString("gourmet_tuna_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_persimmon", comment: ""), description: NSLocalizedString("gourmet_persimmon_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "200-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_kishu_kinzanji_miso", comment: ""), description: NSLocalizedString("gourmet_kishu_kinzanji_miso_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .osaka:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_takoyaki", comment: ""), description: NSLocalizedString("gourmet_takoyaki_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "500-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_okonomiyaki", comment: ""), description: NSLocalizedString("gourmet_okonomiyaki_desc", comment: ""), category: .local, imageSymbol: "circle.grid.3x3.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_kushikatsu", comment: ""), description: NSLocalizedString("gourmet_kushikatsu_desc", comment: ""), category: .meat, imageSymbol: "minus.rectangle.fill", price: "100-300円/本", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_ikayaki", comment: ""), description: NSLocalizedString("gourmet_ikayaki_desc", comment: ""), category: .seafood, imageSymbol: "oval.fill", price: "400-600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_butaman", comment: ""), description: NSLocalizedString("gourmet_butaman_desc", comment: ""), category: .local, imageSymbol: "circle.hexagonpath.fill", price: "200-400円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_niku_sui", comment: ""), description: NSLocalizedString("gourmet_niku_sui_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_doteyaki", comment: ""), description: NSLocalizedString("gourmet_doteyaki_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3)
            ]
        case .tottori:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_matsuba_crab", comment: ""), description: NSLocalizedString("gourmet_matsuba_crab_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_nijisseiki_pear", comment: ""), description: NSLocalizedString("gourmet_nijisseiki_pear_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-1,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_sakaiminato_seafood", comment: ""), description: NSLocalizedString("gourmet_sakaiminato_seafood_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_tofu_chikuwa", comment: ""), description: NSLocalizedString("gourmet_tofu_chikuwa_desc", comment: ""), category: .local, imageSymbol: "minus.rectangle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_gyu_kotsu_ramen", comment: ""), description: NSLocalizedString("gourmet_gyu_kotsu_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .okayama:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_white_peach", comment: ""), description: NSLocalizedString("gourmet_white_peach_desc", comment: ""), category: .vegetables, imageSymbol: "heart.fill", price: "500-3,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_muscat", comment: ""), description: NSLocalizedString("gourmet_muscat_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_summer_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kibidango", comment: ""), description: NSLocalizedString("gourmet_kibidango_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_mamakari", comment: ""), description: NSLocalizedString("gourmet_mamakari_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_demi_katsu_don", comment: ""), description: NSLocalizedString("gourmet_demi_katsu_don_desc", comment: ""), category: .meat, imageSymbol: "bowl.fill", price: "1,000-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .hiroshima:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_okonomiyaki_hiroshima", comment: ""), description: NSLocalizedString("gourmet_okonomiyaki_hiroshima_desc", comment: ""), category: .local, imageSymbol: "circle.grid.3x3.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_oyster", comment: ""), description: NSLocalizedString("gourmet_oyster_desc", comment: ""), category: .seafood, imageSymbol: "oval.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_momiji_manju", comment: ""), description: NSLocalizedString("gourmet_momiji_manju_desc", comment: ""), category: .sweets, imageSymbol: "leaf.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_hiroshima_tsukemen", comment: ""), description: NSLocalizedString("gourmet_hiroshima_tsukemen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_anago_meshi", comment: ""), description: NSLocalizedString("gourmet_anago_meshi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .yamaguchi:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_fugu", comment: ""), description: NSLocalizedString("gourmet_fugu_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_kawara_soba", comment: ""), description: NSLocalizedString("gourmet_kawara_soba_desc", comment: ""), category: .ramen, imageSymbol: "rectangle.fill", price: "1,200-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_iwakuni_lotus_root", comment: ""), description: NSLocalizedString("gourmet_iwakuni_lotus_root_desc", comment: ""), category: .vegetables, imageSymbol: "circle.grid.3x3.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_shimonoseki_whale", comment: ""), description: NSLocalizedString("gourmet_shimonoseki_whale_desc", comment: ""), category: .meat, imageSymbol: "fish.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 2),
                GourmetItem(name: NSLocalizedString("gourmet_natsumikan", comment: ""), description: NSLocalizedString("gourmet_natsumikan_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "200-600円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .shimane:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_izumo_soba", comment: ""), description: NSLocalizedString("gourmet_izumo_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_shinjiko_shijimi", comment: ""), description: NSLocalizedString("gourmet_shinjiko_shijimi_desc", comment: ""), category: .seafood, imageSymbol: "oval.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_nodoguro_shimane", comment: ""), description: NSLocalizedString("gourmet_nodoguro_shimane_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_matsue_wagashi", comment: ""), description: NSLocalizedString("gourmet_matsue_wagashi_desc", comment: ""), category: .sweets, imageSymbol: "heart.fill", price: "300-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_wariko_soba", comment: ""), description: NSLocalizedString("gourmet_wariko_soba_desc", comment: ""), category: .ramen, imageSymbol: "circle.fill", price: "1,000-1,800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .kagawa:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_sanuki_udon", comment: ""), description: NSLocalizedString("gourmet_sanuki_udon_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "200-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_olive", comment: ""), description: NSLocalizedString("gourmet_olive_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "800-3,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_honetsuki_dori", comment: ""), description: NSLocalizedString("gourmet_honetsuki_dori_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_wasanbon", comment: ""), description: NSLocalizedString("gourmet_wasanbon_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_shodoshima_somen", comment: ""), description: NSLocalizedString("gourmet_shodoshima_somen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .tokushima:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_awa_odori_chicken", comment: ""), description: NSLocalizedString("gourmet_awa_odori_chicken_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_tarai_udon", comment: ""), description: NSLocalizedString("gourmet_tarai_udon_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_sudachi", comment: ""), description: NSLocalizedString("gourmet_sudachi_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_naruto_kintoki", comment: ""), description: NSLocalizedString("gourmet_naruto_kintoki_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_handa_somen", comment: ""), description: NSLocalizedString("gourmet_handa_somen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-1,200円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .kochi:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_katsuo_tataki", comment: ""), description: NSLocalizedString("gourmet_katsuo_tataki_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_sawachi_cuisine", comment: ""), description: NSLocalizedString("gourmet_sawachi_cuisine_desc", comment: ""), category: .local, imageSymbol: "fish.fill", price: "3,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_tosa_sake", comment: ""), description: NSLocalizedString("gourmet_tosa_sake_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_yuzu", comment: ""), description: NSLocalizedString("gourmet_yuzu_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_tosa_buntan", comment: ""), description: NSLocalizedString("gourmet_tosa_buntan_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_spring", comment: ""), popularity: 3)
            ]
        case .ehime:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_mikan", comment: ""), description: NSLocalizedString("gourmet_mikan_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-1,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_jakoten", comment: ""), description: NSLocalizedString("gourmet_jakoten_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_tai_meshi", comment: ""), description: NSLocalizedString("gourmet_tai_meshi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_iyokan", comment: ""), description: NSLocalizedString("gourmet_iyokan_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_winter_spring", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_botchan_dango", comment: ""), description: NSLocalizedString("gourmet_botchan_dango_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "300-600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .fukuoka:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_hakata_ramen", comment: ""), description: NSLocalizedString("gourmet_hakata_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_motsu_nabe", comment: ""), description: NSLocalizedString("gourmet_motsu_nabe_desc", comment: ""), category: .meat, imageSymbol: "bowl.fill", price: "2,000-4,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_karashi_mentaiko", comment: ""), description: NSLocalizedString("gourmet_karashi_mentaiko_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_mizutaki", comment: ""), description: NSLocalizedString("gourmet_mizutaki_desc", comment: ""), category: .meat, imageSymbol: "bowl.fill", price: "2,500-5,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_hakata_torimon", comment: ""), description: NSLocalizedString("gourmet_hakata_torimon_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "1,000-2,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_gobo_ten_udon", comment: ""), description: NSLocalizedString("gourmet_gobo_ten_udon_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-900円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_goma_saba", comment: ""), description: NSLocalizedString("gourmet_goma_saba_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "700-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .oita:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_seki_saba_aji", comment: ""), description: NSLocalizedString("gourmet_seki_saba_aji_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_toriten", comment: ""), description: NSLocalizedString("gourmet_toriten_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_dango_soup", comment: ""), description: NSLocalizedString("gourmet_dango_soup_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_bungo_beef", comment: ""), description: NSLocalizedString("gourmet_bungo_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kabosu", comment: ""), description: NSLocalizedString("gourmet_kabosu_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4)
            ]
        case .miyazaki:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_miyazaki_beef", comment: ""), description: NSLocalizedString("gourmet_miyazaki_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-15,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_chicken_nanban", comment: ""), description: NSLocalizedString("gourmet_chicken_nanban_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_hiyajiru", comment: ""), description: NSLocalizedString("gourmet_hiyajiru_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "600-1,200円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_miyazaki_mango", comment: ""), description: NSLocalizedString("gourmet_miyazaki_mango_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_miyazaki_shochu", comment: ""), description: NSLocalizedString("gourmet_miyazaki_shochu_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .kagoshima:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_kurobuta", comment: ""), description: NSLocalizedString("gourmet_kurobuta_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_satsuma_imo", comment: ""), description: NSLocalizedString("gourmet_satsuma_imo_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "200-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kagoshima_shochu", comment: ""), description: NSLocalizedString("gourmet_kagoshima_shochu_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_kibinago", comment: ""), description: NSLocalizedString("gourmet_kibinago_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_shirokuma", comment: ""), description: NSLocalizedString("gourmet_shirokuma_desc", comment: ""), category: .sweets, imageSymbol: "snowflake", price: "500-1,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4)
            ]
        case .kumamoto:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_basashi", comment: ""), description: NSLocalizedString("gourmet_basashi_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_dago_soup", comment: ""), description: NSLocalizedString("gourmet_dago_soup_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_taipien", comment: ""), description: NSLocalizedString("gourmet_taipien_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_karashi_renkon", comment: ""), description: NSLocalizedString("gourmet_karashi_renkon_desc", comment: ""), category: .vegetables, imageSymbol: "circle.grid.3x3.fill", price: "500-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_ikinari_dango", comment: ""), description: NSLocalizedString("gourmet_ikinari_dango_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "200-400円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .saga:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_saga_beef", comment: ""), description: NSLocalizedString("gourmet_saga_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-12,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_yobuko_ika", comment: ""), description: NSLocalizedString("gourmet_yobuko_ika_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_gabai_manju", comment: ""), description: NSLocalizedString("gourmet_gabai_manju_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_marubolo", comment: ""), description: NSLocalizedString("gourmet_marubolo_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_onsen_yudofu", comment: ""), description: NSLocalizedString("gourmet_onsen_yudofu_desc", comment: ""), category: .local, imageSymbol: "rectangle.fill", price: "1,200-2,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .nagasaki:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_champon", comment: ""), description: NSLocalizedString("gourmet_champon_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_sara_udon", comment: ""), description: NSLocalizedString("gourmet_sara_udon_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_castella", comment: ""), description: NSLocalizedString("gourmet_castella_desc", comment: ""), category: .sweets, imageSymbol: "rectangle.fill", price: "1,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_sasebo_burger", comment: ""), description: NSLocalizedString("gourmet_sasebo_burger_desc", comment: ""), category: .local, imageSymbol: "circle.hexagonpath.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kakuni_manju", comment: ""), description: NSLocalizedString("gourmet_kakuni_manju_desc", comment: ""), category: .meat, imageSymbol: "circle.fill", price: "300-600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .okinawa:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_goya_chanpuru", comment: ""), description: NSLocalizedString("gourmet_goya_chanpuru_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_soki_soba", comment: ""), description: NSLocalizedString("gourmet_soki_soba_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_sata_andagi", comment: ""), description: NSLocalizedString("gourmet_sata_andagi_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_umi_budo", comment: ""), description: NSLocalizedString("gourmet_umi_budo_desc", comment: ""), category: .seafood, imageSymbol: "circle.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_awamori", comment: ""), description: NSLocalizedString("gourmet_awamori_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_taco_rice", comment: ""), description: NSLocalizedString("gourmet_taco_rice_desc", comment: ""), category: .local, imageSymbol: "fork.knife", price: "600-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_rafute", comment: ""), description: NSLocalizedString("gourmet_rafute_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .aomori:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_aomori_apple", comment: ""), description: NSLocalizedString("gourmet_aomori_apple_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "100-500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_oma_tuna", comment: ""), description: NSLocalizedString("gourmet_oma_tuna_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "5,000-20,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_senbei_soup", comment: ""), description: NSLocalizedString("gourmet_senbei_soup_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-800円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_tsugaru_soba", comment: ""), description: NSLocalizedString("gourmet_tsugaru_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_ichigo_ni", comment: ""), description: NSLocalizedString("gourmet_ichigo_ni_desc", comment: ""), category: .seafood, imageSymbol: "bowl.fill", price: "2,000-4,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4)
            ]
        case .iwate:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_wanko_soba", comment: ""), description: NSLocalizedString("gourmet_wanko_soba_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "2,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_morioka_cold_noodles", comment: ""), description: NSLocalizedString("gourmet_morioka_cold_noodles_desc", comment: ""), category: .ramen, imageSymbol: "snowflake", price: "800-1,200円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_maezawa_beef", comment: ""), description: NSLocalizedString("gourmet_maezawa_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_nanbu_senbei", comment: ""), description: NSLocalizedString("gourmet_nanbu_senbei_desc", comment: ""), category: .sweets, imageSymbol: "circle.grid.3x3.fill", price: "300-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_gangetsu", comment: ""), description: NSLocalizedString("gourmet_gangetsu_desc", comment: ""), category: .sweets, imageSymbol: "moon.fill", price: "150-300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .akita:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_kiritanpo", comment: ""), description: NSLocalizedString("gourmet_kiritanpo_desc", comment: ""), category: .local, imageSymbol: "minus.rectangle.fill", price: "1,500-2,500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_hinai_chicken", comment: ""), description: NSLocalizedString("gourmet_hinai_chicken_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "2,000-4,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_inaniwa_udon", comment: ""), description: NSLocalizedString("gourmet_inaniwa_udon_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_akita_komachi", comment: ""), description: NSLocalizedString("gourmet_akita_komachi_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "2,000-4,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_babahera_ice", comment: ""), description: NSLocalizedString("gourmet_babahera_ice_desc", comment: ""), category: .sweets, imageSymbol: "snowflake", price: "200-300円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .miyagi:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_beef_tongue", comment: ""), description: NSLocalizedString("gourmet_beef_tongue_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_sasukamaboko", comment: ""), description: NSLocalizedString("gourmet_sasukamaboko_desc", comment: ""), category: .seafood, imageSymbol: "leaf.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_zunda_mochi", comment: ""), description: NSLocalizedString("gourmet_zunda_mochi_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "300-600円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_seri_nabe", comment: ""), description: NSLocalizedString("gourmet_seri_nabe_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "2,000-3,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_shiroishi_somen", comment: ""), description: NSLocalizedString("gourmet_shiroishi_somen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .yamagata:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_cherry", comment: ""), description: NSLocalizedString("gourmet_cherry_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_yonezawa_beef", comment: ""), description: NSLocalizedString("gourmet_yonezawa_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "5,000-15,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_imoni", comment: ""), description: NSLocalizedString("gourmet_imoni_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_tama_konnyaku", comment: ""), description: NSLocalizedString("gourmet_tama_konnyaku_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "100-200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_cold_ramen", comment: ""), description: NSLocalizedString("gourmet_cold_ramen_desc", comment: ""), category: .ramen, imageSymbol: "snowflake", price: "700-1,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3)
            ]
        case .fukushima:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_kitakata_ramen", comment: ""), description: NSLocalizedString("gourmet_kitakata_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_aizu_chicken", comment: ""), description: NSLocalizedString("gourmet_aizu_chicken_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_mamadooru", comment: ""), description: NSLocalizedString("gourmet_mamadooru_desc", comment: ""), category: .sweets, imageSymbol: "heart.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_fukushima_peach", comment: ""), description: NSLocalizedString("gourmet_fukushima_peach_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_shirakawa_ramen", comment: ""), description: NSLocalizedString("gourmet_shirakawa_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "600-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .ibaraki:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_natto", comment: ""), description: NSLocalizedString("gourmet_natto_desc", comment: ""), category: .local, imageSymbol: "oval.fill", price: "100-300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_anko_nabe", comment: ""), description: NSLocalizedString("gourmet_anko_nabe_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-8,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_hitachi_beef", comment: ""), description: NSLocalizedString("gourmet_hitachi_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-6,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_ibaraki_melon", comment: ""), description: NSLocalizedString("gourmet_ibaraki_melon_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_dried_sweet_potato", comment: ""), description: NSLocalizedString("gourmet_dried_sweet_potato_desc", comment: ""), category: .sweets, imageSymbol: "leaf.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 3)
            ]
        case .chiba:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_peanuts", comment: ""), description: NSLocalizedString("gourmet_peanuts_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_loquat", comment: ""), description: NSLocalizedString("gourmet_loquat_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "200-500円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_namerou", comment: ""), description: NSLocalizedString("gourmet_namerou_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_katsuura_tantanmen", comment: ""), description: NSLocalizedString("gourmet_katsuura_tantanmen_desc", comment: ""), category: .ramen, imageSymbol: "flame.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_boso_seafood", comment: ""), description: NSLocalizedString("gourmet_boso_seafood_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .tochigi:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_utsunomiya_gyoza", comment: ""), description: NSLocalizedString("gourmet_utsunomiya_gyoza_desc", comment: ""), category: .local, imageSymbol: "circle.hexagonpath.fill", price: "300-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_yuba", comment: ""), description: NSLocalizedString("gourmet_yuba_desc", comment: ""), category: .local, imageSymbol: "rectangle.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_tochiotome", comment: ""), description: NSLocalizedString("gourmet_tochiotome_desc", comment: ""), category: .vegetables, imageSymbol: "heart.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_winter_spring", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_shimotsukare", comment: ""), description: NSLocalizedString("gourmet_shimotsukare_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "300-600円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 2),
                GourmetItem(name: NSLocalizedString("gourmet_lemon_milk", comment: ""), description: NSLocalizedString("gourmet_lemon_milk_desc", comment: ""), category: .drinks, imageSymbol: "drop.fill", price: "150-200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .gunma:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_yaki_manju", comment: ""), description: NSLocalizedString("gourmet_yaki_manju_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "100-200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_shimonita_negi", comment: ""), description: NSLocalizedString("gourmet_shimonita_negi_desc", comment: ""), category: .vegetables, imageSymbol: "minus.rectangle.fill", price: "300-800円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_konnyaku", comment: ""), description: NSLocalizedString("gourmet_konnyaku_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_mizusawa_udon", comment: ""), description: NSLocalizedString("gourmet_mizusawa_udon_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_daruma_bento", comment: ""), description: NSLocalizedString("gourmet_daruma_bento_desc", comment: ""), category: .local, imageSymbol: "oval.fill", price: "1,000-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .saitama:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_kawagoe_sweet_potato", comment: ""), description: NSLocalizedString("gourmet_kawagoe_sweet_potato_desc", comment: ""), category: .vegetables, imageSymbol: "oval.fill", price: "300-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_chichibu_soba", comment: ""), description: NSLocalizedString("gourmet_chichibu_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_soka_senbei", comment: ""), description: NSLocalizedString("gourmet_soka_senbei_desc", comment: ""), category: .sweets, imageSymbol: "circle.grid.3x3.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_gokaho", comment: ""), description: NSLocalizedString("gourmet_gokaho_desc", comment: ""), category: .sweets, imageSymbol: "rectangle.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 2),
                GourmetItem(name: NSLocalizedString("gourmet_iga_manju", comment: ""), description: NSLocalizedString("gourmet_iga_manju_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "150-300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 2)
            ]
        case .tokyo:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_edomae_sushi", comment: ""), description: NSLocalizedString("gourmet_edomae_sushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-30,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_monjayaki", comment: ""), description: NSLocalizedString("gourmet_monjayaki_desc", comment: ""), category: .local, imageSymbol: "circle.grid.3x3.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_fukagawa_don", comment: ""), description: NSLocalizedString("gourmet_fukagawa_don_desc", comment: ""), category: .seafood, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_imagawayaki", comment: ""), description: NSLocalizedString("gourmet_imagawayaki_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "100-200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_tsukudani", comment: ""), description: NSLocalizedString("gourmet_tsukudani_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "500-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_chanko_nabe", comment: ""), description: NSLocalizedString("gourmet_chanko_nabe_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_edomae_tempura", comment: ""), description: NSLocalizedString("gourmet_edomae_tempura_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .kanagawa:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_shumai", comment: ""), description: NSLocalizedString("gourmet_shumai_desc", comment: ""), category: .local, imageSymbol: "circle.hexagonpath.fill", price: "600-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_kamakura_vegetables", comment: ""), description: NSLocalizedString("gourmet_kamakura_vegetables_desc", comment: ""), category: .vegetables, imageSymbol: "leaf.fill", price: "200-800円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_shonan_shirasu", comment: ""), description: NSLocalizedString("gourmet_shonan_shirasu_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_spring_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_iekei_ramen", comment: ""), description: NSLocalizedString("gourmet_iekei_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_yokohama_chinatown_gourmet", comment: ""), description: NSLocalizedString("gourmet_yokohama_chinatown_gourmet_desc", comment: ""), category: .local, imageSymbol: "flame.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_sanma_men", comment: ""), description: NSLocalizedString("gourmet_sanma_men_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "700-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_yokosuka_navy_curry", comment: ""), description: NSLocalizedString("gourmet_yokosuka_navy_curry_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "900-1,600円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .niigata:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_niigata_rice", comment: ""), description: NSLocalizedString("gourmet_niigata_rice_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_noppe", comment: ""), description: NSLocalizedString("gourmet_noppe_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_hegi_soba", comment: ""), description: NSLocalizedString("gourmet_hegi_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_niigata_salmon", comment: ""), description: NSLocalizedString("gourmet_niigata_salmon_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_sake", comment: ""), description: NSLocalizedString("gourmet_sake_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5)
            ]
        case .nagano:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_shinshu_soba", comment: ""), description: NSLocalizedString("gourmet_shinshu_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_oyaki", comment: ""), description: NSLocalizedString("gourmet_oyaki_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "200-400円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_nozawana", comment: ""), description: NSLocalizedString("gourmet_nozawana_desc", comment: ""), category: .vegetables, imageSymbol: "leaf.fill", price: "300-800円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_shinshu_apple", comment: ""), description: NSLocalizedString("gourmet_shinshu_apple_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "200-800円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_shinshu_miso", comment: ""), description: NSLocalizedString("gourmet_shinshu_miso_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .yamanashi:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_hoto", comment: ""), description: NSLocalizedString("gourmet_hoto_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_shingen_mochi", comment: ""), description: NSLocalizedString("gourmet_shingen_mochi_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "500-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_yamanashi_grape", comment: ""), description: NSLocalizedString("gourmet_yamanashi_grape_desc", comment: ""), category: .vegetables, imageSymbol: "circle.fill", price: "800-3,000円", bestSeason: NSLocalizedString("season_summer_autumn", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_yamanashi_peach", comment: ""), description: NSLocalizedString("gourmet_yamanashi_peach_desc", comment: ""), category: .vegetables, imageSymbol: "heart.fill", price: "300-1,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_koshu_wine", comment: ""), description: NSLocalizedString("gourmet_koshu_wine_desc", comment: ""), category: .drinks, imageSymbol: "wineglass.fill", price: "1,500-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .shizuoka:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_shizuoka_tea", comment: ""), description: NSLocalizedString("gourmet_shizuoka_tea_desc", comment: ""), category: .drinks, imageSymbol: "leaf.fill", price: "1,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_unagi", comment: ""), description: NSLocalizedString("gourmet_unagi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_wasabi", comment: ""), description: NSLocalizedString("gourmet_wasabi_desc", comment: ""), category: .vegetables, imageSymbol: "leaf.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_sakura_ebi", comment: ""), description: NSLocalizedString("gourmet_sakura_ebi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,000-3,000円", bestSeason: NSLocalizedString("season_spring_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kuro_hanpen", comment: ""), description: NSLocalizedString("gourmet_kuro_hanpen_desc", comment: ""), category: .seafood, imageSymbol: "oval.fill", price: "100-300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .aichi:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_miso_katsu", comment: ""), description: NSLocalizedString("gourmet_miso_katsu_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_hitsumabushi", comment: ""), description: NSLocalizedString("gourmet_hitsumabushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,500-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_tebasaki", comment: ""), description: NSLocalizedString("gourmet_tebasaki_desc", comment: ""), category: .meat, imageSymbol: "bird.fill", price: "600-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kishimen", comment: ""), description: NSLocalizedString("gourmet_kishimen_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "500-1,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_taiwan_ramen", comment: ""), description: NSLocalizedString("gourmet_taiwan_ramen_desc", comment: ""), category: .ramen, imageSymbol: "flame.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_miso_nikomi_udon", comment: ""), description: NSLocalizedString("gourmet_miso_nikomi_udon_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "900-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_ankake_spa", comment: ""), description: NSLocalizedString("gourmet_ankake_spa_desc", comment: ""), category: .local, imageSymbol: "fork.knife", price: "800-1,300円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .mie:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_ise_ebi", comment: ""), description: NSLocalizedString("gourmet_ise_ebi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-15,000円", bestSeason: NSLocalizedString("season_autumn_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_matsusaka_beef", comment: ""), description: NSLocalizedString("gourmet_matsusaka_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_akafuku", comment: ""), description: NSLocalizedString("gourmet_akafuku_desc", comment: ""), category: .sweets, imageSymbol: "heart.fill", price: "200-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_tekone_sushi", comment: ""), description: NSLocalizedString("gourmet_tekone_sushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_iga_beef", comment: ""), description: NSLocalizedString("gourmet_iga_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .gifu:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_hida_beef", comment: ""), description: NSLocalizedString("gourmet_hida_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-15,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_hoba_miso", comment: ""), description: NSLocalizedString("gourmet_hoba_miso_desc", comment: ""), category: .local, imageSymbol: "leaf.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_gohei_mochi", comment: ""), description: NSLocalizedString("gourmet_gohei_mochi_desc", comment: ""), category: .local, imageSymbol: "oval.fill", price: "200-400円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_ayu_shioyaki", comment: ""), description: NSLocalizedString("gourmet_ayu_shioyaki_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_summer", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_kuri_kinton", comment: ""), description: NSLocalizedString("gourmet_kuri_kinton_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_autumn", comment: ""), popularity: 3)
            ]
        case .fukui:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_echizen_crab", comment: ""), description: NSLocalizedString("gourmet_echizen_crab_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_winter", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_echizen_soba", comment: ""), description: NSLocalizedString("gourmet_echizen_soba_desc", comment: ""), category: .ramen, imageSymbol: "minus.rectangle.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_sauce_katsu_don", comment: ""), description: NSLocalizedString("gourmet_sauce_katsu_don_desc", comment: ""), category: .meat, imageSymbol: "bowl.fill", price: "800-1,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_habutae_mochi", comment: ""), description: NSLocalizedString("gourmet_habutae_mochi_desc", comment: ""), category: .sweets, imageSymbol: "circle.fill", price: "1,000-2,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_wakasa_beef", comment: ""), description: NSLocalizedString("gourmet_wakasa_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .ishikawa:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_kaga_cuisine", comment: ""), description: NSLocalizedString("gourmet_kaga_cuisine_desc", comment: ""), category: .local, imageSymbol: "fish.fill", price: "5,000-30,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_kanazawa_curry", comment: ""), description: NSLocalizedString("gourmet_kanazawa_curry_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_noto_beef", comment: ""), description: NSLocalizedString("gourmet_noto_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_jibuni", comment: ""), description: NSLocalizedString("gourmet_jibuni_desc", comment: ""), category: .local, imageSymbol: "bowl.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_nodoguro", comment: ""), description: NSLocalizedString("gourmet_nodoguro_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "3,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4)
            ]
        case .toyama:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_shiro_ebi", comment: ""), description: NSLocalizedString("gourmet_shiro_ebi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_spring_summer", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_hotaru_ika", comment: ""), description: NSLocalizedString("gourmet_hotaru_ika_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "800-2,000円", bestSeason: NSLocalizedString("season_spring", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_masu_sushi", comment: ""), description: NSLocalizedString("gourmet_masu_sushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,200-2,500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 4),
                GourmetItem(name: NSLocalizedString("gourmet_toyama_black_ramen", comment: ""), description: NSLocalizedString("gourmet_toyama_black_ramen_desc", comment: ""), category: .ramen, imageSymbol: "bowl.fill", price: "800-1,200円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_himi_beef", comment: ""), description: NSLocalizedString("gourmet_himi_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "2,000-8,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        case .shiga:
            return [
                GourmetItem(name: NSLocalizedString("gourmet_omi_beef", comment: ""), description: NSLocalizedString("gourmet_omi_beef_desc", comment: ""), category: .meat, imageSymbol: "flame.fill", price: "3,000-15,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 5),
                GourmetItem(name: NSLocalizedString("gourmet_funa_sushi", comment: ""), description: NSLocalizedString("gourmet_funa_sushi_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "2,000-5,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 2),
                GourmetItem(name: NSLocalizedString("gourmet_aka_konnyaku", comment: ""), description: NSLocalizedString("gourmet_aka_konnyaku_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "200-500円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_shigaraki_pottery", comment: ""), description: NSLocalizedString("gourmet_shigaraki_pottery_desc", comment: ""), category: .local, imageSymbol: "circle.fill", price: "1,000-10,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3),
                GourmetItem(name: NSLocalizedString("gourmet_lake_fish_cuisine", comment: ""), description: NSLocalizedString("gourmet_lake_fish_cuisine_desc", comment: ""), category: .seafood, imageSymbol: "fish.fill", price: "1,500-3,000円", bestSeason: NSLocalizedString("season_all_year", comment: ""), popularity: 3)
            ]
        }
    }
}
