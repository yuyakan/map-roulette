//
//  FestivalView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/08/02.
//

import SwiftUI
import MapKit

// お祭りカテゴリの定義
enum FestivalCategory: String, CaseIterable {
    case summer
    case fireworks
    case traditional
    case dance
    case food
    case seasonal
    case religious
    
    var localizedName: String {
        switch self {
        case .summer:
            return NSLocalizedString("festival.summer", comment: "夏祭り")
        case .fireworks:
            return NSLocalizedString("festival.fireworks", comment: "花火大会")
        case .traditional:
            return NSLocalizedString("festival.traditional", comment: "伝統祭り")
        case .dance:
            return NSLocalizedString("festival.dance", comment: "踊り祭り")
        case .food:
            return NSLocalizedString("festival.food", comment: "食の祭り")
        case .seasonal:
            return NSLocalizedString("festival.seasonal", comment: "季節祭り")
        case .religious:
            return NSLocalizedString("festival.religious", comment: "宗教祭り")
        }
    }

    var icon: String {
        switch self {
        case .summer: return "sun.max.fill"
        case .fireworks: return "sparkles"
        case .traditional: return "building.columns.fill"
        case .dance: return "figure.dance"
        case .food: return "fork.knife"
        case .seasonal: return "leaf.fill"
        case .religious: return "building.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .summer: return .orange
        case .fireworks: return .purple
        case .traditional: return .brown
        case .dance: return .pink
        case .food: return .green
        case .seasonal: return .blue
        case .religious: return .indigo
        }
    }
}

