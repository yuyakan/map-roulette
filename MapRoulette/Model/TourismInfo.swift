//
//  TourismInfo.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/20.
//

import SwiftUI
import MapKit

// 観光情報データ構造
struct TourismInfo {
    let attractions: [AttractionLocation]
    let foods: [String]
    let searchKeyword: String // Unsplash検索用キーワード
    let region: CLLocationCoordinate2D // 地域の中心座標
}

// 観光スポット情報を保持する構造体
struct AttractionLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let description: String
}

// 都道府県別観光情報データ
import CoreLocation

// ローカライズされた観光地情報構造体
struct LocalizedAttractionLocation: Identifiable {
    let id = UUID()
    let nameKey: String
    let descriptionKey: String
    let coordinate: CLLocationCoordinate2D
    
    var name: String {
        return NSLocalizedString(nameKey, comment: "")
    }
    
    var description: String {
        return NSLocalizedString(descriptionKey, comment: "")
    }
}

// ローカライズされた観光情報構造体
struct LocalizedTourismInfo {
    let attractions: [LocalizedAttractionLocation]
    let foodKeys: [String]
    let searchKeyword: String
    let region: CLLocationCoordinate2D
    
    var foods: [String] {
        return foodKeys.map { NSLocalizedString($0, comment: "") }
    }
}

