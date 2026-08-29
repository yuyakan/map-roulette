//
//  NatureSpotMapView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/08/12.
//

import SwiftUI
import Combine
import MapKit

// MARK: - 自然観光名所タイプ
enum NatureSpotType: String, CaseIterable {
    case nightView = "night_view"
    case starry = "starry_sky"
    case sea = "sea"
    case camping = "camping"
    
    var localizedName: String {
        switch self {
        case .nightView: return "nature_type.night_view".localized
        case .starry: return "nature_type.starry_sky".localized
        case .sea: return "nature_type.sea".localized
        case .camping: return "nature_type.camping".localized
        }
    }
    
    var icon: String {
        switch self {
        case .nightView: return "sparkles"
        case .starry: return "moon.stars"
        case .sea: return "water.waves"
        case .camping: return "tent.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .nightView: return .yellow
        case .starry: return .indigo
        case .sea: return .sea
        case .camping: return .green
        }
    }
}

// MARK: - 自然観光名所アイテム
class FixedNatureSpotItem: Identifiable, ObservableObject {
    let id: String
    let nameKey: String  // ローカライズキーを保存
    let descriptionKey: String  // ローカライズキーを保存
    let imageSymbol: String
    let spotType: NatureSpotType
    let popularity: Int
    let coordinate: CLLocationCoordinate2D
    
    // 使用時にローカライズされる計算プロパティ
    var name: String {
        return nameKey.localized
    }
    
    var description: String {
        return descriptionKey.localized
    }

    /// このスポットが属する都道府県（nameKey から確定的に解決）。
    var prefecture: Prefecture? {
        NatureSpotPrefecture.byNameKey[nameKey]
    }

    init(nameKey: String, descriptionKey: String, imageSymbol: String, spotType: NatureSpotType, popularity: Int, coordinate: CLLocationCoordinate2D) {
        self.nameKey = nameKey
        self.descriptionKey = descriptionKey
        self.imageSymbol = imageSymbol
        self.spotType = spotType
        self.popularity = popularity
        self.coordinate = coordinate
        self.id = "\(nameKey)_\(spotType.rawValue)"
    }
}

// MARK: - FixedNatureSpotItem Hashable & Equatable
extension FixedNatureSpotItem: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FixedNatureSpotItem, rhs: FixedNatureSpotItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - 自然観光名所データリポジトリ
class NatureSpotDataRepository {
    static let shared = NatureSpotDataRepository()
    
    private var _cachedSpots: [FixedNatureSpotItem] = []
    private var _spotsByName: [String: FixedNatureSpotItem] = [:]
    
    private init() {
        loadFixedNatureSpotData()
    }
    
