//
//  SettingsView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/19.
//

import SwiftUI
import Combine

enum DisplayMode: String, CaseIterable {
    case tourism = "全国モード"
    case onsen = "温泉地モード"
    
    private var localizedKey: String {
        switch self {
        case .tourism: return "tourism"
        case .onsen: return "onsen"
        }
    }
    
    var name: String {
        return NSLocalizedString("display_mode.\(localizedKey)", comment: "Display mode name")
    }
    
    var description: String {
        return NSLocalizedString("display_mode.\(localizedKey).description", comment: "Display mode description")
    }
    
    var icon: String {
        switch self {
        case .tourism:
            return "map.fill"
        case .onsen:
            return "thermometer.sun.fill"
        }
    }
}

import Foundation
import SwiftUI

// MARK: - Prefecture Extension for Onsen Mode
extension Prefecture {
    var hasOnsen: Bool {
        return !self.onsenItems.isEmpty
    }
    
    static var prefecturesWithOnsen: [Prefecture] {
        return Prefecture.allCases.filter { $0.hasOnsen }
    }
}

// MARK: - Settings View with Onsen Mode
struct SettingsView: View {
    @Binding var enabledPrefectures: Set<Prefecture>
    @ObservedObject var weightManager: WeightManager
    @Binding var displayMode: DisplayMode
    @Environment(\.dismiss) private var dismiss
    @State private var showWeightSettings = false
    
    // 表示モードに応じた都道府県リストを取得
    private var availablePrefectures: [Prefecture] {
        switch displayMode {
        case .tourism:
            return Prefecture.allCases
        case .onsen:
            return Prefecture.prefecturesWithOnsen
        }
    }
    
    // 地方ごとにグループ化された都道府県を取得（表示モードに応じてフィルタリング）
    private var prefecturesByRegion: [(String, [Prefecture])] {
        let filteredPrefectures = availablePrefectures
        let groupedPrefectures = Dictionary(grouping: filteredPrefectures) { $0.region }
        
        // 地方の順序をキーで定義し、ローカライズされた名前を取得
        let regionKeys = ["hokkaido", "tohoku", "kanto", "koshinetsu", "tokai", "hokuriku", "kinki", "chugoku", "shikoku", "kyushu", "okinawa"]
        
        return regionKeys.compactMap { regionKey in
            let localizedRegionName = NSLocalizedString("region.\(regionKey)", comment: "Region name")
            if let prefectures = groupedPrefectures[localizedRegionName], !prefectures.isEmpty {
                return (localizedRegionName, prefectures)
            }
            return nil
        }
    }
    
    var body: some View {
        NavigationView {
            listView
        }
        .sheet(isPresented: $showWeightSettings) {
            WeightSettingsView(
                weightManager: weightManager,
                enabledPrefectures: $enabledPrefectures,
                availablePrefectures: availablePrefectures
            )
        }
    }
    
    private var listView: some View {
        List {
            // 表示モード選択セクション
            Section(header: Text(NSLocalizedString("display_mode", comment: "Display Mode"))) {
                DisplayModeSelectionView(displayMode: $displayMode)
            }
            
            // 重み付け設定セクション
            Section {
                WeightSettingsButtonView(showWeightSettings: $showWeightSettings)
            }
            
            // 都道府県選択セクション
            PrefectureSelectionView(
                prefecturesByRegion: prefecturesByRegion,
                enabledPrefectures: $enabledPrefectures,
                weightManager: weightManager,
                displayMode: displayMode
            )
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 16) {
                    Button(NSLocalizedString("select_all", comment: "Select All")) {
                        enabledPrefectures = Set(availablePrefectures)
                    }
                    
                    Button(NSLocalizedString("deselect_all", comment: "Deselect All")) {
                        enabledPrefectures.removeAll()
                    }
                    .foregroundColor(.red)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("done", comment: "Done")) {
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    // 表示モード変更時の処理
    private func changeDisplayMode(to newMode: DisplayMode) {
        displayMode = newMode
        
        // 現在選択されている都道府県のうち、新しいモードで利用可能なもののみを保持
        let newAvailablePrefectures = Set(availablePrefectures)
        enabledPrefectures = enabledPrefectures.intersection(newAvailablePrefectures)
        
        // 温泉地モードで選択可能な都道府県がない場合は、自動的に全選択
        if displayMode == .onsen && enabledPrefectures.isEmpty {
            enabledPrefectures = newAvailablePrefectures
        }
    }
}

// MARK: - Display Mode Selection View
struct DisplayModeSelectionView: View {
    @Binding var displayMode: DisplayMode
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(DisplayMode.allCases, id: \.self) { mode in
                DisplayModeRow(mode: mode, displayMode: $displayMode)
            }
        }
    }
}

