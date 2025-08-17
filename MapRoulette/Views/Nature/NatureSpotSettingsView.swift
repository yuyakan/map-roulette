//
//  NatureSpotSettingsView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/08/12.
//

import SwiftUI

// MARK: - 自然観光名所設定画面
struct NatureSpotSettingsView: View {
    @Binding var enabledSpots: Set<FixedNatureSpotItem>
    @ObservedObject var spotWeightManager: NatureSpotWeightManager
    @Environment(\.dismiss) private var dismiss
    @State private var showWeightSettings = false
    @Binding var selectedDisplayTypes: Set<NatureSpotType>
    
    // 全ての自然観光名所リストを取得
    private var allSpots: [FixedNatureSpotItem] {
        return NatureSpotDataRepository.shared.allFixedSpots
    }
    
    // 表示タイプでフィルタリングされた観光名所を取得
    private var filteredSpots: [FixedNatureSpotItem] {
        return allSpots.filter { selectedDisplayTypes.contains($0.spotType) }
    }
    
    // タイプごとにグループ化された観光名所を取得
    private var spotsByType: [(NatureSpotType, [FixedNatureSpotItem])] {
        return NatureSpotType.allCases.compactMap { type in
            let spots = filteredSpots.filter { $0.spotType == type }
            if !spots.isEmpty {
                return (type, spots.sorted { $0.name < $1.name })
            }
            return nil
        }
    }
    
    var body: some View {
        NavigationView {
            listView
        }
        .sheet(isPresented: $showWeightSettings) {
            NatureSpotWeightSettingsView(
                spotWeightManager: spotWeightManager,
                enabledSpots: $enabledSpots,
                allSpots: allSpots
            )
        }
        .onAppear {
            // 初期設定: 有効になっているスポットのタイプを選択状態にする
            if selectedDisplayTypes.isEmpty {
                selectedDisplayTypes = Set(enabledSpots.map { $0.spotType })
            }
        }
    }
    