    private func loadFixedNatureSpotData() {
        // ローカライズキーのみを使用
        let natureSpotData: [(String, String, NatureSpotType, Int, CLLocationCoordinate2D)] = [
            // 夜景スポット
            ("nightview_hakodate_name", "nightview_hakodate_description", .nightView, 5, CLLocationCoordinate2D(latitude: 41.7637, longitude: 140.7108)),
            ("nightview_maya_name", "nightview_maya_description", .nightView, 5, CLLocationCoordinate2D(latitude: 34.7622, longitude: 135.2358)),
            ("nightview_inasa_name", "nightview_inasa_description", .nightView, 5, CLLocationCoordinate2D(latitude: 32.7645, longitude: 129.8608)),
            ("nightview_tokyo_towers_name", "nightview_tokyo_towers_description", .nightView, 5, CLLocationCoordinate2D(latitude: 35.7101, longitude: 139.8107)),
            ("nightview_shonan_name", "nightview_shonan_description", .nightView, 4, CLLocationCoordinate2D(latitude: 35.3139, longitude: 139.4819)),
            ("nightview_rokko_name", "nightview_rokko_description", .nightView, 5, CLLocationCoordinate2D(latitude: 34.7622, longitude: 135.2358)),
            ("nightview_sarakura_name", "nightview_sarakura_description", .nightView, 4, CLLocationCoordinate2D(latitude: 33.8183, longitude: 130.6883)),
            ("nightview_minatomirai_name", "nightview_minatomirai_description", .nightView, 4, CLLocationCoordinate2D(latitude: 35.4537, longitude: 139.6317)),
            ("nightview_tempozan_name", "nightview_tempozan_description", .nightView, 3, CLLocationCoordinate2D(latitude: 34.6539, longitude: 135.4339)),
            ("nightview_wakakusa_name", "nightview_wakakusa_description", .nightView, 4, CLLocationCoordinate2D(latitude: 34.6839, longitude: 135.8539)),
            ("nightview_shiroyama_name", "nightview_shiroyama_description", .nightView, 4, CLLocationCoordinate2D(latitude: 31.5839, longitude: 130.5539)),
            ("nightview_moiwa_name", "nightview_moiwa_description", .nightView, 4, CLLocationCoordinate2D(latitude: 43.0239, longitude: 141.3239)),
            
            // 星空スポット
            ("starry_achi_name", "starry_achi_description", .starry, 5, CLLocationCoordinate2D(latitude: 35.4539, longitude: 137.6539)),
            ("starry_ishigaki_name", "starry_ishigaki_description", .starry, 5, CLLocationCoordinate2D(latitude: 24.3439, longitude: 124.1569)),
            ("starry_nobeyama_name", "starry_nobeyama_description", .starry, 4, CLLocationCoordinate2D(latitude: 35.9239, longitude: 138.4739)),
            ("starry_utsukushigahara_name", "starry_utsukushigahara_description", .starry, 5, CLLocationCoordinate2D(latitude: 36.2019, longitude: 138.1819)),
            ("starry_odaigahara_name", "starry_odaigahara_description", .starry, 4, CLLocationCoordinate2D(latitude: 34.1739, longitude: 136.1039)),
            ("starry_yatsugatake_name", "starry_yatsugatake_description", .starry, 5, CLLocationCoordinate2D(latitude: 35.9139, longitude: 138.3439)),
            ("starry_iriomote_name", "starry_iriomote_description", .starry, 5, CLLocationCoordinate2D(latitude: 24.3239, longitude: 123.7969)),
            ("starry_kuju_name", "starry_kuju_description", .starry, 4, CLLocationCoordinate2D(latitude: 33.0839, longitude: 131.2539)),
            ("starry_kirigamine_name", "starry_kirigamine_description", .starry, 4, CLLocationCoordinate2D(latitude: 36.1039, longitude: 138.1639)),
            ("starry_akagi_name", "starry_akagi_description", .starry, 4, CLLocationCoordinate2D(latitude: 36.5439, longitude: 139.1939)),
            ("starry_zao_name", "starry_zao_description", .starry, 4, CLLocationCoordinate2D(latitude: 38.1439, longitude: 140.4439)),
            ("starry_daisetsu_name", "starry_daisetsu_description", .starry, 5, CLLocationCoordinate2D(latitude: 43.6639, longitude: 142.8539)),
            ("starry_tsubetsu_name", "starry_tsubetsu_description", .starry, 4, CLLocationCoordinate2D(latitude: 43.6139, longitude: 144.1339)),
            ("starry_erimo_name", "starry_erimo_description", .starry, 4, CLLocationCoordinate2D(latitude: 41.9239, longitude: 143.2539)),
            
            // キャンプ地
            // 北海道
            ("camping_toya_name", "camping_toya_description", .camping, 5, CLLocationCoordinate2D(latitude: 42.5968, longitude: 140.7524)),
            ("camping_shikotsu_name", "camping_shikotsu_description", .camping, 4, CLLocationCoordinate2D(latitude: 42.7439, longitude: 141.3739)),
            ("camping_mashu_name", "camping_mashu_description", .camping, 5, CLLocationCoordinate2D(latitude: 43.5739, longitude: 144.5639)),
            ("camping_furano_biei_name", "camping_furano_biei_description", .camping, 5, CLLocationCoordinate2D(latitude: 43.3542, longitude: 142.3834)),
            ("camping_niseko_name", "camping_niseko_description", .camping, 4, CLLocationCoordinate2D(latitude: 42.8048, longitude: 140.6874)),
            
            // 東北
            ("camping_towada_name", "camping_towada_description", .camping, 5, CLLocationCoordinate2D(latitude: 40.4439, longitude: 140.9239)),
            ("camping_bandai_name", "camping_bandai_description", .camping, 4, CLLocationCoordinate2D(latitude: 37.6639, longitude: 140.0839)),
            ("camping_goshikinuma_name", "camping_goshikinuma_description", .camping, 4, CLLocationCoordinate2D(latitude: 37.6500, longitude: 140.0667)),
            ("camping_zao_name", "camping_zao_description", .camping, 4, CLLocationCoordinate2D(latitude: 38.1439, longitude: 140.4439)),
            
            // 関東
            ("camping_okutama_name", "camping_okutama_description", .camping, 4, CLLocationCoordinate2D(latitude: 35.8039, longitude: 139.0539)),
            ("camping_tanzawa_name", "camping_tanzawa_description", .camping, 4, CLLocationCoordinate2D(latitude: 35.4639, longitude: 139.1639)),
            ("camping_nasu_name", "camping_nasu_description", .camping, 4, CLLocationCoordinate2D(latitude: 37.1439, longitude: 140.0239)),
            ("camping_okunikko_name", "camping_okunikko_description", .camping, 4, CLLocationCoordinate2D(latitude: 36.7239, longitude: 139.4939)),
            ("camping_hakone_name", "camping_hakone_description", .camping, 4, CLLocationCoordinate2D(latitude: 35.2043, longitude: 139.0235)),
            
            // 中部
            ("camping_fujigoko_name", "camping_fujigoko_description", .camping, 5, CLLocationCoordinate2D(latitude: 35.4739, longitude: 138.7339)),
            ("camping_kamikochi_name", "camping_kamikochi_description", .camping, 5, CLLocationCoordinate2D(latitude: 36.2539, longitude: 137.6339)),
            ("camping_hakuba_name", "camping_hakuba_description", .camping, 4, CLLocationCoordinate2D(latitude: 36.7039, longitude: 137.8639)),
            ("camping_karuizawa_name", "camping_karuizawa_description", .camping, 4, CLLocationCoordinate2D(latitude: 36.3439, longitude: 138.6239)),
            ("camping_kiyosato_name", "camping_kiyosato_description", .camping, 4, CLLocationCoordinate2D(latitude: 35.9239, longitude: 138.4439)),
            ("camping_shiga_name", "camping_shiga_description", .camping, 4, CLLocationCoordinate2D(latitude: 36.7439, longitude: 138.5139)),
            
            // 関西・中国・四国
            ("camping_biwa_name", "camping_biwa_description", .camping, 4, CLLocationCoordinate2D(latitude: 35.3717, longitude: 136.1069)),
            ("camping_hiruzen_name", "camping_hiruzen_description", .camping, 4, CLLocationCoordinate2D(latitude: 35.3139, longitude: 133.6639)),
            ("camping_odaigahara_name", "camping_odaigahara_description", .camping, 4, CLLocationCoordinate2D(latitude: 34.1739, longitude: 136.1039)),
            ("camping_tsurugi_name", "camping_tsurugi_description", .camping, 4, CLLocationCoordinate2D(latitude: 33.8739, longitude: 134.1139)),
            ("camping_shimanto_name", "camping_shimanto_description", .camping, 4, CLLocationCoordinate2D(latitude: 33.2339, longitude: 133.2139)),
            
            // 九州・沖縄
            ("camping_aso_name", "camping_aso_description", .camping, 5, CLLocationCoordinate2D(latitude: 32.8847, longitude: 131.1040)),
            ("camping_kuju_name", "camping_kuju_description", .camping, 4, CLLocationCoordinate2D(latitude: 33.0839, longitude: 131.2539)),
            ("camping_kirishima_name", "camping_kirishima_description", .camping, 4, CLLocationCoordinate2D(latitude: 31.9300, longitude: 130.8642)),
            ("camping_yakushima_name", "camping_yakushima_description", .camping, 5, CLLocationCoordinate2D(latitude: 30.3000, longitude: 130.5000)),
            ("camping_yanbaru_name", "camping_yanbaru_description", .camping, 4, CLLocationCoordinate2D(latitude: 26.7439, longitude: 128.2439)),
                        
            
            // 海スポット
            ("sea_miyako_irabu_name", "sea_miyako_irabu_description", .sea, 5, CLLocationCoordinate2D(latitude: 24.8059, longitude: 125.2819)),
            ("sea_ishigaki_kabira_name", "sea_ishigaki_kabira_description", .sea, 5, CLLocationCoordinate2D(latitude: 24.4239, longitude: 124.1569)),
            ("sea_shirahama_name", "sea_shirahama_description", .sea, 4, CLLocationCoordinate2D(latitude: 33.6859, longitude: 135.3439)),
            ("sea_tsunoshima_name", "sea_tsunoshima_description", .sea, 5, CLLocationCoordinate2D(latitude: 34.4139, longitude: 130.8739)),
            ("sea_takeno_name", "sea_takeno_description", .sea, 4, CLLocationCoordinate2D(latitude: 35.6339, longitude: 134.7239)),
            ("sea_kujukurihama_name", "sea_kujukurihama_description", .sea, 3, CLLocationCoordinate2D(latitude: 35.5539, longitude: 140.4239)),
            ("sea_shonan_name", "sea_shonan_description", .sea, 4, CLLocationCoordinate2D(latitude: 35.3139, longitude: 139.4819)),
            ("sea_izu_shirahama_name", "sea_izu_shirahama_description", .sea, 4, CLLocationCoordinate2D(latitude: 34.6639, longitude: 138.9439)),
            ("sea_chirihama_name", "sea_chirihama_description", .sea, 4, CLLocationCoordinate2D(latitude: 36.8839, longitude: 136.6439)),
            ("sea_tottori_name", "sea_tottori_description", .sea, 4, CLLocationCoordinate2D(latitude: 35.5439, longitude: 134.2339)),
            ("sea_katsurahama_name", "sea_katsurahama_description", .sea, 4, CLLocationCoordinate2D(latitude: 33.4939, longitude: 133.5739)),
            ("sea_blue_cave_name", "sea_blue_cave_description", .sea, 4, CLLocationCoordinate2D(latitude: 26.3939, longitude: 127.8169)),
            ("sea_zanpa_name", "sea_zanpa_description", .sea, 4, CLLocationCoordinate2D(latitude: 26.4339, longitude: 127.7439)),
            ("sea_manzamo_name", "sea_manzamo_description", .sea, 4, CLLocationCoordinate2D(latitude: 26.4939, longitude: 127.8539)),
            ("sea_hedo_name", "sea_hedo_description", .sea, 4, CLLocationCoordinate2D(latitude: 26.8639, longitude: 128.2539)),
            ("sea_erimo_cape_name", "sea_erimo_cape_description", .sea, 4, CLLocationCoordinate2D(latitude: 41.9239, longitude: 143.2539)),
            ("sea_shakotan_name", "sea_shakotan_description", .sea, 5, CLLocationCoordinate2D(latitude: 43.3339, longitude: 140.6139)),
            ("sea_shiretoko_name", "sea_shiretoko_description", .sea, 5, CLLocationCoordinate2D(latitude: 44.0739, longitude: 145.1139)),
            ("sea_sanriku_name", "sea_sanriku_description", .sea, 4, CLLocationCoordinate2D(latitude: 39.6439, longitude: 141.9439)),
            ("sea_matsushima_name", "sea_matsushima_description", .sea, 5, CLLocationCoordinate2D(latitude: 38.3739, longitude: 141.0639)),
            ("sea_tanesashi_name", "sea_tanesashi_description", .sea, 4, CLLocationCoordinate2D(latitude: 40.5039, longitude: 141.5639)),
            ("sea_jogashima_name", "sea_jogashima_description", .sea, 3, CLLocationCoordinate2D(latitude: 35.1339, longitude: 139.6139)),
            ("sea_enoshima_name", "sea_enoshima_description", .sea, 4, CLLocationCoordinate2D(latitude: 35.2989, longitude: 139.4819)),
            ("sea_atami_name", "sea_atami_description", .sea, 3, CLLocationCoordinate2D(latitude: 35.0939, longitude: 139.0639)),
            ("sea_iseshima_name", "sea_iseshima_description", .sea, 4, CLLocationCoordinate2D(latitude: 34.3239, longitude: 136.8239)),
            ("sea_amanohashidate_name", "sea_amanohashidate_description", .sea, 5, CLLocationCoordinate2D(latitude: 35.5739, longitude: 135.1939)),
            ("sea_naruto_name", "sea_naruto_description", .sea, 4, CLLocationCoordinate2D(latitude: 34.2339, longitude: 134.6139)),
            ("sea_muroto_name", "sea_muroto_description", .sea, 4, CLLocationCoordinate2D(latitude: 33.2439, longitude: 134.1639)),
            ("sea_ashizuri_name", "sea_ashizuri_description", .sea, 4, CLLocationCoordinate2D(latitude: 32.7239, longitude: 133.0139)),
            ("sea_munakata_name", "sea_munakata_description", .sea, 4, CLLocationCoordinate2D(latitude: 34.2439, longitude: 130.1039)),
            ("sea_iki_tsushima_name", "sea_iki_tsushima_description", .sea, 4, CLLocationCoordinate2D(latitude: 34.1439, longitude: 129.2839)),
            ("sea_amakusa_name", "sea_amakusa_description", .sea, 4, CLLocationCoordinate2D(latitude: 32.4539, longitude: 130.1939)),
            ("sea_nichinan_name", "sea_nichinan_description", .sea, 4, CLLocationCoordinate2D(latitude: 31.5739, longitude: 131.4239))
        ]
        
        for (nameKey, descriptionKey, spotType, popularity, coordinate) in natureSpotData {
            let fixedSpot = FixedNatureSpotItem(
                nameKey: nameKey,
                descriptionKey: descriptionKey,
                imageSymbol: spotType.icon,
                spotType: spotType,
                popularity: popularity,
                coordinate: coordinate
            )
            _cachedSpots.append(fixedSpot)
            _spotsByName[fixedSpot.id] = fixedSpot
        }
    }
    