// お祭りアイテムのデータモデル
struct FestivalItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let category: FestivalCategory
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
        category: FestivalCategory,
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

    static func == (lhs: FestivalItem, rhs: FestivalItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// 都道府県の拡張（お祭り情報を含む）
extension Prefecture {
    var festivalItems: [FestivalItem] {
        switch self {
        case .gifu:
            return [
                FestivalItem(
                    name: NSLocalizedString("gujo_odori_name", comment: ""),
                    description: NSLocalizedString("gujo_odori_description", comment: ""),
                    category: .dance,
                    month: NSLocalizedString("month_range_july_september", comment: ""),
                    duration: NSLocalizedString("duration_2_months", comment: ""),
                    scale: 4,
                    imageSymbol: "figure.dance",
                    location: NSLocalizedString("gujo_odori_location", comment: ""),
                    features: [
                        NSLocalizedString("gujo_odori_feature1", comment: ""),
                        NSLocalizedString("gujo_odori_feature2", comment: ""),
                        NSLocalizedString("gujo_odori_feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.7479, longitude: 136.9646) // 郡上八幡
                ),
                FestivalItem(
                    name: NSLocalizedString("gero_onsen_festival_name", comment: ""),
                    description: NSLocalizedString("gero_onsen_festival_description", comment: ""),
                    category: .summer,
                    month: NSLocalizedString("month_august", comment: ""),
                    duration: NSLocalizedString("duration_4_days", comment: ""),
                    scale: 3,
                    imageSymbol: "drop.fill",
                    location: NSLocalizedString("gero_onsen_festival_location", comment: ""),
                    features: [
                        NSLocalizedString("gero_onsen_festival_feature1", comment: ""),
                        NSLocalizedString("gero_onsen_festival_feature2", comment: ""),
                        NSLocalizedString("gero_onsen_festival_feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 35.8074, longitude: 137.2436) // 下呂温泉
                ),
                FestivalItem(
                    name: NSLocalizedString("hida_takayama_summer_festival_name", comment: ""),
                    description: NSLocalizedString("hida_takayama_summer_festival_description", comment: ""),
                    category: .summer,
                    month: NSLocalizedString("month_range_july_august", comment: ""),
                    duration: NSLocalizedString("duration_1_month", comment: ""),
                    scale: 3,
                    imageSymbol: "building.columns.fill",
                    location: NSLocalizedString("hida_takayama_summer_festival_location", comment: ""),
                    features: [
                        NSLocalizedString("hida_takayama_summer_festival_feature1", comment: ""),
                        NSLocalizedString("hida_takayama_summer_festival_feature2", comment: ""),
                        NSLocalizedString("hida_takayama_summer_festival_feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 36.1408, longitude: 137.2531) // 高山市（高山陣屋周辺）
                )
            ]

        // MARK: - 岡山県 (Okayama Prefecture)
        case .okayama:
            return [
                FestivalItem(
                    name: NSLocalizedString("okayama_momotaro_festival_name", comment: ""),
                    description: NSLocalizedString("okayama_momotaro_festival_description", comment: ""),
                    category: .summer,
                    month: NSLocalizedString("month_august", comment: ""),
                    duration: NSLocalizedString("duration_2_days", comment: ""),
                    scale: 4,
                    imageSymbol: "figure.dance",
                    location: NSLocalizedString("okayama_momotaro_festival_location", comment: ""),
                    features: [
                        NSLocalizedString("okayama_momotaro_festival_feature1", comment: ""),
                        NSLocalizedString("okayama_momotaro_festival_feature2", comment: ""),
                        NSLocalizedString("okayama_momotaro_festival_feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.6657, longitude: 133.9183) // 岡山市中心部(桃太郎大通り)
                ),
                FestivalItem(
                    name: NSLocalizedString("kurashiki_tenryo_festival_name", comment: ""),
                    description: NSLocalizedString("kurashiki_tenryo_festival_description", comment: ""),
                    category: .summer,
                    month: NSLocalizedString("month_july", comment: ""),
                    duration: NSLocalizedString("duration_2_days", comment: ""),
                    scale: 3,
                    imageSymbol: "drum.fill",
                    location: NSLocalizedString("kurashiki_tenryo_festival_location", comment: ""),
                    features: [
                        NSLocalizedString("kurashiki_tenryo_festival_feature1", comment: ""),
                        NSLocalizedString("kurashiki_tenryo_festival_feature2", comment: ""),
                        NSLocalizedString("kurashiki_tenryo_festival_feature3", comment: "")
                    ],
                    coordinate: CLLocationCoordinate2D(latitude: 34.595, longitude: 133.7717) // 倉敷美観地区
                )
            ]
        case .kumamoto:
                return [
                    FestivalItem(
                        name: NSLocalizedString("kumamoto_hinokuni_festival_name", comment: ""),
                        description: NSLocalizedString("kumamoto_hinokuni_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "flame.fill",
                        location: NSLocalizedString("kumamoto_hinokuni_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kumamoto_hinokuni_festival_feature1", comment: ""),
                            NSLocalizedString("kumamoto_hinokuni_festival_feature2", comment: ""),
                            NSLocalizedString("kumamoto_hinokuni_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 32.8032, longitude: 130.7079) // 熊本市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("yamaga_toro_festival_name", comment: ""),
                        description: NSLocalizedString("yamaga_toro_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "lightbulb.fill",
                        location: NSLocalizedString("yamaga_toro_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("yamaga_toro_festival_feature1", comment: ""),
                            NSLocalizedString("yamaga_toro_festival_feature2", comment: ""),
                            NSLocalizedString("yamaga_toro_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.0156, longitude: 130.6889) // 山鹿市(山鹿温泉)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("hitoyoshi_fireworks_name", comment: ""),
                        description: NSLocalizedString("hitoyoshi_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("hitoyoshi_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("hitoyoshi_fireworks_feature1", comment: ""),
                            NSLocalizedString("hitoyoshi_fireworks_feature2", comment: ""),
                            NSLocalizedString("hitoyoshi_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 32.2107, longitude: 130.7625) // 人吉市・球磨川
                    )
                ]
            case .oita:
                return [
                    FestivalItem(
                        name: NSLocalizedString("oita_tanabata_festival_name", comment: ""),
                        description: NSLocalizedString("oita_tanabata_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "star.fill",
                        location: NSLocalizedString("oita_tanabata_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("oita_tanabata_festival_feature1", comment: ""),
                            NSLocalizedString("oita_tanabata_festival_feature2", comment: ""),
                            NSLocalizedString("oita_tanabata_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.2382, longitude: 131.6126) // 大分市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("hita_gion_festival_name", comment: ""),
                        description: NSLocalizedString("hita_gion_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "sailboat.fill",
                        location: NSLocalizedString("hita_gion_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("hita_gion_festival_feature1", comment: ""),
                            NSLocalizedString("hita_gion_festival_feature2", comment: ""),
                            NSLocalizedString("hita_gion_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.3214, longitude: 130.941) // 日田市
                    ),
                    FestivalItem(
                        name: NSLocalizedString("beppu_hinoumi_festival_name", comment: ""),
                        description: NSLocalizedString("beppu_hinoumi_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "flame.fill",
                        location: NSLocalizedString("beppu_hinoumi_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("beppu_hinoumi_festival_feature1", comment: ""),
                            NSLocalizedString("beppu_hinoumi_festival_feature2", comment: ""),
                            NSLocalizedString("beppu_hinoumi_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.2846, longitude: 131.4911) // 別府市
                    )
                ]
            case .miyazaki:
                return [
                    FestivalItem(
                        name: NSLocalizedString("hyuga_hyottoko_festival_name", comment: ""),
                        description: NSLocalizedString("hyuga_hyottoko_festival_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "theatermasks.fill",
                        location: NSLocalizedString("hyuga_hyottoko_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("hyuga_hyottoko_festival_feature1", comment: ""),
                            NSLocalizedString("hyuga_hyottoko_festival_feature2", comment: ""),
                            NSLocalizedString("hyuga_hyottoko_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 32.4222, longitude: 131.6238) // 日向市
                    ),
                    FestivalItem(
                        name: NSLocalizedString("miyazaki_jingu_taisai_name", comment: ""),
                        description: NSLocalizedString("miyazaki_jingu_taisai_description", comment: ""),
                        category: .religious,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "building.columns.fill",
                        location: NSLocalizedString("miyazaki_jingu_taisai_location", comment: ""),
                        features: [
                            NSLocalizedString("miyazaki_jingu_taisai_feature1", comment: ""),
                            NSLocalizedString("miyazaki_jingu_taisai_feature2", comment: ""),
                            NSLocalizedString("miyazaki_jingu_taisai_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 31.9388, longitude: 131.4242) // 宮崎神宮
                    )
                ]
            case .kagoshima:
                return [
                    FestivalItem(
                        name: NSLocalizedString("kagoshima_ohara_festival_name", comment: ""),
                        description: NSLocalizedString("kagoshima_ohara_festival_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_november", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("kagoshima_ohara_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kagoshima_ohara_festival_feature1", comment: ""),
                            NSLocalizedString("kagoshima_ohara_festival_feature2", comment: ""),
                            NSLocalizedString("kagoshima_ohara_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 31.5904, longitude: 130.5571) // 鹿児島市中心部(天文館)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("sendaigawa_fireworks_name", comment: ""),
                        description: NSLocalizedString("sendaigawa_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("sendaigawa_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("sendaigawa_fireworks_feature1", comment: ""),
                            NSLocalizedString("sendaigawa_fireworks_feature2", comment: ""),
                            NSLocalizedString("sendaigawa_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 31.8133, longitude: 130.3037) // 薩摩川内市・川内川
                    )
                ]
            case .okinawa:
                return [
                    FestivalItem(
                        name: NSLocalizedString("okinawa_zento_eisa_festival_name", comment: ""),
                        description: NSLocalizedString("okinawa_zento_eisa_festival_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 5,
                        imageSymbol: "drum.fill",
                        location: NSLocalizedString("okinawa_zento_eisa_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("okinawa_zento_eisa_festival_feature1", comment: ""),
                            NSLocalizedString("okinawa_zento_eisa_festival_feature2", comment: ""),
                            NSLocalizedString("okinawa_zento_eisa_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 26.3344, longitude: 127.8056) // 沖縄市(コザ運動公園)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("naha_festival_name", comment: ""),
                        description: NSLocalizedString("naha_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("naha_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("naha_festival_feature1", comment: ""),
                            NSLocalizedString("naha_festival_feature2", comment: ""),
                            NSLocalizedString("naha_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 26.2124, longitude: 127.6792) // 那覇市(国際通り)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("ginowan_hagoromo_festival_name", comment: ""),
                        description: NSLocalizedString("ginowan_hagoromo_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("ginowan_hagoromo_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("ginowan_hagoromo_festival_feature1", comment: ""),
                            NSLocalizedString("ginowan_hagoromo_festival_feature2", comment: ""),
                            NSLocalizedString("ginowan_hagoromo_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 26.2816, longitude: 127.7785) // 宜野湾市
                    )
                ]
            case .hyogo:
                return [
                    FestivalItem(
                        name: NSLocalizedString("minato_kobe_fireworks_name", comment: ""),
                        description: NSLocalizedString("okayama_momotaro_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("okayama_momotaro_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("okayama_momotaro_festival_feature1", comment: ""),
                            NSLocalizedString("okayama_momotaro_festival_feature2", comment: ""),
                            NSLocalizedString("okayama_momotaro_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.6657, longitude: 133.9183) // 岡山市中心部(桃太郎大通り)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kurashiki_tenryo_festival_name", comment: ""),
                        description: NSLocalizedString("kurashiki_tenryo_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "drum.fill",
                        location: NSLocalizedString("kurashiki_tenryo_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kurashiki_tenryo_festival_feature1", comment: ""),
                            NSLocalizedString("kurashiki_tenryo_festival_feature2", comment: ""),
                            NSLocalizedString("kurashiki_tenryo_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.595, longitude: 133.7717) // 倉敷美観地区
                    )
                ]
            case .hiroshima:
                return [
                    FestivalItem(
                        name: NSLocalizedString("miyajima_suichu_fireworks_name", comment: ""),
                        description: NSLocalizedString("miyajima_suichu_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("miyajima_suichu_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("miyajima_suichu_fireworks_feature1", comment: ""),
                            NSLocalizedString("miyajima_suichu_fireworks_feature2", comment: ""),
                            NSLocalizedString("miyajima_suichu_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.296, longitude: 132.3197) // 廿日市市・宮島(厳島神社沖)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kure_kaijo_fireworks_name", comment: ""),
                        description: NSLocalizedString("kure_kaijo_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("kure_kaijo_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("kure_kaijo_fireworks_feature1", comment: ""),
                            NSLocalizedString("kure_kaijo_fireworks_feature2", comment: ""),
                            NSLocalizedString("kure_kaijo_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.2336, longitude: 132.5557) // 呉港
                    ),
                    FestivalItem(
                        name: NSLocalizedString("hiroshima_minato_fireworks_name", comment: ""),
                        description: NSLocalizedString("hiroshima_minato_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("hiroshima_minato_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("hiroshima_minato_fireworks_feature1", comment: ""),
                            NSLocalizedString("hiroshima_minato_fireworks_feature2", comment: ""),
                            NSLocalizedString("hiroshima_minato_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.3489, longitude: 132.4595) // 広島港(宇品)
                    )
                ]
            case .yamaguchi:
                return [
                    FestivalItem(
                        name: NSLocalizedString("kanmon_kaikyo_fireworks_name", comment: ""),
                        description: NSLocalizedString("kanmon_kaikyo_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("kanmon_kaikyo_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("kanmon_kaikyo_fireworks_feature1", comment: ""),
                            NSLocalizedString("kanmon_kaikyo_fireworks_feature2", comment: ""),
                            NSLocalizedString("kanmon_kaikyo_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.956, longitude: 130.9419) // 下関市・関門海峡
                    ),
                    FestivalItem(
                        name: NSLocalizedString("shimonoseki_kaikyo_kan_fireworks_name", comment: ""),
                        description: NSLocalizedString("shimonoseki_kaikyo_kan_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("shimonoseki_kaikyo_kan_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("shimonoseki_kaikyo_kan_fireworks_feature1", comment: ""),
                            NSLocalizedString("shimonoseki_kaikyo_kan_fireworks_feature2", comment: ""),
                            NSLocalizedString("shimonoseki_kaikyo_kan_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.956, longitude: 130.9419) // 下関市・海響館
                    ),
                    FestivalItem(
                        name: NSLocalizedString("yamaguchi_tanabata_chochin_festival_name", comment: ""),
                        description: NSLocalizedString("yamaguchi_tanabata_chochin_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "lightbulb.fill",
                        location: NSLocalizedString("yamaguchi_tanabata_chochin_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("yamaguchi_tanabata_chochin_festival_feature1", comment: ""),
                            NSLocalizedString("yamaguchi_tanabata_chochin_festival_feature2", comment: ""),
                            NSLocalizedString("yamaguchi_tanabata_chochin_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.1785, longitude: 131.4737) // 山口市中心部
                    )
                ]
            case .tokushima:
                return [
                    FestivalItem(
                        name: NSLocalizedString("awa_odori_name", comment: ""),
                        description: NSLocalizedString("awa_odori_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_4_days", comment: ""),
                        scale: 5,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("awa_odori_location", comment: ""),
                        features: [
                            NSLocalizedString("awa_odori_feature1", comment: ""),
                            NSLocalizedString("awa_odori_feature2", comment: ""),
                            NSLocalizedString("awa_odori_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.0703, longitude: 134.5549) // 徳島市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("tokushima_awa_odori_name", comment: ""),
                        description: NSLocalizedString("tokushima_awa_odori_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_4_days", comment: ""),
                        scale: 5,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("tokushima_awa_odori_location", comment: ""),
                        features: [
                            NSLocalizedString("tokushima_awa_odori_feature1", comment: ""),
                            NSLocalizedString("tokushima_awa_odori_feature2", comment: ""),
                            NSLocalizedString("tokushima_awa_odori_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.0703, longitude: 134.5549) // 徳島市
                    )
                ]
            case .kagawa:
                return [
                    FestivalItem(
                        name: NSLocalizedString("sanuki_takamatsu_festival_name", comment: ""),
                        description: NSLocalizedString("sanuki_takamatsu_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("sanuki_takamatsu_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("sanuki_takamatsu_festival_feature1", comment: ""),
                            NSLocalizedString("sanuki_takamatsu_festival_feature2", comment: ""),
                            NSLocalizedString("sanuki_takamatsu_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.3501, longitude: 134.0466) // 高松市中心部(中央通り)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("marugame_oshiro_festival_name", comment: ""),
                        description: NSLocalizedString("marugame_oshiro_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_may", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "castle.fill",
                        location: NSLocalizedString("marugame_oshiro_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("marugame_oshiro_festival_feature1", comment: ""),
                            NSLocalizedString("marugame_oshiro_festival_feature2", comment: ""),
                            NSLocalizedString("marugame_oshiro_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.2864, longitude: 133.8003) // 丸亀城
                    )
                ]
            case .ehime:
                return [
                    FestivalItem(
                        name: NSLocalizedString("matsuyama_festival_name", comment: ""),
                        description: NSLocalizedString("matsuyama_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("matsuyama_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("matsuyama_festival_feature1", comment: ""),
                            NSLocalizedString("matsuyama_festival_feature2", comment: ""),
                            NSLocalizedString("matsuyama_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.8392, longitude: 132.7657) // 松山市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("niihama_taiko_festival_name", comment: ""),
                        description: NSLocalizedString("niihama_taiko_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_4_days", comment: ""),
                        scale: 4,
                        imageSymbol: "drum.fill",
                        location: NSLocalizedString("niihama_taiko_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("niihama_taiko_festival_feature1", comment: ""),
                            NSLocalizedString("niihama_taiko_festival_feature2", comment: ""),
                            NSLocalizedString("niihama_taiko_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.9603, longitude: 133.2833) // 新居浜市
                    ),
                    FestivalItem(
                        name: NSLocalizedString("uwajima_ushioni_festival_name", comment: ""),
                        description: NSLocalizedString("uwajima_ushioni_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "figure.wave",
                        location: NSLocalizedString("uwajima_ushioni_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("uwajima_ushioni_festival_feature1", comment: ""),
                            NSLocalizedString("uwajima_ushioni_festival_feature2", comment: ""),
                            NSLocalizedString("uwajima_ushioni_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.2233, longitude: 132.5605) // 宇和島市
                    )
                ]
            case .kochi:
                return [
                    FestivalItem(
                        name: NSLocalizedString("yosakoi_festival_name", comment: ""),
                        description: NSLocalizedString("yosakoi_festival_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_4_days", comment: ""),
                        scale: 5,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("yosakoi_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("yosakoi_festival_feature1", comment: ""),
                            NSLocalizedString("yosakoi_festival_feature2", comment: ""),
                            NSLocalizedString("yosakoi_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.5597, longitude: 133.5311) // 高知市中心部(追手筋)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("tosa_festival_name", comment: ""),
                        description: NSLocalizedString("tosa_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("tosa_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("tosa_festival_feature1", comment: ""),
                            NSLocalizedString("tosa_festival_feature2", comment: ""),
                            NSLocalizedString("tosa_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.5587, longitude: 133.5311) // 高知市
                    )
                ]
            case .fukuoka:
                return [
                    FestivalItem(
                        name: NSLocalizedString("hakata_gion_yamakasa_name", comment: ""),
                        description: NSLocalizedString("hakata_gion_yamakasa_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_15_days", comment: ""),
                        scale: 5,
                        imageSymbol: "mountain.2.fill",
                        location: NSLocalizedString("hakata_gion_yamakasa_location", comment: ""),
                        features: [
                            NSLocalizedString("hakata_gion_yamakasa_feature1", comment: ""),
                            NSLocalizedString("hakata_gion_yamakasa_feature2", comment: ""),
                            NSLocalizedString("hakata_gion_yamakasa_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.5926, longitude: 130.4106) // 博多区(櫛田神社)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kokura_gion_taiko_name", comment: ""),
                        description: NSLocalizedString("kokura_gion_taiko_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "drum.fill",
                        location: NSLocalizedString("kokura_gion_taiko_location", comment: ""),
                        features: [
                            NSLocalizedString("kokura_gion_taiko_feature1", comment: ""),
                            NSLocalizedString("kokura_gion_taiko_feature2", comment: ""),
                            NSLocalizedString("kokura_gion_taiko_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.8853, longitude: 130.8752) // 北九州市小倉北区(小倉城)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("tobata_gion_oyamakasa_name", comment: ""),
                        description: NSLocalizedString("tobata_gion_oyamakasa_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "lightbulb.fill",
                        location: NSLocalizedString("tobata_gion_oyamakasa_location", comment: ""),
                        features: [
                            NSLocalizedString("tobata_gion_oyamakasa_feature1", comment: ""),
                            NSLocalizedString("tobata_gion_oyamakasa_feature2", comment: ""),
                            NSLocalizedString("tobata_gion_oyamakasa_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.8975, longitude: 130.8307) // 北九州市戸畑区
                    ),
                    FestivalItem(
                        name: NSLocalizedString("chikugogawa_fireworks_name", comment: ""),
                        description: NSLocalizedString("chikugogawa_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("chikugogawa_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("chikugogawa_fireworks_feature1", comment: ""),
                            NSLocalizedString("chikugogawa_fireworks_feature2", comment: ""),
                            NSLocalizedString("chikugogawa_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.3192, longitude: 130.5085) // 久留米市・筑後川
                    )
                ]
            case .saga:
                return [
                    FestivalItem(
                        name: NSLocalizedString("saga_balloon_festa_name", comment: ""),
                        description: NSLocalizedString("saga_balloon_festa_description", comment: ""),
                        category: .seasonal,
                        month: NSLocalizedString("month_november", comment: ""),
                        duration: NSLocalizedString("duration_5_days", comment: ""),
                        scale: 5,
                        imageSymbol: "balloon.2.fill",
                        location: NSLocalizedString("saga_balloon_festa_location", comment: ""),
                        features: [
                            NSLocalizedString("saga_balloon_festa_feature1", comment: ""),
                            NSLocalizedString("saga_balloon_festa_feature2", comment: ""),
                            NSLocalizedString("saga_balloon_festa_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.2456, longitude: 130.3055) // 佐賀市・嘉瀬川河川敷
                    ),
                    FestivalItem(
                        name: NSLocalizedString("karatsu_kunchi_name", comment: ""),
                        description: NSLocalizedString("karatsu_kunchi_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_november", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.wave",
                        location: NSLocalizedString("karatsu_kunchi_location", comment: ""),
                        features: [
                            NSLocalizedString("karatsu_kunchi_feature1", comment: ""),
                            NSLocalizedString("karatsu_kunchi_feature2", comment: ""),
                            NSLocalizedString("karatsu_kunchi_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.4502, longitude: 129.9686) // 唐津市(唐津神社)
                    )
                ]
            case .nagasaki:
                return [
                    FestivalItem(
                        name: NSLocalizedString("nagasaki_shoryonagashi_name", comment: ""),
                        description: NSLocalizedString("nagasaki_shoryonagashi_description", comment: ""),
                        category: .religious,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sailboat.fill",
                        location: NSLocalizedString("nagasaki_shoryonagashi_location", comment: ""),
                        features: [
                            NSLocalizedString("nagasaki_shoryonagashi_feature1", comment: ""),
                            NSLocalizedString("nagasaki_shoryonagashi_feature2", comment: ""),
                            NSLocalizedString("nagasaki_shoryonagashi_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 32.7448, longitude: 129.8737) // 長崎市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("nagasaki_kunchi_name", comment: ""),
                        description: NSLocalizedString("nagasaki_kunchi_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("nagasaki_kunchi_location", comment: ""),
                        features: [
                            NSLocalizedString("nagasaki_kunchi_feature1", comment: ""),
                            NSLocalizedString("nagasaki_kunchi_feature2", comment: ""),
                            NSLocalizedString("nagasaki_kunchi_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 32.7475, longitude: 129.8739) // 長崎市(諏訪神社)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("sasebo_seaside_festival_name", comment: ""),
                        description: NSLocalizedString("sasebo_seaside_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "sailboat.fill",
                        location: NSLocalizedString("sasebo_seaside_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("sasebo_seaside_festival_feature1", comment: ""),
                            NSLocalizedString("sasebo_seaside_festival_feature2", comment: ""),
                            NSLocalizedString("sasebo_seaside_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.1597, longitude: 129.715) // 佐世保港
                    )
                ]
            case .nara:
                return [
                    FestivalItem(
                        name: NSLocalizedString("nara_tokae_name", comment: ""),
                        description: NSLocalizedString("nara_tokae_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_10_days", comment: ""),
                        scale: 4,
                        imageSymbol: "candle.fill",
                        location: NSLocalizedString("nara_tokae_location", comment: ""),
                        features: [
                            NSLocalizedString("nara_tokae_feature1", comment: ""),
                            NSLocalizedString("nara_tokae_feature2", comment: ""),
                            NSLocalizedString("nara_tokae_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.6851, longitude: 135.843) // 奈良公園一帯
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kasuga_taisha_mantoro_name", comment: ""),
                        description: NSLocalizedString("kasuga_taisha_mantoro_description", comment: ""),
                        category: .religious,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "lightbulb.fill",
                        location: NSLocalizedString("kasuga_taisha_mantoro_location", comment: ""),
                        features: [
                            NSLocalizedString("kasuga_taisha_mantoro_feature1", comment: ""),
                            NSLocalizedString("kasuga_taisha_mantoro_feature2", comment: ""),
                            NSLocalizedString("kasuga_taisha_mantoro_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.6815, longitude: 135.8484) // 春日大社
                    ),
                    FestivalItem(
                        name: NSLocalizedString("heijokyo_tenpyo_festival_name", comment: ""),
                        description: NSLocalizedString("heijokyo_tenpyo_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_may", comment: ""),
                        duration: NSLocalizedString("duration_5_days", comment: ""),
                        scale: 3,
                        imageSymbol: "building.columns.fill",
                        location: NSLocalizedString("heijokyo_tenpyo_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("heijokyo_tenpyo_festival_feature1", comment: ""),
                            NSLocalizedString("heijokyo_tenpyo_festival_feature2", comment: ""),
                            NSLocalizedString("heijokyo_tenpyo_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.6911, longitude: 135.7949) // 平城宮跡
                    )
                ]
            case .wakayama:
                return [
                    FestivalItem(
                        name: NSLocalizedString("kinokawa_momoyama_festival_name", comment: ""),
                        description: NSLocalizedString("kinokawa_momoyama_festival_description", comment: ""),
                        category: .food,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "leaf.fill",
                        location: NSLocalizedString("kinokawa_momoyama_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kinokawa_momoyama_festival_feature1", comment: ""),
                            NSLocalizedString("kinokawa_momoyama_festival_feature2", comment: ""),
                            NSLocalizedString("kinokawa_momoyama_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.267, longitude: 135.3461) // 紀の川市
                    ),
                    FestivalItem(
                        name: NSLocalizedString("tanabe_benkei_festival_name", comment: ""),
                        description: NSLocalizedString("tanabe_benkei_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "figure.martial.arts",
                        location: NSLocalizedString("tanabe_benkei_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("tanabe_benkei_festival_feature1", comment: ""),
                            NSLocalizedString("tanabe_benkei_festival_feature2", comment: ""),
                            NSLocalizedString("tanabe_benkei_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.7269, longitude: 135.3779) // 田辺市
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kushimoto_festival_name", comment: ""),
                        description: NSLocalizedString("kushimoto_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "fish.fill",
                        location: NSLocalizedString("kushimoto_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kushimoto_festival_feature1", comment: ""),
                            NSLocalizedString("kushimoto_festival_feature2", comment: ""),
                            NSLocalizedString("kushimoto_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 33.472, longitude: 135.7838) // 串本町
                    )
                ]
            case .tottori:
                return [
                    FestivalItem(
                        name: NSLocalizedString("tottori_shanshan_festival_name", comment: ""),
                        description: NSLocalizedString("tottori_shanshan_festival_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "umbrella.fill",
                        location: NSLocalizedString("tottori_shanshan_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("tottori_shanshan_festival_feature1", comment: ""),
                            NSLocalizedString("tottori_shanshan_festival_feature2", comment: ""),
                            NSLocalizedString("tottori_shanshan_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.4938, longitude: 134.237) // 鳥取市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("yonago_gaina_festival_name", comment: ""),
                        description: NSLocalizedString("yonago_gaina_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_range_july_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "lightbulb.fill",
                        location: NSLocalizedString("yonago_gaina_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("yonago_gaina_festival_feature1", comment: ""),
                            NSLocalizedString("yonago_gaina_festival_feature2", comment: ""),
                            NSLocalizedString("yonago_gaina_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.4281, longitude: 133.3311) // 米子市
                    )
                ]
            case .shimane:
                return [
                    FestivalItem(
                        name: NSLocalizedString("matsue_suigo_festival_name", comment: ""),
                        description: NSLocalizedString("matsue_suigo_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "sailboat.fill",
                        location: NSLocalizedString("matsue_suigo_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("matsue_suigo_festival_feature1", comment: ""),
                            NSLocalizedString("matsue_suigo_festival_feature2", comment: ""),
                            NSLocalizedString("matsue_suigo_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.4533, longitude: 133.0606) // 松江市・宍道湖
                    ),
                    FestivalItem(
                        name: NSLocalizedString("izumo_shinwa_festival_name", comment: ""),
                        description: NSLocalizedString("izumo_shinwa_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "building.columns.fill",
                        location: NSLocalizedString("izumo_shinwa_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("izumo_shinwa_festival_feature1", comment: ""),
                            NSLocalizedString("izumo_shinwa_festival_feature2", comment: ""),
                            NSLocalizedString("izumo_shinwa_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.3669, longitude: 132.7544) // 出雲市
                    )
                ]
            case .fukui:
                return [
                    FestivalItem(
                        name: NSLocalizedString("mikuni_fireworks_name", comment: ""),
                        description: NSLocalizedString("mikuni_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_range_july_september", comment: ""),
                        duration: NSLocalizedString("duration_2_months", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("gujo_odori_location", comment: ""),
                        features: [
                            NSLocalizedString("gujo_odori_feature1", comment: ""),
                            NSLocalizedString("gujo_odori_feature2", comment: ""),
                            NSLocalizedString("gujo_odori_feature3", comment: "")
                        ]
                    ),
                    FestivalItem(
                        name: NSLocalizedString("gero_onsen_festival_name", comment: ""),
                        description: NSLocalizedString("gero_onsen_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_4_days", comment: ""),
                        scale: 3,
                        imageSymbol: "drop.fill",
                        location: NSLocalizedString("gero_onsen_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("gero_onsen_festival_feature1", comment: ""),
                            NSLocalizedString("gero_onsen_festival_feature2", comment: ""),
                            NSLocalizedString("gero_onsen_festival_feature3", comment: "")
                        ]
                    ),
                    FestivalItem(
                        name: NSLocalizedString("hida_takayama_summer_festival_name", comment: ""),
                        description: NSLocalizedString("hida_takayama_summer_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_range_july_august", comment: ""),
                        duration: NSLocalizedString("duration_1_month", comment: ""),
                        scale: 3,
                        imageSymbol: "building.columns.fill",
                        location: NSLocalizedString("hida_takayama_summer_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("hida_takayama_summer_festival_feature1", comment: ""),
                            NSLocalizedString("hida_takayama_summer_festival_feature2", comment: ""),
                            NSLocalizedString("hida_takayama_summer_festival_feature3", comment: "")
                        ]
                    )
                ]
            case .shizuoka:
                return [
                    FestivalItem(
                        name: NSLocalizedString("atami_kaijo_fireworks_name", comment: ""),
                        description: NSLocalizedString("atami_kaijo_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_range_july_august", comment: ""),
                        duration: NSLocalizedString("duration_multiple_times_year", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("atami_kaijo_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("atami_kaijo_fireworks_feature1", comment: ""),
                            NSLocalizedString("atami_kaijo_fireworks_feature2", comment: ""),
                            NSLocalizedString("atami_kaijo_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.096, longitude: 139.076) // 熱海湾
                    ),
                    FestivalItem(
                        name: NSLocalizedString("shimizu_port_festival_name", comment: ""),
                        description: NSLocalizedString("shimizu_port_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "sailboat.fill",
                        location: NSLocalizedString("shimizu_port_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("shimizu_port_festival_feature1", comment: ""),
                            NSLocalizedString("shimizu_port_festival_feature2", comment: ""),
                            NSLocalizedString("shimizu_port_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.0167, longitude: 138.51) // 静岡市清水区(清水港)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("hamamatsu_festival_name", comment: ""),
                        description: NSLocalizedString("hamamatsu_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_may", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "airplane",
                        location: NSLocalizedString("hamamatsu_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("hamamatsu_festival_feature1", comment: ""),
                            NSLocalizedString("hamamatsu_festival_feature2", comment: ""),
                            NSLocalizedString("hamamatsu_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.6792, longitude: 137.6035) // 浜松市
                    )
                ]
            case .aichi:
                return [
                    FestivalItem(
                        name: NSLocalizedString("anjo_tanabata_festival_name", comment: ""),
                        description: NSLocalizedString("anjo_tanabata_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "star.fill",
                        location: NSLocalizedString("anjo_tanabata_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("anjo_tanabata_festival_feature1", comment: ""),
                            NSLocalizedString("anjo_tanabata_festival_feature2", comment: ""),
                            NSLocalizedString("anjo_tanabata_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.9583, longitude: 137.0805) // 安城市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("toyohashi_gion_festival_name", comment: ""),
                        description: NSLocalizedString("toyohashi_gion_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("toyohashi_gion_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("toyohashi_gion_festival_feature1", comment: ""),
                            NSLocalizedString("toyohashi_gion_festival_feature2", comment: ""),
                            NSLocalizedString("toyohashi_gion_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.7639, longitude: 137.3914) // 豊橋市(吉田神社)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("nagoya_festival_name", comment: ""),
                        description: NSLocalizedString("nagoya_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "crown.fill",
                        location: NSLocalizedString("nagoya_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("nagoya_festival_feature1", comment: ""),
                            NSLocalizedString("nagoya_festival_feature2", comment: ""),
                            NSLocalizedString("nagoya_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.1709, longitude: 136.8815) // 名古屋市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("okazaki_ieyasu_summer_festival_name", comment: ""),
                        description: NSLocalizedString("okazaki_ieyasu_summer_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "castle.fill",
                        location: NSLocalizedString("okazaki_ieyasu_summer_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("okazaki_ieyasu_summer_festival_feature1", comment: ""),
                            NSLocalizedString("okazaki_ieyasu_summer_festival_feature2", comment: ""),
                            NSLocalizedString("okazaki_ieyasu_summer_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.9576, longitude: 137.1592) // 岡崎市(岡崎城)
                    )
                ]
            case .mie:
                return [
                    FestivalItem(
                        name: NSLocalizedString("tsu_festival_name", comment: ""),
                        description: NSLocalizedString("tsu_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("tsu_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("tsu_festival_feature1", comment: ""),
                            NSLocalizedString("tsu_festival_feature2", comment: ""),
                            NSLocalizedString("tsu_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.7186, longitude: 136.5056) // 津市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("suzuka_genki_fireworks_name", comment: ""),
                        description: NSLocalizedString("suzuka_genki_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("suzuka_genki_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("suzuka_genki_fireworks_feature1", comment: ""),
                            NSLocalizedString("suzuka_genki_fireworks_feature2", comment: ""),
                            NSLocalizedString("suzuka_genki_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.8823, longitude: 136.5844) // 鈴鹿市
                    ),
                    FestivalItem(
                        name: NSLocalizedString("ise_jingu_fireworks_name", comment: ""),
                        description: NSLocalizedString("ise_jingu_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("ise_jingu_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("ise_jingu_fireworks_feature1", comment: ""),
                            NSLocalizedString("ise_jingu_fireworks_feature2", comment: ""),
                            NSLocalizedString("ise_jingu_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.49, longitude: 136.709) // 伊勢市・宮川河畔
                    )
                ]
            case .shiga:
                return [
                    FestivalItem(
                        name: NSLocalizedString("biwako_dai_fireworks_name", comment: ""),
                        description: NSLocalizedString("biwako_dai_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("biwako_dai_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("biwako_dai_fireworks_feature1", comment: ""),
                            NSLocalizedString("biwako_dai_fireworks_feature2", comment: ""),
                            NSLocalizedString("biwako_dai_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.0036, longitude: 135.8767) // 大津市・琵琶湖(大津港)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("otsu_festival_name", comment: ""),
                        description: NSLocalizedString("otsu_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.wave",
                        location: NSLocalizedString("otsu_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("otsu_festival_feature1", comment: ""),
                            NSLocalizedString("otsu_festival_feature2", comment: ""),
                            NSLocalizedString("otsu_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.0036, longitude: 135.859) // 大津市(天孫神社)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("nagahama_hikiyama_festival_name", comment: ""),
                        description: NSLocalizedString("nagahama_hikiyama_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_april", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "theatermasks.fill",
                        location: NSLocalizedString("nagahama_hikiyama_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("nagahama_hikiyama_festival_feature1", comment: ""),
                            NSLocalizedString("nagahama_hikiyama_festival_feature2", comment: ""),
                            NSLocalizedString("nagahama_hikiyama_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.3826, longitude: 136.2719) // 長浜市(長浜八幡宮)
                    )
                ]
            case .kyoto:
                return [
                    FestivalItem(
                        name: NSLocalizedString("gion_festival_name", comment: ""),
                        description: NSLocalizedString("gion_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_1_month", comment: ""),
                        scale: 5,
                        imageSymbol: "building.columns.fill",
                        location: NSLocalizedString("gion_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("gion_festival_feature1", comment: ""),
                            NSLocalizedString("gion_festival_feature2", comment: ""),
                            NSLocalizedString("gion_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.0036, longitude: 135.7783) // 京都市中心部(八坂神社)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("gozan_okuribi_name", comment: ""),
                        description: NSLocalizedString("gozan_okuribi_description", comment: ""),
                        category: .religious,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "flame.fill",
                        location: NSLocalizedString("gozan_okuribi_location", comment: ""),
                        features: [
                            NSLocalizedString("gozan_okuribi_feature1", comment: ""),
                            NSLocalizedString("gozan_okuribi_feature2", comment: ""),
                            NSLocalizedString("gozan_okuribi_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.0264, longitude: 135.7826) // 京都市・東山(大文字山)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("jidai_festival_name", comment: ""),
                        description: NSLocalizedString("jidai_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "crown.fill",
                        location: NSLocalizedString("jidai_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("jidai_festival_feature1", comment: ""),
                            NSLocalizedString("jidai_festival_feature2", comment: ""),
                            NSLocalizedString("jidai_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.0167, longitude: 135.782) // 京都御所〜平安神宮
                    )
                ]
            case .osaka:
                return [
                    FestivalItem(
                        name: NSLocalizedString("tenjin_festival_name", comment: ""),
                        description: NSLocalizedString("tenjin_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 5,
                        imageSymbol: "sailboat.fill",
                        location: NSLocalizedString("tenjin_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("tenjin_festival_feature1", comment: ""),
                            NSLocalizedString("tenjin_festival_feature2", comment: ""),
                            NSLocalizedString("tenjin_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.696, longitude: 135.513) // 大阪天満宮・大川
                    ),
                    FestivalItem(
                        name: NSLocalizedString("yodogawa_fireworks_name", comment: ""),
                        description: NSLocalizedString("yodogawa_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("yodogawa_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("yodogawa_fireworks_feature1", comment: ""),
                            NSLocalizedString("yodogawa_fireworks_feature2", comment: ""),
                            NSLocalizedString("yodogawa_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.728, longitude: 135.479) // 大阪市・淀川河川敷
                    ),
                    FestivalItem(
                        name: NSLocalizedString("pl_fireworks_name", comment: ""),
                        description: NSLocalizedString("pl_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("pl_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("pl_fireworks_feature1", comment: ""),
                            NSLocalizedString("pl_fireworks_feature2", comment: ""),
                            NSLocalizedString("pl_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.5009, longitude: 135.6019) // 富田林市PL教団
                    ),
                    FestivalItem(
                        name: NSLocalizedString("naniwa_yodogawa_fireworks_name", comment: ""),
                        description: NSLocalizedString("naniwa_yodogawa_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("naniwa_yodogawa_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("naniwa_yodogawa_fireworks_feature1", comment: ""),
                            NSLocalizedString("naniwa_yodogawa_fireworks_feature2", comment: ""),
                            NSLocalizedString("naniwa_yodogawa_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 34.728, longitude: 135.479) // 大阪市・淀川
                    )
                ]
            case .yamanashi:
                return [
                    FestivalItem(
                        name: NSLocalizedString("fujigoko_fireworks_name", comment: ""),
                        description: NSLocalizedString("fujigoko_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("fujigoko_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("fujigoko_fireworks_feature1", comment: ""),
                            NSLocalizedString("fujigoko_fireworks_feature2", comment: ""),
                            NSLocalizedString("fujigoko_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.5043, longitude: 138.7689) // 富士五湖周辺(河口湖)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kofu_summer_festival_name", comment: ""),
                        description: NSLocalizedString("kofu_summer_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "person.fill",
                        location: NSLocalizedString("kofu_summer_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kofu_summer_festival_feature1", comment: ""),
                            NSLocalizedString("kofu_summer_festival_feature2", comment: ""),
                            NSLocalizedString("kofu_summer_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.6642, longitude: 138.5685) // 甲府市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("yoshida_himatsuri_name", comment: ""),
                        description: NSLocalizedString("yoshida_himatsuri_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "flame.fill",
                        location: NSLocalizedString("yoshida_himatsuri_location", comment: ""),
                        features: [
                            NSLocalizedString("yoshida_himatsuri_feature1", comment: ""),
                            NSLocalizedString("yoshida_himatsuri_feature2", comment: ""),
                            NSLocalizedString("yoshida_himatsuri_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.4796, longitude: 138.7942) // 富士吉田市(北口本宮冨士浅間神社)
                    )
                ]
            case .nagano:
                return [
                    FestivalItem(
                        name: NSLocalizedString("suwako_fireworks_name", comment: ""),
                        description: NSLocalizedString("suwako_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("suwako_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("suwako_fireworks_feature1", comment: ""),
                            NSLocalizedString("suwako_fireworks_feature2", comment: ""),
                            NSLocalizedString("suwako_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.0494, longitude: 138.1133) // 諏訪市・諏訪湖
                    ),
                    FestivalItem(
                        name: NSLocalizedString("matsumoto_bonbon_name", comment: ""),
                        description: NSLocalizedString("matsumoto_bonbon_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("matsumoto_bonbon_location", comment: ""),
                        features: [
                            NSLocalizedString("matsumoto_bonbon_feature1", comment: ""),
                            NSLocalizedString("matsumoto_bonbon_feature2", comment: ""),
                            NSLocalizedString("matsumoto_bonbon_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.2381, longitude: 137.972) // 松本市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("iida_ringon_name", comment: ""),
                        description: NSLocalizedString("iida_ringon_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "applelogo",
                        location: NSLocalizedString("iida_ringon_location", comment: ""),
                        features: [
                            NSLocalizedString("iida_ringon_feature1", comment: ""),
                            NSLocalizedString("iida_ringon_feature2", comment: ""),
                            NSLocalizedString("iida_ringon_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.5147, longitude: 137.8217) // 飯田市中心部
                    )
                ]
        case .hokkaido:
                return [
                    FestivalItem(
                        name: NSLocalizedString("sapporo_summer_festival_name", comment: ""),
                        description: NSLocalizedString("sapporo_summer_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_range_july_august", comment: ""),
                        duration: NSLocalizedString("duration_1_month", comment: ""),
                        scale: 4,
                        imageSymbol: "sun.max.fill",
                        location: NSLocalizedString("sapporo_summer_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("sapporo_summer_festival_feature1", comment: ""),
                            NSLocalizedString("sapporo_summer_festival_feature2", comment: ""),
                            NSLocalizedString("sapporo_summer_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 43.0608, longitude: 141.3469) // 札幌市・大通公園
                    ),
                    FestivalItem(
                        name: NSLocalizedString("noboribetsu_hell_festival_name", comment: ""),
                        description: NSLocalizedString("noboribetsu_hell_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "flame.fill",
                        location: NSLocalizedString("noboribetsu_hell_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("noboribetsu_hell_festival_feature1", comment: ""),
                            NSLocalizedString("noboribetsu_hell_festival_feature2", comment: ""),
                            NSLocalizedString("noboribetsu_hell_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 42.4922, longitude: 141.1469) // 登別温泉街
                    ),
                    FestivalItem(
                        name: NSLocalizedString("otaru_ushio_festival_name", comment: ""),
                        description: NSLocalizedString("otaru_ushio_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "water.waves",
                        location: NSLocalizedString("otaru_ushio_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("otaru_ushio_festival_feature1", comment: ""),
                            NSLocalizedString("otaru_ushio_festival_feature2", comment: ""),
                            NSLocalizedString("otaru_ushio_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 43.1979, longitude: 141.0086) // 小樽港周辺
                    ),
                    FestivalItem(
                        name: NSLocalizedString("hakodate_port_festival_name", comment: ""),
                        description: NSLocalizedString("hakodate_port_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_5_days", comment: ""),
                        scale: 4,
                        imageSymbol: "ferry.fill",
                        location: NSLocalizedString("hakodate_port_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("hakodate_port_festival_feature1", comment: ""),
                            NSLocalizedString("hakodate_port_festival_feature2", comment: ""),
                            NSLocalizedString("hakodate_port_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 41.7791, longitude: 140.7264) // 函館港周辺
                    ),
                    FestivalItem(
                        name: NSLocalizedString("doshin_uhb_fireworks_name", comment: ""),
                        description: NSLocalizedString("doshin_uhb_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("doshin_uhb_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("doshin_uhb_fireworks_feature1", comment: ""),
                            NSLocalizedString("doshin_uhb_fireworks_feature2", comment: ""),
                            NSLocalizedString("doshin_uhb_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 43.0405, longitude: 141.321) // 豊平川河川敷(札幌)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("toyako_longrun_fireworks_name", comment: ""),
                        description: NSLocalizedString("toyako_longrun_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_range_april_october", comment: ""),
                        duration: NSLocalizedString("duration_daily", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("toyako_longrun_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("toyako_longrun_fireworks_feature1", comment: ""),
                            NSLocalizedString("toyako_longrun_fireworks_feature2", comment: ""),
                            NSLocalizedString("toyako_longrun_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 42.5683, longitude: 140.7536) // 洞爺湖畔
                    )
                ]
            case .aomori:
                return [
                    FestivalItem(
                        name: NSLocalizedString("aomori_nebuta_festival_name", comment: ""),
                        description: NSLocalizedString("aomori_nebuta_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_7_days", comment: ""),
                        scale: 5,
                        imageSymbol: "lightbulb.fill",
                        location: NSLocalizedString("aomori_nebuta_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("aomori_nebuta_festival_feature1", comment: ""),
                            NSLocalizedString("aomori_nebuta_festival_feature2", comment: ""),
                            NSLocalizedString("aomori_nebuta_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 40.8278, longitude: 140.734) // 青森市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("hirosaki_neputa_festival_name", comment: ""),
                        description: NSLocalizedString("hirosaki_neputa_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_7_days", comment: ""),
                        scale: 4,
                        imageSymbol: "fan.fill",
                        location: NSLocalizedString("hirosaki_neputa_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("hirosaki_neputa_festival_feature1", comment: ""),
                            NSLocalizedString("hirosaki_neputa_festival_feature2", comment: ""),
                            NSLocalizedString("hirosaki_neputa_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 40.6031, longitude: 140.4639) // 弘前市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("goshogawara_tachineputa_name", comment: ""),
                        description: NSLocalizedString("goshogawara_tachineputa_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_5_days", comment: ""),
                        scale: 4,
                        imageSymbol: "triangle.fill",
                        location: NSLocalizedString("goshogawara_tachineputa_location", comment: ""),
                        features: [
                            NSLocalizedString("goshogawara_tachineputa_feature1", comment: ""),
                            NSLocalizedString("goshogawara_tachineputa_feature2", comment: ""),
                            NSLocalizedString("goshogawara_tachineputa_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 40.8082, longitude: 140.4406) // 五所川原市街地
                    ),
                    FestivalItem(
                        name: NSLocalizedString("hachinohe_sansha_festival_name", comment: ""),
                        description: NSLocalizedString("hachinohe_sansha_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_range_july_august", comment: ""),
                        duration: NSLocalizedString("duration_5_days", comment: ""),
                        scale: 4,
                        imageSymbol: "crown.fill",
                        location: NSLocalizedString("hachinohe_sansha_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("hachinohe_sansha_festival_feature1", comment: ""),
                            NSLocalizedString("hachinohe_sansha_festival_feature2", comment: ""),
                            NSLocalizedString("hachinohe_sansha_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 40.5123, longitude: 141.4883) // 八戸市中心部
                    )
                ]
            case .iwate:
                return [
                    FestivalItem(
                        name: NSLocalizedString("morioka_sansa_festival_name", comment: ""),
                        description: NSLocalizedString("morioka_sansa_festival_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_4_days", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("morioka_sansa_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("morioka_sansa_festival_feature1", comment: ""),
                            NSLocalizedString("morioka_sansa_festival_feature2", comment: ""),
                            NSLocalizedString("morioka_sansa_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 39.7036, longitude: 141.1525) // 盛岡市中心部(中央通り)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("hanamaki_festival_name", comment: ""),
                        description: NSLocalizedString("hanamaki_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_september", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "leaf.fill",
                        location: NSLocalizedString("hanamaki_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("hanamaki_festival_feature1", comment: ""),
                            NSLocalizedString("hanamaki_festival_feature2", comment: ""),
                            NSLocalizedString("hanamaki_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 39.3886, longitude: 141.1169) // 花巻市街地
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kitakami_michinoku_festival_name", comment: ""),
                        description: NSLocalizedString("kitakami_michinoku_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_4_days", comment: ""),
                        scale: 3,
                        imageSymbol: "theatermasks.fill",
                        location: NSLocalizedString("kitakami_michinoku_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kitakami_michinoku_festival_feature1", comment: ""),
                            NSLocalizedString("kitakami_michinoku_festival_feature2", comment: ""),
                            NSLocalizedString("kitakami_michinoku_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 39.2867, longitude: 141.113) // 北上市
                    )
                ]
            case .miyagi:
                return [
                    FestivalItem(
                        name: NSLocalizedString("sendai_tanabata_festival_name", comment: ""),
                        description: NSLocalizedString("sendai_tanabata_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 5,
                        imageSymbol: "star.fill",
                        location: NSLocalizedString("sendai_tanabata_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("sendai_tanabata_festival_feature1", comment: ""),
                            NSLocalizedString("sendai_tanabata_festival_feature2", comment: ""),
                            NSLocalizedString("sendai_tanabata_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 38.2602, longitude: 140.8821) // 仙台市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("sendai_aoba_festival_name", comment: ""),
                        description: NSLocalizedString("sendai_aoba_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_may", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "person.fill",
                        location: NSLocalizedString("sendai_aoba_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("sendai_aoba_festival_feature1", comment: ""),
                            NSLocalizedString("sendai_aoba_festival_feature2", comment: ""),
                            NSLocalizedString("sendai_aoba_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 38.2682, longitude: 140.8694) // 仙台市中心部(青葉城)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("ishinomaki_kawabiraki_festival_name", comment: ""),
                        description: NSLocalizedString("ishinomaki_kawabiraki_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_range_july_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "water.waves",
                        location: NSLocalizedString("ishinomaki_kawabiraki_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("ishinomaki_kawabiraki_festival_feature1", comment: ""),
                            NSLocalizedString("ishinomaki_kawabiraki_festival_feature2", comment: ""),
                            NSLocalizedString("ishinomaki_kawabiraki_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 38.4346, longitude: 141.3022) // 石巻市・北上川
                    )
                ]
            case .akita:
                return [
                    FestivalItem(
                        name: NSLocalizedString("akita_kanto_festival_name", comment: ""),
                        description: NSLocalizedString("akita_kanto_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_4_days", comment: ""),
                        scale: 5,
                        imageSymbol: "lightbulb.fill",
                        location: NSLocalizedString("akita_kanto_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("akita_kanto_festival_feature1", comment: ""),
                            NSLocalizedString("akita_kanto_festival_feature2", comment: ""),
                            NSLocalizedString("akita_kanto_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 39.7196, longitude: 140.1066) // 秋田市中心部(竿燈大通り)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("omagari_fireworks_name", comment: ""),
                        description: NSLocalizedString("omagari_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("omagari_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("omagari_fireworks_feature1", comment: ""),
                            NSLocalizedString("omagari_fireworks_feature2", comment: ""),
                            NSLocalizedString("omagari_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 39.4506, longitude: 140.4736) // 大仙市・雄物川河川敷
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kakunodate_festival_name", comment: ""),
                        description: NSLocalizedString("kakunodate_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_september", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "crown.fill",
                        location: NSLocalizedString("kakunodate_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kakunodate_festival_feature1", comment: ""),
                            NSLocalizedString("kakunodate_festival_feature2", comment: ""),
                            NSLocalizedString("kakunodate_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 39.5969, longitude: 140.5614) // 角館町
                    )
                ]
            case .yamagata:
                return [
                    FestivalItem(
                        name: NSLocalizedString("yamagata_hanagasa_festival_name", comment: ""),
                        description: NSLocalizedString("yamagata_hanagasa_festival_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("yamagata_hanagasa_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("yamagata_hanagasa_festival_feature1", comment: ""),
                            NSLocalizedString("yamagata_hanagasa_festival_feature2", comment: ""),
                            NSLocalizedString("yamagata_hanagasa_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 38.2554, longitude: 140.3396) // 山形市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("shinjo_festival_name", comment: ""),
                        description: NSLocalizedString("shinjo_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "theatermasks.fill",
                        location: NSLocalizedString("shinjo_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("shinjo_festival_feature1", comment: ""),
                            NSLocalizedString("shinjo_festival_feature2", comment: ""),
                            NSLocalizedString("shinjo_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 38.7656, longitude: 140.301) // 新庄市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("sakata_festival_name", comment: ""),
                        description: NSLocalizedString("sakata_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_may", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "sailboat.fill",
                        location: NSLocalizedString("sakata_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("sakata_festival_feature1", comment: ""),
                            NSLocalizedString("sakata_festival_feature2", comment: ""),
                            NSLocalizedString("sakata_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 38.9145, longitude: 139.8366) // 酒田市中心部
                    )
                ]
            case .fukushima:
                return [
                    FestivalItem(
                        name: NSLocalizedString("fukushima_waraji_festival_name", comment: ""),
                        description: NSLocalizedString("fukushima_waraji_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "shoe.fill",
                        location: NSLocalizedString("fukushima_waraji_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("fukushima_waraji_festival_feature1", comment: ""),
                            NSLocalizedString("fukushima_waraji_festival_feature2", comment: ""),
                            NSLocalizedString("fukushima_waraji_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 37.7503, longitude: 140.4676) // 福島市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("soma_nomaoi_name", comment: ""),
                        description: NSLocalizedString("soma_nomaoi_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 5,
                        imageSymbol: "figure.equestrian.sports",
                        location: NSLocalizedString("soma_nomaoi_location", comment: ""),
                        features: [
                            NSLocalizedString("soma_nomaoi_feature1", comment: ""),
                            NSLocalizedString("soma_nomaoi_feature2", comment: ""),
                            NSLocalizedString("soma_nomaoi_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 37.796, longitude: 140.919) // 相馬市・南相馬市(雲雀ヶ原)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("aizu_festival_name", comment: ""),
                        description: NSLocalizedString("aizu_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_september", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "castle.fill",
                        location: NSLocalizedString("aizu_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("aizu_festival_feature1", comment: ""),
                            NSLocalizedString("aizu_festival_feature2", comment: ""),
                            NSLocalizedString("aizu_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 37.4881, longitude: 139.9296) // 会津若松市(鶴ヶ城)
                    )
                ]
            case .ibaraki:
                return [
                    FestivalItem(
                        name: NSLocalizedString("mito_komon_festival_name", comment: ""),
                        description: NSLocalizedString("mito_komon_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "person.fill",
                        location: NSLocalizedString("mito_komon_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("mito_komon_festival_feature1", comment: ""),
                            NSLocalizedString("mito_komon_festival_feature2", comment: ""),
                            NSLocalizedString("mito_komon_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.3658, longitude: 140.471) // 水戸市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("tsuchiura_fireworks_name", comment: ""),
                        description: NSLocalizedString("tsuchiura_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("tsuchiura_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("tsuchiura_fireworks_feature1", comment: ""),
                            NSLocalizedString("tsuchiura_fireworks_feature2", comment: ""),
                            NSLocalizedString("tsuchiura_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.0712, longitude: 140.196) // 土浦市・桜川畔
                    ),
                    FestivalItem(
                        name: NSLocalizedString("koga_fireworks_name", comment: ""),
                        description: NSLocalizedString("koga_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("koga_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("koga_fireworks_feature1", comment: ""),
                            NSLocalizedString("koga_fireworks_feature2", comment: ""),
                            NSLocalizedString("koga_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.1783, longitude: 139.7556) // 古河市・渡良瀬川
                    )
                ]
            case .tochigi:
                return [
                    FestivalItem(
                        name: NSLocalizedString("utsunomiya_fireworks_name", comment: ""),
                        description: NSLocalizedString("utsunomiya_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("utsunomiya_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("utsunomiya_fireworks_feature1", comment: ""),
                            NSLocalizedString("utsunomiya_fireworks_feature2", comment: ""),
                            NSLocalizedString("utsunomiya_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.5293, longitude: 139.9333) // 宇都宮市・鬼怒川河川敷
                    ),
                    FestivalItem(
                        name: NSLocalizedString("ashikaga_fireworks_name", comment: ""),
                        description: NSLocalizedString("ashikaga_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("ashikaga_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("ashikaga_fireworks_feature1", comment: ""),
                            NSLocalizedString("ashikaga_fireworks_feature2", comment: ""),
                            NSLocalizedString("ashikaga_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.33, longitude: 139.4502) // 足利市・渡良瀬川
                    ),
                    FestivalItem(
                        name: NSLocalizedString("nasu_makigari_festival_name", comment: ""),
                        description: NSLocalizedString("nasu_makigari_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "figure.archery",
                        location: NSLocalizedString("nasu_makigari_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("nasu_makigari_festival_feature1", comment: ""),
                            NSLocalizedString("nasu_makigari_festival_feature2", comment: ""),
                            NSLocalizedString("nasu_makigari_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 37.0021, longitude: 140.0192) // 那須町
                    )
                ]
            case .gunma:
                return [
                    FestivalItem(
                        name: NSLocalizedString("maebashi_tanabata_festival_name", comment: ""),
                        description: NSLocalizedString("maebashi_tanabata_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "star.fill",
                        location: NSLocalizedString("maebashi_tanabata_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("maebashi_tanabata_festival_feature1", comment: ""),
                            NSLocalizedString("maebashi_tanabata_festival_feature2", comment: ""),
                            NSLocalizedString("maebashi_tanabata_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.3895, longitude: 139.0634) // 前橋市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kiryu_yagibushi_festival_name", comment: ""),
                        description: NSLocalizedString("kiryu_yagibushi_festival_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("kiryu_yagibushi_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kiryu_yagibushi_festival_feature1", comment: ""),
                            NSLocalizedString("kiryu_yagibushi_festival_feature2", comment: ""),
                            NSLocalizedString("kiryu_yagibushi_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.4106, longitude: 139.3308) // 桐生市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("isesaki_fireworks_name", comment: ""),
                        description: NSLocalizedString("isesaki_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("isesaki_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("isesaki_fireworks_feature1", comment: ""),
                            NSLocalizedString("isesaki_fireworks_feature2", comment: ""),
                            NSLocalizedString("isesaki_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.322, longitude: 139.209) // 伊勢崎市・利根川河川敷
                    )
                ]
            case .saitama:
                return [
                    FestivalItem(
                        name: NSLocalizedString("kumagaya_uchiwa_festival_name", comment: ""),
                        description: NSLocalizedString("kumagaya_uchiwa_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "fan.fill",
                        location: NSLocalizedString("kumagaya_uchiwa_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kumagaya_uchiwa_festival_feature1", comment: ""),
                            NSLocalizedString("kumagaya_uchiwa_festival_feature2", comment: ""),
                            NSLocalizedString("kumagaya_uchiwa_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.139, longitude: 139.3886) // 熊谷市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kawagoe_festival_name", comment: ""),
                        description: NSLocalizedString("kawagoe_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_october", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "building.columns.fill",
                        location: NSLocalizedString("kawagoe_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kawagoe_festival_feature1", comment: ""),
                            NSLocalizedString("kawagoe_festival_feature2", comment: ""),
                            NSLocalizedString("kawagoe_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.9251, longitude: 139.4858) // 川越市中心部(蔵造りの町並み)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("chichibu_yomatsuri_name", comment: ""),
                        description: NSLocalizedString("chichibu_yomatsuri_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_december", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 5,
                        imageSymbol: "snowflake",
                        location: NSLocalizedString("chichibu_yomatsuri_location", comment: ""),
                        features: [
                            NSLocalizedString("chichibu_yomatsuri_feature1", comment: ""),
                            NSLocalizedString("chichibu_yomatsuri_feature2", comment: ""),
                            NSLocalizedString("chichibu_yomatsuri_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.9925, longitude: 139.0856) // 秩父市(秩父神社)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("todabashi_fireworks_name", comment: ""),
                        description: NSLocalizedString("todabashi_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("todabashi_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("todabashi_fireworks_feature1", comment: ""),
                            NSLocalizedString("todabashi_fireworks_feature2", comment: ""),
                            NSLocalizedString("todabashi_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.7958, longitude: 139.684) // 戸田市・荒川河川敷
                    )
                ]
            case .chiba:
                return [
                    FestivalItem(
                        name: NSLocalizedString("sakura_fireworks_name", comment: ""),
                        description: NSLocalizedString("sakura_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("sakura_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("sakura_fireworks_feature1", comment: ""),
                            NSLocalizedString("sakura_fireworks_feature2", comment: ""),
                            NSLocalizedString("sakura_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.7239, longitude: 140.233) // 佐倉市・印旛沼
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kashiwa_festival_name", comment: ""),
                        description: NSLocalizedString("kashiwa_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "building.fill",
                        location: NSLocalizedString("kashiwa_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kashiwa_festival_feature1", comment: ""),
                            NSLocalizedString("kashiwa_festival_feature2", comment: ""),
                            NSLocalizedString("kashiwa_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.8623, longitude: 139.9709) // 柏駅周辺
                    ),
                    FestivalItem(
                        name: NSLocalizedString("narita_gion_festival_name", comment: ""),
                        description: NSLocalizedString("narita_gion_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "building.columns.fill",
                        location: NSLocalizedString("narita_gion_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("narita_gion_festival_feature1", comment: ""),
                            NSLocalizedString("narita_gion_festival_feature2", comment: ""),
                            NSLocalizedString("narita_gion_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.7864, longitude: 140.3187) // 成田市・成田山周辺
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kisarazu_port_festival_name", comment: ""),
                        description: NSLocalizedString("kisarazu_port_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "sailboat.fill",
                        location: NSLocalizedString("kisarazu_port_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kisarazu_port_festival_feature1", comment: ""),
                            NSLocalizedString("kisarazu_port_festival_feature2", comment: ""),
                            NSLocalizedString("kisarazu_port_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.3818, longitude: 139.9163) // 木更津港周辺
                    )
                ]
            case .tokyo:
                return [
                    FestivalItem(
                        name: NSLocalizedString("sumidagawa_fireworks_name", comment: ""),
                        description: NSLocalizedString("sumidagawa_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("sumidagawa_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("sumidagawa_fireworks_feature1", comment: ""),
                            NSLocalizedString("sumidagawa_fireworks_feature2", comment: ""),
                            NSLocalizedString("sumidagawa_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.7148, longitude: 139.803) // 隅田川河川敷
                    ),
                    FestivalItem(
                        name: NSLocalizedString("jingu_gaien_fireworks_name", comment: ""),
                        description: NSLocalizedString("jingu_gaien_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("jingu_gaien_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("jingu_gaien_fireworks_feature1", comment: ""),
                            NSLocalizedString("jingu_gaien_fireworks_feature2", comment: ""),
                            NSLocalizedString("jingu_gaien_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.6745, longitude: 139.717) // 明治神宮外苑
                    ),
                    FestivalItem(
                        name: NSLocalizedString("edogawaku_fireworks_name", comment: ""),
                        description: NSLocalizedString("edogawaku_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("edogawaku_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("edogawaku_fireworks_feature1", comment: ""),
                            NSLocalizedString("edogawaku_fireworks_feature2", comment: ""),
                            NSLocalizedString("edogawaku_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.705, longitude: 139.9) // 江戸川河川敷
                    ),
                    FestivalItem(
                        name: NSLocalizedString("adachi_fireworks_name", comment: ""),
                        description: NSLocalizedString("adachi_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("adachi_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("adachi_fireworks_feature1", comment: ""),
                            NSLocalizedString("adachi_fireworks_feature2", comment: ""),
                            NSLocalizedString("adachi_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.77, longitude: 139.799) // 荒川河川敷(足立)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("itabashi_fireworks_name", comment: ""),
                        description: NSLocalizedString("itabashi_fireworks_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 3,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("itabashi_fireworks_location", comment: ""),
                        features: [
                            NSLocalizedString("itabashi_fireworks_feature1", comment: ""),
                            NSLocalizedString("itabashi_fireworks_feature2", comment: ""),
                            NSLocalizedString("itabashi_fireworks_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.79, longitude: 139.665) // 荒川河川敷(板橋)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("fukagawa_hachiman_festival_name", comment: ""),
                        description: NSLocalizedString("fukagawa_hachiman_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "drop.fill",
                        location: NSLocalizedString("fukagawa_hachiman_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("fukagawa_hachiman_festival_feature1", comment: ""),
                            NSLocalizedString("fukagawa_hachiman_festival_feature2", comment: ""),
                            NSLocalizedString("fukagawa_hachiman_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.6722, longitude: 139.7977) // 富岡八幡宮周辺
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kanda_festival_name", comment: ""),
                        description: NSLocalizedString("kanda_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_may", comment: ""),
                        duration: NSLocalizedString("duration_1_week", comment: ""),
                        scale: 5,
                        imageSymbol: "building.columns.fill",
                        location: NSLocalizedString("kanda_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kanda_festival_feature1", comment: ""),
                            NSLocalizedString("kanda_festival_feature2", comment: ""),
                            NSLocalizedString("kanda_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.7019, longitude: 139.7679) // 神田明神周辺
                    )
                ]
            case .kanagawa:
                return [
                    FestivalItem(
                        name: NSLocalizedString("shonan_hiratsuka_tanabata_name", comment: ""),
                        description: NSLocalizedString("shonan_hiratsuka_tanabata_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "star.fill",
                        location: NSLocalizedString("shonan_hiratsuka_tanabata_location", comment: ""),
                        features: [
                            NSLocalizedString("shonan_hiratsuka_tanabata_feature1", comment: ""),
                            NSLocalizedString("shonan_hiratsuka_tanabata_feature2", comment: ""),
                            NSLocalizedString("shonan_hiratsuka_tanabata_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.3356, longitude: 139.349) // 平塚市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("yokohama_kaikosai_name", comment: ""),
                        description: NSLocalizedString("yokohama_kaikosai_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_june", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "sailboat.fill",
                        location: NSLocalizedString("yokohama_kaikosai_location", comment: ""),
                        features: [
                            NSLocalizedString("yokohama_kaikosai_feature1", comment: ""),
                            NSLocalizedString("yokohama_kaikosai_feature2", comment: ""),
                            NSLocalizedString("yokohama_kaikosai_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.4564, longitude: 139.6317) // みなとみらい21
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kamakura_festival_name", comment: ""),
                        description: NSLocalizedString("kamakura_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_april", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "building.columns.fill",
                        location: NSLocalizedString("kamakura_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kamakura_festival_feature1", comment: ""),
                            NSLocalizedString("kamakura_festival_feature2", comment: ""),
                            NSLocalizedString("kamakura_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.3263, longitude: 139.556) // 鶴岡八幡宮
                    ),
                    FestivalItem(
                        name: NSLocalizedString("atsugi_ayu_festival_name", comment: ""),
                        description: NSLocalizedString("atsugi_ayu_festival_description", comment: ""),
                        category: .food,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 3,
                        imageSymbol: "fish.fill",
                        location: NSLocalizedString("atsugi_ayu_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("atsugi_ayu_festival_feature1", comment: ""),
                            NSLocalizedString("atsugi_ayu_festival_feature2", comment: ""),
                            NSLocalizedString("atsugi_ayu_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 35.4333, longitude: 139.365) // 相模川河川敷(厚木)
                    )
                ]
            case .niigata:
                return [
                    FestivalItem(
                        name: NSLocalizedString("nagaoka_hanabi_name", comment: ""),
                        description: NSLocalizedString("nagaoka_hanabi_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("nagaoka_hanabi_location", comment: ""),
                        features: [
                            NSLocalizedString("nagaoka_hanabi_feature1", comment: ""),
                            NSLocalizedString("nagaoka_hanabi_feature2", comment: ""),
                            NSLocalizedString("nagaoka_hanabi_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 37.4413, longitude: 138.8517) // 長岡市・信濃川河川敷
                    ),
                    FestivalItem(
                        name: NSLocalizedString("katakai_festival_name", comment: ""),
                        description: NSLocalizedString("katakai_festival_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_september", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 5,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("katakai_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("katakai_festival_feature1", comment: ""),
                            NSLocalizedString("katakai_festival_feature2", comment: ""),
                            NSLocalizedString("katakai_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 37.3289, longitude: 138.805) // 小千谷市片貝町
                    ),
                    FestivalItem(
                        name: NSLocalizedString("kashiwazaki_umi_hanabi_name", comment: ""),
                        description: NSLocalizedString("kashiwazaki_umi_hanabi_description", comment: ""),
                        category: .fireworks,
                        month: NSLocalizedString("month_july", comment: ""),
                        duration: NSLocalizedString("duration_1_day", comment: ""),
                        scale: 4,
                        imageSymbol: "sparkles",
                        location: NSLocalizedString("kashiwazaki_umi_hanabi_location", comment: ""),
                        features: [
                            NSLocalizedString("kashiwazaki_umi_hanabi_feature1", comment: ""),
                            NSLocalizedString("kashiwazaki_umi_hanabi_feature2", comment: ""),
                            NSLocalizedString("kashiwazaki_umi_hanabi_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 37.358, longitude: 138.538) // 柏崎市・中央海岸
                    ),
                    FestivalItem(
                        name: NSLocalizedString("echigo_festival_name", comment: ""),
                        description: NSLocalizedString("echigo_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 4,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("echigo_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("echigo_festival_feature1", comment: ""),
                            NSLocalizedString("echigo_festival_feature2", comment: ""),
                            NSLocalizedString("echigo_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 37.9161, longitude: 139.0364) // 新潟市中心部
                    )
                ]
            case .toyama:
                return [
                    FestivalItem(
                        name: NSLocalizedString("takaoka_tanabata_name", comment: ""),
                        description: NSLocalizedString("takaoka_tanabata_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_7_days", comment: ""),
                        scale: 3,
                        imageSymbol: "star.fill",
                        location: NSLocalizedString("takaoka_tanabata_location", comment: ""),
                        features: [
                            NSLocalizedString("takaoka_tanabata_feature1", comment: ""),
                            NSLocalizedString("takaoka_tanabata_feature2", comment: ""),
                            NSLocalizedString("takaoka_tanabata_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.7541, longitude: 137.0256) // 高岡市中心部
                    ),
                    FestivalItem(
                        name: NSLocalizedString("owara_kazenobon_name", comment: ""),
                        description: NSLocalizedString("owara_kazenobon_description", comment: ""),
                        category: .dance,
                        month: NSLocalizedString("month_september", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 5,
                        imageSymbol: "figure.dance",
                        location: NSLocalizedString("owara_kazenobon_location", comment: ""),
                        features: [
                            NSLocalizedString("owara_kazenobon_feature1", comment: ""),
                            NSLocalizedString("owara_kazenobon_feature2", comment: ""),
                            NSLocalizedString("owara_kazenobon_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.5651, longitude: 137.1376) // 富山市八尾町
                    ),
                    FestivalItem(
                        name: NSLocalizedString("toyama_festival_name", comment: ""),
                        description: NSLocalizedString("toyama_festival_description", comment: ""),
                        category: .summer,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 3,
                        imageSymbol: "building.fill",
                        location: NSLocalizedString("toyama_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("toyama_festival_feature1", comment: ""),
                            NSLocalizedString("toyama_festival_feature2", comment: ""),
                            NSLocalizedString("toyama_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.6953, longitude: 137.2113) // 富山市中心部
                    )
                ]
            case .ishikawa:
                return [
                    FestivalItem(
                        name: NSLocalizedString("kanazawa_hyakumangoku_festival_name", comment: ""),
                        description: NSLocalizedString("kanazawa_hyakumangoku_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_june", comment: ""),
                        duration: NSLocalizedString("duration_3_days", comment: ""),
                        scale: 5,
                        imageSymbol: "crown.fill",
                        location: NSLocalizedString("kanazawa_hyakumangoku_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("kanazawa_hyakumangoku_festival_feature1", comment: ""),
                            NSLocalizedString("kanazawa_hyakumangoku_festival_feature2", comment: ""),
                            NSLocalizedString("kanazawa_hyakumangoku_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.5613, longitude: 136.6562) // 金沢市中心部(金沢城)
                    ),
                    FestivalItem(
                        name: NSLocalizedString("wajima_taisai_name", comment: ""),
                        description: NSLocalizedString("wajima_taisai_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_august", comment: ""),
                        duration: NSLocalizedString("duration_4_days", comment: ""),
                        scale: 3,
                        imageSymbol: "drum.fill",
                        location: NSLocalizedString("wajima_taisai_location", comment: ""),
                        features: [
                            NSLocalizedString("wajima_taisai_feature1", comment: ""),
                            NSLocalizedString("wajima_taisai_feature2", comment: ""),
                            NSLocalizedString("wajima_taisai_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 37.3906, longitude: 136.899) // 輪島市
                    ),
                    FestivalItem(
                        name: NSLocalizedString("komatsu_otabi_festival_name", comment: ""),
                        description: NSLocalizedString("komatsu_otabi_festival_description", comment: ""),
                        category: .traditional,
                        month: NSLocalizedString("month_may", comment: ""),
                        duration: NSLocalizedString("duration_2_days", comment: ""),
                        scale: 4,
                        imageSymbol: "theatermasks.fill",
                        location: NSLocalizedString("komatsu_otabi_festival_location", comment: ""),
                        features: [
                            NSLocalizedString("komatsu_otabi_festival_feature1", comment: ""),
                            NSLocalizedString("komatsu_otabi_festival_feature2", comment: ""),
                            NSLocalizedString("komatsu_otabi_festival_feature3", comment: "")
                        ],
                        coordinate: CLLocationCoordinate2D(latitude: 36.4023, longitude: 136.4453) // 小松市
                    )
                ]
        }
    }
}

// リッチなお祭りセクションのView
struct RichFestivalSection: View {
    let prefecture: Prefecture
    @State private var selectedCategory: FestivalCategory? = nil
    @State private var showAllItems = false
    @State private var selectedItem: FestivalItem? = nil
    
    var filteredItems: [FestivalItem] {
        let items = prefecture.festivalItems
        if let category = selectedCategory {
            return items.filter { $0.category == category }
        }
        return showAllItems ? items : Array(items.prefix(4))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ヘッダー
            HStack {
                Image(systemName: "party.popper.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .pink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("festival.summer_fireworks", comment: "夏祭り・花火大会")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(String(format: "festival.experience".localized, prefecture.prefectureName))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // カテゴリフィルターボタン
                Menu {
                    Button("food_category_all".localized) {
                        selectedCategory = nil
                    }
                    
                    ForEach(FestivalCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Label(category.localizedName, systemImage: category.icon)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.title3)
                        .foregroundColor(.purple)
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
            
            // お祭りアイテムのグリッド
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(filteredItems) { item in
                    FestivalItemCard(item: item) {
                        selectedItem = item
                    }
                }
            }

            // もっと見るボタン
            if !showAllItems && prefecture.festivalItems.count > 4 && selectedCategory == nil {
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
                    .foregroundColor(.purple)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            .background(Color.purple.opacity(0.05))
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .sheet(item: $selectedItem) { item in
            FestivalDetailView(item: item, prefecture: prefecture)
        }
    }
}

// 個別のお祭りアイテムカード
struct FestivalItemCard: View {
    let item: FestivalItem
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

// お祭り詳細画面
struct FestivalDetailView: View {
    let item: FestivalItem
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
                                FestivalInfoCard(icon: "calendar.circle.fill", title: NSLocalizedString("festival.period", comment: "開催時期"), value: item.month, color: .blue)
                                FestivalInfoCard(icon: "clock.circle.fill", title: NSLocalizedString("festival.duration", comment: "期間"), value: item.duration, color: .green)
                                FestivalInfoCard(icon: "location.circle.fill", title: NSLocalizedString("festival.location", comment: "開催地"), value: item.location, color: .red)
                                FestivalInfoCard(icon: "trophy.fill", title: NSLocalizedString("festival.scale", comment: "規模"), value: getScaleText(item.scale), color: .orange)
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
                                ForEach(getRecommendations(for: item), id: \.self) { recommendation in
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
    
    private func getRecommendations(for item: FestivalItem) -> [String] {
        switch item.category {
        case .summer:
            return [
                NSLocalizedString("tips.summer.1", comment: ""),
                NSLocalizedString("tips.summer.2", comment: ""),
                NSLocalizedString("tips.summer.3", comment: "")
            ]
        case .fireworks:
            return [
                NSLocalizedString("tips.fireworks.1", comment: ""),
                NSLocalizedString("tips.fireworks.2", comment: ""),
                NSLocalizedString("tips.fireworks.3", comment: "")
            ]
        case .traditional:
            return [
                NSLocalizedString("tips.traditional.1", comment: ""),
                NSLocalizedString("tips.traditional.2", comment: ""),
                NSLocalizedString("tips.traditional.3", comment: "")
            ]
        case .dance:
            return [
                NSLocalizedString("tips.dance.1", comment: ""),
                NSLocalizedString("tips.dance.2", comment: ""),
                NSLocalizedString("tips.dance.3", comment: "")
            ]
        case .food:
            return [
                NSLocalizedString("tips.food.1", comment: ""),
                NSLocalizedString("tips.food.2", comment: ""),
                NSLocalizedString("tips.food.3", comment: "")
            ]
        case .seasonal:
            return [
                NSLocalizedString("tips.seasonal.1", comment: ""),
                NSLocalizedString("tips.seasonal.2", comment: ""),
                NSLocalizedString("tips.seasonal.3", comment: "")
            ]
        case .religious:
            return [
                NSLocalizedString("tips.religious.1", comment: ""),
                NSLocalizedString("tips.religious.2", comment: ""),
                NSLocalizedString("tips.religious.3", comment: "")
            ]
        }
    }
}

// 祭り情報カードコンポーネント
struct FestivalInfoCard: View {
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
