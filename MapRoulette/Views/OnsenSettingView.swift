//
//  OnsenSettingView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/08/02.
//

import SwiftUI
import Combine
import MapKit

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(_ arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}

// MARK: - Fixed Onsen Data Class
class FixedOnsenItem: Identifiable, ObservableObject {
    let id: String
    let name: String
    let description: String
    let imageSymbol: String
    let onsenType: OnsenType
    let popularity: Int
    let coordinate: CLLocationCoordinate2D
    
    init(name: String, description: String, imageSymbol: String, onsenType: OnsenType, popularity: Int, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.description = description
        self.imageSymbol = imageSymbol
        self.onsenType = onsenType
        self.popularity = popularity
        self.coordinate = coordinate
        self.id = "\(name)_\(onsenType.rawValue)"
    }
    
    // OnsenItemから変換（位置情報を追加）
    convenience init(from onsenItem: OnsenItem, coordinate: CLLocationCoordinate2D) {
        self.init(
            name: onsenItem.name,
            description: onsenItem.description,
            imageSymbol: onsenItem.imageSymbol,
            onsenType: onsenItem.onsenType,
            popularity: onsenItem.popularity,
            coordinate: coordinate
        )
    }
}

// MARK: - FixedOnsenItem Hashable & Equatable
extension FixedOnsenItem: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FixedOnsenItem, rhs: FixedOnsenItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Onsen Data Repository
class OnsenDataRepository {
    static let shared = OnsenDataRepository()
    
    private var _cachedOnsens: [FixedOnsenItem] = []
    private var _onsensByName: [String: FixedOnsenItem] = [:]
    
    private init() {
        loadFixedOnsenData()
    }
    
