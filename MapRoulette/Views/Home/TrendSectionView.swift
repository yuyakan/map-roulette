//
//  TrendSectionView.swift
//  MapRoulette
//
//  ホーム内の「トレンド」セクション。エリア×カテゴリのグループごとに、
//  縦型サムネ（TrendCard）を横スクロールで並べる。タップで ShortsFeedView を開く。
//
//  要件C: このセクションは HomeView 内で独自コンテンツと共存する（単独広告画面にしない）。
//  要件D: 見出し／カードに YouTube 出典を明示する。
//

import SwiftUI

struct TrendSectionView: View {
    let groups: [TrendGroup]

    /// タップで開く Shorts フィード（動画配列 + 開始位置）。
    @State private var feed: FeedContext?

    var body: some View {
        // セクション見出し（要件D: 出典明示）は HomeView 側に一元化しているため
        // ここでは持たない。グループ行のみを縦に並べる。
        VStack(alignment: .leading, spacing: 20) {
            ForEach(groups) { group in
                groupRow(group)
            }
        }
        .fullScreenCover(item: $feed) { ctx in
            ShortsFeedView(videos: ctx.videos, startIndex: ctx.startIndex)
        }
    }

    // MARK: - グループ 1 行（見出し + 横スクロールのカード）

    private func groupRow(_ group: TrendGroup) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.displayTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(group.videos.enumerated()), id: \.element.id) { index, video in
                        Button {
                            feed = FeedContext(videos: group.videos, startIndex: index)
                        } label: {
                            TrendCard(video: video)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    /// fullScreenCover(item:) 用のコンテキスト。
    private struct FeedContext: Identifiable {
        let id = UUID()
        let videos: [TrendVideo]
        let startIndex: Int
    }
}
