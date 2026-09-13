//
//  FirebaseBootstrap.swift
//  MapRoulette
//
//  Firebase の起動時初期化（計画書 §4.4）。
//  App の init で 1 回だけ FirebaseApp.configure() を呼ぶためのラッパー。
//
//  ホームタブのトレンド機能は Firestore の名前付き DB `japantripmap-youtube` を読む。
//  DB 名の指定は TrendRepository 側で行う（Firestore.firestore(database:)）。
//  ここは configure だけを担当する。
//

import Foundation
import FirebaseCore

enum FirebaseBootstrap {
    /// バッチが書き込む Firestore の名前付き DB 名。
    /// バッチ（JapanTripMapBatch）の FIRESTORE_DATABASE_ID と必ず一致させること。
    static let databaseId = "japantripmap-youtube"

    private static var configured = false

    /// FirebaseApp を 1 回だけ初期化する。多重呼び出しは無視。
    static func configureIfNeeded() {
        guard !configured else { return }
        // GoogleService-Info.plist が無い環境（テスト等）でクラッシュしないよう防御。
        guard FirebaseApp.app() == nil else {
            configured = true
            return
        }
        FirebaseApp.configure()
        configured = true
    }
}
