//
//  WeightManager.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/19.
//

import SwiftUI
import Combine

class WeightManager: ObservableObject {
    @Published var weights: [Prefecture: Double] = [:]
    
    init() {
        // 初期値として全ての都道府県に重み1.0を設定
        for prefecture in Prefecture.allCases {
            weights[prefecture] = 1.0
        }
    }
    
    // 重み付きランダム選択
    func selectRandomPrefecture(from enabledPrefectures: Set<Prefecture>) -> Prefecture? {
        let validPrefectures = Array(enabledPrefectures.filter { weights[$0, default: 1.0] > 0 })
        guard !validPrefectures.isEmpty else { return nil }
        
        let totalWeight = validPrefectures.reduce(0.0) { sum, prefecture in
            sum + weights[prefecture, default: 1.0]
        }
        
        let randomValue = Double.random(in: 0..<totalWeight)
        var currentWeight = 0.0
        
        for prefecture in validPrefectures {
            currentWeight += weights[prefecture, default: 1.0]
            if randomValue < currentWeight {
                return prefecture
            }
        }
        
        return validPrefectures.last
    }
    
    // 重みをリセット
    func resetWeights() {
        for prefecture in Prefecture.allCases {
            weights[prefecture] = 1.0
        }
    }
    
    // 選択確率を計算
    func getProbability(for prefecture: Prefecture, in enabledPrefectures: Set<Prefecture>) -> Double {
        guard enabledPrefectures.contains(prefecture) else { return 0.0 }
        
        let validPrefectures = Array(enabledPrefectures.filter { weights[$0, default: 1.0] > 0 })
        let totalWeight = validPrefectures.reduce(0.0) { sum, pref in
            sum + weights[pref, default: 1.0]
        }
        
        return totalWeight > 0 ? (weights[prefecture, default: 1.0] / totalWeight) * 100 : 0.0
    }
}
