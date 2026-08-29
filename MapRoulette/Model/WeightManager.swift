//
//  WeightManager.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/19.
//

import SwiftUI
import Combine

class WeightManager: ObservableObject {
    @Published var weights: [Prefecture: Double] = [:] {
        didSet {
            saveWeights()
        }
    }

    // UserDefaults 保存用キー
    private static let storageKey = "roulette.weights"

    private var isLoading = false

    init() {
        loadWeights()
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

    // MARK: - 永続化

    // UserDefaults へ保存（rawValue をキーにした辞書として保存）
    private func saveWeights() {
        guard !isLoading else { return }
        let encoded = Dictionary(uniqueKeysWithValues: weights.map { ($0.key.rawValue, $0.value) })
        UserDefaults.standard.set(encoded, forKey: Self.storageKey)
    }

    // UserDefaults から読み込み（保存がなければ全て 1.0）
    private func loadWeights() {
        isLoading = true
        defer { isLoading = false }

        var loaded: [Prefecture: Double] = [:]
        // 初期値として全ての都道府県に重み1.0を設定
        for prefecture in Prefecture.allCases {
            loaded[prefecture] = 1.0
        }

        if let stored = UserDefaults.standard.dictionary(forKey: Self.storageKey) as? [String: Double] {
            for (rawValue, weight) in stored {
                if let prefecture = Prefecture(rawValue: rawValue) {
                    loaded[prefecture] = weight
                }
            }
        }

        weights = loaded
    }
}