struct DisplayModeRow: View {
    let mode: DisplayMode
    @Binding var displayMode: DisplayMode
    
    var body: some View {
        Button(action: {
            displayMode = mode
        }) {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .foregroundColor(displayMode == mode ? (displayMode == .onsen ? .selectedColor2 : .green) : .gray)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.name)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium))
                    Text(mode.description)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                Spacer()
                
                if displayMode == mode {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Weight Settings Button View
struct WeightSettingsButtonView: View {
    @Binding var showWeightSettings: Bool
    
    var body: some View {
        Button(action: {
            showWeightSettings = true
        }) {
            HStack {
                Image(systemName: "scale.3d")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("weight_settings", comment: "Weight Settings"))
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .medium))
                    Text(NSLocalizedString("weight_settings_description", comment: "Adjust selection probability for each prefecture"))
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

// MARK: - Prefecture Selection View
struct PrefectureSelectionView: View {
    let prefecturesByRegion: [(String, [Prefecture])]
    @Binding var enabledPrefectures: Set<Prefecture>
    @ObservedObject var weightManager: WeightManager
    let displayMode: DisplayMode
    
    var body: some View {
        ForEach(prefecturesByRegion, id: \.0) { region, prefectures in
            Section(header: RegionHeaderView(region: region, prefectures: prefectures, displayMode: displayMode)) {
                ForEach(prefectures, id: \.self) { prefecture in
                    PrefectureRow(
                        prefecture: prefecture,
                        enabledPrefectures: $enabledPrefectures,
                        weightManager: weightManager,
                        displayMode: displayMode
                    )
                }
            }
        }
    }
}

struct RegionHeaderView: View {
    let region: String
    let prefectures: [Prefecture]
    let displayMode: DisplayMode
    
    var body: some View {
        HStack {
            Text(region)
            Spacer()
            if displayMode == .onsen {
                let onsenCount = prefectures.map { $0.onsenItems.count }.reduce(0, +)
                Text(String(format: NSLocalizedString("onsen_count_format", comment: "Onsen count format"), onsenCount))
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
    }
}

struct PrefectureRow: View {
    let prefecture: Prefecture
    @Binding var enabledPrefectures: Set<Prefecture>
    @ObservedObject var weightManager: WeightManager
    let displayMode: DisplayMode
    
    var body: some View {
        HStack {
            Button(action: {
                if enabledPrefectures.contains(prefecture) {
                    enabledPrefectures.remove(prefecture)
                } else {
                    enabledPrefectures.insert(prefecture)
                }
            }) {
                HStack {
                    Image(systemName: enabledPrefectures.contains(prefecture) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(enabledPrefectures.contains(prefecture) ? .green : .gray)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(prefecture.prefectureName)
                            .foregroundColor(.primary)
                        
                        if displayMode == .onsen && prefecture.hasOnsen {
                            Text(String(format: NSLocalizedString("onsen_locations_count", comment: "Onsen locations count"), prefecture.onsenItems.count))
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    // 重み表示
                    if enabledPrefectures.contains(prefecture) {
                        let weightValue = weightManager.weights[prefecture, default: 1.0]
                        Text("×\(weightValue, specifier: "%.1f")")
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(3)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
