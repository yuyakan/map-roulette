//
//  RouletteSettingsStore.swift
//  MapRoulette
//
//  ルーレット設定（有効な都道府県・表示モード）の永続化を担当する。
//

import Foundation

enum RouletteSettingsStore {
    private static let enabledPrefecturesKey = "roulette.enabledPrefectures"
    private static let displayModeKey = "roulette.displayMode"

    // MARK: - 有効な都道府県

    // 保存（rawValue の配列として保存）
    static func saveEnabledPrefectures(_ prefectures: Set<Prefecture>) {
        let rawValues = prefectures.map { $0.rawValue }
        UserDefaults.standard.set(rawValues, forKey: enabledPrefecturesKey)
    }

    // 読み込み（保存がなければ全都道府県を返す）
    static func loadEnabledPrefectures() -> Set<Prefecture> {
        guard let rawValues = UserDefaults.standard.array(forKey: enabledPrefecturesKey) as? [String] else {
            return Set(Prefecture.allCases)
        }
        let prefectures = rawValues.compactMap { Prefecture(rawValue: $0) }
        return Set(prefectures)
    }

    // MARK: - 表示モード

    // 保存（rawValue として保存）
    static func saveDisplayMode(_ mode: DisplayMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: displayModeKey)
    }

    // 読み込み（保存がなければ .tourism を返す）
    static func loadDisplayMode() -> DisplayMode {
        guard let rawValue = UserDefaults.standard.string(forKey: displayModeKey),
              let mode = DisplayMode(rawValue: rawValue) else {
            return .tourism
        }
        return mode
    }
}