extension Prefecture {
    var tourismInfo: LocalizedTourismInfo {
        switch self {
        case .hokkaido:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_sapporo_snow_festival", descriptionKey: "attraction_sapporo_snow_festival_desc", coordinate: CLLocationCoordinate2D(latitude: 43.0642, longitude: 141.3469)),
                    LocalizedAttractionLocation(nameKey: "attraction_hakodate_mountain", descriptionKey: "attraction_hakodate_mountain_desc", coordinate: CLLocationCoordinate2D(latitude: 41.7518, longitude: 140.7013)),
                    LocalizedAttractionLocation(nameKey: "attraction_asahiyama_zoo", descriptionKey: "attraction_asahiyama_zoo_desc", coordinate: CLLocationCoordinate2D(latitude: 43.7682, longitude: 142.4626)),
                    LocalizedAttractionLocation(nameKey: "attraction_furano_lavender", descriptionKey: "attraction_furano_lavender_desc", coordinate: CLLocationCoordinate2D(latitude: 43.3417, longitude: 142.3833)),
                    LocalizedAttractionLocation(nameKey: "attraction_shiretoko_lakes", descriptionKey: "attraction_shiretoko_lakes_desc", coordinate: CLLocationCoordinate2D(latitude: 44.1288, longitude: 145.0085)),
                    LocalizedAttractionLocation(nameKey: "attraction_otaru_canal", descriptionKey: "attraction_otaru_canal_desc", coordinate: CLLocationCoordinate2D(latitude: 43.1907, longitude: 141.0006)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_toya", descriptionKey: "attraction_lake_toya_desc", coordinate: CLLocationCoordinate2D(latitude: 42.5833, longitude: 140.8333)),
                    LocalizedAttractionLocation(nameKey: "attraction_goryokaku", descriptionKey: "attraction_goryokaku_desc", coordinate: CLLocationCoordinate2D(latitude: 41.7965, longitude: 140.7570)),
                    LocalizedAttractionLocation(nameKey: "attraction_noboribetsu_jigokudani", descriptionKey: "attraction_noboribetsu_jigokudani_desc", coordinate: CLLocationCoordinate2D(latitude: 42.4976, longitude: 141.1487))
                ],
                foodKeys: ["food_genghis_khan", "food_seafood_bowl", "food_soup_curry", "food_yubari_melon", "food_shiroi_koibito"],
                searchKeyword: "Hokkaido Japan",
                region: CLLocationCoordinate2D(latitude: 43.2203, longitude: 142.8635)
            )
        case .aomori:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_hirosaki_castle", descriptionKey: "attraction_hirosaki_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 40.6044, longitude: 140.4637)),
                    LocalizedAttractionLocation(nameKey: "attraction_oirase_stream", descriptionKey: "attraction_oirase_stream_desc", coordinate: CLLocationCoordinate2D(latitude: 40.5839, longitude: 140.9464)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_towada", descriptionKey: "attraction_lake_towada_desc", coordinate: CLLocationCoordinate2D(latitude: 40.4667, longitude: 140.8833)),
                    LocalizedAttractionLocation(nameKey: "attraction_shirakami_mountains", descriptionKey: "attraction_shirakami_mountains_desc", coordinate: CLLocationCoordinate2D(latitude: 40.5167, longitude: 140.1333)),
                    LocalizedAttractionLocation(nameKey: "attraction_nebuta_museum", descriptionKey: "attraction_nebuta_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 40.8244, longitude: 140.7400)),
                    LocalizedAttractionLocation(nameKey: "attraction_hakkoda_mountains", descriptionKey: "attraction_hakkoda_mountains_desc", coordinate: CLLocationCoordinate2D(latitude: 40.6500, longitude: 140.8833))
                ],
                foodKeys: ["food_apple", "food_oma_tuna", "food_senbei_soup", "food_tsugaru_soba", "food_ichigo_ni"],
                searchKeyword: "Aomori Japan",
                region: CLLocationCoordinate2D(latitude: 40.8244, longitude: 140.74)
            )
        case .iwate:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_chusonji", descriptionKey: "attraction_chusonji_desc", coordinate: CLLocationCoordinate2D(latitude: 38.9889, longitude: 141.1019)),
                    LocalizedAttractionLocation(nameKey: "attraction_hiraizumi", descriptionKey: "attraction_hiraizumi_desc", coordinate: CLLocationCoordinate2D(latitude: 38.9889, longitude: 141.1019)),
                    LocalizedAttractionLocation(nameKey: "attraction_ryusendo_cave", descriptionKey: "attraction_ryusendo_cave_desc", coordinate: CLLocationCoordinate2D(latitude: 39.8667, longitude: 141.7833)),
                    LocalizedAttractionLocation(nameKey: "attraction_hachimantai", descriptionKey: "attraction_hachimantai_desc", coordinate: CLLocationCoordinate2D(latitude: 39.9500, longitude: 140.8500)),
                    LocalizedAttractionLocation(nameKey: "attraction_hanamaki_onsen", descriptionKey: "attraction_hanamaki_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 39.4333, longitude: 141.0667)),
                    LocalizedAttractionLocation(nameKey: "attraction_jodogahama", descriptionKey: "attraction_jodogahama_desc", coordinate: CLLocationCoordinate2D(latitude: 39.9500, longitude: 141.9833))
                ],
                foodKeys: ["food_wanko_soba", "food_morioka_cold_noodles", "food_maezawa_beef", "food_nanbu_senbei", "food_gangetsu"],
                searchKeyword: "Iwate Japan",
                region: CLLocationCoordinate2D(latitude: 39.7036, longitude: 141.1527)
            )
        case .akita:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kakunodate_samurai_houses", descriptionKey: "attraction_kakunodate_samurai_houses_desc", coordinate: CLLocationCoordinate2D(latitude: 39.5944, longitude: 140.5569)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_tazawa", descriptionKey: "attraction_lake_tazawa_desc", coordinate: CLLocationCoordinate2D(latitude: 39.7222, longitude: 140.6608)),
                    LocalizedAttractionLocation(nameKey: "attraction_namahage_museum", descriptionKey: "attraction_namahage_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 39.9333, longitude: 139.7167)),
                    LocalizedAttractionLocation(nameKey: "attraction_akita_kanto_festival", descriptionKey: "attraction_akita_kanto_festival_desc", coordinate: CLLocationCoordinate2D(latitude: 39.7186, longitude: 140.1023)),
                    LocalizedAttractionLocation(nameKey: "attraction_shirakami_mountains_akita", descriptionKey: "attraction_shirakami_mountains_akita_desc", coordinate: CLLocationCoordinate2D(latitude: 40.5167, longitude: 140.1333)),
                    LocalizedAttractionLocation(nameKey: "attraction_nyuto_onsen", descriptionKey: "attraction_nyuto_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 39.7500, longitude: 140.7167))
                ],
                foodKeys: ["food_kiritanpo", "food_hinai_chicken", "food_inaniwa_udon", "food_akita_komachi", "food_babahera_ice"],
                searchKeyword: "Akita Japan",
                region: CLLocationCoordinate2D(latitude: 39.7186, longitude: 140.1023)
            )
        case .miyagi:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_matsushima", descriptionKey: "attraction_matsushima_desc", coordinate: CLLocationCoordinate2D(latitude: 38.3722, longitude: 141.0667)),
                    LocalizedAttractionLocation(nameKey: "attraction_sendai_castle", descriptionKey: "attraction_sendai_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 38.2548, longitude: 140.8617)),
                    LocalizedAttractionLocation(nameKey: "attraction_zao", descriptionKey: "attraction_zao_desc", coordinate: CLLocationCoordinate2D(latitude: 38.1167, longitude: 140.4333)),
                    LocalizedAttractionLocation(nameKey: "attraction_naruko_onsen", descriptionKey: "attraction_naruko_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 38.7333, longitude: 140.7333)),
                    LocalizedAttractionLocation(nameKey: "attraction_zuiganji", descriptionKey: "attraction_zuiganji_desc", coordinate: CLLocationCoordinate2D(latitude: 38.3722, longitude: 141.0667)),
                    LocalizedAttractionLocation(nameKey: "attraction_akiu_onsen", descriptionKey: "attraction_akiu_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 38.2333, longitude: 140.7167)),
                    LocalizedAttractionLocation(nameKey: "attraction_zuihoden", descriptionKey: "attraction_zuihoden_desc", coordinate: CLLocationCoordinate2D(latitude: 38.2507, longitude: 140.8664)),
                    LocalizedAttractionLocation(nameKey: "attraction_zao_fox_village", descriptionKey: "attraction_zao_fox_village_desc", coordinate: CLLocationCoordinate2D(latitude: 38.0409, longitude: 140.5304))
                ],
                foodKeys: ["food_beef_tongue", "food_sasukamaboko", "food_zunda_mochi", "food_seri_nabe", "food_shiroishi_somen"],
                searchKeyword: "Miyagi Japan",
                region: CLLocationCoordinate2D(latitude: 38.2682, longitude: 140.8721)
            )
        case .yamagata:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_yamadera", descriptionKey: "attraction_yamadera_desc", coordinate: CLLocationCoordinate2D(latitude: 38.3167, longitude: 140.4333)),
                    LocalizedAttractionLocation(nameKey: "attraction_zao_onsen", descriptionKey: "attraction_zao_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 38.1500, longitude: 140.4167)),
                    LocalizedAttractionLocation(nameKey: "attraction_ginzan_onsen", descriptionKey: "attraction_ginzan_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 38.5667, longitude: 140.5167)),
                    LocalizedAttractionLocation(nameKey: "attraction_mount_gassan", descriptionKey: "attraction_mount_gassan_desc", coordinate: CLLocationCoordinate2D(latitude: 38.5500, longitude: 140.0167)),
                    LocalizedAttractionLocation(nameKey: "attraction_mount_haguro", descriptionKey: "attraction_mount_haguro_desc", coordinate: CLLocationCoordinate2D(latitude: 38.7167, longitude: 139.9833)),
                    LocalizedAttractionLocation(nameKey: "attraction_mogami_river_cruise", descriptionKey: "attraction_mogami_river_cruise_desc", coordinate: CLLocationCoordinate2D(latitude: 38.6833, longitude: 140.1000))
                ],
                foodKeys: ["food_cherry", "food_yonezawa_beef", "food_imoni", "food_tama_konnyaku", "food_cold_ramen"],
                searchKeyword: "Yamagata Japan",
                region: CLLocationCoordinate2D(latitude: 38.2404, longitude: 140.3633)
            )
        case .fukushima:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_aizu_wakamatsu_castle", descriptionKey: "attraction_aizu_wakamatsu_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 37.4889, longitude: 139.9292)),
                    LocalizedAttractionLocation(nameKey: "attraction_goshikinuma", descriptionKey: "attraction_goshikinuma_desc", coordinate: CLLocationCoordinate2D(latitude: 37.6500, longitude: 140.0833)),
                    LocalizedAttractionLocation(nameKey: "attraction_spa_resort_hawaiians", descriptionKey: "attraction_spa_resort_hawaiians_desc", coordinate: CLLocationCoordinate2D(latitude: 37.0558, longitude: 140.8394)),
                    LocalizedAttractionLocation(nameKey: "attraction_ouchi_juku", descriptionKey: "attraction_ouchi_juku_desc", coordinate: CLLocationCoordinate2D(latitude: 37.3167, longitude: 139.8500)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_inawashiro", descriptionKey: "attraction_lake_inawashiro_desc", coordinate: CLLocationCoordinate2D(latitude: 37.5167, longitude: 140.1000)),
                    LocalizedAttractionLocation(nameKey: "attraction_abukuma_cave", descriptionKey: "attraction_abukuma_cave_desc", coordinate: CLLocationCoordinate2D(latitude: 37.1167, longitude: 140.6500))
                ],
                foodKeys: ["food_kitakata_ramen", "food_aizu_chicken", "food_mamadooru", "food_peach", "food_shirakawa_ramen"],
                searchKeyword: "Fukushima Japan",
                region: CLLocationCoordinate2D(latitude: 37.7503, longitude: 140.4676)
            )
        case .ibaraki:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kairakuen", descriptionKey: "attraction_kairakuen_desc", coordinate: CLLocationCoordinate2D(latitude: 36.3700, longitude: 140.4644)),
                    LocalizedAttractionLocation(nameKey: "attraction_fukuroda_falls", descriptionKey: "attraction_fukuroda_falls_desc", coordinate: CLLocationCoordinate2D(latitude: 36.7167, longitude: 140.3833)),
                    LocalizedAttractionLocation(nameKey: "attraction_hitachi_seaside_park", descriptionKey: "attraction_hitachi_seaside_park_desc", coordinate: CLLocationCoordinate2D(latitude: 36.4000, longitude: 140.5833)),
                    LocalizedAttractionLocation(nameKey: "attraction_mount_tsukuba", descriptionKey: "attraction_mount_tsukuba_desc", coordinate: CLLocationCoordinate2D(latitude: 36.2250, longitude: 140.1069)),
                    LocalizedAttractionLocation(nameKey: "attraction_oarai_coast", descriptionKey: "attraction_oarai_coast_desc", coordinate: CLLocationCoordinate2D(latitude: 36.3167, longitude: 140.5833)),
                    LocalizedAttractionLocation(nameKey: "attraction_ryujin_bridge", descriptionKey: "attraction_ryujin_bridge_desc", coordinate: CLLocationCoordinate2D(latitude: 36.7167, longitude: 140.4333))
                ],
                foodKeys: ["food_natto", "food_anko_nabe", "food_hitachi_beef", "food_melon", "food_dried_sweet_potato"],
                searchKeyword: "Ibaraki Japan",
                region: CLLocationCoordinate2D(latitude: 36.3418, longitude: 140.4468)
            )
        case .chiba:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_tokyo_disneyland", descriptionKey: "attraction_tokyo_disneyland_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6329, longitude: 139.8804)),
                    LocalizedAttractionLocation(nameKey: "attraction_naritasan_shinshoji", descriptionKey: "attraction_naritasan_shinshoji_desc", coordinate: CLLocationCoordinate2D(latitude: 35.7806, longitude: 140.3181)),
                    LocalizedAttractionLocation(nameKey: "attraction_kamogawa_seaworld", descriptionKey: "attraction_kamogawa_seaworld_desc", coordinate: CLLocationCoordinate2D(latitude: 35.1167, longitude: 140.1167)),
                    LocalizedAttractionLocation(nameKey: "attraction_choshi", descriptionKey: "attraction_choshi_desc", coordinate: CLLocationCoordinate2D(latitude: 35.7342, longitude: 140.8317)),
                    LocalizedAttractionLocation(nameKey: "attraction_mother_farm", descriptionKey: "attraction_mother_farm_desc", coordinate: CLLocationCoordinate2D(latitude: 35.2167, longitude: 139.9167)),
                    LocalizedAttractionLocation(nameKey: "attraction_tokyo_disneysea", descriptionKey: "attraction_tokyo_disneysea_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6265, longitude: 139.8846)),
                    LocalizedAttractionLocation(nameKey: "attraction_inubosaki_lighthouse", descriptionKey: "attraction_inubosaki_lighthouse_desc", coordinate: CLLocationCoordinate2D(latitude: 35.7078, longitude: 140.8694)),
                    LocalizedAttractionLocation(nameKey: "attraction_nokogiriyama", descriptionKey: "attraction_nokogiriyama_desc", coordinate: CLLocationCoordinate2D(latitude: 35.1604, longitude: 139.8409))
                ],
                foodKeys: ["food_peanuts", "food_loquat", "food_namerou", "food_katsuura_tantanmen", "food_boso_seafood"],
                searchKeyword: "Chiba Japan",
                region: CLLocationCoordinate2D(latitude: 35.6074, longitude: 140.1065)
            )
        case .tochigi:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_nikko_toshogu", descriptionKey: "attraction_nikko_toshogu_desc", coordinate: CLLocationCoordinate2D(latitude: 36.7581, longitude: 139.5969)),
                    LocalizedAttractionLocation(nameKey: "attraction_kegon_falls", descriptionKey: "attraction_kegon_falls_desc", coordinate: CLLocationCoordinate2D(latitude: 36.7389, longitude: 139.5044)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_chuzenji", descriptionKey: "attraction_lake_chuzenji_desc", coordinate: CLLocationCoordinate2D(latitude: 36.7167, longitude: 139.4833)),
                    LocalizedAttractionLocation(nameKey: "attraction_nasu_highlands", descriptionKey: "attraction_nasu_highlands_desc", coordinate: CLLocationCoordinate2D(latitude: 37.1167, longitude: 139.9500)),
                    LocalizedAttractionLocation(nameKey: "attraction_ashikaga_flower_park", descriptionKey: "attraction_ashikaga_flower_park_desc", coordinate: CLLocationCoordinate2D(latitude: 36.3089, longitude: 139.4633)),
                    LocalizedAttractionLocation(nameKey: "attraction_oya_museum", descriptionKey: "attraction_oya_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 36.5167, longitude: 139.7000))
                ],
                foodKeys: ["food_utsunomiya_gyoza", "food_yuba", "food_tochiotome", "food_shimotsukare", "food_lemon_milk"],
                searchKeyword: "Tochigi Japan",
                region: CLLocationCoordinate2D(latitude: 36.5658, longitude: 139.8836)
            )
        case .gunma:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kusatsu_onsen", descriptionKey: "attraction_kusatsu_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 36.6167, longitude: 138.6000)),
                    LocalizedAttractionLocation(nameKey: "attraction_ikaho_onsen", descriptionKey: "attraction_ikaho_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 36.4889, longitude: 138.9111)),
                    LocalizedAttractionLocation(nameKey: "attraction_oze", descriptionKey: "attraction_oze_desc", coordinate: CLLocationCoordinate2D(latitude: 36.9000, longitude: 139.2833)),
                    LocalizedAttractionLocation(nameKey: "attraction_tomioka_silk_mill", descriptionKey: "attraction_tomioka_silk_mill_desc", coordinate: CLLocationCoordinate2D(latitude: 36.2581, longitude: 138.8906)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_haruna", descriptionKey: "attraction_lake_haruna_desc", coordinate: CLLocationCoordinate2D(latitude: 36.4833, longitude: 138.8667)),
                    LocalizedAttractionLocation(nameKey: "attraction_mount_tanigawa", descriptionKey: "attraction_mount_tanigawa_desc", coordinate: CLLocationCoordinate2D(latitude: 36.8333, longitude: 138.9167))
                ],
                foodKeys: ["food_yaki_manju", "food_shimonita_negi", "food_konnyaku", "food_mizusawa_udon", "food_daruma_bento"],
                searchKeyword: "Gunma Japan",
                region: CLLocationCoordinate2D(latitude: 36.3911, longitude: 139.0608)
            )
        case .saitama:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kawagoe", descriptionKey: "attraction_kawagoe_desc", coordinate: CLLocationCoordinate2D(latitude: 35.9250, longitude: 139.4856)),
                    LocalizedAttractionLocation(nameKey: "attraction_chichibu", descriptionKey: "attraction_chichibu_desc", coordinate: CLLocationCoordinate2D(latitude: 35.9917, longitude: 139.0861)),
                    LocalizedAttractionLocation(nameKey: "attraction_nagatoro", descriptionKey: "attraction_nagatoro_desc", coordinate: CLLocationCoordinate2D(latitude: 36.1000, longitude: 139.1167)),
                    LocalizedAttractionLocation(nameKey: "attraction_railway_museum", descriptionKey: "attraction_railway_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 35.9167, longitude: 139.6167)),
                    LocalizedAttractionLocation(nameKey: "attraction_ranzan_valley", descriptionKey: "attraction_ranzan_valley_desc", coordinate: CLLocationCoordinate2D(latitude: 36.0167, longitude: 139.2833)),
                    LocalizedAttractionLocation(nameKey: "attraction_musashi_ichinomiya_hikawa_shrine", descriptionKey: "attraction_musashi_ichinomiya_hikawa_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 35.9069, longitude: 139.6264))
                ],
                foodKeys: ["food_kawagoe_sweet_potato", "food_chichibu_soba", "food_soka_senbei", "food_gokaho", "food_iga_manju"],
                searchKeyword: "Saitama Japan",
                region: CLLocationCoordinate2D(latitude: 35.8571, longitude: 139.6489)
            )
        case .tokyo:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_tokyo_skytree", descriptionKey: "attraction_tokyo_skytree_desc", coordinate: CLLocationCoordinate2D(latitude: 35.7101, longitude: 139.8107)),
                    LocalizedAttractionLocation(nameKey: "attraction_sensoji", descriptionKey: "attraction_sensoji_desc", coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7967)),
                    LocalizedAttractionLocation(nameKey: "attraction_shibuya_crossing", descriptionKey: "attraction_shibuya_crossing_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6598, longitude: 139.7006)),
                    LocalizedAttractionLocation(nameKey: "attraction_wb_studio_tour_tokyo", descriptionKey: "attraction_wb_studio_tour_tokyo_desc", coordinate: CLLocationCoordinate2D(latitude: 35.7426, longitude: 139.6479)),
                    LocalizedAttractionLocation(nameKey: "attraction_tokyo_tower", descriptionKey: "attraction_tokyo_tower_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6586, longitude: 139.7454)),
                    LocalizedAttractionLocation(nameKey: "attraction_meiji_shrine", descriptionKey: "attraction_meiji_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6993)),
                    LocalizedAttractionLocation(nameKey: "attraction_azabudai_hills", descriptionKey: "attraction_azabudai_hills_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6616, longitude: 139.7409)),
                    LocalizedAttractionLocation(nameKey: "attraction_imperial_palace", descriptionKey: "attraction_imperial_palace_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6852, longitude: 139.7528)),
                    LocalizedAttractionLocation(nameKey: "attraction_toyosu_market", descriptionKey: "attraction_toyosu_market_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6441, longitude: 139.7843)),
                    LocalizedAttractionLocation(nameKey: "attraction_odaiba", descriptionKey: "attraction_odaiba_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6269, longitude: 139.7772)),
                    LocalizedAttractionLocation(nameKey: "attraction_shinjuku_gyoen", descriptionKey: "attraction_shinjuku_gyoen_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6867, longitude: 139.7082)),
                    LocalizedAttractionLocation(nameKey: "attraction_ueno_zoo", descriptionKey: "attraction_ueno_zoo_desc", coordinate: CLLocationCoordinate2D(latitude: 35.7164, longitude: 139.7706))
                ],
                foodKeys: ["food_edomae_sushi", "food_monjayaki", "food_fukagawa_don", "food_imagawayaki", "food_tsukudani"],
                searchKeyword: "Tokyo Japan",
                region: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)
            )
        case .kanagawa:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kamakura_daibutsu", descriptionKey: "attraction_kamakura_daibutsu_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3167, longitude: 139.5361)),
                    LocalizedAttractionLocation(nameKey: "attraction_enoshima", descriptionKey: "attraction_enoshima_desc", coordinate: CLLocationCoordinate2D(latitude: 35.2989, longitude: 139.4803)),
                    LocalizedAttractionLocation(nameKey: "attraction_hakone", descriptionKey: "attraction_hakone_desc", coordinate: CLLocationCoordinate2D(latitude: 35.2333, longitude: 139.1000)),
                    LocalizedAttractionLocation(nameKey: "attraction_yokohama_chinatown", descriptionKey: "attraction_yokohama_chinatown_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4431, longitude: 139.6464)),
                    LocalizedAttractionLocation(nameKey: "attraction_minato_mirai", descriptionKey: "attraction_minato_mirai_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4556, longitude: 139.6317)),
                    LocalizedAttractionLocation(nameKey: "attraction_owakudani", descriptionKey: "attraction_owakudani_desc", coordinate: CLLocationCoordinate2D(latitude: 35.2444, longitude: 139.0239)),
                    LocalizedAttractionLocation(nameKey: "attraction_hokokuji", descriptionKey: "attraction_hokokuji_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3167, longitude: 139.5500)),
                    LocalizedAttractionLocation(nameKey: "attraction_yokohama_akarenga", descriptionKey: "attraction_yokohama_akarenga_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4526, longitude: 139.6428)),
                    LocalizedAttractionLocation(nameKey: "attraction_tsurugaoka_hachimangu", descriptionKey: "attraction_tsurugaoka_hachimangu_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3249, longitude: 139.5560))
                ],
                foodKeys: ["food_shumai", "food_kamakura_vegetables", "food_shonan_shirasu", "food_iekei_ramen", "food_yokohama_chinatown_gourmet"],
                searchKeyword: "Kanagawa Japan",
                region: CLLocationCoordinate2D(latitude: 35.4478, longitude: 139.6425)
            )
        case .niigata:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_sado_island", descriptionKey: "attraction_sado_island_desc", coordinate: CLLocationCoordinate2D(latitude: 38.0167, longitude: 138.3667)),
                    LocalizedAttractionLocation(nameKey: "attraction_naeba_ski_resort", descriptionKey: "attraction_naeba_ski_resort_desc", coordinate: CLLocationCoordinate2D(latitude: 36.8500, longitude: 138.7000)),
                    LocalizedAttractionLocation(nameKey: "attraction_yahiko_shrine", descriptionKey: "attraction_yahiko_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 37.7167, longitude: 138.9500)),
                    LocalizedAttractionLocation(nameKey: "attraction_joetsu_kokusai_ski_resort", descriptionKey: "attraction_joetsu_kokusai_ski_resort_desc", coordinate: CLLocationCoordinate2D(latitude: 37.0500, longitude: 138.7833)),
                    LocalizedAttractionLocation(nameKey: "attraction_myoko_kogen", descriptionKey: "attraction_myoko_kogen_desc", coordinate: CLLocationCoordinate2D(latitude: 36.8833, longitude: 138.1333)),
                    LocalizedAttractionLocation(nameKey: "attraction_kiyotsu_gorge", descriptionKey: "attraction_kiyotsu_gorge_desc", coordinate: CLLocationCoordinate2D(latitude: 37.0000, longitude: 138.7333))
                ],
                foodKeys: ["food_niigata_rice", "food_noppe", "food_hegi_soba", "food_salmon", "food_sake"],
                searchKeyword: "Niigata Japan",
                region: CLLocationCoordinate2D(latitude: 37.9022, longitude: 139.0234)
            )
        case .nagano:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_zenkoji", descriptionKey: "attraction_zenkoji_desc", coordinate: CLLocationCoordinate2D(latitude: 36.6611, longitude: 138.1889)),
                    LocalizedAttractionLocation(nameKey: "attraction_karuizawa", descriptionKey: "attraction_karuizawa_desc", coordinate: CLLocationCoordinate2D(latitude: 36.3500, longitude: 138.6167)),
                    LocalizedAttractionLocation(nameKey: "attraction_kamikochi", descriptionKey: "attraction_kamikochi_desc", coordinate: CLLocationCoordinate2D(latitude: 36.2500, longitude: 137.6500)),
                    LocalizedAttractionLocation(nameKey: "attraction_hakuba", descriptionKey: "attraction_hakuba_desc", coordinate: CLLocationCoordinate2D(latitude: 36.7000, longitude: 137.8667)),
                    LocalizedAttractionLocation(nameKey: "attraction_matsumoto_castle", descriptionKey: "attraction_matsumoto_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 36.2389, longitude: 137.9692)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_suwa", descriptionKey: "attraction_lake_suwa_desc", coordinate: CLLocationCoordinate2D(latitude: 36.0500, longitude: 138.0833)),
                    LocalizedAttractionLocation(nameKey: "attraction_togakushi", descriptionKey: "attraction_togakushi_desc", coordinate: CLLocationCoordinate2D(latitude: 36.7167, longitude: 138.1000)),
                    LocalizedAttractionLocation(nameKey: "attraction_jigokudani_monkey", descriptionKey: "attraction_jigokudani_monkey_desc", coordinate: CLLocationCoordinate2D(latitude: 36.7327, longitude: 138.4621)),
                    LocalizedAttractionLocation(nameKey: "attraction_suwa_taisha", descriptionKey: "attraction_suwa_taisha_desc", coordinate: CLLocationCoordinate2D(latitude: 35.9981, longitude: 138.1194))
                ],
                foodKeys: ["food_shinshu_soba", "food_oyaki", "food_nozawana", "food_apple_nagano", "food_shinshu_miso"],
                searchKeyword: "Nagano Japan",
                region: CLLocationCoordinate2D(latitude: 36.6513, longitude: 138.1808)
            )
        case .yamanashi:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_mount_fuji", descriptionKey: "attraction_mount_fuji_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3606, longitude: 138.7274)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_kawaguchi", descriptionKey: "attraction_lake_kawaguchi_desc", coordinate: CLLocationCoordinate2D(latitude: 35.5167, longitude: 138.7500)),
                    LocalizedAttractionLocation(nameKey: "attraction_shosenkyo", descriptionKey: "attraction_shosenkyo_desc", coordinate: CLLocationCoordinate2D(latitude: 35.7667, longitude: 138.6333)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_yamanaka", descriptionKey: "attraction_lake_yamanaka_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4167, longitude: 138.8667)),
                    LocalizedAttractionLocation(nameKey: "attraction_oshino_hakkai", descriptionKey: "attraction_oshino_hakkai_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4667, longitude: 138.8333)),
                    LocalizedAttractionLocation(nameKey: "attraction_takeda_shrine", descriptionKey: "attraction_takeda_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6833, longitude: 138.5667))
                ],
                foodKeys: ["food_hoto", "food_shingen_mochi", "food_grape", "food_peach_yamanashi", "food_koshu_wine"],
                searchKeyword: "Yamanashi Japan",
                region: CLLocationCoordinate2D(latitude: 35.6642, longitude: 138.5686)
            )
        case .shizuoka:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_mount_fuji_shizuoka", descriptionKey: "attraction_mount_fuji_shizuoka_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3606, longitude: 138.7274)),
                    LocalizedAttractionLocation(nameKey: "attraction_izu_peninsula", descriptionKey: "attraction_izu_peninsula_desc", coordinate: CLLocationCoordinate2D(latitude: 34.9000, longitude: 139.0000)),
                    LocalizedAttractionLocation(nameKey: "attraction_atami_onsen", descriptionKey: "attraction_atami_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0961, longitude: 139.0778)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_hamana", descriptionKey: "attraction_lake_hamana_desc", coordinate: CLLocationCoordinate2D(latitude: 34.7167, longitude: 137.6167)),
                    LocalizedAttractionLocation(nameKey: "attraction_kunozan_toshogu", descriptionKey: "attraction_kunozan_toshogu_desc", coordinate: CLLocationCoordinate2D(latitude: 34.9833, longitude: 138.3833)),
                    LocalizedAttractionLocation(nameKey: "attraction_shiraito_falls", descriptionKey: "attraction_shiraito_falls_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3167, longitude: 138.5833)),
                    LocalizedAttractionLocation(nameKey: "attraction_miho_matsubara", descriptionKey: "attraction_miho_matsubara_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0167, longitude: 138.5167)),
                    LocalizedAttractionLocation(nameKey: "attraction_sunpu_castle", descriptionKey: "attraction_sunpu_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 34.9786, longitude: 138.3830)),
                    LocalizedAttractionLocation(nameKey: "attraction_omuroyama", descriptionKey: "attraction_omuroyama_desc", coordinate: CLLocationCoordinate2D(latitude: 34.9031, longitude: 139.0947))
                ],
                foodKeys: ["food_shizuoka_tea", "food_unagi", "food_wasabi", "food_sakura_ebi", "food_kuro_hanpen"],
                searchKeyword: "Shizuoka Japan",
                region: CLLocationCoordinate2D(latitude: 34.9756, longitude: 138.3828)
            )
        case .aichi:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_nagoya_castle", descriptionKey: "attraction_nagoya_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 35.1856, longitude: 136.8994)),
                    LocalizedAttractionLocation(nameKey: "attraction_ghibli_park", descriptionKey: "attraction_ghibli_park_desc", coordinate: CLLocationCoordinate2D(latitude: 35.1736, longitude: 137.0894)),
                    LocalizedAttractionLocation(nameKey: "attraction_atsuta_shrine", descriptionKey: "attraction_atsuta_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 35.1278, longitude: 136.9075)),
                    LocalizedAttractionLocation(nameKey: "attraction_inuyama_castle", descriptionKey: "attraction_inuyama_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3889, longitude: 136.9417)),
                    LocalizedAttractionLocation(nameKey: "attraction_chita_peninsula", descriptionKey: "attraction_chita_peninsula_desc", coordinate: CLLocationCoordinate2D(latitude: 34.8333, longitude: 136.8167)),
                    LocalizedAttractionLocation(nameKey: "attraction_korankei", descriptionKey: "attraction_korankei_desc", coordinate: CLLocationCoordinate2D(latitude: 35.1167, longitude: 137.3333)),
                    LocalizedAttractionLocation(nameKey: "attraction_linear_railway_museum", descriptionKey: "attraction_linear_railway_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0333, longitude: 136.8167))
                ],
                foodKeys: ["food_miso_katsu", "food_hitsumabushi", "food_tebasaki", "food_kishimen", "food_taiwan_ramen"],
                searchKeyword: "Aichi Japan",
                region: CLLocationCoordinate2D(latitude: 35.1803, longitude: 136.9066)
            )
        case .mie:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_ise_shrine", descriptionKey: "attraction_ise_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 34.4556, longitude: 136.7250)),
                    LocalizedAttractionLocation(nameKey: "attraction_toba_aquarium", descriptionKey: "attraction_toba_aquarium_desc", coordinate: CLLocationCoordinate2D(latitude: 34.4833, longitude: 136.8500)),
                    LocalizedAttractionLocation(nameKey: "attraction_kumano_kodo", descriptionKey: "attraction_kumano_kodo_desc", coordinate: CLLocationCoordinate2D(latitude: 33.8000, longitude: 136.1000)),
                    LocalizedAttractionLocation(nameKey: "attraction_nabana_no_sato", descriptionKey: "attraction_nabana_no_sato_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0167, longitude: 136.6833)),
                    LocalizedAttractionLocation(nameKey: "attraction_iga_ueno_castle", descriptionKey: "attraction_iga_ueno_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 34.7667, longitude: 136.1333)),
                    LocalizedAttractionLocation(nameKey: "attraction_shima_spain_village", descriptionKey: "attraction_shima_spain_village_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3333, longitude: 136.8000))
                ],
                foodKeys: ["food_ise_ebi", "food_matsusaka_beef", "food_akafuku", "food_tekone_sushi", "food_iga_beef"],
                searchKeyword: "Mie Japan",
                region: CLLocationCoordinate2D(latitude: 34.7303, longitude: 136.5085)
            )
        case .gifu:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_shirakawago", descriptionKey: "attraction_shirakawago_desc", coordinate: CLLocationCoordinate2D(latitude: 36.2589, longitude: 136.9061)),
                    LocalizedAttractionLocation(nameKey: "attraction_hida_takayama", descriptionKey: "attraction_hida_takayama_desc", coordinate: CLLocationCoordinate2D(latitude: 36.1467, longitude: 137.2533)),
                    LocalizedAttractionLocation(nameKey: "attraction_gero_onsen", descriptionKey: "attraction_gero_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 35.8000, longitude: 137.2500)),
                    LocalizedAttractionLocation(nameKey: "attraction_kinkazan", descriptionKey: "attraction_kinkazan_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4333, longitude: 136.7833)),
                    LocalizedAttractionLocation(nameKey: "attraction_magome_juku", descriptionKey: "attraction_magome_juku_desc", coordinate: CLLocationCoordinate2D(latitude: 35.5333, longitude: 137.5833)),
                    LocalizedAttractionLocation(nameKey: "attraction_okuhida_onsen", descriptionKey: "attraction_okuhida_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 36.2333, longitude: 137.6000))
                ],
                foodKeys: ["food_hida_beef", "food_hoba_miso", "food_gohei_mochi", "food_ayu_shioyaki", "food_kuri_kinton"],
                searchKeyword: "Gifu Japan",
                region: CLLocationCoordinate2D(latitude: 35.3912, longitude: 136.7223)
            )
        case .fukui:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_tojinbo", descriptionKey: "attraction_tojinbo_desc", coordinate: CLLocationCoordinate2D(latitude: 36.2375, longitude: 136.1267)),
                    LocalizedAttractionLocation(nameKey: "attraction_eiheiji", descriptionKey: "attraction_eiheiji_desc", coordinate: CLLocationCoordinate2D(latitude: 36.0667, longitude: 136.3167)),
                    LocalizedAttractionLocation(nameKey: "attraction_dinosaur_museum", descriptionKey: "attraction_dinosaur_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 36.0889, longitude: 136.5000)),
                    LocalizedAttractionLocation(nameKey: "attraction_ichijodani_asakura_ruins", descriptionKey: "attraction_ichijodani_asakura_ruins_desc", coordinate: CLLocationCoordinate2D(latitude: 35.9833, longitude: 136.2833)),
                    LocalizedAttractionLocation(nameKey: "attraction_wakasa_bay", descriptionKey: "attraction_wakasa_bay_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6000, longitude: 135.8000)),
                    LocalizedAttractionLocation(nameKey: "attraction_mikata_goko", descriptionKey: "attraction_mikata_goko_desc", coordinate: CLLocationCoordinate2D(latitude: 35.5833, longitude: 135.9167))
                ],
                foodKeys: ["food_echizen_crab", "food_echizen_soba", "food_sauce_katsu_don", "food_habutae_mochi", "food_wakasa_beef"],
                searchKeyword: "Fukui Japan",
                region: CLLocationCoordinate2D(latitude: 36.0652, longitude: 136.2216)
            )
        case .ishikawa:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kenrokuen", descriptionKey: "attraction_kenrokuen_desc", coordinate: CLLocationCoordinate2D(latitude: 36.5619, longitude: 136.6625)),
                    LocalizedAttractionLocation(nameKey: "attraction_kanazawa_castle", descriptionKey: "attraction_kanazawa_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 36.5653, longitude: 136.6583)),
                    LocalizedAttractionLocation(nameKey: "attraction_wakura_onsen", descriptionKey: "attraction_wakura_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 37.1167, longitude: 136.9167)),
                    LocalizedAttractionLocation(nameKey: "attraction_chirihama_nagisa_driveway", descriptionKey: "attraction_chirihama_nagisa_driveway_desc", coordinate: CLLocationCoordinate2D(latitude: 36.8833, longitude: 136.6833)),
                    LocalizedAttractionLocation(nameKey: "attraction_wajima_morning_market", descriptionKey: "attraction_wajima_morning_market_desc", coordinate: CLLocationCoordinate2D(latitude: 37.3889, longitude: 136.9000)),
                    LocalizedAttractionLocation(nameKey: "attraction_higashi_chaya_district", descriptionKey: "attraction_higashi_chaya_district_desc", coordinate: CLLocationCoordinate2D(latitude: 36.5700, longitude: 136.6725)),
                    LocalizedAttractionLocation(nameKey: "attraction_kanazawa_21museum", descriptionKey: "attraction_kanazawa_21museum_desc", coordinate: CLLocationCoordinate2D(latitude: 36.5609, longitude: 136.6582)),
                    LocalizedAttractionLocation(nameKey: "attraction_myoryuji", descriptionKey: "attraction_myoryuji_desc", coordinate: CLLocationCoordinate2D(latitude: 36.5554, longitude: 136.6490))
                ],
                foodKeys: ["food_kaga_cuisine", "food_kanazawa_curry", "food_noto_beef", "food_jibuni", "food_nodoguro"],
                searchKeyword: "Ishikawa Japan",
                region: CLLocationCoordinate2D(latitude: 36.5946, longitude: 136.6256)
            )
        case .toyama:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_tateyama_kurobe_alpine_route", descriptionKey: "attraction_tateyama_kurobe_alpine_route_desc", coordinate: CLLocationCoordinate2D(latitude: 36.5833, longitude: 137.6167)),
                    LocalizedAttractionLocation(nameKey: "attraction_kurobe_dam", descriptionKey: "attraction_kurobe_dam_desc", coordinate: CLLocationCoordinate2D(latitude: 36.5667, longitude: 137.6667)),
                    LocalizedAttractionLocation(nameKey: "attraction_gokayama", descriptionKey: "attraction_gokayama_desc", coordinate: CLLocationCoordinate2D(latitude: 36.4167, longitude: 136.9333)),
                    LocalizedAttractionLocation(nameKey: "attraction_toyama_bay", descriptionKey: "attraction_toyama_bay_desc", coordinate: CLLocationCoordinate2D(latitude: 36.8333, longitude: 137.2000)),
                    LocalizedAttractionLocation(nameKey: "attraction_shomyo_falls", descriptionKey: "attraction_shomyo_falls_desc", coordinate: CLLocationCoordinate2D(latitude: 36.6167, longitude: 137.5833)),
                    LocalizedAttractionLocation(nameKey: "attraction_unazuki_onsen", descriptionKey: "attraction_unazuki_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 36.8167, longitude: 137.6167))
                ],
                foodKeys: ["food_shiro_ebi", "food_hotaru_ika", "food_masu_sushi", "food_toyama_black_ramen", "food_himi_beef"],
                searchKeyword: "Toyama Japan",
                region: CLLocationCoordinate2D(latitude: 36.6959, longitude: 137.2113)
            )
        case .shiga:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_lake_biwa", descriptionKey: "attraction_lake_biwa_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3167, longitude: 136.1000)),
                    LocalizedAttractionLocation(nameKey: "attraction_hikone_castle", descriptionKey: "attraction_hikone_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 35.2764, longitude: 136.2514)),
                    LocalizedAttractionLocation(nameKey: "attraction_hieizan_enryakuji", descriptionKey: "attraction_hieizan_enryakuji_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0708, longitude: 135.8411)),
                    LocalizedAttractionLocation(nameKey: "attraction_azuchi_castle_ruins", descriptionKey: "attraction_azuchi_castle_ruins_desc", coordinate: CLLocationCoordinate2D(latitude: 35.1333, longitude: 136.1333)),
                    LocalizedAttractionLocation(nameKey: "attraction_omihachiman", descriptionKey: "attraction_omihachiman_desc", coordinate: CLLocationCoordinate2D(latitude: 35.1281, longitude: 136.0967)),
                    LocalizedAttractionLocation(nameKey: "attraction_metasequoia_avenue", descriptionKey: "attraction_metasequoia_avenue_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4500, longitude: 136.0500))
                ],
                foodKeys: ["food_omi_beef", "food_funa_sushi", "food_aka_konnyaku", "food_shigaraki_pottery", "food_lake_fish_cuisine"],
                searchKeyword: "Shiga Japan",
                region: CLLocationCoordinate2D(latitude: 35.0045, longitude: 135.8686)
            )
        case .kyoto:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kiyomizu_dera", descriptionKey: "attraction_kiyomizu_dera_desc", coordinate: CLLocationCoordinate2D(latitude: 34.9949, longitude: 135.7849)),
                    LocalizedAttractionLocation(nameKey: "attraction_kinkakuji", descriptionKey: "attraction_kinkakuji_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0394, longitude: 135.7292)),
                    LocalizedAttractionLocation(nameKey: "attraction_fushimi_inari_taisha", descriptionKey: "attraction_fushimi_inari_taisha_desc", coordinate: CLLocationCoordinate2D(latitude: 34.9671, longitude: 135.7727)),
                    LocalizedAttractionLocation(nameKey: "attraction_arashiyama", descriptionKey: "attraction_arashiyama_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0096, longitude: 135.6683)),
                    LocalizedAttractionLocation(nameKey: "attraction_philosophers_path", descriptionKey: "attraction_philosophers_path_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0166, longitude: 135.7914)),
                    LocalizedAttractionLocation(nameKey: "attraction_amanohashidate", descriptionKey: "attraction_amanohashidate_desc", coordinate: CLLocationCoordinate2D(latitude: 35.5667, longitude: 135.1833)),
                    LocalizedAttractionLocation(nameKey: "attraction_byodoin", descriptionKey: "attraction_byodoin_desc", coordinate: CLLocationCoordinate2D(latitude: 34.8889, longitude: 135.8075)),
                    LocalizedAttractionLocation(nameKey: "attraction_nijo_castle", descriptionKey: "attraction_nijo_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0142, longitude: 135.7479)),
                    LocalizedAttractionLocation(nameKey: "attraction_ginkakuji", descriptionKey: "attraction_ginkakuji_desc", coordinate: CLLocationCoordinate2D(latitude: 35.0268, longitude: 135.7982))
                ],
                foodKeys: ["food_yudofu", "food_kyoto_kaiseki", "food_matcha_sweets", "food_obanzai", "food_kyoto_pickles"],
                searchKeyword: "Kyoto Japan",
                region: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681)
            )
        case .hyogo:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_himeji_castle", descriptionKey: "attraction_himeji_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 34.8394, longitude: 134.6939)),
                    LocalizedAttractionLocation(nameKey: "attraction_arima_onsen", descriptionKey: "attraction_arima_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 34.7972, longitude: 135.2489)),
                    LocalizedAttractionLocation(nameKey: "attraction_kobe_port_tower", descriptionKey: "attraction_kobe_port_tower_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6739, longitude: 135.1875)),
                    LocalizedAttractionLocation(nameKey: "attraction_takeda_castle_ruins", descriptionKey: "attraction_takeda_castle_ruins_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3056, longitude: 134.8167)),
                    LocalizedAttractionLocation(nameKey: "attraction_awaji_island", descriptionKey: "attraction_awaji_island_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3333, longitude: 134.8333)),
                    LocalizedAttractionLocation(nameKey: "attraction_mount_rokko", descriptionKey: "attraction_mount_rokko_desc", coordinate: CLLocationCoordinate2D(latitude: 34.7667, longitude: 135.2333)),
                    LocalizedAttractionLocation(nameKey: "attraction_takarazuka_grand_theater", descriptionKey: "attraction_takarazuka_grand_theater_desc", coordinate: CLLocationCoordinate2D(latitude: 34.7833, longitude: 135.3500))
                ],
                foodKeys: ["food_kobe_beef", "food_akashiyaki", "food_ikanago", "food_banshu_ramen", "food_awaji_onion"],
                searchKeyword: "Hyogo Japan",
                region: CLLocationCoordinate2D(latitude: 34.6913, longitude: 135.1830)
            )
        case .nara:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_todaiji", descriptionKey: "attraction_todaiji_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6889, longitude: 135.8397)),
                    LocalizedAttractionLocation(nameKey: "attraction_nara_park", descriptionKey: "attraction_nara_park_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6851, longitude: 135.8048)),
                    LocalizedAttractionLocation(nameKey: "attraction_kasuga_taisha", descriptionKey: "attraction_kasuga_taisha_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6815, longitude: 135.8483)),
                    LocalizedAttractionLocation(nameKey: "attraction_horyuji", descriptionKey: "attraction_horyuji_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6147, longitude: 135.7344)),
                    LocalizedAttractionLocation(nameKey: "attraction_yoshinoyama", descriptionKey: "attraction_yoshinoyama_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3667, longitude: 135.8667)),
                    LocalizedAttractionLocation(nameKey: "attraction_kofukuji", descriptionKey: "attraction_kofukuji_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6836, longitude: 135.8311)),
                    LocalizedAttractionLocation(nameKey: "attraction_yakushiji", descriptionKey: "attraction_yakushiji_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6685, longitude: 135.7843)),
                    LocalizedAttractionLocation(nameKey: "attraction_hasedera", descriptionKey: "attraction_hasedera_desc", coordinate: CLLocationCoordinate2D(latitude: 34.5359, longitude: 135.9067))
                ],
                foodKeys: ["food_kakinoha_sushi", "food_miwa_somen", "food_narazuke", "food_yamato_beef", "food_kuzukiri"],
                searchKeyword: "Nara Japan",
                region: CLLocationCoordinate2D(latitude: 34.6851, longitude: 135.8048)
            )
        case .wakayama:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kumano_kodo_wakayama", descriptionKey: "attraction_kumano_kodo_wakayama_desc", coordinate: CLLocationCoordinate2D(latitude: 33.8000, longitude: 135.7833)),
                    LocalizedAttractionLocation(nameKey: "attraction_koyasan", descriptionKey: "attraction_koyasan_desc", coordinate: CLLocationCoordinate2D(latitude: 34.2133, longitude: 135.5808)),
                    LocalizedAttractionLocation(nameKey: "attraction_shirahama_onsen", descriptionKey: "attraction_shirahama_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 33.6833, longitude: 135.3333)),
                    LocalizedAttractionLocation(nameKey: "attraction_nachi_falls", descriptionKey: "attraction_nachi_falls_desc", coordinate: CLLocationCoordinate2D(latitude: 33.6667, longitude: 135.8833)),
                    LocalizedAttractionLocation(nameKey: "attraction_adventure_world", descriptionKey: "attraction_adventure_world_desc", coordinate: CLLocationCoordinate2D(latitude: 33.6833, longitude: 135.3500)),
                    LocalizedAttractionLocation(nameKey: "attraction_wakayama_castle", descriptionKey: "attraction_wakayama_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 34.2267, longitude: 135.1706))
                ],
                foodKeys: ["food_umeboshi", "food_wakayama_ramen", "food_tuna", "food_persimmon", "food_kishu_kinzanji_miso"],
                searchKeyword: "Wakayama Japan",
                region: CLLocationCoordinate2D(latitude: 34.2261, longitude: 135.1675)
            )
        case .osaka:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_osaka_castle", descriptionKey: "attraction_osaka_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6873, longitude: 135.5262)),
                    LocalizedAttractionLocation(nameKey: "attraction_dotonbori", descriptionKey: "attraction_dotonbori_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6686, longitude: 135.5023)),
                    LocalizedAttractionLocation(nameKey: "attraction_universal_studios", descriptionKey: "attraction_universal_studios_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6658, longitude: 135.4321)),
                    LocalizedAttractionLocation(nameKey: "attraction_kaiyukan", descriptionKey: "attraction_kaiyukan_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6545, longitude: 135.4290)),
                    LocalizedAttractionLocation(nameKey: "attraction_shinsekai", descriptionKey: "attraction_shinsekai_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6521, longitude: 135.5063)),
                    LocalizedAttractionLocation(nameKey: "attraction_expo_park", descriptionKey: "attraction_expo_park_desc", coordinate: CLLocationCoordinate2D(latitude: 34.8097, longitude: 135.5324)),
                    LocalizedAttractionLocation(nameKey: "attraction_sumiyoshi_taisha", descriptionKey: "attraction_sumiyoshi_taisha_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6169, longitude: 135.4942)),
                    LocalizedAttractionLocation(nameKey: "attraction_grand_green_osaka", descriptionKey: "attraction_grand_green_osaka_desc", coordinate: CLLocationCoordinate2D(latitude: 34.7036, longitude: 135.4955)),
                    LocalizedAttractionLocation(nameKey: "attraction_shitennoji", descriptionKey: "attraction_shitennoji_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6542, longitude: 135.5156))
                ],
                foodKeys: ["food_takoyaki", "food_okonomiyaki", "food_kushikatsu", "food_ikayaki", "food_butaman"],
                searchKeyword: "Osaka Japan",
                region: CLLocationCoordinate2D(latitude: 34.6937, longitude: 135.5023)
            )
        case .tottori:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_tottori_sand_dunes", descriptionKey: "attraction_tottori_sand_dunes_desc", coordinate: CLLocationCoordinate2D(latitude: 35.5333, longitude: 134.2333)),
                    LocalizedAttractionLocation(nameKey: "attraction_mount_daisen", descriptionKey: "attraction_mount_daisen_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3667, longitude: 133.5500)),
                    LocalizedAttractionLocation(nameKey: "attraction_mizuki_shigeru_road", descriptionKey: "attraction_mizuki_shigeru_road_desc", coordinate: CLLocationCoordinate2D(latitude: 35.5333, longitude: 133.2333)),
                    LocalizedAttractionLocation(nameKey: "attraction_uradome_coast", descriptionKey: "attraction_uradome_coast_desc", coordinate: CLLocationCoordinate2D(latitude: 35.6000, longitude: 134.3167)),
                    LocalizedAttractionLocation(nameKey: "attraction_misasa_onsen", descriptionKey: "attraction_misasa_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4167, longitude: 133.9000)),
                    LocalizedAttractionLocation(nameKey: "attraction_hakuto_coast", descriptionKey: "attraction_hakuto_coast_desc", coordinate: CLLocationCoordinate2D(latitude: 35.5333, longitude: 134.2667))
                ],
                foodKeys: ["food_matsuba_crab", "food_nijisseiki_pear", "food_sakaiminato_seafood", "food_tofu_chikuwa", "food_gyu_kotsu_ramen"],
                searchKeyword: "Tottori Japan",
                region: CLLocationCoordinate2D(latitude: 35.5038, longitude: 134.2386)
            )
        case .okayama:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_okayama_castle", descriptionKey: "attraction_okayama_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6556, longitude: 133.9344)),
                    LocalizedAttractionLocation(nameKey: "attraction_korakuen", descriptionKey: "attraction_korakuen_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6617, longitude: 133.9355)),
                    LocalizedAttractionLocation(nameKey: "attraction_kurashiki_bikan", descriptionKey: "attraction_kurashiki_bikan_desc", coordinate: CLLocationCoordinate2D(latitude: 34.5944, longitude: 133.7722)),
                    LocalizedAttractionLocation(nameKey: "attraction_kibitsu_shrine", descriptionKey: "attraction_kibitsu_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 34.6667, longitude: 133.8167)),
                    LocalizedAttractionLocation(nameKey: "attraction_hiruzen_kogen", descriptionKey: "attraction_hiruzen_kogen_desc", coordinate: CLLocationCoordinate2D(latitude: 35.3167, longitude: 133.6167)),
                    LocalizedAttractionLocation(nameKey: "attraction_seto_ohashi", descriptionKey: "attraction_seto_ohashi_desc", coordinate: CLLocationCoordinate2D(latitude: 34.4167, longitude: 133.8000))
                ],
                foodKeys: ["food_white_peach", "food_muscat", "food_kibidango", "food_mamakari", "food_demi_katsu_don"],
                searchKeyword: "Okayama Japan",
                region: CLLocationCoordinate2D(latitude: 34.6617, longitude: 133.9355)
            )
        case .hiroshima:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_itsukushima_shrine", descriptionKey: "attraction_itsukushima_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 34.2967, longitude: 132.3197)),
                    LocalizedAttractionLocation(nameKey: "attraction_atomic_bomb_dome", descriptionKey: "attraction_atomic_bomb_dome_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3955, longitude: 132.4536)),
                    LocalizedAttractionLocation(nameKey: "attraction_miyajima", descriptionKey: "attraction_miyajima_desc", coordinate: CLLocationCoordinate2D(latitude: 34.2967, longitude: 132.3197)),
                    LocalizedAttractionLocation(nameKey: "attraction_onomichi", descriptionKey: "attraction_onomichi_desc", coordinate: CLLocationCoordinate2D(latitude: 34.4097, longitude: 133.2044)),
                    LocalizedAttractionLocation(nameKey: "attraction_takehara", descriptionKey: "attraction_takehara_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3400, longitude: 132.9100)),
                    LocalizedAttractionLocation(nameKey: "attraction_tomonoura", descriptionKey: "attraction_tomonoura_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3833, longitude: 133.3833)),
                    LocalizedAttractionLocation(nameKey: "attraction_hiroshima_castle", descriptionKey: "attraction_hiroshima_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 34.4027, longitude: 132.4590)),
                    LocalizedAttractionLocation(nameKey: "attraction_yamato_museum", descriptionKey: "attraction_yamato_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 34.2417, longitude: 132.5560))
                ],
                foodKeys: ["food_okonomiyaki_hiroshima", "food_oyster", "food_momiji_manju", "food_hiroshima_tsukemen", "food_anago_meshi"],
                searchKeyword: "Hiroshima Japan",
                region: CLLocationCoordinate2D(latitude: 34.3965, longitude: 132.4596)
            )
        case .yamaguchi:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_akiyoshidai", descriptionKey: "attraction_akiyoshidai_desc", coordinate: CLLocationCoordinate2D(latitude: 34.2333, longitude: 131.3000)),
                    LocalizedAttractionLocation(nameKey: "attraction_hagi", descriptionKey: "attraction_hagi_desc", coordinate: CLLocationCoordinate2D(latitude: 34.4167, longitude: 131.4000)),
                    LocalizedAttractionLocation(nameKey: "attraction_kintaikyo", descriptionKey: "attraction_kintaikyo_desc", coordinate: CLLocationCoordinate2D(latitude: 34.1700, longitude: 132.1800)),
                    LocalizedAttractionLocation(nameKey: "attraction_shimonoseki", descriptionKey: "attraction_shimonoseki_desc", coordinate: CLLocationCoordinate2D(latitude: 33.9500, longitude: 130.9167)),
                    LocalizedAttractionLocation(nameKey: "attraction_rurikoji", descriptionKey: "attraction_rurikoji_desc", coordinate: CLLocationCoordinate2D(latitude: 34.1833, longitude: 131.4667)),
                    LocalizedAttractionLocation(nameKey: "attraction_tsunoshima_bridge", descriptionKey: "attraction_tsunoshima_bridge_desc", coordinate: CLLocationCoordinate2D(latitude: 34.4167, longitude: 130.8833))
                ],
                foodKeys: ["food_fugu", "food_kawara_soba", "food_iwakuni_lotus_root", "food_shimonoseki_whale", "food_natsumikan"],
                searchKeyword: "Yamaguchi Japan",
                region: CLLocationCoordinate2D(latitude: 34.1859, longitude: 131.4706)
            )
        case .shimane:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_izumo_taisha", descriptionKey: "attraction_izumo_taisha_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4019, longitude: 132.6858)),
                    LocalizedAttractionLocation(nameKey: "attraction_matsue_castle", descriptionKey: "attraction_matsue_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4742, longitude: 133.0506)),
                    LocalizedAttractionLocation(nameKey: "attraction_iwami_ginzan", descriptionKey: "attraction_iwami_ginzan_desc", coordinate: CLLocationCoordinate2D(latitude: 35.1000, longitude: 132.4333)),
                    LocalizedAttractionLocation(nameKey: "attraction_oki_islands", descriptionKey: "attraction_oki_islands_desc", coordinate: CLLocationCoordinate2D(latitude: 36.2000, longitude: 133.3000)),
                    LocalizedAttractionLocation(nameKey: "attraction_adachi_museum", descriptionKey: "attraction_adachi_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4333, longitude: 133.3167)),
                    LocalizedAttractionLocation(nameKey: "attraction_lake_shinji", descriptionKey: "attraction_lake_shinji_desc", coordinate: CLLocationCoordinate2D(latitude: 35.4333, longitude: 132.9667))
                ],
                foodKeys: ["food_izumo_soba", "food_shinjiko_shijimi", "food_nodoguro_shimane", "food_matsue_wagashi", "food_wariko_soba"],
                searchKeyword: "Shimane Japan",
                region: CLLocationCoordinate2D(latitude: 35.4723, longitude: 133.0505)
            )
        case .kagawa:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kotohira_shrine", descriptionKey: "attraction_kotohira_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 34.1833, longitude: 133.8167)),
                    LocalizedAttractionLocation(nameKey: "attraction_ritsurin_garden", descriptionKey: "attraction_ritsurin_garden_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3306, longitude: 134.0444)),
                    LocalizedAttractionLocation(nameKey: "attraction_shodoshima", descriptionKey: "attraction_shodoshima_desc", coordinate: CLLocationCoordinate2D(latitude: 34.4833, longitude: 134.2833)),
                    LocalizedAttractionLocation(nameKey: "attraction_yashima", descriptionKey: "attraction_yashima_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3500, longitude: 134.0833)),
                    LocalizedAttractionLocation(nameKey: "attraction_naoshima", descriptionKey: "attraction_naoshima_desc", coordinate: CLLocationCoordinate2D(latitude: 34.4667, longitude: 133.9833)),
                    LocalizedAttractionLocation(nameKey: "attraction_seto_ohashi_memorial_park", descriptionKey: "attraction_seto_ohashi_memorial_park_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3667, longitude: 133.8167))
                ],
                foodKeys: ["food_sanuki_udon", "food_olive", "food_honetsuki_dori", "food_wasanbon", "food_shodoshima_somen"],
                searchKeyword: "Kagawa Japan",
                region: CLLocationCoordinate2D(latitude: 34.3401, longitude: 134.0434)
            )
        case .tokushima:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_naruto_whirlpools", descriptionKey: "attraction_naruto_whirlpools_desc", coordinate: CLLocationCoordinate2D(latitude: 34.2333, longitude: 134.6000)),
                    LocalizedAttractionLocation(nameKey: "attraction_awa_odori", descriptionKey: "attraction_awa_odori_desc", coordinate: CLLocationCoordinate2D(latitude: 34.0658, longitude: 134.5594)),
                    LocalizedAttractionLocation(nameKey: "attraction_iya_kazura_bridge", descriptionKey: "attraction_iya_kazura_bridge_desc", coordinate: CLLocationCoordinate2D(latitude: 33.8667, longitude: 133.8167)),
                    LocalizedAttractionLocation(nameKey: "attraction_otsuka_museum", descriptionKey: "attraction_otsuka_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 34.2333, longitude: 134.6000)),
                    LocalizedAttractionLocation(nameKey: "attraction_mount_tsurugi", descriptionKey: "attraction_mount_tsurugi_desc", coordinate: CLLocationCoordinate2D(latitude: 33.8667, longitude: 134.1000)),
                    LocalizedAttractionLocation(nameKey: "attraction_bizan", descriptionKey: "attraction_bizan_desc", coordinate: CLLocationCoordinate2D(latitude: 34.0667, longitude: 134.5500))
                ],
                foodKeys: ["food_awa_odori_chicken", "food_tarai_udon", "food_sudachi", "food_naruto_kintoki", "food_handa_somen"],
                searchKeyword: "Tokushima Japan",
                region: CLLocationCoordinate2D(latitude: 34.0658, longitude: 134.5594)
            )
        case .kochi:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kochi_castle", descriptionKey: "attraction_kochi_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 33.5597, longitude: 133.5311)),
                    LocalizedAttractionLocation(nameKey: "attraction_katsurahama", descriptionKey: "attraction_katsurahama_desc", coordinate: CLLocationCoordinate2D(latitude: 33.5000, longitude: 133.5833)),
                    LocalizedAttractionLocation(nameKey: "attraction_shimanto_river", descriptionKey: "attraction_shimanto_river_desc", coordinate: CLLocationCoordinate2D(latitude: 33.0000, longitude: 133.0000)),
                    LocalizedAttractionLocation(nameKey: "attraction_muroto_cape", descriptionKey: "attraction_muroto_cape_desc", coordinate: CLLocationCoordinate2D(latitude: 33.2500, longitude: 134.1667)),
                    LocalizedAttractionLocation(nameKey: "attraction_ashizuri_cape", descriptionKey: "attraction_ashizuri_cape_desc", coordinate: CLLocationCoordinate2D(latitude: 32.7333, longitude: 133.0167)),
                    LocalizedAttractionLocation(nameKey: "attraction_ryugado_cave", descriptionKey: "attraction_ryugado_cave_desc", coordinate: CLLocationCoordinate2D(latitude: 33.6667, longitude: 133.7000))
                ],
                foodKeys: ["food_katsuo_tataki", "food_sawachi_cuisine", "food_tosa_sake", "food_yuzu", "food_tosa_buntan"],
                searchKeyword: "Kochi Japan",
                region: CLLocationCoordinate2D(latitude: 33.5597, longitude: 133.5311)
            )
        case .ehime:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_matsuyama_castle", descriptionKey: "attraction_matsuyama_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 33.8456, longitude: 132.7653)),
                    LocalizedAttractionLocation(nameKey: "attraction_dogo_onsen", descriptionKey: "attraction_dogo_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 33.8517, longitude: 132.7867)),
                    LocalizedAttractionLocation(nameKey: "attraction_shimanami_kaido", descriptionKey: "attraction_shimanami_kaido_desc", coordinate: CLLocationCoordinate2D(latitude: 34.3000, longitude: 133.2000)),
                    LocalizedAttractionLocation(nameKey: "attraction_uchiko_town", descriptionKey: "attraction_uchiko_town_desc", coordinate: CLLocationCoordinate2D(latitude: 33.5500, longitude: 132.6500)),
                    LocalizedAttractionLocation(nameKey: "attraction_mount_ishizuchi", descriptionKey: "attraction_mount_ishizuchi_desc", coordinate: CLLocationCoordinate2D(latitude: 33.7667, longitude: 133.1167)),
                    LocalizedAttractionLocation(nameKey: "attraction_imabari_castle", descriptionKey: "attraction_imabari_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 34.0667, longitude: 132.9833))
                ],
                foodKeys: ["food_mikan", "food_jakoten", "food_tai_meshi", "food_iyokan", "food_botchan_dango"],
                searchKeyword: "Ehime Japan",
                region: CLLocationCoordinate2D(latitude: 33.8416, longitude: 132.7658)
            )
        case .fukuoka:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_dazaifu_tenmangu", descriptionKey: "attraction_dazaifu_tenmangu_desc", coordinate: CLLocationCoordinate2D(latitude: 33.5194, longitude: 130.5339)),
                    LocalizedAttractionLocation(nameKey: "attraction_fukuoka_castle", descriptionKey: "attraction_fukuoka_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 33.5833, longitude: 130.3833)),
                    LocalizedAttractionLocation(nameKey: "attraction_hakata_za", descriptionKey: "attraction_hakata_za_desc", coordinate: CLLocationCoordinate2D(latitude: 33.5944, longitude: 130.4056)),
                    LocalizedAttractionLocation(nameKey: "attraction_canal_city", descriptionKey: "attraction_canal_city_desc", coordinate: CLLocationCoordinate2D(latitude: 33.5903, longitude: 130.4111)),
                    LocalizedAttractionLocation(nameKey: "attraction_yanagawa_kudari", descriptionKey: "attraction_yanagawa_kudari_desc", coordinate: CLLocationCoordinate2D(latitude: 33.1667, longitude: 130.4000)),
                    LocalizedAttractionLocation(nameKey: "attraction_mojiko_retro", descriptionKey: "attraction_mojiko_retro_desc", coordinate: CLLocationCoordinate2D(latitude: 33.9417, longitude: 130.9608)),
                    LocalizedAttractionLocation(nameKey: "attraction_fukuoka_tower", descriptionKey: "attraction_fukuoka_tower_desc", coordinate: CLLocationCoordinate2D(latitude: 33.5932, longitude: 130.3515)),
                    LocalizedAttractionLocation(nameKey: "attraction_uminonakamichi", descriptionKey: "attraction_uminonakamichi_desc", coordinate: CLLocationCoordinate2D(latitude: 33.6700, longitude: 130.3320))
                ],
                foodKeys: ["food_hakata_ramen", "food_motsu_nabe", "food_karashi_mentaiko", "food_mizutaki", "food_hakata_torimon"],
                searchKeyword: "Fukuoka Japan",
                region: CLLocationCoordinate2D(latitude: 33.6064, longitude: 130.4181)
            )
        case .oita:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_beppu_onsen", descriptionKey: "attraction_beppu_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 33.2833, longitude: 131.5000)),
                    LocalizedAttractionLocation(nameKey: "attraction_yufuin", descriptionKey: "attraction_yufuin_desc", coordinate: CLLocationCoordinate2D(latitude: 33.2667, longitude: 131.3667)),
                    LocalizedAttractionLocation(nameKey: "attraction_usuki_stone_buddhas", descriptionKey: "attraction_usuki_stone_buddhas_desc", coordinate: CLLocationCoordinate2D(latitude: 33.1167, longitude: 131.8000)),
                    LocalizedAttractionLocation(nameKey: "attraction_kuju_mountains", descriptionKey: "attraction_kuju_mountains_desc", coordinate: CLLocationCoordinate2D(latitude: 33.1167, longitude: 131.2333)),
                    LocalizedAttractionLocation(nameKey: "attraction_nakatsu_castle", descriptionKey: "attraction_nakatsu_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 33.6000, longitude: 131.1833)),
                    LocalizedAttractionLocation(nameKey: "attraction_jigoku_meguri", descriptionKey: "attraction_jigoku_meguri_desc", coordinate: CLLocationCoordinate2D(latitude: 33.2833, longitude: 131.4667))
                ],
                foodKeys: ["food_seki_saba_aji", "food_toriten", "food_dango_soup", "food_bungo_beef", "food_kabosu"],
                searchKeyword: "Oita Japan",
                region: CLLocationCoordinate2D(latitude: 33.2382, longitude: 131.6126)
            )
        case .miyazaki:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_takachiho_gorge", descriptionKey: "attraction_takachiho_gorge_desc", coordinate: CLLocationCoordinate2D(latitude: 32.7167, longitude: 131.3000)),
                    LocalizedAttractionLocation(nameKey: "attraction_nichinan_coast", descriptionKey: "attraction_nichinan_coast_desc", coordinate: CLLocationCoordinate2D(latitude: 31.5667, longitude: 131.4167)),
                    LocalizedAttractionLocation(nameKey: "attraction_aoshima", descriptionKey: "attraction_aoshima_desc", coordinate: CLLocationCoordinate2D(latitude: 31.7833, longitude: 131.4667)),
                    LocalizedAttractionLocation(nameKey: "attraction_udo_shrine", descriptionKey: "attraction_udo_shrine_desc", coordinate: CLLocationCoordinate2D(latitude: 31.6833, longitude: 131.4500)),
                    LocalizedAttractionLocation(nameKey: "attraction_sun_messe_nichinan", descriptionKey: "attraction_sun_messe_nichinan_desc", coordinate: CLLocationCoordinate2D(latitude: 31.5500, longitude: 131.4000)),
                    LocalizedAttractionLocation(nameKey: "attraction_saito_ancient_burial_mounds", descriptionKey: "attraction_saito_ancient_burial_mounds_desc", coordinate: CLLocationCoordinate2D(latitude: 32.1000, longitude: 131.4000))
                ],
                foodKeys: ["food_miyazaki_beef", "food_chicken_nanban", "food_hiyajiru", "food_mango", "food_shochu"],
                searchKeyword: "Miyazaki Japan",
                region: CLLocationCoordinate2D(latitude: 31.9077, longitude: 131.4202)
            )
        case .kagoshima:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_sakurajima", descriptionKey: "attraction_sakurajima_desc", coordinate: CLLocationCoordinate2D(latitude: 31.5856, longitude: 130.6575)),
                    LocalizedAttractionLocation(nameKey: "attraction_yakushima", descriptionKey: "attraction_yakushima_desc", coordinate: CLLocationCoordinate2D(latitude: 30.3333, longitude: 130.5000)),
                    LocalizedAttractionLocation(nameKey: "attraction_kirishima_onsen", descriptionKey: "attraction_kirishima_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 31.9333, longitude: 130.8667)),
                    LocalizedAttractionLocation(nameKey: "attraction_ibusuki_onsen", descriptionKey: "attraction_ibusuki_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 31.2500, longitude: 130.6333)),
                    LocalizedAttractionLocation(nameKey: "attraction_amami_oshima", descriptionKey: "attraction_amami_oshima_desc", coordinate: CLLocationCoordinate2D(latitude: 28.3833, longitude: 129.5000)),
                    LocalizedAttractionLocation(nameKey: "attraction_chiran_peace_museum", descriptionKey: "attraction_chiran_peace_museum_desc", coordinate: CLLocationCoordinate2D(latitude: 31.3667, longitude: 130.4333))
                ],
                foodKeys: ["food_kurobuta", "food_satsuma_imo", "food_shochu_kagoshima", "food_kibinago", "food_shirokuma"],
                searchKeyword: "Kagoshima Japan",
                region: CLLocationCoordinate2D(latitude: 31.5602, longitude: 130.5581)
            )
        case .kumamoto:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_kumamoto_castle", descriptionKey: "attraction_kumamoto_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 32.8064, longitude: 130.7056)),
                    LocalizedAttractionLocation(nameKey: "attraction_mount_aso", descriptionKey: "attraction_mount_aso_desc", coordinate: CLLocationCoordinate2D(latitude: 32.8833, longitude: 131.1000)),
                    LocalizedAttractionLocation(nameKey: "attraction_kurokawa_onsen", descriptionKey: "attraction_kurokawa_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 33.0500, longitude: 131.1167)),
                    LocalizedAttractionLocation(nameKey: "attraction_amakusa", descriptionKey: "attraction_amakusa_desc", coordinate: CLLocationCoordinate2D(latitude: 32.4500, longitude: 130.1833)),
                    LocalizedAttractionLocation(nameKey: "attraction_kikuchi_valley", descriptionKey: "attraction_kikuchi_valley_desc", coordinate: CLLocationCoordinate2D(latitude: 32.9833, longitude: 131.0167)),
                    LocalizedAttractionLocation(nameKey: "attraction_tsujun_bridge", descriptionKey: "attraction_tsujun_bridge_desc", coordinate: CLLocationCoordinate2D(latitude: 32.7167, longitude: 131.0833))
                ],
                foodKeys: ["food_basashi", "food_dago_soup", "food_taipien", "food_karashi_renkon", "food_ikinari_dango"],
                searchKeyword: "Kumamoto Japan",
                region: CLLocationCoordinate2D(latitude: 32.7898, longitude: 130.7417)
            )
        case .saga:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_yoshinogari_ruins", descriptionKey: "attraction_yoshinogari_ruins_desc", coordinate: CLLocationCoordinate2D(latitude: 33.3333, longitude: 130.3833)),
                    LocalizedAttractionLocation(nameKey: "attraction_arita_porcelain", descriptionKey: "attraction_arita_porcelain_desc", coordinate: CLLocationCoordinate2D(latitude: 33.1833, longitude: 129.8833)),
                    LocalizedAttractionLocation(nameKey: "attraction_yobuko", descriptionKey: "attraction_yobuko_desc", coordinate: CLLocationCoordinate2D(latitude: 33.5333, longitude: 129.8167)),
                    LocalizedAttractionLocation(nameKey: "attraction_takeo_onsen", descriptionKey: "attraction_takeo_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 33.1833, longitude: 130.0167)),
                    LocalizedAttractionLocation(nameKey: "attraction_karatsu_castle", descriptionKey: "attraction_karatsu_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 33.4500, longitude: 129.9667)),
                    LocalizedAttractionLocation(nameKey: "attraction_ureshino_onsen", descriptionKey: "attraction_ureshino_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 33.1000, longitude: 130.0667))
                ],
                foodKeys: ["food_saga_beef", "food_yobuko_ika", "food_gabai_manju", "food_marubolo", "food_onsen_yudofu"],
                searchKeyword: "Saga Japan",
                region: CLLocationCoordinate2D(latitude: 33.2494, longitude: 130.2989)
            )
        case .nagasaki:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_huis_ten_bosch", descriptionKey: "attraction_huis_ten_bosch_desc", coordinate: CLLocationCoordinate2D(latitude: 33.0889, longitude: 129.7889)),
                    LocalizedAttractionLocation(nameKey: "attraction_glover_garden", descriptionKey: "attraction_glover_garden_desc", coordinate: CLLocationCoordinate2D(latitude: 32.7333, longitude: 129.8667)),
                    LocalizedAttractionLocation(nameKey: "attraction_peace_park", descriptionKey: "attraction_peace_park_desc", coordinate: CLLocationCoordinate2D(latitude: 32.7756, longitude: 129.8653)),
                    LocalizedAttractionLocation(nameKey: "attraction_gunkanjima", descriptionKey: "attraction_gunkanjima_desc", coordinate: CLLocationCoordinate2D(latitude: 32.6278, longitude: 129.7389)),
                    LocalizedAttractionLocation(nameKey: "attraction_unzen_onsen", descriptionKey: "attraction_unzen_onsen_desc", coordinate: CLLocationCoordinate2D(latitude: 32.7500, longitude: 130.2833)),
                    LocalizedAttractionLocation(nameKey: "attraction_shimabara_castle", descriptionKey: "attraction_shimabara_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 32.7833, longitude: 130.3667)),
                    LocalizedAttractionLocation(nameKey: "attraction_dejima", descriptionKey: "attraction_dejima_desc", coordinate: CLLocationCoordinate2D(latitude: 32.7436, longitude: 129.8724)),
                    LocalizedAttractionLocation(nameKey: "attraction_oura_church", descriptionKey: "attraction_oura_church_desc", coordinate: CLLocationCoordinate2D(latitude: 32.7343, longitude: 129.8701))
                ],
                foodKeys: ["food_champon", "food_sara_udon", "food_castella", "food_sasebo_burger", "food_kakuni_manju"],
                searchKeyword: "Nagasaki Japan",
                region: CLLocationCoordinate2D(latitude: 32.7503, longitude: 129.8677)
            )
        case .okinawa:
            return LocalizedTourismInfo(
                attractions: [
                    LocalizedAttractionLocation(nameKey: "attraction_shuri_castle", descriptionKey: "attraction_shuri_castle_desc", coordinate: CLLocationCoordinate2D(latitude: 26.2173, longitude: 127.7195)),
                    LocalizedAttractionLocation(nameKey: "attraction_churaumi_aquarium", descriptionKey: "attraction_churaumi_aquarium_desc", coordinate: CLLocationCoordinate2D(latitude: 26.6936, longitude: 127.8778)),
                    LocalizedAttractionLocation(nameKey: "attraction_junglia_okinawa", descriptionKey: "attraction_junglia_okinawa_desc", coordinate: CLLocationCoordinate2D(latitude: 26.6906, longitude: 127.9869)),
                    LocalizedAttractionLocation(nameKey: "attraction_taketomi_island", descriptionKey: "attraction_taketomi_island_desc", coordinate: CLLocationCoordinate2D(latitude: 24.3239, longitude: 124.0894)),
                    LocalizedAttractionLocation(nameKey: "attraction_ishigaki_island", descriptionKey: "attraction_ishigaki_island_desc", coordinate: CLLocationCoordinate2D(latitude: 24.3364, longitude: 124.1557)),
                    LocalizedAttractionLocation(nameKey: "attraction_zamami_island", descriptionKey: "attraction_zamami_island_desc", coordinate: CLLocationCoordinate2D(latitude: 26.2413, longitude: 127.3044)),
                    LocalizedAttractionLocation(nameKey: "attraction_manzamo", descriptionKey: "attraction_manzamo_desc", coordinate: CLLocationCoordinate2D(latitude: 26.4950, longitude: 127.8508)),
                    LocalizedAttractionLocation(nameKey: "attraction_himeyuri_no_to", descriptionKey: "attraction_himeyuri_no_to_desc", coordinate: CLLocationCoordinate2D(latitude: 26.1028, longitude: 127.7258))
                ],
                foodKeys: ["food_goya_chanpuru", "food_soki_soba", "food_sata_andagi", "food_umi_budo", "food_awamori"],
                searchKeyword: "Okinawa Japan",
                region: CLLocationCoordinate2D(latitude: 26.2474, longitude: 127.8311)
            )
        }
    }
}