    private func loadFixedOnsenData() {
        // 温泉地の座標データを定義
        let onsenCoordinates: [String: CLLocationCoordinate2D] = [
            // 北海道
            NSLocalizedString("onsen.noboribetsu", comment: ""): CLLocationCoordinate2D(latitude: 42.4919, longitude: 141.1539),
            NSLocalizedString("onsen.toyako", comment: ""): CLLocationCoordinate2D(latitude: 42.5968, longitude: 140.7524),
            NSLocalizedString("onsen.jozankei", comment: ""): CLLocationCoordinate2D(latitude: 42.9621, longitude: 141.1621),
            NSLocalizedString("onsen.hakodateyunokawa", comment: ""): CLLocationCoordinate2D(latitude: 41.7774, longitude: 140.7886),
            
            // 東北
            NSLocalizedString("onsen.nyuto", comment: ""): CLLocationCoordinate2D(latitude: 39.7372, longitude: 140.7372),
            NSLocalizedString("onsen.ginzan", comment: ""): CLLocationCoordinate2D(latitude: 38.5398, longitude: 140.5098),
            NSLocalizedString("onsen.zao", comment: ""): CLLocationCoordinate2D(latitude: 38.1495, longitude: 140.4495),
            NSLocalizedString("onsen.hanamaki", comment: ""): CLLocationCoordinate2D(latitude: 39.3778, longitude: 141.1048),
            NSLocalizedString("onsen.naruko", comment: ""): CLLocationCoordinate2D(latitude: 38.7299, longitude: 140.7299),
            NSLocalizedString("onsen.iizaka", comment: ""): CLLocationCoordinate2D(latitude: 37.8267, longitude: 140.4267),
            
            // 関東
            NSLocalizedString("onsen.hakone", comment: ""): CLLocationCoordinate2D(latitude: 35.2043, longitude: 139.0235),
            NSLocalizedString("onsen.kusatsu", comment: ""): CLLocationCoordinate2D(latitude: 36.6228, longitude: 138.5989),
            NSLocalizedString("onsen.ikaho", comment: ""): CLLocationCoordinate2D(latitude: 36.4895, longitude: 138.9095),
            NSLocalizedString("onsen.atami", comment: ""): CLLocationCoordinate2D(latitude: 35.1042, longitude: 139.0731),
            NSLocalizedString("onsen.shuzenji", comment: ""): CLLocationCoordinate2D(latitude: 34.9679, longitude: 138.9279),
            NSLocalizedString("onsen.atagawa", comment: ""): CLLocationCoordinate2D(latitude: 34.8164, longitude: 139.0764),
            NSLocalizedString("onsen.isawa", comment: ""): CLLocationCoordinate2D(latitude: 35.6536, longitude: 138.6336),
            
            // 中部
            NSLocalizedString("onsen.nozawa", comment: ""): CLLocationCoordinate2D(latitude: 36.9144, longitude: 138.4444),
            NSLocalizedString("onsen.kamisuwa", comment: ""): CLLocationCoordinate2D(latitude: 36.0461, longitude: 138.1161),
            NSLocalizedString("onsen.gero", comment: ""): CLLocationCoordinate2D(latitude: 35.8080, longitude: 137.2480),
            NSLocalizedString("onsen.unazuki", comment: ""): CLLocationCoordinate2D(latitude: 36.8033, longitude: 137.5833),
            
            // 北陸
            NSLocalizedString("onsen.yamanaka", comment: ""): CLLocationCoordinate2D(latitude: 36.2889, longitude: 136.3689),
            NSLocalizedString("onsen.wakura", comment: ""): CLLocationCoordinate2D(latitude: 37.1169, longitude: 136.9269),
            NSLocalizedString("onsen.yamashiro", comment: ""): CLLocationCoordinate2D(latitude: 36.2981, longitude: 136.3681),
            NSLocalizedString("onsen.katayamazu", comment: ""): CLLocationCoordinate2D(latitude: 36.3200, longitude: 136.3500),
            
            // 関西
            NSLocalizedString("onsen.arima", comment: ""): CLLocationCoordinate2D(latitude: 34.7974, longitude: 135.2574),
            NSLocalizedString("onsen.kinosaki", comment: ""): CLLocationCoordinate2D(latitude: 35.6076, longitude: 134.8076),
            NSLocalizedString("onsen.yumura", comment: ""): CLLocationCoordinate2D(latitude: 35.4883, longitude: 134.6183),
            NSLocalizedString("onsen.shirahama", comment: ""): CLLocationCoordinate2D(latitude: 33.6886, longitude: 135.3386),
            NSLocalizedString("onsen.katsuura", comment: ""): CLLocationCoordinate2D(latitude: 33.6767, longitude: 135.8867),
            
            // 中国
            NSLocalizedString("onsen.misasa", comment: ""): CLLocationCoordinate2D(latitude: 35.4036, longitude: 133.8936),
            NSLocalizedString("onsen.tamatsukuri", comment: ""): CLLocationCoordinate2D(latitude: 35.4230, longitude: 132.8730),
            
            // 四国
            NSLocalizedString("onsen.dogo", comment: ""): CLLocationCoordinate2D(latitude: 33.8518, longitude: 132.7818),
            
            // 九州
            NSLocalizedString("onsen.beppu", comment: ""): CLLocationCoordinate2D(latitude: 33.2695, longitude: 131.4895),
            NSLocalizedString("onsen.yufuin", comment: ""): CLLocationCoordinate2D(latitude: 33.2667, longitude: 131.3567),
            NSLocalizedString("onsen.ibusuki", comment: ""): CLLocationCoordinate2D(latitude: 31.2513, longitude: 130.6413),
            NSLocalizedString("onsen.kurokawa", comment: ""): CLLocationCoordinate2D(latitude: 33.0600, longitude: 131.1000),
            NSLocalizedString("onsen.unzen", comment: ""): CLLocationCoordinate2D(latitude: 32.7600, longitude: 130.2900),
            NSLocalizedString("onsen.ureshino", comment: ""): CLLocationCoordinate2D(latitude: 33.1056, longitude: 129.9956),
            NSLocalizedString("onsen.takeo", comment: ""): CLLocationCoordinate2D(latitude: 33.1936, longitude: 129.9936)
        ]
        
        // 全ての温泉地データを一度だけロードして固定する
        let allOriginalOnsens = Prefecture.prefecturesWithOnsen.flatMap { $0.onsenItems }
        
        for originalOnsen in allOriginalOnsens {
            let coordinate = onsenCoordinates[originalOnsen.name] ?? CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503) // デフォルトは東京
            let fixedOnsen = FixedOnsenItem(from: originalOnsen, coordinate: coordinate)
            _cachedOnsens.append(fixedOnsen)
            _onsensByName[fixedOnsen.id] = fixedOnsen
        }
    }
    
    // 固定された温泉地データを取得
    var allFixedOnsens: [FixedOnsenItem] {
        return _cachedOnsens
    }
    
    // 名前で固定された温泉地を取得
    func getFixedOnsen(name: String, type: OnsenType) -> FixedOnsenItem? {
        let key = "\(name)_\(type.rawValue)"
        return _onsensByName[key]
    }
    
    // 地方別にグループ化
    func getOnsensByRegion() -> [(String, [FixedOnsenItem])] {
        var groupedOnsens: [String: [FixedOnsenItem]] = [:]
        
        for prefecture in Prefecture.prefecturesWithOnsen {
            let region = prefecture.region
            for originalOnsen in prefecture.onsenItems {
                if let fixedOnsen = getFixedOnsen(name: originalOnsen.name, type: originalOnsen.onsenType) {
                    if groupedOnsens[region] == nil {
                        groupedOnsens[region] = []
                    }
                    groupedOnsens[region]?.append(fixedOnsen)
                }
            }
        }
        
        let regionKeys = ["hokkaido", "tohoku", "kanto", "koshinetsu", "tokai", "hokuriku", "kinki", "chugoku", "shikoku", "kyushu", "okinawa"]
        
        return regionKeys.compactMap { regionKey in
            let localizedRegionName = NSLocalizedString("region.\(regionKey)", comment: "Region name")
            if let prefectures = groupedOnsens[localizedRegionName], !prefectures.isEmpty {
                return (localizedRegionName, prefectures)
            }
            return nil
        }
    }
    
    // タイプ別にグループ化
    func getOnsensByType() -> [(OnsenType, [FixedOnsenItem])] {
        let groupedOnsens = Dictionary(grouping: allFixedOnsens) { $0.onsenType }
        return OnsenType.allCases.compactMap { type in
            if let onsens = groupedOnsens[type], !onsens.isEmpty {
                return (type, onsens.sorted { $0.name < $1.name })
            }
            return nil
        }
    }
}

