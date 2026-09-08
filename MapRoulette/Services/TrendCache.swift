//
//  TrendCache.swift
//  MapRoulette
//
//  トレンド（Shorts）のローカルキャッシュと鮮度（TTL）判定。
//
//  目的（取得の最適化）:
//  - バッチ（JapanTripMapBatch）は毎日 06:00 JST に 1 回だけ Firestore を更新する。
//    よってアプリも「1 日 1 回」だけ取得すれば十分で、それ以上は Firestore を叩く必要がない。
//  - 起動時はまずキャッシュを即表示し（オフライン・低速回線でも速い）、
//    直近の更新境界（毎朝 06:00 JST）をまたいでいる時だけ Firestore を再取得する。
//  - 取得に失敗してもキャッシュは保持し、次回や手動更新で再取得できるようにする。
//

import Foundation

enum TrendCache {
    /// バッチ更新後にアプリが再取得してよくなる「1 日 1 回の更新境界」時刻（JST の時）。
    /// バッチ(GitHub Actions)は 04:00 JST 目標で走るが、スケジュール遅延で書き込み完了が
    /// 数時間ずれ込むことがある（公式仕様・保証なし）。この境界を書き込み完了より前に置くと、
    /// 遅延中の古いデータを取得して lastFetchAt を更新してしまい、その日は新データを取り逃す。
    /// そのため遅延を吸収できる 8 時に設定する（バッチ側 cron のコメントと対応）。
    static let refreshHourJST = 8

    private static let lastFetchKey = "trend.lastFetchAt"
    private static let cacheFileName = "trend_cache.json"

    // MARK: - キャッシュファイルの場所

    private static var cacheURL: URL? {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        // Application Support は初回に存在しないことがあるので作成しておく。
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(cacheFileName)
    }

    // MARK: - 読み書き

    /// 保存済みのトレンドを読み込む（無ければ nil）。
    static func load() -> [TrendGroup]? {
        guard let url = cacheURL, let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode([TrendGroup].self, from: data)
    }

    /// トレンドを保存し、取得時刻を記録する。
    static func save(_ groups: [TrendGroup], fetchedAt: Date = Date()) {
        guard let url = cacheURL, let data = try? JSONEncoder().encode(groups) else { return }
        try? data.write(to: url, options: .atomic)
        UserDefaults.standard.set(fetchedAt, forKey: lastFetchKey)
    }

    /// 最後に取得した時刻（無ければ nil）。
    static var lastFetchAt: Date? {
        UserDefaults.standard.object(forKey: lastFetchKey) as? Date
    }

    // MARK: - 鮮度判定

    /// 再取得すべきか。
    /// 「前回取得時刻が、直近の更新境界（毎朝 refreshHourJST 時）より前」なら true。
    /// = 前回取得以降にバッチ更新が挟まっていれば取得、そうでなければキャッシュで足りる。
    static func shouldRefresh(now: Date = Date()) -> Bool {
        guard let last = lastFetchAt else { return true }   // 一度も取得していない
        return last < lastRefreshBoundary(before: now)
    }

    /// `now` から見て直近の「更新境界（今日 or 昨日の refreshHourJST 時 JST）」を返す。
    static func lastRefreshBoundary(before now: Date = Date()) -> Date {
        var cal = Calendar(identifier: .gregorian)
        // JST 固定で境界を計算（端末のタイムゾーンに依存しない）。
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current

        // 今日の refreshHourJST 時（JST）。
        let todayBoundary = cal.date(
            bySettingHour: refreshHourJST, minute: 0, second: 0, of: now
        ) ?? now

        if now >= todayBoundary {
            // 既に今朝の更新時刻を過ぎている → 直近境界は今朝。
            return todayBoundary
        } else {
            // まだ今朝の更新時刻前 → 直近境界は昨日の同時刻。
            return cal.date(byAdding: .day, value: -1, to: todayBoundary) ?? todayBoundary
        }
    }
}