    // 固定された自然観光名所データを取得
    var allFixedSpots: [FixedNatureSpotItem] {
        return _cachedSpots
    }
    
    // タイプで絞り込み
    func getSpots(byType type: NatureSpotType) -> [FixedNatureSpotItem] {
        return _cachedSpots.filter { $0.spotType == type }
    }
}

// MARK: - 自然観光名所重み管理
class NatureSpotWeightManager: ObservableObject {
    @Published var weights: [String: Double] = [:]
    
    func selectRandomSpot(from spots: Set<FixedNatureSpotItem>) -> FixedNatureSpotItem? {
        let spotArray = Array(spots)
        guard !spotArray.isEmpty else { return nil }
        
        let totalWeight = spotArray.reduce(0.0) { result, spot in
            result + weights[spot.id, default: 1.0]
        }
        
        let randomValue = Double.random(in: 0...totalWeight)
        var currentWeight = 0.0
        
        for spot in spotArray {
            currentWeight += weights[spot.id, default: 1.0]
            if randomValue <= currentWeight {
                return spot
            }
        }
        
        return spotArray.last
    }
}

struct NatureSpotMapView: View {
    /// 統合タブ内で表示されているか。true のとき、上部に重なる切替帯のぶんだけ
    /// コンテンツを下げる余白を確保する（帯自体は IntegratedMapView が描画する）。
    /// false（単独利用時）は余白ゼロで既存挙動を一切変えない。
    var isIntegrated: Bool = false

    @State private var selectedSpot: FixedNatureSpotItem? = nil
    @State private var isSpinning = false
    @State private var spinTimer: Timer?
    @State private var currentSpinInterval: TimeInterval = 0.1
    @State private var spinCount = 0
    @State private var isStopping = false
    @State private var showResultModal = false
    @State private var showSettings = false
    @State private var enabledSpots: Set<FixedNatureSpotItem> = Set(NatureSpotDataRepository.shared.allFixedSpots)
    @StateObject private var spotWeightManager = NatureSpotWeightManager()
    @State private var showSpotInfo = false
    @State private var tappedSpot: FixedNatureSpotItem? = nil
    @State private var isListView = false
    
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width

