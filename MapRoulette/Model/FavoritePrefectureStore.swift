//
//  FavoritePrefectureStore.swift
//  MapRoulette
//
//  「お気に入り都道府県」の唯一の情報源（保存ストア）。
//  ホームタブの「お気に入りの県」セクションの元データ。県詳細（TourismDetailView）の
//  お気に入りボタンからトグルする。UserDefaults に rawValue 配列で永続化する
//  （VisitedPrefectureStore と同じ方式）。
//
//  関連: [[HomeTab_Renewal_Plan]] R2 / ホームの「お気に入りの県」セクション。
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class FavoritePrefectureStore: ObservableObject {
    static let shared = FavoritePrefectureStore()

    @Published private(set) var favorites: Set<Prefecture> = []

    private let storageKey = "favorite.prefectures"

    init() {
        load()
    }

    // MARK: - 読み込み / 保存

    private func load() {
        guard let rawValues = UserDefaults.standard.array(forKey: storageKey) as? [String] else {
            favorites = []
            return
        }
        favorites = Set(rawValues.compactMap { Prefecture(rawValue: $0) })
    }

    private func persist() {
        UserDefaults.standard.set(favorites.map { $0.rawValue }, forKey: storageKey)
    }

    // MARK: - 更新

    /// お気に入りをトグルする（県詳細のお気に入りボタン用）。
    func toggle(_ prefecture: Prefecture) {
        if favorites.contains(prefecture) {
            favorites.remove(prefecture)
        } else {
            favorites.insert(prefecture)
        }
        persist()
    }

    func isFavorite(_ prefecture: Prefecture) -> Bool {
        favorites.contains(prefecture)
    }
}
