//
//  RecentPrefectureStore.swift
//  MapRoulette
//
//  「最近見た都道府県」の唯一の情報源（保存ストア）。
//  県詳細（TourismDetailView）を開いた瞬間に record(_:) で記録する。
//  ホームタブの「最近見た県」セクションの元データ。
//
//  Visited/Favorite が「集合（Set・順不同）」なのに対し、こちらは順序が意味を持つ:
//   - 最新が先頭（recents[0] が一番最近）
//   - 重複は先頭へ繰り上げ（同じ県を再度開いたら先頭に移動）
//   - 上限 maxCount 件でトリム（古いものから落とす）
//  よって Set ではなく順序付き配列で保持し、UserDefaults に rawValue 配列で永続化する。
//
//  関連: [[HomeTab_Renewal_Plan]] R2 / R3（TourismDetailView.onAppear で記録）。
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class RecentPrefectureStore: ObservableObject {
    static let shared = RecentPrefectureStore()

    /// 最近見た県。先頭が最も最近。
    @Published private(set) var recents: [Prefecture] = []

    /// 保持する最大件数。これを超えたら古いもの（末尾）から落とす。
    private let maxCount = 10
    private let storageKey = "recent.prefectures"

    init() {
        load()
    }

    // MARK: - 読み込み / 保存

    private func load() {
        guard let rawValues = UserDefaults.standard.array(forKey: storageKey) as? [String] else {
            recents = []
            return
        }
        // 保存順（先頭=最近）を保ったままデコード。上限も念のためトリム。
        recents = Array(rawValues.compactMap { Prefecture(rawValue: $0) }.prefix(maxCount))
    }

    private func persist() {
        UserDefaults.standard.set(recents.map { $0.rawValue }, forKey: storageKey)
    }

    // MARK: - 更新

    /// 県を「最近見た」として記録する（県詳細を開いた瞬間に呼ぶ）。
    /// 既にあれば先頭へ繰り上げ、無ければ先頭に追加。上限を超えたら末尾を落とす。
    func record(_ prefecture: Prefecture) {
        if recents.first == prefecture {
            return  // 既に先頭なら何もしない（無駄な保存を避ける）
        }
        recents.removeAll { $0 == prefecture }   // 重複除去
        recents.insert(prefecture, at: 0)         // 先頭へ
        if recents.count > maxCount {
            recents.removeLast(recents.count - maxCount)
        }
        persist()
    }
}
