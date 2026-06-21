//
//  OtherFestivalView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/08/03.
//

import SwiftUI
import MapKit

// その他祭りカテゴリの定義
enum OtherFestivalCategory: String, CaseIterable {
    case spring
    case autumn
    case winter
    case sakura
    case illumination
    case snow
    case traditional
    
    var localizedName: String {
        switch self {
        case .spring:
            return NSLocalizedString("otherFestival.spring", comment: "春祭り")
        case .autumn:
            return NSLocalizedString("otherFestival.autumn", comment: "秋祭り")
        case .winter:
            return NSLocalizedString("otherFestival.winter", comment: "冬祭り")
        case .sakura:
            return NSLocalizedString("otherFestival.sakura", comment: "桜まつり")
        case .illumination:
            return NSLocalizedString("otherFestival.illumination", comment: "イルミネーション")
        case .snow:
            return NSLocalizedString("otherFestival.snow", comment: "雪まつり")
        case .traditional:
            return NSLocalizedString("otherFestival.traditional", comment: "伝統行事")
        }
    }
    
    var icon: String {
        switch self {
        case .spring: return "leaf.fill"
        case .autumn: return "leaf.arrow.circlepath"
        case .winter: return "snowflake"
        case .sakura: return "tree.fill"
        case .illumination: return "lightbulb.fill"
        case .snow: return "cloud.snow.fill"
        case .traditional: return "building.columns.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .spring: return .green
        case .autumn: return .orange
        case .winter: return .blue
        case .sakura: return .pink
        case .illumination: return .yellow
        case .snow: return .cyan
        case .traditional: return .purple
        }
    }
}

