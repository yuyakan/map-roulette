//
//  TrendRepository.swift
//  MapRoulette
//
//  Firestore `trends` コレクションの読み取り（計画書 §4.3 / §4.5）。
//  バッチ（JapanTripMapBatch）が名前付き DB `japantripmap-youtube` に書き込んだ
//  トレンド（YouTube Shorts）を読むだけ。アプリからの書き込みは行わない（ルールでも write:false）。
//
//  要件A（30日ルール）: updatedAt が古すぎるグループ／動画は表示しない。
//  ここでは保守的に「maxAge（既定30日）より古い updatedAt のグループは除外」する。
//  さらにバッチが毎日更新するため、通常は数時間以内の updatedAt になる。
//

import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore

@MainActor
final class TrendRepository: ObservableObject {
    /// 取得失敗の種別。UI のメッセージ出し分けに使う。
    enum FailureKind: Equatable {
        case network      // 通信不可・オフライン・サーバ到達不可
        case generic      // その他

        /// 表示メッセージ（ローカライズキー）。
        var messageKey: String {
            switch self {
            case .network: return "home.trend.error.network"
            case .generic: return "home.trend.error.generic"
            }
        }
    }

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded([TrendGroup])
        case failed(FailureKind)
    }

    @Published private(set) var state: LoadState = .idle

    /// 要件A: これより古い updatedAt のグループは表示しない（保守的に 30 日）。
    private let maxAge: TimeInterval = 30 * 24 * 60 * 60

    private var db: Firestore {
        // バッチと同じ名前付き DB を指定（既定の (default) ではない）。
        Firestore.firestore(database: FirebaseBootstrap.databaseId)
    }

    /// 画面初回表示時に呼ぶ。キャッシュ優先で、必要なときだけ Firestore を取得する。
    /// - まずキャッシュがあれば即表示（オフライン・低速でも速い）。
    /// - 直近の更新境界（毎朝 06:00 JST）をまたいでいなければ取得しない（1 日 1 回に抑制）。
    /// - またいでいれば取得。失敗してもキャッシュは維持する。
    func load() async {
        // 1) キャッシュを即表示（要件Aガードを通す）。
        if let cached = TrendCache.load() {
            let groups = applyGuards(cached)
            if !groups.isEmpty {
                state = .loaded(groups)
            }
        }

        // 2) 鮮度判定。今日ぶんの更新を既に取得済みならここで終了（Firestore を叩かない）。
        guard TrendCache.shouldRefresh() else {
            if case .idle = state {
                // キャッシュが無い/空だが、境界的には取得不要 → それでも一度は取りに行く。
                await fetchFromServer()
            }
            return
        }

        await fetchFromServer()
    }

    /// 取得失敗時のみ UI の「再試行」ボタンから呼ぶ。取得成功状態では使わせない
    /// （成功時のユーザー起点の再取得は提供しない = 1 日 1 回の自動取得に限定）。
    func retry() async {
        await fetchFromServer()
    }

    /// Firestore から取得してキャッシュを更新する。失敗時はキャッシュ/現状表示を維持。
    private func fetchFromServer() async {
        // キャッシュ表示が無い場合のみ loading を見せる（キャッシュ表示中はちらつかせない）。
        if case .loaded = state {} else { state = .loading }

        do {
            // 集約ドキュメント（trends_bundle/latest）を 1 件だけ読む。
            // これで Firestore 読み取りは「1 回の取得 = 1 読み取り」になる
            // （個別 trends/{area}_{category} を全件読むと 56 読み取りになっていた）。
            let doc = try await db.collection("trends_bundle").document("latest").getDocument()
            let rawGroups = doc.data()?["groups"] as? [[String: Any]] ?? []
            let groups = applyGuards(rawGroups.compactMap { Self.decodeGroup(from: $0) })
            TrendCache.save(groups)
            state = .loaded(groups)
        } catch {
            // 失敗: キャッシュがあれば維持、無ければ失敗表示（種別つき・「再試行」ボタンで再取得可能）。
            if case .loaded = state {
                // 既にキャッシュを表示済み → そのまま維持。
            } else if let cached = TrendCache.load(), !applyGuards(cached).isEmpty {
                state = .loaded(applyGuards(cached))
            } else {
                state = .failed(Self.classify(error))
            }
        }
    }

    /// エラーがネットワーク起因かどうかを判定する。
    private static func classify(_ error: Error) -> FailureKind {
        let ns = error as NSError
        // URLError（オフライン等）
        if ns.domain == NSURLErrorDomain {
            return .network
        }
        // Firestore は到達不可を FIRFirestoreErrorDomain の code=14(unavailable) で返す。
        if ns.domain == "FIRFirestoreErrorDomain" && ns.code == 14 {
            return .network
        }
        return .generic
    }

    /// 要件Aガード + 空グループ除外 + 新しい順ソート。
    private func applyGuards(_ groups: [TrendGroup]) -> [TrendGroup] {
        let now = Date()
        return groups
            .filter { now.timeIntervalSince($0.updatedAt) <= maxAge }   // 要件A
            .filter { !$0.videos.isEmpty }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    // MARK: - デコード（Firestore の辞書 → モデル）

    /// Firestore のドキュメント辞書を TrendGroup に変換。
    /// updatedAt は Firestore Timestamp、videos は辞書配列で来るため手動でデコードする。
    private static func decodeGroup(from data: [String: Any]) -> TrendGroup? {
        guard
            let area = data["area"] as? String,
            let areaKey = data["areaKey"] as? String,
            let category = data["category"] as? String,
            let categoryKey = data["categoryKey"] as? String
        else { return nil }

        let updatedAt: Date
        if let ts = data["updatedAt"] as? Timestamp {
            updatedAt = ts.dateValue()
        } else if let d = data["updatedAt"] as? Date {
            updatedAt = d
        } else {
            return nil   // 要件A: updatedAt が無いデータは信用しない
        }

        let rawVideos = data["videos"] as? [[String: Any]] ?? []
        let videos = rawVideos.compactMap(decodeVideo(from:))

        return TrendGroup(
            area: area,
            areaKey: areaKey,
            category: category,
            categoryKey: categoryKey,
            updatedAt: updatedAt,
            videos: videos
        )
    }

    private static func decodeVideo(from data: [String: Any]) -> TrendVideo? {
        guard
            let videoId = data["videoId"] as? String, !videoId.isEmpty,
            let title = data["title"] as? String
        else { return nil }

        // durationSeconds は Int / Int64 / NSNumber いずれでも来うる。
        let duration: Int
        if let i = data["durationSeconds"] as? Int {
            duration = i
        } else if let n = data["durationSeconds"] as? NSNumber {
            duration = n.intValue
        } else {
            duration = 0
        }

        let thumbnailUrl = data["thumbnailUrl"] as? String
            ?? "https://i.ytimg.com/vi/\(videoId)/hqdefault.jpg"

        return TrendVideo(
            videoId: videoId,
            title: title,
            thumbnailUrl: thumbnailUrl,
            channelTitle: data["channelTitle"] as? String ?? "",
            publishedAt: data["publishedAt"] as? String ?? "",
            durationSeconds: duration,
            isShort: data["isShort"] as? Bool ?? (duration <= 60)
        )
    }
}
