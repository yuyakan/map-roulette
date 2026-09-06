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
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded([TrendGroup])
        case failed(String)
    }

    @Published private(set) var state: LoadState = .idle

    /// 要件A: これより古い updatedAt のグループは表示しない（保守的に 30 日）。
    private let maxAge: TimeInterval = 30 * 24 * 60 * 60

    private var db: Firestore {
        // バッチと同じ名前付き DB を指定（既定の (default) ではない）。
        Firestore.firestore(database: FirebaseBootstrap.databaseId)
    }

    /// `trends` を読み込み、要件Aガードを通したグループ配列を state に反映する。
    func load() async {
        state = .loading
        do {
            let snapshot = try await db.collection("trends").getDocuments()
            let now = Date()
            let groups = snapshot.documents
                .compactMap { Self.decodeGroup(from: $0.data()) }
                .filter { now.timeIntervalSince($0.updatedAt) <= maxAge }   // 要件A
                .filter { !$0.videos.isEmpty }
                .sorted { $0.updatedAt > $1.updatedAt }
            state = .loaded(groups)
        } catch {
            state = .failed(error.localizedDescription)
        }
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
