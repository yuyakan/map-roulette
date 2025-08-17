//
//  WeightSettingsView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/19.
//

import Foundation
import SwiftUI

struct WeightSettingsView: View {
    @ObservedObject var weightManager: WeightManager
    @Binding var enabledPrefectures: Set<Prefecture>
    let availablePrefectures: [Prefecture]
    @Environment(\.dismiss) private var dismiss
    
    // 地方ごとにグループ化（利用可能な都道府県のみ）
    private var prefecturesByRegion: [(String, [Prefecture])] {
        let groupedPrefectures = Dictionary(grouping: availablePrefectures) { $0.region }
        
        // 地方の順序をキーで定義し、ローカライズされた名前を取得
        let regionKeys = ["hokkaido", "tohoku", "kanto", "koshinetsu", "tokai", "hokuriku", "kinki", "chugoku", "shikoku", "kyushu", "okinawa"]
        
        return regionKeys.compactMap { regionKey in
                   let localizedRegionName = NSLocalizedString("region.\(regionKey)", comment: "Region name")
                   if let prefectures = groupedPrefectures[localizedRegionName], !prefectures.isEmpty {
                       let filteredPrefectures = prefectures.filter { enabledPrefectures.contains($0) }
                       return filteredPrefectures.isEmpty ? nil : (localizedRegionName, filteredPrefectures)
                   }
                   return nil
               }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("weight_settings", comment: "Weight Settings"))
                            .font(.headline)
                        Text(NSLocalizedString("weight_settings_explanation", comment: "Weight settings explanation"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                ForEach(prefecturesByRegion, id: \.0) { region, prefectures in
                    Section(header: Text(region)) {
                        ForEach(prefectures, id: \.self) { prefecture in
                            WeightSliderRow(
                                prefecture: prefecture,
                                weightManager: weightManager,
                                enabledPrefectures: enabledPrefectures
                            )
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("weight_settings", comment: "Weight Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("reset", comment: "Reset")) {
                        weightManager.resetWeights()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "Done")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            })
        }
    }
}

// 重み付け設定画面
struct WeightSliderRow: View {
    let prefecture: Prefecture
    @ObservedObject var weightManager: WeightManager
    let enabledPrefectures: Set<Prefecture>
    
    private var currentWeight: Double {
        weightManager.weights[prefecture, default: 1.0]
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(prefecture.prefectureName)
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                // 確率表示
                if enabledPrefectures.contains(prefecture) {
                    let probability = weightManager.getProbability(for: prefecture, in: enabledPrefectures)
                    Text("\(probability, specifier: "%.1f")%")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                } else {
                    Text(NSLocalizedString("disabled", comment: "Disabled"))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            HStack {
                // 重み値表示
                Text(String(format: NSLocalizedString("weight_format", comment: "Weight format"), currentWeight))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // クイック調整ボタン
                HStack(spacing: 4) {
                    Button("-") {
                        weightManager.weights[prefecture] = max(0.1, currentWeight - 0.5)
                    }
                    .font(.caption)
                    .frame(width: 20, height: 20)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                    
                    Button("+") {
                        weightManager.weights[prefecture] = min(10.0, currentWeight + 0.5)
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
                    set: { weightManager.weights[prefecture] = $0 }
                ),
                in: 0.1...10.0,
                step: 0.1
            )
            .accentColor(enabledPrefectures.contains(prefecture) ? .blue : .gray)
            .disabled(!enabledPrefectures.contains(prefecture))
        }
        .padding(.vertical, 4)
        .opacity(enabledPrefectures.contains(prefecture) ? 1.0 : 0.5)
    }
}
