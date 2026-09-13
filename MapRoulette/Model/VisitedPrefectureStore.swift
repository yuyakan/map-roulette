//
//  VisitedPrefectureStore.swift
//  MapRoulette
//
//  「訪問済み都道府県」の唯一の情報源（保存ストア）。
//  訪問済みは県ごとに 1 つの状態として保持し、後勝ちで上書きする:
//   - 地図タップ … その県の訪問済みを手動でトグル（オン/オフ）
//   - プランを「旅行済み」にする … その瞬間、含まれる県を訪問済みへ追加（オン）
//  どちらも同じ集合を書き換えるため、常に「最後の操作結果」が残る。
//  UserDefaults に rawValue 配列で永続化する（RouletteSettingsStore と同じ方式）。
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class VisitedPrefectureStore: ObservableObject {
    static let shared = VisitedPrefectureStore()

    @Published private(set) var visited: Set<Prefecture> = []

    private let storageKey = "visited.prefectures"

    init() {
        load()
    }

    // MARK: - 読み込み / 保存

    private func load() {
        guard let rawValues = UserDefaults.standard.array(forKey: storageKey) as? [String] else {
            visited = []
            return
        }
        visited = Set(rawValues.compactMap { Prefecture(rawValue: $0) })
    }

    private func persist() {
        UserDefaults.standard.set(visited.map { $0.rawValue }, forKey: storageKey)
    }

    // MARK: - 更新

    /// 県の訪問済みを手動でトグルする（地図タップ用）。
    func toggle(_ prefecture: Prefecture) {
        if visited.contains(prefecture) {
            visited.remove(prefecture)
        } else {
            visited.insert(prefecture)
        }
        persist()
    }

    /// 県を訪問済みにする（オンで上書き）。
    func markVisited(_ prefecture: Prefecture) {
        guard !visited.contains(prefecture) else { return }
        visited.insert(prefecture)
        persist()
    }

    /// 複数県をまとめて訪問済みにする（プランを旅行済みにしたとき用）。
    func markVisited<S: Sequence>(_ prefectures: S) where S.Element == Prefecture {
        let before = visited.count
        visited.formUnion(prefectures)
        if visited.count != before { persist() }
    }

    func isVisited(_ prefecture: Prefecture) -> Bool {
        visited.contains(prefecture)
    }
}