    private var listView: some View {
        List {
            // 表示アイコン選択セクション
            Section(header: HStack(spacing: 6) {
                Image(systemName: "leaf")
                    .foregroundColor(.green)
                Text("display_icon_settings".localized)
            }) {
                DisplayIconSelectionView(
                    selectedDisplayTypes: $selectedDisplayTypes,
                    enabledSpots: $enabledSpots,
                    allSpots: allSpots
                )
            }
            
            // 重み付け設定セクション
            Section {
                NatureSpotWeightSettingsButtonView(showWeightSettings: $showWeightSettings)
            }
            
            // 観光名所選択セクション
            NatureSpotSelectionByTypeView(
                spotsByType: spotsByType,
                enabledSpots: $enabledSpots,
                spotWeightManager: spotWeightManager
            )
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 16) {
                    Button("select_all".localized) {
                        enabledSpots = Set(filteredSpots)
                    }
                    
                    Button("deselect_all".localized) {
                        enabledSpots.removeAll()
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

// MARK: - 表示アイコン選択ビュー
struct DisplayIconSelectionView: View {
    @Binding var selectedDisplayTypes: Set<NatureSpotType>
    @Binding var enabledSpots: Set<FixedNatureSpotItem>
    let allSpots: [FixedNatureSpotItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(NatureSpotType.allCases, id: \.self) { spotType in
                    let isSelected = selectedDisplayTypes.contains(spotType)
                    let spotsForType = allSpots.filter { $0.spotType == spotType }
                    
                    Button(action: {
                        if isSelected {
                            selectedDisplayTypes.remove(spotType)
                            // このタイプの観光名所を無効化
                            for spot in spotsForType {
                                enabledSpots.remove(spot)
                            }
                        } else {
                            selectedDisplayTypes.insert(spotType)
                            // このタイプの観光名所を有効化
                            for spot in spotsForType {
                                enabledSpots.insert(spot)
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(
                                        isSelected
                                        ? LinearGradient(
                                            gradient: Gradient(colors: [spotType.color, spotType.color.opacity(0.7)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            gradient: Gradient(colors: [Color.gray.opacity(0.3)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 32, height: 32)
                                    .shadow(
                                        color: isSelected ? spotType.color.opacity(0.3) : .black.opacity(0.1),
                                        radius: isSelected ? 3 : 1,
                                        x: 0,
                                        y: isSelected ? 2 : 1
                                    )
                                
                                Image(systemName: spotType.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(spotType.localizedName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(isSelected ? .primary : .secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7) // 最小70%まで縮小
                                    .truncationMode(.tail)
                                
                                Text("spots_count_format".localized(spotsForType.count))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8) // 最小80%まで縮小
                                    .truncationMode(.tail)
                            }
                            
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? spotType.color : .gray)
                                .font(.system(size: 18))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? spotType.color.opacity(0.1) : Color.gray.opacity(0.05))
                                .stroke(
                                    isSelected ? spotType.color.opacity(0.3) : Color.gray.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 自然観光名所重み設定ボタンビュー
struct NatureSpotWeightSettingsButtonView: View {
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

// MARK: - タイプ別自然観光名所選択ビュー
struct NatureSpotSelectionByTypeView: View {
    let spotsByType: [(NatureSpotType, [FixedNatureSpotItem])]
    @Binding var enabledSpots: Set<FixedNatureSpotItem>
    @ObservedObject var spotWeightManager: NatureSpotWeightManager
    
    var body: some View {
        ForEach(spotsByType, id: \.0.rawValue) { type, spots in
            Section(header: NatureSpotTypeHeaderView(type: type, spots: spots)) {
                ForEach(spots, id: \.id) { spot in
                    NatureSpotRow(
                        spot: spot,
                        enabledSpots: $enabledSpots,
                        spotWeightManager: spotWeightManager
                    )
                }
            }
        }
    }
}

// MARK: - 自然観光名所タイプヘッダービュー
struct NatureSpotTypeHeaderView: View {
    let type: NatureSpotType
    let spots: [FixedNatureSpotItem]
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                Text(type.localizedName)
            }
            Spacer()
            Text("locations_count_format".localized(spots.count))
                .font(.caption2)
                .foregroundColor(.orange)
        }
    }
}

// MARK: - 自然観光名所行
struct NatureSpotRow: View {
    let spot: FixedNatureSpotItem
    @Binding var enabledSpots: Set<FixedNatureSpotItem>
    @ObservedObject var spotWeightManager: NatureSpotWeightManager
    
    var body: some View {
        HStack {
            Button(action: {
                if enabledSpots.contains(spot) {
                    enabledSpots.remove(spot)
                } else {
                    enabledSpots.insert(spot)
                }
            }) {
                HStack {
                    Image(systemName: enabledSpots.contains(spot) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(enabledSpots.contains(spot) ? spot.spotType.color : .gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(spot.name)
                            .foregroundColor(.primary)
                            .font(.system(size: 15, weight: .medium))
                        
                        HStack(spacing: 8) {
                            // 観光名所タイプ
                            HStack(spacing: 4) {
                                Image(systemName: spot.spotType.icon)
                                    .font(.caption2)
                                    .foregroundColor(spot.spotType.color)
                                Text(spot.spotType.localizedName)
                                    .font(.caption2)
                                    .foregroundColor(spot.spotType.color)
                            }
                            
                            // 人気度
                            HStack(spacing: 1) {
                                ForEach(0..<spot.popularity, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        Text(spot.description.localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // 重み表示
                    if enabledSpots.contains(spot) {
                        let weightValue = spotWeightManager.weights[spot.id, default: 1.0]
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

// MARK: - 自然観光名所重み設定画面
struct NatureSpotWeightSettingsView: View {
    @ObservedObject var spotWeightManager: NatureSpotWeightManager
    @Binding var enabledSpots: Set<FixedNatureSpotItem>
    let allSpots: [FixedNatureSpotItem]
    @Environment(\.dismiss) private var dismiss
    
    // 有効な観光名所のみをタイプ別にグループ化
    private var spotsByType: [(NatureSpotType, [FixedNatureSpotItem])] {
        var groupedSpots: [NatureSpotType: [FixedNatureSpotItem]] = [:]
        
        // 有効な観光名所をタイプ別に分類
        for spot in allSpots.filter({ enabledSpots.contains($0) }) {
            if groupedSpots[spot.spotType] == nil {
                groupedSpots[spot.spotType] = []
            }
            groupedSpots[spot.spotType]?.append(spot)
        }
        
        // タイプ順でソート
        let typeOrder = NatureSpotType.allCases
        return typeOrder.compactMap { spotType in
            if let spots = groupedSpots[spotType], !spots.isEmpty {
                return (spotType, spots.sorted { $0.name < $1.name })
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
                
                ForEach(spotsByType, id: \.0) { spotType, spots in
                    Section(header:
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: spotType.icon)
                                    .foregroundColor(spotType.color)
                                Text(spotType.localizedName)
                            }
                            Spacer()
                            Text("locations_count_format".localized(spots.count))
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    ) {
                        ForEach(spots, id: \.id) { spot in
                            NatureSpotWeightSliderRow(
                                spot: spot,
                                spotWeightManager: spotWeightManager,
                                enabledSpots: enabledSpots
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
                        spotWeightManager.weights.removeAll()
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

// MARK: - 自然観光名所重みスライダー行
struct NatureSpotWeightSliderRow: View {
    let spot: FixedNatureSpotItem
    @ObservedObject var spotWeightManager: NatureSpotWeightManager
    let enabledSpots: Set<FixedNatureSpotItem>
    
    private var currentWeight: Double {
        spotWeightManager.weights[spot.id, default: 1.0]
    }
    
    private var probability: Double {
        let totalWeight = enabledSpots.reduce(0.0) { result, item in
            result + spotWeightManager.weights[item.id, default: 1.0]
        }
        return totalWeight > 0 ? (currentWeight / totalWeight) * 100 : 0
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(spot.name.localized)
                        .font(.system(size: 14, weight: .medium))
                    
                    HStack(spacing: 4) {
                        Image(systemName: spot.spotType.icon)
                            .font(.caption2)
                            .foregroundColor(spot.spotType.color)
                        Text(spot.spotType.localizedName)
                            .font(.caption2)
                            .foregroundColor(spot.spotType.color)
                        
                        // 人気度
                        HStack(spacing: 1) {
                            ForEach(0..<spot.popularity, id: \.self) { _ in
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
                        spotWeightManager.weights[spot.id] = max(0.1, currentWeight - 0.5)
                    }
                    .font(.caption)
                    .frame(width: 20, height: 20)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                    
                    Button("+") {
                        spotWeightManager.weights[spot.id] = min(10.0, currentWeight + 0.5)
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
                    set: { spotWeightManager.weights[spot.id] = $0 }
                ),
                in: 0.1...10.0,
                step: 0.1
            )
            .accentColor(spot.spotType.color)
        }
        .padding(.vertical, 4)
    }
}
