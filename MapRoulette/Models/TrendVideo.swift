//
//  TrendVideo.swift
//  MapRoulette
//
//  ホームタブ「トレンド機能」の動画メタデータモデル。
//
//  YouTube 規約対応（計画書 §1）:
//  - 要件B: 保持してよいのは videoId とサムネURLだけ。動画本体・音声は一切保存しない。
//  - 要件E: Shorts（≤60秒）のみを対象とし、縦型プレイヤーで再生する。
//
//  P1 ではダミーデータで表示のみ。Firestore からのデコードは P3 で結線する。
//  そのため Codable に準拠し、Firestore のフィールド名にそのまま合わせている。
//

import Foundation

/// トレンド一覧に表示する 1 本の Shorts のメタデータ。
struct TrendVideo: Identifiable, Codable, Hashable {
    /// YouTube の動画 ID（埋め込み再生・サムネ生成に使用）。これと thumbnailUrl 以外は保持しない方針。
    let videoId: String
    /// 動画タイトル。
    let title: String
    /// サムネイル URL。videoId から生成することも可能だが、バッチが返した値をそのまま保持する。
    let thumbnailUrl: String
    /// 投稿チャンネル名（要件D: 出典表記に使用）。
    let channelTitle: String
    /// 投稿日時（ISO 8601 文字列）。
    let publishedAt: String
    /// 尺（秒）。要件E: 60 秒以下のみが保存・表示される。
    let durationSeconds: Int
    /// Shorts（縦型・短尺）フラグ。要件E: 縦型プレイヤー出し分けに使用。
    let isShort: Bool

    /// Identifiable。videoId をそのまま利用。
    var id: String { videoId }

    /// 埋め込みプレイヤー URL。要件B: 公式の埋め込みのみを使用する。
    var embedURL: URL? {
        URL(string: "https://www.youtube.com/embed/\(videoId)")
    }

    /// 「YouTubeで見る」導線用の公開ページ URL（要件D）。
    var watchURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(videoId)")
    }
}
