//
//  TrendCard.swift
//  MapRoulette
//
//  トレンドセクションに並ぶ 1 枚の縦型サムネカード。
//
//  要件D: 出典はチャンネル名を必ず表示することで担保する（サムネ隅の帰属アイコンは置かない。
//         画面全体の出典はホーム下部の「Developed with YouTube」ロゴが担う）。
//  要件E: Shorts に合わせ 9:16 の縦型サムネで表示する。
//

import SwiftUI

struct TrendCard: View {
    let video: TrendVideo

    /// カード幅（9:16 の縦型。高さは幅 × 16/9 で算出）。
    private let width: CGFloat = 132

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            thumbnail
            title
            channel
        }
        .frame(width: width)
    }

    // MARK: - サムネイル（9:16）

    private var thumbnail: some View {
        ZStack(alignment: .topLeading) {
            // キャッシュ対応のサムネ。読み込み済みなら最初のフレームから画像が出るので、
            // 県の切り替わり時にプレースホルダーを挟まずに済む（スクロールのカクつき対策）。
            CachedThumbnail(urlString: video.thumbnailUrl) {
                placeholder
            }
            .frame(width: width, height: width * 16 / 9)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // 要件D: サムネ隅の帰属アイコンは置かない。出典はフッターの
            // 「Developed with YouTube」ロゴ＋各カードのチャンネル名表示で担保する。

            // 尺表示（右下）
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(durationText)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                }
            }
            .frame(width: width, height: width * 16 / 9)
            .padding(6)
        }
        .frame(width: width, height: width * 16 / 9)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color(.secondarySystemBackground))
            .overlay(
                Image(systemName: "play.rectangle")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
            )
    }

    // MARK: - タイトル / チャンネル

    private var title: some View {
        Text(video.displayTitle)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(height: 32, alignment: .top)
    }

    private var channel: some View {
        Text(video.displayChannelTitle)
            .font(.system(size: 10))
            .foregroundColor(.secondary)
            .lineLimit(1)
    }

    private var durationText: String {
        let m = video.durationSeconds / 60
        let s = video.durationSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