// MARK: - OnsenItem Hashable & Equatable (Fixed)
extension OnsenItem: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(onsenType.rawValue)
    }
    
    static func == (lhs: OnsenItem, rhs: OnsenItem) -> Bool {
        return lhs.name == rhs.name && lhs.onsenType == rhs.onsenType
    }
}

// MARK: - Onsen Settings View
struct OnsenSettingsView: View {
    @Binding var enabledOnsens: Set<FixedOnsenItem>
    @ObservedObject var onsenWeightManager: OnsenWeightManager
    @Environment(\.dismiss) private var dismiss
    @State private var showWeightSettings = false
    
    // 全ての温泉地リストを取得
    private var allOnsens: [FixedOnsenItem] {
        return OnsenDataRepository.shared.allFixedOnsens
    }
    
    // 地方ごとにグループ化された温泉地を取得
    private var onsensByRegion: [(String, [FixedOnsenItem])] {
        return OnsenDataRepository.shared.getOnsensByRegion()
    }
    
    // 温泉タイプごとにグループ化された温泉地を取得
    private var onsensByType: [(OnsenType, [FixedOnsenItem])] {
        return OnsenDataRepository.shared.getOnsensByType()
    }
    
    @State private var groupingMode: GroupingMode = .region
    
    var body: some View {
        NavigationView {
            listView
        }
        .sheet(isPresented: $showWeightSettings) {
            OnsenWeightSettingsView(
                onsenWeightManager: onsenWeightManager,
                enabledOnsens: $enabledOnsens,
                allOnsens: allOnsens
            )
        }
    }
    