// その他祭りアイテムのデータモデル
struct OtherFestivalItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let category: OtherFestivalCategory
    let month: String
    let duration: String
    let scale: Int // 1-5で規模を表現
    let imageSymbol: String
    let location: String
    let features: [String]
    let coordinate: CLLocationCoordinate2D? // 旅行プラン用の位置情報（順次入力）

    // coordinate はデフォルト nil。既存の生成箇所は coordinate を省略でき、
    // 座標を入れたものから順に coordinate: を渡していける。
    init(
        name: String,
        description: String,
        category: OtherFestivalCategory,
        month: String,
        duration: String,
        scale: Int,
        imageSymbol: String,
        location: String,
        features: [String],
        coordinate: CLLocationCoordinate2D? = nil
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.month = month
        self.duration = duration
        self.scale = scale
        self.imageSymbol = imageSymbol
        self.location = location
        self.features = features
        self.coordinate = coordinate
    }

    static func == (lhs: OtherFestivalItem, rhs: OtherFestivalItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// 都道府県の拡張（その他祭り情報を含む）
extension Prefecture {
    var otherFestivalItems: [OtherFestivalItem] {
        switch self {
        case .hokkaido:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("hokkaido.sapporo_snow_festival.name", comment: ""),
                    description: NSLocalizedString("hokkaido.sapporo_snow_festival.description", comment: ""),
                    category: .snow,
                    month: NSLocalizedString("month_february", comment: ""),
                    duration: NSLocalizedString("duration_1_week", comment: ""),
                    scale: 5,
                    imageSymbol: "snowflake",
                    location: NSLocalizedString("hokkaido.sapporo_snow_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("hokkaido.sapporo_snow_festival.feature1", comment: ""),
                        NSLocalizedString("hokkaido.sapporo_snow_festival.feature2", comment: ""),
                        NSLocalizedString("hokkaido.sapporo_snow_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 43.0608, longitude: 141.3469) // 大通公園・すすきの
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("hokkaido.hakodate_goryokaku_festival.name", comment: ""),
                    description: NSLocalizedString("hokkaido.hakodate_goryokaku_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_may", comment: ""),
                    duration: NSLocalizedString("duration_2_days", comment: ""),
                    scale: 3,
                    imageSymbol: "star.fill",
                    location: NSLocalizedString("hokkaido.hakodate_goryokaku_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("hokkaido.hakodate_goryokaku_festival.feature1", comment: ""),
                        NSLocalizedString("hokkaido.hakodate_goryokaku_festival.feature2", comment: ""),
                        NSLocalizedString("hokkaido.hakodate_goryokaku_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 41.7969, longitude: 140.7569) // 五稜郭公園
                )
            ]
        case .aomori:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("aomori.hirosaki_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("aomori.hirosaki_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_range_april_may", comment: ""),
                    duration: NSLocalizedString("duration_3_weeks", comment: ""),
                    scale: 5,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("aomori.hirosaki_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("aomori.hirosaki_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("aomori.hirosaki_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("aomori.hirosaki_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 40.6075, longitude: 140.4644) // 弘前公園
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("aomori.hachinohe_enburi.name", comment: ""),
                    description: NSLocalizedString("aomori.hachinohe_enburi.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_february", comment: ""),
                    duration: NSLocalizedString("duration_4_days", comment: ""),
                    scale: 4,
                    imageSymbol: "figure.dance",
                    location: NSLocalizedString("aomori.hachinohe_enburi.location", comment: ""),
                    features: [
                        NSLocalizedString("aomori.hachinohe_enburi.feature1", comment: ""),
                        NSLocalizedString("aomori.hachinohe_enburi.feature2", comment: ""),
                        NSLocalizedString("aomori.hachinohe_enburi.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 40.5123, longitude: 141.4883) // 八戸市中心部
                )
            ]
        case .iwate:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("iwate.kitakami_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("iwate.kitakami_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_range_april_may", comment: ""),
                    duration: NSLocalizedString("duration_3_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("iwate.kitakami_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("iwate.kitakami_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("iwate.kitakami_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("iwate.kitakami_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 39.2956, longitude: 141.1289) // 北上展勝地
                )
            ]
        case .miyagi:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("miyagi.hitome_senbon_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("miyagi.hitome_senbon_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("miyagi.hitome_senbon_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("miyagi.hitome_senbon_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("miyagi.hitome_senbon_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("miyagi.hitome_senbon_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 38.0561, longitude: 140.7211) // 大河原町・柴田町(白石川堤)
                )
            ]
        case .akita:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("akita.namahage_sedo_festival.name", comment: ""),
                    description: NSLocalizedString("akita.namahage_sedo_festival.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_february", comment: ""),
                    duration: NSLocalizedString("duration_3_days", comment: ""),
                    scale: 4,
                    imageSymbol: "flame.fill",
                    location: NSLocalizedString("akita.namahage_sedo_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("akita.namahage_sedo_festival.feature1", comment: ""),
                        NSLocalizedString("akita.namahage_sedo_festival.feature2", comment: ""),
                        NSLocalizedString("akita.namahage_sedo_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 39.9214, longitude: 139.7869) // 男鹿市真山神社
                )
            ]
        case .yamagata:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("yamagata.zao_frost_festival.name", comment: ""),
                    description: NSLocalizedString("yamagata.zao_frost_festival.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_range_december_march", comment: ""),
                    duration: NSLocalizedString("duration_3_months", comment: ""),
                    scale: 5,
                    imageSymbol: "cloud.snow.fill",
                    location: NSLocalizedString("yamagata.zao_frost_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("yamagata.zao_frost_festival.feature1", comment: ""),
                        NSLocalizedString("yamagata.zao_frost_festival.feature2", comment: ""),
                        NSLocalizedString("yamagata.zao_frost_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 38.1597, longitude: 140.4419) // 蔵王温泉スキー場
                )
            ]
        case .fukushima:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("fukushima.ouchi_juku_snow_festival.name", comment: ""),
                    description: NSLocalizedString("fukushima.ouchi_juku_snow_festival.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_february", comment: ""),
                    duration: NSLocalizedString("duration_2_days", comment: ""),
                    scale: 4,
                    imageSymbol: "house.fill",
                    location: NSLocalizedString("fukushima.ouchi_juku_snow_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("fukushima.ouchi_juku_snow_festival.feature1", comment: ""),
                        NSLocalizedString("fukushima.ouchi_juku_snow_festival.feature2", comment: ""),
                        NSLocalizedString("fukushima.ouchi_juku_snow_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 37.3361, longitude: 139.8556) // 下郷町大内宿
                )
            ]
        case .ibaraki:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("ibaraki.nemophila_festival.name", comment: ""),
                    description: NSLocalizedString("ibaraki.nemophila_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_april_may", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 5,
                    imageSymbol: "leaf.fill",
                    location: NSLocalizedString("ibaraki.nemophila_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("ibaraki.nemophila_festival.feature1", comment: ""),
                        NSLocalizedString("ibaraki.nemophila_festival.feature2", comment: ""),
                        NSLocalizedString("ibaraki.nemophila_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 36.4017, longitude: 140.59) // ひたちなか海浜公園
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("ibaraki.kairakuen_plum_festival.name", comment: ""),
                    description: NSLocalizedString("ibaraki.kairakuen_plum_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_february_march", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("ibaraki.kairakuen_plum_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("ibaraki.kairakuen_plum_festival.feature1", comment: ""),
                        NSLocalizedString("ibaraki.kairakuen_plum_festival.feature2", comment: ""),
                        NSLocalizedString("ibaraki.kairakuen_plum_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 36.3756, longitude: 140.4525) // 水戸市偕楽園
                )
            ]
        case .tochigi:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("tochigi.ashikaga_wisteria_festival.name", comment: ""),
                    description: NSLocalizedString("tochigi.ashikaga_wisteria_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_april_may", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 5,
                    imageSymbol: "leaf.fill",
                    location: NSLocalizedString("tochigi.ashikaga_wisteria_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("tochigi.ashikaga_wisteria_festival.feature1", comment: ""),
                        NSLocalizedString("tochigi.ashikaga_wisteria_festival.feature2", comment: ""),
                        NSLocalizedString("tochigi.ashikaga_wisteria_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 36.3146, longitude: 139.5197) // 足利フラワーパーク
                )
            ]
        case .gunma:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("gunma.kusatsu_onsen_festival.name", comment: ""),
                    description: NSLocalizedString("gunma.kusatsu_onsen_festival.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_january", comment: ""),
                    duration: NSLocalizedString("duration_1_day", comment: ""),
                    scale: 3,
                    imageSymbol: "drop.fill",
                    location: NSLocalizedString("gunma.kusatsu_onsen_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("gunma.kusatsu_onsen_festival.feature1", comment: ""),
                        NSLocalizedString("gunma.kusatsu_onsen_festival.feature2", comment: ""),
                        NSLocalizedString("gunma.kusatsu_onsen_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 36.6228, longitude: 138.5967) // 草津温泉街
                )
            ]
        case .saitama:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("saitama.chichibu_night_festival.name", comment: ""),
                    description: NSLocalizedString("saitama.chichibu_night_festival.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_december", comment: ""),
                    duration: NSLocalizedString("duration_2_days", comment: ""),
                    scale: 5,
                    imageSymbol: "snowflake",
                    location: NSLocalizedString("saitama.chichibu_night_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("saitama.chichibu_night_festival.feature1", comment: ""),
                        NSLocalizedString("saitama.chichibu_night_festival.feature2", comment: ""),
                        NSLocalizedString("saitama.chichibu_night_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.9925, longitude: 139.0856) // 秩父市(秩父神社)
                )
            ]
        case .chiba:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("chiba.sakura_tulip_festa.name", comment: ""),
                    description: NSLocalizedString("chiba.sakura_tulip_festa.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_3_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "leaf.fill",
                    location: NSLocalizedString("chiba.sakura_tulip_festa.location", comment: ""),
                    features: [
                        NSLocalizedString("chiba.sakura_tulip_festa.feature1", comment: ""),
                        NSLocalizedString("chiba.sakura_tulip_festa.feature2", comment: ""),
                        NSLocalizedString("chiba.sakura_tulip_festa.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.7372, longitude: 140.2228) // 佐倉ふるさと広場
                )
            ]
        case .tokyo:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("tokyo.ueno_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("tokyo.ueno_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_range_march_may", comment: ""),
                    duration: NSLocalizedString("duration_3_weeks", comment: ""),
                    scale: 5,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("tokyo.ueno_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("tokyo.ueno_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("tokyo.ueno_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("tokyo.ueno_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.7714) // 上野恩賜公園
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("tokyo.meiji_jingu_ginkgo_festival.name", comment: ""),
                    description: NSLocalizedString("tokyo.meiji_jingu_ginkgo_festival.description", comment: ""),
                    category: .autumn,
                    month: NSLocalizedString("month_november", comment: ""),
                    duration: NSLocalizedString("duration_3_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "leaf.arrow.circlepath",
                    location: NSLocalizedString("tokyo.meiji_jingu_ginkgo_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("tokyo.meiji_jingu_ginkgo_festival.feature1", comment: ""),
                        NSLocalizedString("tokyo.meiji_jingu_ginkgo_festival.feature2", comment: ""),
                        NSLocalizedString("tokyo.meiji_jingu_ginkgo_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.6745, longitude: 139.717) // 明治神宮外苑
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("tokyo.meiji_jingu_hatsumode.name", comment: ""),
                    description: NSLocalizedString("tokyo.meiji_jingu_hatsumode.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_january", comment: ""),
                    duration: NSLocalizedString("duration_3_days", comment: ""),
                    scale: 5,
                    imageSymbol: "building.columns.fill",
                    location: NSLocalizedString("tokyo.meiji_jingu_hatsumode.location", comment: ""),
                    features: [
                        NSLocalizedString("tokyo.meiji_jingu_hatsumode.feature1", comment: ""),
                        NSLocalizedString("tokyo.meiji_jingu_hatsumode.feature2", comment: ""),
                        NSLocalizedString("tokyo.meiji_jingu_hatsumode.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.6764, longitude: 139.6993) // 明治神宮
                )
            ]
        case .kanagawa:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("kanagawa.odawara_plum_festival.name", comment: ""),
                    description: NSLocalizedString("kanagawa.odawara_plum_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_february_march", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 3,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("kanagawa.odawara_plum_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("kanagawa.odawara_plum_festival.feature1", comment: ""),
                        NSLocalizedString("kanagawa.odawara_plum_festival.feature2", comment: ""),
                        NSLocalizedString("kanagawa.odawara_plum_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.2506, longitude: 139.1536) // 小田原城址公園
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("kanagawa.hakone_ekiden.name", comment: ""),
                    description: NSLocalizedString("kanagawa.hakone_ekiden.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_january", comment: ""),
                    duration: NSLocalizedString("duration_2_days", comment: ""),
                    scale: 5,
                    imageSymbol: "figure.run",
                    location: NSLocalizedString("kanagawa.hakone_ekiden.location", comment: ""),
                    features: [
                        NSLocalizedString("kanagawa.hakone_ekiden.feature1", comment: ""),
                        NSLocalizedString("kanagawa.hakone_ekiden.feature2", comment: ""),
                        NSLocalizedString("kanagawa.hakone_ekiden.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.2324, longitude: 139.1069) // 東京〜箱根(芦ノ湖)
                )
            ]
        case .niigata:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("niigata.takada_castle_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("niigata.takada_castle_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 5,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("niigata.takada_castle_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("niigata.takada_castle_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("niigata.takada_castle_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("niigata.takada_castle_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 37.1075, longitude: 138.2517) // 高田公園
                )
            ]
        case .toyama:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("toyama.tonami_tulip_fair.name", comment: ""),
                    description: NSLocalizedString("toyama.tonami_tulip_fair.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_april_may", comment: ""),
                    duration: NSLocalizedString("duration_3_weeks", comment: ""),
                    scale: 5,
                    imageSymbol: "leaf.fill",
                    location: NSLocalizedString("toyama.tonami_tulip_fair.location", comment: ""),
                    features: [
                        NSLocalizedString("toyama.tonami_tulip_fair.feature1", comment: ""),
                        NSLocalizedString("toyama.tonami_tulip_fair.feature2", comment: ""),
                        NSLocalizedString("toyama.tonami_tulip_fair.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 36.6469, longitude: 136.9508) // 砺波チューリップ公園
                )
            ]
        case .ishikawa:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("ishikawa.kenrokuen_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("ishikawa.kenrokuen_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("ishikawa.kenrokuen_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("ishikawa.kenrokuen_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("ishikawa.kenrokuen_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("ishikawa.kenrokuen_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 36.5622, longitude: 136.6625) // 兼六園
                )
            ]
        case .yamanashi:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("yamanashi.fuji_shibazakura_festival.name", comment: ""),
                    description: NSLocalizedString("yamanashi.fuji_shibazakura_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_april_may", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 5,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("yamanashi.fuji_shibazakura_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("yamanashi.fuji_shibazakura_festival.feature1", comment: ""),
                        NSLocalizedString("yamanashi.fuji_shibazakura_festival.feature2", comment: ""),
                        NSLocalizedString("yamanashi.fuji_shibazakura_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.4869, longitude: 138.6056) // 富士本栖湖リゾート
                )
            ]
        case .nagano:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("nagano.takato_castle_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("nagano.takato_castle_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_3_weeks", comment: ""),
                    scale: 5,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("nagano.takato_castle_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("nagano.takato_castle_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("nagano.takato_castle_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("nagano.takato_castle_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.8336, longitude: 138.0631) // 高遠城址公園
                )
            ]
        case .gifu:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("gifu.shirakawago_illumination.name", comment: ""),
                    description: NSLocalizedString("gifu.shirakawago_illumination.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_range_january_february", comment: ""),
                    duration: NSLocalizedString("duration_few_days", comment: ""),
                    scale: 5,
                    imageSymbol: "lightbulb.fill",
                    location: NSLocalizedString("gifu.shirakawago_illumination.location", comment: ""),
                    features: [
                        NSLocalizedString("gifu.shirakawago_illumination.feature1", comment: ""),
                        NSLocalizedString("gifu.shirakawago_illumination.feature2", comment: ""),
                        NSLocalizedString("gifu.shirakawago_illumination.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 36.2581, longitude: 136.9063) // 白川郷合掌造り集落
                )
            ]
        case .shizuoka:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("shizuoka.kawazu_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("shizuoka.kawazu_cherry_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_february_march", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("shizuoka.kawazu_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("shizuoka.kawazu_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("shizuoka.kawazu_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("shizuoka.kawazu_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.7536, longitude: 138.9519) // 河津町
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("shizuoka.atami_plum_festival.name", comment: ""),
                    description: NSLocalizedString("shizuoka.atami_plum_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_january_march", comment: ""),
                    duration: NSLocalizedString("duration_2_months", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("shizuoka.atami_plum_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("shizuoka.atami_plum_festival.feature1", comment: ""),
                        NSLocalizedString("shizuoka.atami_plum_festival.feature2", comment: ""),
                        NSLocalizedString("shizuoka.atami_plum_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.1108, longitude: 139.0639) // 熱海梅園
                )
            ]
        case .aichi:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("aichi.korankei_maple_festival.name", comment: ""),
                    description: NSLocalizedString("aichi.korankei_maple_festival.description", comment: ""),
                    category: .autumn,
                    month: NSLocalizedString("month_november", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 5,
                    imageSymbol: "leaf.arrow.circlepath",
                    location: NSLocalizedString("aichi.korankei_maple_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("aichi.korankei_maple_festival.feature1", comment: ""),
                        NSLocalizedString("aichi.korankei_maple_festival.feature2", comment: ""),
                        NSLocalizedString("aichi.korankei_maple_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.1531, longitude: 137.3211) // 豊田市香嵐渓
                )
            ]
        case .mie:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("mie.nabana_no_sato_illumination.name", comment: ""),
                    description: NSLocalizedString("mie.nabana_no_sato_illumination.description", comment: ""),
                    category: .illumination,
                    month: NSLocalizedString("month_range_october_may", comment: ""),
                    duration: NSLocalizedString("duration_8_months", comment: ""),
                    scale: 5,
                    imageSymbol: "lightbulb.fill",
                    location: NSLocalizedString("mie.nabana_no_sato_illumination.location", comment: ""),
                    features: [
                        NSLocalizedString("mie.nabana_no_sato_illumination.feature1", comment: ""),
                        NSLocalizedString("mie.nabana_no_sato_illumination.feature2", comment: ""),
                        NSLocalizedString("mie.nabana_no_sato_illumination.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.0489, longitude: 136.6906) // なばなの里
                )
            ]
        case .kyoto:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("kyoto.aoi_matsuri.name", comment: ""),
                    description: NSLocalizedString("kyoto.aoi_matsuri.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_may", comment: ""),
                    duration: NSLocalizedString("duration_1_day", comment: ""),
                    scale: 5,
                    imageSymbol: "crown.fill",
                    location: NSLocalizedString("kyoto.aoi_matsuri.location", comment: ""),
                    features: [
                        NSLocalizedString("kyoto.aoi_matsuri.feature1", comment: ""),
                        NSLocalizedString("kyoto.aoi_matsuri.feature2", comment: ""),
                        NSLocalizedString("kyoto.aoi_matsuri.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.0606, longitude: 135.7528) // 京都御所〜上賀茂神社
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("kyoto.kyoto_hanatoro.name", comment: ""),
                    description: NSLocalizedString("kyoto.kyoto_hanatoro.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_december", comment: ""),
                    duration: NSLocalizedString("duration_10_days", comment: ""),
                    scale: 4,
                    imageSymbol: "lightbulb.fill",
                    location: NSLocalizedString("kyoto.kyoto_hanatoro.location", comment: ""),
                    features: [
                        NSLocalizedString("kyoto.kyoto_hanatoro.feature1", comment: ""),
                        NSLocalizedString("kyoto.kyoto_hanatoro.feature2", comment: ""),
                        NSLocalizedString("kyoto.kyoto_hanatoro.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.0094, longitude: 135.6772) // 嵐山・東山
                )
            ]
        case .osaka:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("osaka.mint_cherry_blossom.name", comment: ""),
                    description: NSLocalizedString("osaka.mint_cherry_blossom.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_1_week", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("osaka.mint_cherry_blossom.location", comment: ""),
                    features: [
                        NSLocalizedString("osaka.mint_cherry_blossom.feature1", comment: ""),
                        NSLocalizedString("osaka.mint_cherry_blossom.feature2", comment: ""),
                        NSLocalizedString("osaka.mint_cherry_blossom.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.6939, longitude: 135.5217) // 造幣局
                )
            ]
        case .hyogo:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("hyogo.kobe_luminarie.name", comment: ""),
                    description: NSLocalizedString("hyogo.kobe_luminarie.description", comment: ""),
                    category: .illumination,
                    month: NSLocalizedString("month_december", comment: ""),
                    duration: NSLocalizedString("duration_12_days", comment: ""),
                    scale: 5,
                    imageSymbol: "lightbulb.fill",
                    location: NSLocalizedString("hyogo.kobe_luminarie.location", comment: ""),
                    features: [
                        NSLocalizedString("hyogo.kobe_luminarie.feature1", comment: ""),
                        NSLocalizedString("hyogo.kobe_luminarie.feature2", comment: ""),
                        NSLocalizedString("hyogo.kobe_luminarie.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.69, longitude: 135.1956) // 神戸市中心部(旧居留地)
                )
            ]
        case .nara:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("nara.yoshinoyama_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("nara.yoshinoyama_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_3_weeks", comment: ""),
                    scale: 5,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("nara.yoshinoyama_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("nara.yoshinoyama_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("nara.yoshinoyama_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("nara.yoshinoyama_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.3656, longitude: 135.8581) // 吉野山
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("nara.wakakusayama_yamayaki.name", comment: ""),
                    description: NSLocalizedString("nara.wakakusayama_yamayaki.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_january", comment: ""),
                    duration: NSLocalizedString("duration_1_day", comment: ""),
                    scale: 4,
                    imageSymbol: "flame.fill",
                    location: NSLocalizedString("nara.wakakusayama_yamayaki.location", comment: ""),
                    features: [
                        NSLocalizedString("nara.wakakusayama_yamayaki.feature1", comment: ""),
                        NSLocalizedString("nara.wakakusayama_yamayaki.feature2", comment: ""),
                        NSLocalizedString("nara.wakakusayama_yamayaki.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.6839, longitude: 135.8556) // 若草山
                )
            ]
        case .wakayama:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("wakayama.nanbu_plum_grove.name", comment: ""),
                    description: NSLocalizedString("wakayama.nanbu_plum_grove.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_february_march", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("wakayama.nanbu_plum_grove.location", comment: ""),
                    features: [
                        NSLocalizedString("wakayama.nanbu_plum_grove.feature1", comment: ""),
                        NSLocalizedString("wakayama.nanbu_plum_grove.feature2", comment: ""),
                        NSLocalizedString("wakayama.nanbu_plum_grove.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 33.7989, longitude: 135.3239) // みなべ町(南部梅林)
                )
            ]
        case .shimane:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("shimane.matsue_castle_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("shimane.matsue_castle_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "castle.fill",
                    location: NSLocalizedString("shimane.matsue_castle_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("shimane.matsue_castle_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("shimane.matsue_castle_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("shimane.matsue_castle_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.475, longitude: 133.0506) // 松江城
                )
            ]
        case .okayama:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("okayama.korakuen_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("okayama.korakuen_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("okayama.korakuen_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("okayama.korakuen_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("okayama.korakuen_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("okayama.korakuen_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.6678, longitude: 133.9358) // 岡山後楽園
                )
            ]
        case .hiroshima:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("hiroshima.miyajima_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("hiroshima.miyajima_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 5,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("hiroshima.miyajima_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("hiroshima.miyajima_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("hiroshima.miyajima_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("hiroshima.miyajima_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.2958, longitude: 132.3197) // 宮島(厳島神社)
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("hiroshima.miyajima_autumn_festival.name", comment: ""),
                    description: NSLocalizedString("hiroshima.miyajima_autumn_festival.description", comment: ""),
                    category: .autumn,
                    month: NSLocalizedString("month_november", comment: ""),
                    duration: NSLocalizedString("duration_3_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "leaf.arrow.circlepath",
                    location: NSLocalizedString("hiroshima.miyajima_autumn_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("hiroshima.miyajima_autumn_festival.feature1", comment: ""),
                        NSLocalizedString("hiroshima.miyajima_autumn_festival.feature2", comment: ""),
                        NSLocalizedString("hiroshima.miyajima_autumn_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.29, longitude: 132.3197) // 宮島(紅葉谷)
                )
            ]
        case .yamaguchi:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("yamaguchi.kintaikyo_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("yamaguchi.kintaikyo_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("yamaguchi.kintaikyo_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("yamaguchi.kintaikyo_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("yamaguchi.kintaikyo_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("yamaguchi.kintaikyo_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.1675, longitude: 132.1769) // 岩国市錦帯橋
                )
            ]
        case .tokushima:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("tokushima.katsuura_big_hina_festival.name", comment: ""),
                    description: NSLocalizedString("tokushima.katsuura_big_hina_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_february_april", comment: ""),
                    duration: NSLocalizedString("duration_2_months", comment: ""),
                    scale: 4,
                    imageSymbol: "figure.2.and.child.holdinghands",
                    location: NSLocalizedString("tokushima.katsuura_big_hina_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("tokushima.katsuura_big_hina_festival.feature1", comment: ""),
                        NSLocalizedString("tokushima.katsuura_big_hina_festival.feature2", comment: ""),
                        NSLocalizedString("tokushima.katsuura_big_hina_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 33.93, longitude: 134.4017) // 勝浦町
                )
            ]
        case .kagawa:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("kagawa.ritsurin_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("kagawa.ritsurin_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "tree.fill",
                    location: NSLocalizedString("kagawa.ritsurin_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("kagawa.ritsurin_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("kagawa.ritsurin_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("kagawa.ritsurin_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.3294, longitude: 134.0436) // 栗林公園
                )
            ]
        case .ehime:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("ehime.matsuyama_castle_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("ehime.matsuyama_castle_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "castle.fill",
                    location: NSLocalizedString("ehime.matsuyama_castle_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("ehime.matsuyama_castle_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("ehime.matsuyama_castle_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("ehime.matsuyama_castle_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 33.8456, longitude: 132.7656) // 松山城
                )
            ]
        case .kochi:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("kochi.kochi_castle_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("kochi.kochi_castle_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "castle.fill",
                    location: NSLocalizedString("kochi.kochi_castle_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("kochi.kochi_castle_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("kochi.kochi_castle_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("kochi.kochi_castle_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 33.5606, longitude: 133.5311) // 高知城
                )
            ]
        case .fukuoka:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("fukuoka.fukuoka_castle_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("fukuoka.fukuoka_castle_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "castle.fill",
                    location: NSLocalizedString("fukuoka.fukuoka_castle_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("fukuoka.fukuoka_castle_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("fukuoka.fukuoka_castle_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("fukuoka.fukuoka_castle_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 33.5847, longitude: 130.3825) // 舞鶴公園(福岡城)
                )
            ]
        case .saga:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("saga.arita_pottery_fair.name", comment: ""),
                    description: NSLocalizedString("saga.arita_pottery_fair.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_april_may", comment: ""),
                    duration: NSLocalizedString("duration_5_days", comment: ""),
                    scale: 5,
                    imageSymbol: "cup.and.saucer.fill",
                    location: NSLocalizedString("saga.arita_pottery_fair.location", comment: ""),
                    features: [
                        NSLocalizedString("saga.arita_pottery_fair.feature1", comment: ""),
                        NSLocalizedString("saga.arita_pottery_fair.feature2", comment: ""),
                        NSLocalizedString("saga.arita_pottery_fair.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 33.2061, longitude: 129.8869) // 有田町
                )
            ]
        case .nagasaki:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("nagasaki.huis_ten_bosch_flower_festival.name", comment: ""),
                    description: NSLocalizedString("nagasaki.huis_ten_bosch_flower_festival.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_range_march_may", comment: ""),
                    duration: NSLocalizedString("duration_2_months", comment: ""),
                    scale: 4,
                    imageSymbol: "leaf.fill",
                    location: NSLocalizedString("nagasaki.huis_ten_bosch_flower_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("nagasaki.huis_ten_bosch_flower_festival.feature1", comment: ""),
                        NSLocalizedString("nagasaki.huis_ten_bosch_flower_festival.feature2", comment: ""),
                        NSLocalizedString("nagasaki.huis_ten_bosch_flower_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 33.0858, longitude: 129.7906) // ハウステンボス
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("nagasaki.huis_ten_bosch_kingdom_of_light.name", comment: ""),
                    description: NSLocalizedString("nagasaki.huis_ten_bosch_kingdom_of_light.description", comment: ""),
                    category: .illumination,
                    month: NSLocalizedString("month_range_november_may", comment: ""),
                    duration: NSLocalizedString("duration_6_months", comment: ""),
                    scale: 5,
                    imageSymbol: "lightbulb.fill",
                    location: NSLocalizedString("nagasaki.huis_ten_bosch_kingdom_of_light.location", comment: ""),
                    features: [
                        NSLocalizedString("nagasaki.huis_ten_bosch_kingdom_of_light.feature1", comment: ""),
                        NSLocalizedString("nagasaki.huis_ten_bosch_kingdom_of_light.feature2", comment: ""),
                        NSLocalizedString("nagasaki.huis_ten_bosch_kingdom_of_light.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 33.0858, longitude: 129.7906) // ハウステンボス
                )
            ]
        case .kumamoto:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("kumamoto.kumamoto_castle_cherry_festival.name", comment: ""),
                    description: NSLocalizedString("kumamoto.kumamoto_castle_cherry_festival.description", comment: ""),
                    category: .sakura,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_2_weeks", comment: ""),
                    scale: 4,
                    imageSymbol: "castle.fill",
                    location: NSLocalizedString("kumamoto.kumamoto_castle_cherry_festival.location", comment: ""),
                    features: [
                        NSLocalizedString("kumamoto.kumamoto_castle_cherry_festival.feature1", comment: ""),
                        NSLocalizedString("kumamoto.kumamoto_castle_cherry_festival.feature2", comment: ""),
                        NSLocalizedString("kumamoto.kumamoto_castle_cherry_festival.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 32.8061, longitude: 130.7058) // 熊本城
                )
            ]
        case .miyazaki:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("miyazaki.takachiho_yokagura.name", comment: ""),
                    description: NSLocalizedString("miyazaki.takachiho_yokagura.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_range_november_february", comment: ""),
                    duration: NSLocalizedString("duration_4_months", comment: ""),
                    scale: 4,
                    imageSymbol: "theatermasks.fill",
                    location: NSLocalizedString("miyazaki.takachiho_yokagura.location", comment: ""),
                    features: [
                        NSLocalizedString("miyazaki.takachiho_yokagura.feature1", comment: ""),
                        NSLocalizedString("miyazaki.takachiho_yokagura.feature2", comment: ""),
                        NSLocalizedString("miyazaki.takachiho_yokagura.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 32.7117, longitude: 131.3072) // 高千穂町
                )
            ]
        case .okinawa:
            return [
                OtherFestivalItem(
                    name: NSLocalizedString("okinawa.ryukyu_kaiensai.name", comment: ""),
                    description: NSLocalizedString("okinawa.ryukyu_kaiensai.description", comment: ""),
                    category: .spring,
                    month: NSLocalizedString("month_april", comment: ""),
                    duration: NSLocalizedString("duration_1_day", comment: ""),
                    scale: 4,
                    imageSymbol: "sparkles",
                    location: NSLocalizedString("okinawa.ryukyu_kaiensai.location", comment: ""),
                    features: [
                        NSLocalizedString("okinawa.ryukyu_kaiensai.feature1", comment: ""),
                        NSLocalizedString("okinawa.ryukyu_kaiensai.feature2", comment: ""),
                        NSLocalizedString("okinawa.ryukyu_kaiensai.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 26.2806, longitude: 127.7) // 宜野湾海浜公園
                ),
                OtherFestivalItem(
                    name: NSLocalizedString("okinawa.professional_baseball_camp.name", comment: ""),
                    description: NSLocalizedString("okinawa.professional_baseball_camp.description", comment: ""),
                    category: .winter,
                    month: NSLocalizedString("month_range_february_march", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 4,
                    imageSymbol: "baseball.fill",
                    location: NSLocalizedString("okinawa.professional_baseball_camp.location", comment: ""),
                    features: [
                        NSLocalizedString("okinawa.professional_baseball_camp.feature1", comment: ""),
                        NSLocalizedString("okinawa.professional_baseball_camp.feature2", comment: ""),
                        NSLocalizedString("okinawa.professional_baseball_camp.feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 26.3344, longitude: 127.8056) // 沖縄県内各地(沖縄市)
                )
            ]
        default:
            return []
        }
    }
}

// リッチなその他祭りセクションのView
struct RichOtherFestivalSection: View {
    let prefecture: Prefecture
    @State private var selectedCategory: OtherFestivalCategory? = nil
    @State private var showAllItems = false
    @State private var selectedItem: OtherFestivalItem? = nil
    
    var filteredItems: [OtherFestivalItem] {
        let items = prefecture.otherFestivalItems
        if let category = selectedCategory {
            return items.filter { $0.category == category }
        }
        return showAllItems ? items : Array(items.prefix(4))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ヘッダー
            HStack {
                Image(systemName: "snowflake")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .cyan]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("festival.seasons", comment: "春・秋・冬の祭り"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(String(format: NSLocalizedString("festival.experience_seasons", comment: "%@の四季を体験"), prefecture.prefectureName))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // カテゴリフィルターボタン
                Menu {
                    Button("food_category_all".localized) {
                        selectedCategory = nil
                    }
                    
                    ForEach(OtherFestivalCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Label(category.localizedName, systemImage: category.icon)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            // カテゴリタグ（選択中の場合）
            if let category = selectedCategory {
                HStack {
                    Label(category.localizedName, systemImage: category.icon)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(category.color.opacity(0.2))
                        .foregroundColor(category.color)
                        .clipShape(Capsule())
                    
                    Button("groumet_clear".localized) {
                        selectedCategory = nil
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            // その他祭りアイテムのグリッド
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(filteredItems) { item in
                    OtherFestivalItemCard(item: item) {
                        selectedItem = item
                    }
                }
            }

            // もっと見るボタン
            if !showAllItems && prefecture.otherFestivalItems.count > 4 && selectedCategory == nil {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showAllItems = true
                    }
                }) {
                    HStack {
                        Text("load_more_groumet".localized)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            .background(Color.blue.opacity(0.05))
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .sheet(item: $selectedItem) { item in
            OtherFestivalDetailView(item: item, prefecture: prefecture)
        }
    }
}

// 個別のその他祭りアイテムカード
struct OtherFestivalItemCard: View {
    let item: OtherFestivalItem
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // トップセクション（アイコンと規模）
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    item.category.color.opacity(0.8),
                                    item.category.color
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.imageSymbol)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 規模スター
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= item.scale ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(star <= item.scale ? .orange : .gray.opacity(0.3))
                    }
                }
            }
            
            // メイン情報
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                
                Text(item.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // ボトム情報
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "calendar.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text(item.month)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: "clock.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text(item.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // カテゴリータグ
                    Text(item.category.localizedName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.category.color.opacity(0.2))
                        .foregroundColor(item.category.color)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: isPressed ? 2 : 8,
                    x: 0,
                    y: isPressed ? 1 : 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            item.category.color.opacity(0.3),
                            item.category.color.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // タップ時のアクション
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                // 詳細画面を表示
                onTap()
            }
        }
    }
}

// その他祭り詳細画面
struct OtherFestivalDetailView: View {
    let item: OtherFestivalItem
    let prefecture: Prefecture
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ヘッダーセクション
                    VStack(spacing: 20) {
                        // 大きなアイコンヘッダー
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            item.category.color.opacity(0.8),
                                            item.category.color
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: item.imageSymbol)
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        
                        // タイトル情報
                        VStack(spacing: 8) {
                            Text(item.name)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [item.category.color, item.category.color.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .multilineTextAlignment(.center)
                            
                            Text(String(format: "festival.of_prefecture".localized, prefecture.prefectureName))
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            // 規模表示
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= item.scale ? "star.fill" : "star")
                                        .font(.title3)
                                        .foregroundColor(star <= item.scale ? .orange : .gray.opacity(0.3))
                                }
                            }
                            .padding(.top, 8)

                            AddToPlanButton {
                                PlanItem(
                                    category: .festival,
                                    prefecture: prefecture,
                                    name: item.name
                                )
                            }
                            .padding(.top, 4)
                        }

                        // カテゴリータグ
                        Label(item.category.localizedName, systemImage: item.category.icon)
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(item.category.color.opacity(0.2))
                            .foregroundColor(item.category.color)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // 説明文
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.quote")
                                    .foregroundColor(.blue)
                                Text("detailed_info".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(item.description)
                                .font(.body)
                                .lineSpacing(6)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                        .stroke(item.category.color.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // 詳細情報カード
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.green)
                                Text("festival.event_info", comment: "開催情報")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                OtherFestivalInfoCard(icon: "calendar.circle.fill", title: NSLocalizedString("festival.period", comment: "開催時期"), value: item.month, color: .blue)
                                OtherFestivalInfoCard(icon: "clock.circle.fill", title: NSLocalizedString("festival.duration", comment: "期間"), value: item.duration, color: .green)
                                OtherFestivalInfoCard(icon: "location.circle.fill", title: NSLocalizedString("festival.location", comment: "開催地"), value: item.location, color: .red)
                                OtherFestivalInfoCard(icon: "trophy.fill", title: NSLocalizedString("festival.scale", comment: "規模"), value: getScaleText(item.scale), color: .orange)
                            }
                        }
                        
                        // 特徴・見どころ
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(NSLocalizedString("festival.highlights", comment: "見どころ・特徴"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(item.features, id: \.self) { feature in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                            .padding(.top, 2)
                                        
                                        Text(feature)
                                            .font(.subheadline)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }

                        // 楽しみ方の提案
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text(NSLocalizedString("festival.tips", comment: "楽しみ方のヒント"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(getOtherRecommendations(for: item), id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "heart.circle.fill")
                                            .foregroundColor(.pink)
                                            .font(.caption)
                                            .padding(.top, 2)
                                        
                                        Text(recommendation)
                                            .font(.subheadline)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .stroke(item.category.color.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)

                    // プランから開いたときの下部フローティングボタンを避ける余白
                    Color.clear.frame(height: 40)
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // 閉じるボタン
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    Spacer()
                }
            )
        }
    }
    
    private func getScaleText(_ scale: Int) -> String {
        switch scale {
        case 5: return "★★★★★"
        case 4: return "★★★★☆"
        case 3: return "★★★☆☆"
        case 2: return "★★☆☆☆"
        case 1: return "★☆☆☆☆"
        default: return "☆☆☆☆☆"
        }
    }
    
    private func getOtherRecommendations(for item: OtherFestivalItem) -> [String] {
        switch item.category {
        case .spring:
            return [
                NSLocalizedString("tips.spring.1", comment: ""),
                NSLocalizedString("tips.spring.2", comment: ""),
                NSLocalizedString("tips.spring.3", comment: "")
            ]
        case .autumn:
            return [
                NSLocalizedString("tips.autumn.1", comment: ""),
                NSLocalizedString("tips.autumn.2", comment: ""),
                NSLocalizedString("tips.autumn.3", comment: "")
            ]
        case .winter:
            return [
                NSLocalizedString("tips.winter.1", comment: ""),
                NSLocalizedString("tips.winter.2", comment: ""),
                NSLocalizedString("tips.winter.3", comment: "")
            ]
        case .sakura:
            return [
                NSLocalizedString("tips.sakura.1", comment: ""),
                NSLocalizedString("tips.sakura.2", comment: ""),
                NSLocalizedString("tips.sakura.3", comment: "")
            ]
        case .illumination:
            return [
                NSLocalizedString("tips.illumination.1", comment: ""),
                NSLocalizedString("tips.illumination.2", comment: ""),
                NSLocalizedString("tips.illumination.3", comment: "")
            ]
        case .snow:
            return [
                NSLocalizedString("tips.snow.1", comment: ""),
                NSLocalizedString("tips.snow.2", comment: ""),
                NSLocalizedString("tips.snow.3", comment: "")
            ]
        case .traditional:
            return [
                NSLocalizedString("tips.traditional.1", comment: ""),
                NSLocalizedString("tips.traditional.2", comment: ""),
                NSLocalizedString("tips.traditional.3", comment: "")
            ]
        }
    }
}

// その他祭り情報カードコンポーネント
struct OtherFestivalInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