    @State private var selectedDisplayTypes: Set<NatureSpotType> = [.nightView, .camping, .sea, .starry]


    class OrientationObserver: ObservableObject {
        @Published var orientation = UIDevice.current.orientation
        
        init() {
            NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                self.orientation = UIDevice.current.orientation
            }
        }
    }
    
    @StateObject private var orientationObserver = OrientationObserver()

    private var columnCount: Int {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return screenWidth > 1200 ? 8 : (screenWidth > 1000 ? 7 : 5)
        } else {
            return 3
        }
    }

    let interstitial = InterstitialViewModel()
    
    // 有効な自然観光名所の取得
    private var availableSpots: [FixedNatureSpotItem] {
        return Array(enabledSpots)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 設定ボタンなどのヘッダー要素（最上位zIndex）
                if !isSpinning {
                    VStack {
                        // 統合タブ表示中は、最前面に重なる切替帯のぶんだけ設定ボタン行を下げる
                        if isIntegrated {
                            Spacer().frame(height: mapModeBandHeight)
                        }
                        HStack {
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                            }
                            .disabled(isSpinning)
                            
                            Spacer()
                            
                            // 地図・リスト切り替えボタン
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isListView.toggle()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isListView ? "map.fill" : "list.bullet")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.white)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                            }
                            .disabled(isSpinning)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 4) {
                                    ForEach(Array(selectedDisplayTypes).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { type in
                                        HStack(spacing: 2) {
                                            Image(systemName: type.icon)
                                                .font(.caption2)
                                                .foregroundColor(type.color)
                                            Text(type.localizedName)
                                                .font(.caption2)
                                                .foregroundColor(type.color)
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(type.color.opacity(0.1))
                                        .cornerRadius(4)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 4)
                    
                        Spacer()
                    }
                    .zIndex(99)
                }
                
                VStack {
                    if isListView {
                        // リスト表示
                        spotListView
                    } else {
                        // 地図表示
                        mapView
                        if !isListView && isStopping {
                            if let selected = selectedSpot, isSpinning {
                                    HStack(spacing: 0) {
                                        Text(selected.name)
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [selected.spotType.color, selected.spotType.color.opacity(0.7)]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .multilineTextAlignment(.center)
                                            .shadow(color: selected.spotType.color.opacity(0.3), radius: 2, x: 0, y: 1)
                                    }
                                    .frame(height: 55)
                            } else {
                                Text(" ")
                                    .frame(height: 55)
                            }
                        } else {
                            Text(" ")
                                .frame(height: 55)
                        }
                    }
                }
                
                if isListView {
                    if isStopping {
                        if let selected = selectedSpot, isSpinning {
                            VStack() {
                                Spacer()
                                HStack(spacing: 0) {
                                    Text(selected.name)
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [selected.spotType.color, selected.spotType.color.opacity(0.7)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .multilineTextAlignment(.center)
                                        .shadow(color: selected.spotType.color.opacity(0.3), radius: 2, x: 0, y: 1)
                                }
                                .frame(height: 55)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Spacer()
                            }
                        }
                    } else if !showResultModal {
                        VStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Spacer()
                                Button(action: {
                                    if isSpinning {
                                        stopSpin()
                                    } else {
                                        if availableSpots.count < 2 {
                                            return
                                        }
                                        startSpin()
                                    }
                                }, label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: getButtonIcon())
                                            .font(.title3)
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 55, height: 55)
                                    .background(getButtonGradient())
                                    .cornerRadius(27.5)
                                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                                    .opacity(availableSpots.count < 2 ? 0.5 : 1.0)
                                })
                                .disabled(availableSpots.count < 2)
                                .padding(.trailing, 30)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                } else {
                    if !isStopping && !showResultModal {
                        VStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Spacer()
                                Button(action: {
                                    if isSpinning {
                                        stopSpin()
                                    } else {
                                        if availableSpots.count < 2 {
                                            return
                                        }
                                        startSpin()
                                    }
                                }, label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: getButtonIcon())
                                            .font(.title3)
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 55, height: 55)
                                    .background(getButtonGradient())
                                    .cornerRadius(27.5)
                                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                                    .opacity(availableSpots.count < 2 ? 0.5 : 1.0)
                                })
                                .disabled(availableSpots.count < 2)
                                .padding(.trailing, 30)
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
    
                // 結果モーダル
                if showResultModal {
                    VStack(spacing: 30) {
                        Spacer()
                        if let selected = selectedSpot {
                            VStack(spacing: 20) {
                                // 観光名所名
                                Text(selected.name)
                                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [selected.spotType.color, selected.spotType.color.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                    .shadow(color: selected.spotType.color.opacity(0.3), radius: 4, x: 0, y: 0)
                                    .padding(.top, 40)
                                
                                // 観光名所の詳細情報
                                VStack(spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: selected.spotType.icon)
                                            .foregroundColor(selected.spotType.color)
                                        Text(selected.spotType.localizedName)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(selected.spotType.color)
                                    }
                                    
                                    Text(selected.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    // 人気度表示
                                    HStack(spacing: 2) {
                                        ForEach(0..<5) { index in
                                            Image(systemName: index < selected.popularity ? "star.fill" : "star")
                                                .foregroundColor(.orange)
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                                
                                // 詳細情報ボタン
                                Button(action: {
                                    tappedSpot = selected
                                    showSpotInfo = true
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: selected.spotType.icon)
                                            .font(.system(size: 17))
                                        Text("detail_info".localized)
                                            .font(.system(size: 17))
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 154, height: 44)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [selected.spotType.color.opacity(0.8), selected.spotType.color.opacity(0.6)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(25)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                }
                                .padding(.top, 10)
                            }
                        }
                        Spacer()
                        resetButton
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 140)
                    .background(Color.white.opacity(0.7))
                    .zIndex(100)
                }
            }
            .sheet(isPresented: $showSettings) {
                NatureSpotSettingsView(
                    enabledSpots: $enabledSpots,
                    spotWeightManager: spotWeightManager,
                    selectedDisplayTypes: $selectedDisplayTypes
                )
                .largeSheet()
            }
            // 詳細はウインドウ全体を覆う fullScreenCover で表示（下タブ・帯の上に出るので真の全画面）
            .fullScreenCover(isPresented: $showSpotInfo) {
                if let spot = tappedSpot {
                    NatureSpotDetailView(spot: spot)
                }
            }
            .onChange(of: showSpotInfo) { isShowing in
                if !isShowing {
                    tappedSpot = nil
                }
            }
            .onAppear {
                interstitial.handleMapAppear()
            }
        }
    }
    
    // 地図表示
    private var mapView: some View {
        GeometryReader { geometry in
            ZStack {
                // 都道府県の背景を薄く表示
                ForEach(Prefecture.allCases, id: \.self) { prefecture in
                    PrefectureShape(points: normalizePoints(prefecture.points, to: geometry.size))
                        .fill(getBackgroundColor(for: prefecture))
                        .stroke(.white.opacity(0.3), lineWidth: 0.5)
                        .zIndex(0)
                    
                    // 沖縄の線
                    if prefecture == .okinawa {
                        Path { path in
                            let linePoints = normalizePoints(prefecture.okinawaLinePoints, to: geometry.size)
                            if linePoints.count >= 2 {
                                path.move(to: linePoints[0])
                                for point in linePoints.dropFirst() {
                                    path.addLine(to: point)
                                }
                            }
                        }
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.blue.opacity(0.3)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 1.0, dash: [4, 3])
                        )
                        .opacity(0.4)
                    }
                }
                
                // 自然観光名所のアイコンを表示
                ForEach(availableSpots, id: \.id) { spot in
                    let position = getSpotPosition(for: spot, in: geometry.size)
                    
                    Button(action: {
                        if !isSpinning && !isStopping {
                            tappedSpot = spot
                            showSpotInfo = true
                        }
                    }) {
                        ZStack {
                            // 選択された観光名所の背景効果
                            if selectedSpot?.id == spot.id {
                                Circle()
                                    .fill(spot.spotType.color.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .blur(radius: 8)
                                    .animation(.easeInOut(duration: 0.3), value: selectedSpot?.id)
                            }
                            
                            // アイコンの背景円
                            Circle()
                                .fill(
                                    selectedSpot?.id == spot.id
                                    ? LinearGradient(
                                        gradient: Gradient(colors: [spot.spotType.color, spot.spotType.color.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        gradient: Gradient(colors: [spot.spotType.color.opacity(0.8), spot.spotType.color]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: selectedSpot?.id == spot.id ? 32 : 20, height: selectedSpot?.id == spot.id ? 32 : 20)
                                .shadow(
                                    color: selectedSpot?.id == spot.id ? spot.spotType.color.opacity(0.5) : .black.opacity(0.2),
                                    radius: selectedSpot?.id == spot.id ? 4 : 2,
                                    x: 0,
                                    y: selectedSpot?.id == spot.id ? 2 : 1
                                )
                                .opacity(selectedSpot?.id == spot.id ? 1 : 0.8)

                            
                            // 自然観光名所アイコン
                            Image(systemName: spot.spotType.icon)
                                .font(.system(size: selectedSpot?.id == spot.id ? 16 : 10, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .position(position)
                    .zIndex(selectedSpot?.id == spot.id ? 10 : 5)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.top, 100)
        .zIndex(1)
    }
    
    // リスト表示
    private var spotListView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(NatureSpotType.allCases, id: \.self) { spotType in
                    let typeSpots = getSpotsForType(spotType)
                    
                    if !typeSpots.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            // タイプ名ヘッダー
                            HStack {
                                Text(spotType.localizedName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(spotType.color)
                                
                                Text("spot_count_format".localized(typeSpots.count))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            // 先頭のタイプ見出しは、設定/切替ボタン行を避けるため上に余白を空ける。
                            // 統合タブ表示中は最前面の切替帯のぶんもさらに下げる。
                            .padding(.top, spotType == NatureSpotType.allCases.first ? (80 + (isIntegrated ? mapModeBandHeight : 0)) : 0)
                            
                            // タイプの観光名所をグリッド表示
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount), spacing: 10) {
                                ForEach(typeSpots, id: \.id) { spot in
                                    Button(action: {
                                        if !isSpinning && !isStopping {
                                            tappedSpot = spot
                                            showSpotInfo = true
                                        }
                                    }) {
                                        NatureSpotCardView(spot: spot, selectedSpot: selectedSpot)
                                    }
                                    .disabled(isSpinning)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .onChange(of: orientationObserver.orientation) {
            screenWidth = UIScreen.main.bounds.width
        }
        .zIndex(1)
    }
        
    // タイプごとの観光名所を取得
    private func getSpotsForType(_ spotType: NatureSpotType) -> [FixedNatureSpotItem] {
        return availableSpots.filter { spot in
            spot.spotType == spotType
        }.sorted(by: { $0.name < $1.name })
    }
    
    private var resetButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    resetGame()
                    interstitial.registerRouletteSpin()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .padding(.bottom, 2)
                    }
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(27.5)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.trailing, 30)
        }
    }
    
    // 観光名所の位置を取得
    // 観光名所の位置を取得
    // 観光名所の位置を取得（修正版）
    private func getSpotPosition(for spot: FixedNatureSpotItem, in size: CGSize) -> CGPoint {
        let mapWidth: CGFloat = 500
        let mapHeight: CGFloat = 500
        
        var position = CGPoint(x: 250, y: 250) // デフォルト位置
        
        // ローカライズキーで比較
        switch spot.nameKey {
            // 夜景スポット
            case "nightview_hakodate_name":
                position = CGPoint(x: 350, y: 130) // 函館 - 北海道南部
            case "nightview_maya_name":
                position = CGPoint(x: 200, y: 350) // 摩耶山 - 兵庫県
            case "nightview_inasa_name":
                position = CGPoint(x: 80, y: 415) // 稲佐山 - 長崎県
            case "nightview_tokyo_towers_name":
                position = CGPoint(x: 315, y: 330) // 東京タワー - 東京都
            case "nightview_shonan_name":
                position = CGPoint(x: 315, y: 340) // 湘南 - 神奈川県
            case "nightview_rokko_name":
                position = CGPoint(x: 200, y: 350) // 六甲山 - 兵庫県
            case "nightview_sarakura_name":
                position = CGPoint(x: 105, y: 400) // 皿倉山 - 福岡県
            case "nightview_minatomirai_name":
                position = CGPoint(x: 315, y: 340) // みなとみらい - 神奈川県
            case "nightview_tempozan_name":
                position = CGPoint(x: 220, y: 365) // 天保山 - 大阪府
            case "nightview_wakakusa_name":
                position = CGPoint(x: 225, y: 375) // 若草山 - 奈良県
            case "nightview_shiroyama_name":
                position = CGPoint(x: 95, y: 450) // 城山 - 鹿児島県
            case "nightview_moiwa_name":
                position = CGPoint(x: 360, y: 90) // 藻岩山 - 北海道札幌
                
            // 星空スポット
            case "starry_achi_name":
                position = CGPoint(x: 275, y: 330) // 阿智村 - 長野県
            case "starry_ishigaki_name":
                position = CGPoint(x: 40, y: 485) // 石垣島 - 沖縄県
            case "starry_nobeyama_name":
                position = CGPoint(x: 280, y: 335) // 野辺山 - 長野県
            case "starry_utsukushigahara_name":
                position = CGPoint(x: 275, y: 330) // 美ヶ原 - 長野県
            case "starry_odaigahara_name":
                position = CGPoint(x: 225, y: 380) // 大台ヶ原 - 奈良県
            case "starry_yatsugatake_name":
                position = CGPoint(x: 285, y: 335) // 八ヶ岳 - 長野県・山梨県境
            case "starry_iriomote_name":
                position = CGPoint(x: 35, y: 485) // 西表島 - 沖縄県
            case "starry_kuju_name":
                position = CGPoint(x: 125, y: 410) // 九重 - 大分県
            case "starry_kirigamine_name":
                position = CGPoint(x: 280, y: 330) // 霧ヶ峰 - 長野県
            case "starry_akagi_name":
                position = CGPoint(x: 305, y: 310) // 赤城山 - 群馬県
            case "starry_zao_name":
                position = CGPoint(x: 330, y: 250) // 蔵王 - 山形県・宮城県境
            case "starry_daisetsu_name":
                position = CGPoint(x: 400, y: 73) // 大雪山 - 北海道
            case "starry_tsubetsu_name":
                position = CGPoint(x: 425, y: 65) // 津別峠 - 北海道
            case "starry_erimo_name":
                position = CGPoint(x: 420, y: 120) // 襟裳岬 - 北海道
                
            // キャンプ地
            // 北海道
            case "camping_toya_name":
                position = CGPoint(x: 355, y: 105) // 洞爺湖 - 北海道
            case "camping_shikotsu_name":
                position = CGPoint(x: 360, y: 100) // 支笏湖 - 北海道
            case "camping_mashu_name":
                position = CGPoint(x: 430, y: 70) // 摩周湖 - 北海道
            case "camping_furano_biei_name":
                position = CGPoint(x: 395, y: 85) // 富良野・美瑛 - 北海道
            case "camping_niseko_name":
                position = CGPoint(x: 350, y: 95) // ニセコ - 北海道
                
            // 東北
            case "camping_towada_name":
                position = CGPoint(x: 345, y: 190) // 十和田湖 - 青森県
            case "camping_bandai_name":
                position = CGPoint(x: 335, y: 285) // 磐梯 - 福島県
            case "camping_goshikinuma_name":
                position = CGPoint(x: 335, y: 285) // 五色沼 - 福島県
            case "camping_zao_name":
                position = CGPoint(x: 330, y: 250) // 蔵王 - 山形県・宮城県境
                
            // 関東
            case "camping_okutama_name":
                position = CGPoint(x: 310, y: 330) // 奥多摩 - 東京都
            case "camping_tanzawa_name":
                position = CGPoint(x: 315, y: 340) // 丹沢 - 神奈川県
            case "camping_nasu_name":
                position = CGPoint(x: 320, y: 300) // 那須 - 栃木県
            case "camping_okunikko_name":
                position = CGPoint(x: 320, y: 305) // 奥日光 - 栃木県
            case "camping_hakone_name":
                position = CGPoint(x: 310, y: 345) // 箱根 - 神奈川県
                
            // 中部
            case "camping_fujigoko_name":
                position = CGPoint(x: 290, y: 340) // 富士五湖 - 山梨県
            case "camping_kamikochi_name":
                position = CGPoint(x: 270, y: 330) // 上高地 - 長野県
            case "camping_hakuba_name":
                position = CGPoint(x: 270, y: 325) // 白馬 - 長野県
            case "camping_karuizawa_name":
                position = CGPoint(x: 285, y: 325) // 軽井沢 - 長野県
            case "camping_kiyosato_name":
                position = CGPoint(x: 285, y: 335) // 清里 - 山梨県
            case "camping_shiga_name":
                position = CGPoint(x: 230, y: 350) // 志賀高原 - 長野県
                
            // 関西・中国・四国
            case "camping_biwa_name":
                position = CGPoint(x: 230, y: 350) // 琵琶湖 - 滋賀県
            case "camping_hiruzen_name":
                position = CGPoint(x: 165, y: 345) // 蒜山 - 岡山県
            case "camping_odaigahara_name":
                position = CGPoint(x: 225, y: 380) // 大台ヶ原 - 奈良県
            case "camping_tsurugi_name":
                position = CGPoint(x: 185, y: 385) // 剣山 - 徳島県
            case "camping_shimanto_name":
                position = CGPoint(x: 165, y: 405) // 四万十川 - 高知県
                
            // 九州・沖縄
            case "camping_aso_name":
                position = CGPoint(x: 105, y: 420) // 阿蘇 - 熊本県
            case "camping_kuju_name":
                position = CGPoint(x: 125, y: 410) // 九重 - 大分県
            case "camping_kirishima_name":
                position = CGPoint(x: 105, y: 440) // 霧島 - 鹿児島県
            case "camping_yakushima_name":
                position = CGPoint(x: 95, y: 465) // 屋久島 - 鹿児島県
            case "camping_yanbaru_name":
                position = CGPoint(x: 45, y: 475) // やんばる - 沖縄県
                
            // 海スポット
            case "sea_miyako_irabu_name":
                position = CGPoint(x: 50, y: 480) // 宮古島・伊良部島 - 沖縄県
            case "sea_ishigaki_kabira_name":
                position = CGPoint(x: 40, y: 485) // 石垣島川平湾 - 沖縄県
            case "sea_shirahama_name":
                position = CGPoint(x: 215, y: 390) // 白浜 - 和歌山県
            case "sea_tsunoshima_name":
                position = CGPoint(x: 125, y: 370) // 角島 - 山口県
            case "sea_takeno_name":
                position = CGPoint(x: 190, y: 340) // 竹野 - 兵庫県
            case "sea_kujukurihama_name":
                position = CGPoint(x: 340, y: 340) // 九十九里浜 - 千葉県
            case "sea_shonan_name":
                position = CGPoint(x: 315, y: 340) // 湘南 - 神奈川県
            case "sea_izu_shirahama_name":
                position = CGPoint(x: 295, y: 355) // 伊豆白浜 - 静岡県
            case "sea_chirihama_name":
                position = CGPoint(x: 250, y: 285) // 千里浜 - 石川県
            case "sea_tottori_name":
                position = CGPoint(x: 170, y: 340) // 鳥取砂丘 - 鳥取県
            case "sea_katsurahama_name":
                position = CGPoint(x: 165, y: 405) // 桂浜 - 高知県
            case "sea_blue_cave_name":
                position = CGPoint(x: 45, y: 480) // 青の洞窟 - 沖縄県
            case "sea_zanpa_name":
                position = CGPoint(x: 43, y: 478) // 残波岬 - 沖縄県
            case "sea_manzamo_name":
                position = CGPoint(x: 44, y: 477) // 万座毛 - 沖縄県
            case "sea_hedo_name":
                position = CGPoint(x: 47, y: 473) // 辺戸岬 - 沖縄県
            case "sea_erimo_cape_name":
                position = CGPoint(x: 420, y: 120) // 襟裳岬 - 北海道
            case "sea_shakotan_name":
                position = CGPoint(x: 345, y: 85) // 積丹半島 - 北海道
            case "sea_shiretoko_name":
                position = CGPoint(x: 460, y: 62) // 知床 - 北海道
            case "sea_sanriku_name":
                position = CGPoint(x: 380, y: 210) // 三陸海岸 - 岩手県
            case "sea_matsushima_name":
                position = CGPoint(x: 360, y: 245) // 松島 - 宮城県
            case "sea_tanesashi_name":
                position = CGPoint(x: 365, y: 175) // 種差海岸 - 青森県
            case "sea_jogashima_name":
                position = CGPoint(x: 315, y: 350) // 城ヶ島 - 神奈川県
            case "sea_enoshima_name":
                position = CGPoint(x: 315, y: 342) // 江の島 - 神奈川県
            case "sea_atami_name":
                position = CGPoint(x: 305, y: 350) // 熱海 - 静岡県
            case "sea_iseshima_name":
                position = CGPoint(x: 240, y: 370) // 伊勢志摩 - 三重県
            case "sea_amanohashidate_name":
                position = CGPoint(x: 210, y: 340) // 天橋立 - 京都府
            case "sea_naruto_name":
                position = CGPoint(x: 190, y: 385) // 鳴門 - 徳島県
            case "sea_muroto_name":
                position = CGPoint(x: 185, y: 410) // 室戸岬 - 高知県
            case "sea_ashizuri_name":
                position = CGPoint(x: 155, y: 415) // 足摺岬 - 高知県
            case "sea_munakata_name":
                position = CGPoint(x: 105, y: 395) // 宗像 - 福岡県
            case "sea_iki_tsushima_name":
                position = CGPoint(x: 85, y: 380) // 壱岐・対馬 - 長崎県
            case "sea_amakusa_name":
                position = CGPoint(x: 95, y: 425) // 天草 - 熊本県
            case "sea_nichinan_name":
                position = CGPoint(x: 110, y: 440) // 日南海岸 - 宮崎県
                
        default:
            position = CGPoint(x: 250, y: 250)
        }
        
        return CGPoint(
            x: (position.x / mapWidth) * size.width,
            y: (position.y / mapHeight) * size.height
        )
    }
    
    // 都道府県の背景色を取得
    private func getBackgroundColor(for prefecture: Prefecture) -> LinearGradient {
        // 自然観光名所があるかチェック
        let hasNatureSpot = availableSpots.contains { spot in
            let spotPosition = getSpotPosition(for: spot, in: CGSize(width: 500, height: 500))
            let prefectureCenter = getPrefectureCenter(prefecture)
            let distance = sqrt(pow(spotPosition.x - prefectureCenter.x, 2) + pow(spotPosition.y - prefectureCenter.y, 2))
            return distance < 100 // 100ピクセル以内なら同じ都道府県とみなす
        }
        
        if hasNatureSpot {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.2),
                    Color.green.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // 都道府県の中心座標を取得
    private func getPrefectureCenter(_ prefecture: Prefecture) -> CGPoint {
        let points = prefecture.points
        guard !points.isEmpty else { return CGPoint(x: 250, y: 250) }
        
        let sumX = points.reduce(0) { $0 + $1.x }
        let sumY = points.reduce(0) { $0 + $1.y }
        
        return CGPoint(
            x: sumX / CGFloat(points.count),
            y: sumY / CGFloat(points.count)
        )
    }
    
    // ゲームをリセット
    private func resetGame() {
        showResultModal = false
        selectedSpot = nil
        isStopping = false
    }
    
    // ボタンのアイコンを取得
    private func getButtonIcon() -> String {
        if isStopping {
            return "stop.circle"
        } else if isSpinning {
            return "stop.fill"
        } else {
            return "play.fill"
        }
    }
    
    // ボタンのグラデーションを取得
    private func getButtonGradient() -> LinearGradient {
        if isStopping {
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [.white]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // スピン開始
    private func startSpin() {
        guard !isSpinning && !availableSpots.isEmpty else { return }
        
        isSpinning = true
        isStopping = false
        currentSpinInterval = 0.05
        spinCount = 0
        
        startSpinTimer()
    }
    
    // スピン停止
    private func stopSpin() {
        guard isSpinning && !isStopping else { return }
        
        isStopping = true
        startStoppingSequence()
    }
    
    // スピンタイマーを開始
    private func startSpinTimer() {
        spinTimer?.invalidate()
        
        spinTimer = Timer.scheduledTimer(withTimeInterval: currentSpinInterval, repeats: false) { _ in
            selectedSpot = selectRandomSpot()
            spinCount += 1
            
            if !isStopping {
                startSpinTimer()
            }
        }
    }
    
    // ランダムな観光名所を選択
    private func selectRandomSpot() -> FixedNatureSpotItem {
        guard !enabledSpots.isEmpty else {
            return FixedNatureSpotItem(nameKey: "観光名所なし", descriptionKey: "", imageSymbol: "questionmark", spotType: .nightView, popularity: 1, coordinate: CLLocationCoordinate2D())
        }
        
        return spotWeightManager.selectRandomSpot(from: enabledSpots) ?? enabledSpots.first!
    }
    
    // 停止シーケンスを開始
    private func startStoppingSequence() {
        spinTimer?.invalidate()
        
        var stopSpinCount = 0
        var stopInterval: TimeInterval = currentSpinInterval
        
        func stopSpinTimer() {
            Timer.scheduledTimer(withTimeInterval: stopInterval, repeats: false) { _ in
                selectedSpot = selectRandomSpot()
                
                stopSpinCount += 1
                
                // だんだんゆっくりにする（22回転で停止）
                if stopSpinCount < 22 {
                    // スピンの間隔を徐々に長くする
                    if stopSpinCount > 20 {
                        stopInterval += 0.5
                    } else if stopSpinCount > 17 {
                        stopInterval += 0.2
                    } else if stopSpinCount > 15 {
                        stopInterval += 0.1
                    } else if stopSpinCount > 12 {
                        stopInterval += 0.075
                    } else if stopSpinCount > 8 {
                        stopInterval += 0.05
                    } else if stopSpinCount > 5 {
                        stopInterval += 0.02
                    }
                    stopSpinTimer()
                } else {
                    // 最終的に停止
                    isSpinning = false
                    
                    // 最終選択をアニメーション付きで実行
                    selectedSpot = selectRandomSpot()
                    
                    // 0.5秒後にモーダル表示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showResultModal = true
                        }
                    }
                }
            }
        }
        
        stopSpinTimer()
    }
    
    // 座標を画面サイズに正規化
    private func normalizePoints(_ points: [CGPoint], to size: CGSize) -> [CGPoint] {
        let mapWidth: CGFloat = 500
        let mapHeight: CGFloat = 500
        
        return points.map { point in
            CGPoint(
                x: (point.x / mapWidth) * size.width,
                y: (point.y / mapHeight) * size.height
            )
        }
    }
}

// MARK: - NatureSpotDetailView
struct NatureSpotDetailView: View {
    let spot: FixedNatureSpotItem
    @State private var region: MKCoordinateRegion
    @Environment(\.dismiss) private var dismiss
    
    init(spot: FixedNatureSpotItem) {
        self.spot = spot
        self._region = State(initialValue: MKCoordinateRegion(
            center: spot.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        ))
    }
    
    /// スポット種別の基調色。
    private var accent: Color { spot.spotType.color }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            accent.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    VStack(alignment: .leading, spacing: 18) {
                        actionCard
                        descriptionCard
                        MediumRectangleAdView(adUnitID: adUnitIdDetailBanner)
                        mapCard
                    }
                    .padding(.horizontal, 18)
                }
                .padding(.bottom, 32)
            }
            .background(PlanTheme.backgroundGradient.ignoresSafeArea())
            .ignoresSafeArea(edges: .top)

            closeButton
        }
        .navigationBarHidden(true)
    }

    // MARK: - 閉じるボタン

    private var closeButton: some View {
        Button {
            InterstitialViewModel.count += 2
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        }
        .padding(.top, 56)
        .padding(.trailing, 18)
    }

    // MARK: - ヒーローヘッダー

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle().fill(.white.opacity(0.22)).frame(width: 76, height: 76)
                Image(systemName: spot.imageSymbol)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(spot.name)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                Label(spot.spotType.localizedName, systemImage: spot.spotType.icon)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(.white.opacity(0.22), in: Capsule())
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < spot.popularity ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(index < spot.popularity ? .white : .white.opacity(0.4))
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 22).padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        // ヘッダー自身は背景を持たず、最背面の accent をそのまま透かす（段差を出さない）。
    }

    // MARK: - アクション白カード

    private var actionCard: some View {
        VStack(spacing: 14) {
            AddToPlanButton {
                PlanItem(
                    category: .nature,
                    prefecture: spot.prefecture ?? Prefecture.nearest(to: spot.coordinate),
                    name: spot.name
                )
            }
            HStack(spacing: 6) {
                Text("gourmet.explore_more".localized)
                    .font(.caption.weight(.bold)).foregroundColor(.secondary)
                Spacer()
            }
            SocialSearchButtons(query: spot.name)
        }
        .planCard()
    }

    // MARK: - 説明

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "text.quote", title: "spot_features".localized)
            Text(spot.description).font(.body).lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - 地図カード

    private var mapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "map", title: "spot_map".localized)

            Map(coordinateRegion: $region, annotationItems: [spot]) { spotItem in
                MapAnnotation(coordinate: spotItem.coordinate) {
                    Image(systemName: spotItem.spotType.icon)
                        .font(.title3)
                        .foregroundColor(accent)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 3)
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .onAppear { region.center = spot.coordinate }

            Button(action: { openInExternalMaps() }) {
                HStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(accent)
                        .frame(width: 32, height: 32)
                        .background(.white, in: Circle())
                    Text("open_external_map".localized)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(accent))
                .shadow(color: accent.opacity(0.3), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - 共通

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2, style: .continuous).fill(accent).frame(width: 4, height: 18)
            Image(systemName: icon).font(.subheadline.weight(.semibold)).foregroundColor(accent)
            Text(title).font(.system(.headline, design: .rounded)).fontWeight(.bold)
        }
    }

    private func openInExternalMaps() {
        let searchQuery = spot.name
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let appleMapsSearchURL = "http://maps.apple.com/?q=\(encodedQuery)"
        let googleMapsSearchURL = "https://maps.google.com/maps?q=\(encodedQuery)"
        
        if let url = URL(string: appleMapsSearchURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: googleMapsSearchURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            let webURL = "https://www.google.com/maps/search/\(encodedQuery)"
            if let url = URL(string: webURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - NatureSpotCardView
struct NatureSpotCardView: View {
    let spot: FixedNatureSpotItem
    let selectedSpot: FixedNatureSpotItem?
    
    private var isSelected: Bool {
        selectedSpot?.id == spot.id
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 観光名所アイコン
            ZStack {
                // 選択された観光名所の背景効果
                if isSelected {
                    Circle()
                        .fill(spot.spotType.color.opacity(0.2))
                        .frame(width: 55, height: 55)
                        .blur(radius: 8)
                }
                
                Circle()
                    .fill(
                        isSelected
                        ? LinearGradient(
                            gradient: Gradient(colors: [spot.spotType.color, spot.spotType.color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            gradient: Gradient(colors: [spot.spotType.color.opacity(0.8), spot.spotType.color]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isSelected ? 48 : 42, height: isSelected ? 48 : 42)
                    .shadow(
                        color: isSelected ? spot.spotType.color.opacity(0.5) : .black.opacity(0.15),
                        radius: isSelected ? 4 : 2,
                        x: 0,
                        y: isSelected ? 2 : 1
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Image(systemName: spot.spotType.icon)
                    .font(.system(size: isSelected ? 22 : 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                // 観光名所名
                Text(spot.name)
                    .font(.system(size: 12, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? spot.spotType.color : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28)
                
                // 観光名所タイプと人気度を横並びに
                HStack(spacing: 6) {
                    // 観光名所タイプ
                    Text(spot.spotType.localizedName)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(spot.spotType.color.opacity(0.1))
                        .cornerRadius(3)
                    
                    // 人気度
                    HStack(spacing: 1) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < spot.popularity ? "star.fill" : "star")
                                .foregroundColor(.orange)
                                .font(.system(size: 7))
                        }
                    }
                }
            }
        }
        .padding(10)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isSelected
                    ? LinearGradient(
                        gradient: Gradient(colors: [spot.spotType.color.opacity(0.1), spot.spotType.color.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        gradient: Gradient(colors: [Color.white]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .stroke(
                    isSelected ? spot.spotType.color.opacity(0.4) : Color.gray.opacity(0.2),
                    lineWidth: isSelected ? 2 : 1
                )
                .shadow(
                    color: isSelected ? spot.spotType.color.opacity(0.2) : .black.opacity(0.05),
                    radius: isSelected ? 4 : 2,
                    x: 0,
                    y: isSelected ? 2 : 1
                )
        )
        .frame(height: 150)
    }
}