    private var listView: some View {
        List {
            // グループ化モード選択セクション
            Section(header: Text("display_settings".localized)) {
                GroupingModeSelectionView(groupingMode: $groupingMode)
            }
            
            // 重み付け設定セクション
            Section {
                OnsenWeightSettingsButtonView(showWeightSettings: $showWeightSettings)
            }
            
            // 温泉地選択セクション
            if groupingMode == .region {
                OnsenSelectionByRegionView(
                    onsensByRegion: onsensByRegion,
                    enabledOnsens: $enabledOnsens,
                    onsenWeightManager: onsenWeightManager
                )
            } else {
                OnsenSelectionByTypeView(
                    onsensByType: onsensByType,
                    enabledOnsens: $enabledOnsens,
                    onsenWeightManager: onsenWeightManager
                )
            }
        }
        .navigationTitle("onsen_settings_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 16) {
                    Button("select_all".localized) {
                        enabledOnsens = Set(allOnsens)
                    }
                    
                    Button("deselect_all".localized) {
                        enabledOnsens.removeAll()
                    }
                    .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("done".localized) {
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - Grouping Mode
enum GroupingMode: String, CaseIterable {
    case region = "grouping_by_region"
    case type = "grouping_by_type"
    
    var localizedString: String {
        self.rawValue.localized
    }
    
    var icon: String {
        switch self {
        case .region: return "map.fill"
        case .type: return "tag.fill"
        }
    }
}

// MARK: - Grouping Mode Selection View
struct GroupingModeSelectionView: View {
    @Binding var groupingMode: GroupingMode
    
    var body: some View {
        HStack {
            ForEach(GroupingMode.allCases, id: \.self) { mode in
                Button(action: {
                    groupingMode = mode
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                        Text(mode.localizedString)
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(groupingMode == mode ? .white : .orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(groupingMode == mode ? Color.orange : Color.orange.opacity(0.1))
                    .cornerRadius(15)
                }
                .buttonStyle(PlainButtonStyle())
                
                if mode != GroupingMode.allCases.last {
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Onsen Weight Settings Button View
struct OnsenWeightSettingsButtonView: View {
    @Binding var showWeightSettings: Bool
    
    var body: some View {
        Button(action: {
            showWeightSettings = true
        }) {
            HStack {
                Image(systemName: "scale.3d")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("weight_settings".localized)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium))
                    Text("weight_settings_description".localized)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Onsen Selection By Region View
struct OnsenSelectionByRegionView: View {
    let onsensByRegion: [(String, [FixedOnsenItem])]
    @Binding var enabledOnsens: Set<FixedOnsenItem>
    @ObservedObject var onsenWeightManager: OnsenWeightManager
    
    var body: some View {
        ForEach(onsensByRegion, id: \.0) { region, onsens in
            Section(header: OnsenRegionHeaderView(region: region, onsens: onsens)) {
                ForEach(onsens, id: \.id) { onsen in
                    OnsenRow(
                        onsen: onsen,
                        enabledOnsens: $enabledOnsens,
                        onsenWeightManager: onsenWeightManager
                    )
                }
            }
        }
    }
}

// MARK: - Onsen Selection By Type View
struct OnsenSelectionByTypeView: View {
    let onsensByType: [(OnsenType, [FixedOnsenItem])]
    @Binding var enabledOnsens: Set<FixedOnsenItem>
    @ObservedObject var onsenWeightManager: OnsenWeightManager
    
    var body: some View {
        ForEach(onsensByType, id: \.0.rawValue) { type, onsens in
            Section(header: OnsenTypeHeaderView(type: type, onsens: onsens)) {
                ForEach(onsens, id: \.id) { onsen in
                    OnsenRow(
                        onsen: onsen,
                        enabledOnsens: $enabledOnsens,
                        onsenWeightManager: onsenWeightManager
                    )
                }
            }
        }
    }
}

// MARK: - Header Views
struct OnsenRegionHeaderView: View {
    let region: String
    let onsens: [FixedOnsenItem]
    
    var body: some View {
        HStack {
            Text(region)
            Spacer()
            Text("locations_count_format".localized(onsens.count))
                .font(.caption2)
                .foregroundColor(.orange)
        }
    }
}

struct OnsenTypeHeaderView: View {
    let type: OnsenType
    let onsens: [FixedOnsenItem]
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                Text(type.localizedName)
            }
            Spacer()
            Text("locations_count_format".localized(onsens.count))
                .font(.caption2)
                .foregroundColor(.orange)
        }
    }
}

// MARK: - Onsen Row
struct OnsenRow: View {
    let onsen: FixedOnsenItem
    @Binding var enabledOnsens: Set<FixedOnsenItem>
    @ObservedObject var onsenWeightManager: OnsenWeightManager
    
    var body: some View {
        HStack {
            Button(action: {
                if enabledOnsens.contains(onsen) {
                    enabledOnsens.remove(onsen)
                } else {
                    enabledOnsens.insert(onsen)
                }
            }) {
                HStack {
                    Image(systemName: enabledOnsens.contains(onsen) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(enabledOnsens.contains(onsen) ? .orange : .gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(onsen.name)
                            .foregroundColor(.primary)
                            .font(.system(size: 15, weight: .medium))
                        
                        HStack(spacing: 8) {
                            // 温泉タイプ
                            HStack(spacing: 4) {
                                Image(systemName: onsen.onsenType.icon)
                                    .font(.caption2)
                                    .foregroundColor(onsen.onsenType.color)
                                Text(onsen.onsenType.localizedName)
                                    .font(.caption2)
                                    .foregroundColor(onsen.onsenType.color)
                            }
                            
                            // 人気度
                            HStack(spacing: 1) {
                                ForEach(0..<onsen.popularity, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        Text(onsen.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // 重み表示
                    if enabledOnsens.contains(onsen) {
                        let weightValue = onsenWeightManager.weights[onsen.id, default: 1.0]
                        Text("×\(weightValue, specifier: "%.1f")")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(3)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Onsen Weight Manager
class OnsenWeightManager: ObservableObject {
    @Published var weights: [String: Double] = [:]
    
    private func getOnsenKey(_ onsen: FixedOnsenItem) -> String {
        return onsen.id
    }
    
    func selectRandomOnsen(from onsens: Set<FixedOnsenItem>) -> FixedOnsenItem? {
        let onsenArray = Array(onsens)
        guard !onsenArray.isEmpty else { return nil }
        
        let totalWeight = onsenArray.reduce(0.0) { result, onsen in
            result + weights[getOnsenKey(onsen), default: 1.0]
        }
        
        let randomValue = Double.random(in: 0...totalWeight)
        var currentWeight = 0.0
        
        for onsen in onsenArray {
            currentWeight += weights[getOnsenKey(onsen), default: 1.0]
            if randomValue <= currentWeight {
                return onsen
            }
        }
        
        return onsenArray.last
    }
}

// MARK: - Onsen Weight Settings View
struct OnsenWeightSettingsView: View {
    @ObservedObject var onsenWeightManager: OnsenWeightManager
    @Binding var enabledOnsens: Set<FixedOnsenItem>
    let allOnsens: [FixedOnsenItem]
    @Environment(\.dismiss) private var dismiss
    
    // 有効な温泉地のみを都道府県別にグループ化
    private var onsensByPrefecture: [(Prefecture, [FixedOnsenItem])] {
        var groupedOnsens: [Prefecture: [FixedOnsenItem]] = [:]
        
        // 有効な温泉地を都道府県別に分類
        for onsen in allOnsens.filter({ enabledOnsens.contains($0) }) {
            if let prefecture = Prefecture.allCases.first(where: { prefecture in
                prefecture.onsenItems.contains(where: { originalOnsen in
                    originalOnsen.name == onsen.name && originalOnsen.onsenType == onsen.onsenType
                })
            }) {
                if groupedOnsens[prefecture] == nil {
                    groupedOnsens[prefecture] = []
                }
                groupedOnsens[prefecture]?.append(onsen)
            }
        }
        
        // 地方順でソート
        let prefectureOrder = Prefecture.allCases
        return prefectureOrder.compactMap { prefecture in
            if let onsens = groupedOnsens[prefecture], !onsens.isEmpty {
                return (prefecture, onsens.sorted { $0.name < $1.name })
            }
            return nil
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("weight_settings".localized)
                            .font(.headline)
                        Text("weight_settings_explanation".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                ForEach(onsensByPrefecture, id: \.0) { prefecture, onsens in
                    Section(header:
                        HStack {
                            Text(prefecture.prefectureName)
                            Spacer()
                            Text("locations_count_format".localized(onsens.count))
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    ) {
                        ForEach(onsens, id: \.id) { onsen in
                            OnsenWeightSliderRow(
                                onsen: onsen,
                                onsenWeightManager: onsenWeightManager,
                                enabledOnsens: enabledOnsens
                            )
                        }
                    }
                }
            }
            .navigationTitle("weight_adjustment".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("reset".localized) {
                        onsenWeightManager.weights.removeAll()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done".localized) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Onsen Weight Slider Row
struct OnsenWeightSliderRow: View {
    let onsen: FixedOnsenItem
    @ObservedObject var onsenWeightManager: OnsenWeightManager
    let enabledOnsens: Set<FixedOnsenItem>
    
    private var currentWeight: Double {
        onsenWeightManager.weights[onsen.id, default: 1.0]
    }
    
    private var probability: Double {
        let totalWeight = enabledOnsens.reduce(0.0) { result, item in
            result + onsenWeightManager.weights[item.id, default: 1.0]
        }
        return totalWeight > 0 ? (currentWeight / totalWeight) * 100 : 0
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(onsen.name)
                        .font(.system(size: 14, weight: .medium))
                    
                    HStack(spacing: 4) {
                        Image(systemName: onsen.onsenType.icon)
                            .font(.caption2)
                            .foregroundColor(onsen.onsenType.color)
                        Text(onsen.onsenType.localizedName)
                            .font(.caption2)
                            .foregroundColor(onsen.onsenType.color)
                        
                        // 人気度
                        HStack(spacing: 1) {
                            ForEach(0..<onsen.popularity, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // 確率表示
                Text("probability_format".localized(probability))
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
            }
            
            HStack {
                // 重み値表示
                Text("weight_format".localized(currentWeight))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // クイック調整ボタン
                HStack(spacing: 4) {
                    Button("-") {
                        onsenWeightManager.weights[onsen.id] = max(0.1, currentWeight - 0.5)
                    }
                    .font(.caption)
                    .frame(width: 20, height: 20)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                    
                    Button("+") {
                        onsenWeightManager.weights[onsen.id] = min(10.0, currentWeight + 0.5)
                    }
                    .font(.caption)
                    .frame(width: 20, height: 20)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(10)
                }
            }
            
            // スライダー
            Slider(
                value: Binding(
                    get: { currentWeight },
                    set: { onsenWeightManager.weights[onsen.id] = $0 }
                ),
                in: 0.1...10.0,
                step: 0.1
            )
            .accentColor(.orange)
        }
        .padding(.vertical, 4)
    }
}
