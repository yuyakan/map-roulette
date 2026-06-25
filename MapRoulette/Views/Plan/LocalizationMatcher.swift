//
//  LocalizationMatcher.swift
//  MapRoulette
//
//  端末の言語を切り替えても、保存済みプラン項目（PlanItem.name に
//  「保存時の言語の表示名」を持つ）から元データを引き当てられるようにする。
//
//  元データの name は NSLocalizedString 由来のため、言語を変えると変化する。
//  保存値と現在の表示名が「同じローカライズキーに由来するか」を、
//  全対応言語の Localizable.strings を逆引きして判定する。
//

import Foundation

/// 全対応言語の Localizable.strings を読み込み、
/// 「ローカライズ後の文字列 → それを生むキー集合」を作る逆引きインデックス。
/// これにより、ある文字列がどの言語の表示名であっても、対応するキー集合を得られる。
enum LocalizationMatcher {

    /// アプリが対応する言語コード（*.lproj に対応）。
    private static let languageCodes = ["ja", "en", "ko", "zh-Hans", "zh-Hant", "zh-HK"]

    /// 「ローカライズ後の文字列」→「その文字列を生むキー集合」。
    /// 全言語ぶんを統合して 1 つの辞書にする（同じ文字列が複数キー・複数言語で現れうるため集合）。
    private static let valueToKeys: [String: Set<String>] = {
        var result: [String: Set<String>] = [:]
        for code in languageCodes {
            guard let url = Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: code),
                  let dict = NSDictionary(contentsOf: url) as? [String: String] else {
                continue
            }
            for (key, value) in dict {
                result[value, default: []].insert(key)
            }
        }
        return result
    }()

    /// 指定文字列に対応するローカライズキー集合（どの言語の表示名でも引ける）。
    private static func keys(for value: String) -> Set<String> {
        valueToKeys[value] ?? []
    }

    /// `saved`（保存時の言語の表示名）と `current`（現在の言語での候補の表示名）が、
    /// 同一のローカライズキーに由来するか。言語非依存に「同じ項目か」を判定する。
    /// まず単純一致（同一言語のまま等）を見て、外れたらキー集合の共有で判定する。
    static func isSameLocalizedItem(saved: String, current: String) -> Bool {
        if saved == current { return true }
        let savedKeys = keys(for: saved)
        guard !savedKeys.isEmpty else { return false }
        return !savedKeys.isDisjoint(with: keys(for: current))
    }
}
