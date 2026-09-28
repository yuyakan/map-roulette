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
    /// このカードが並ぶ棚の種別（spot / gourmet / cafe）。
    /// スクショ撮影モードで棚に合ったモック画像を選ぶためだけに使う。
    var shelf: String? = nil
    /// 棚のなかでの並び順。スクショ撮影モードで同じ絵が隣り合わないようにする。
    var position: Int? = nil

    /// カード幅（9:16 の縦型。高さは幅 × 16/9 で算出）。
    private let width: CGFloat = 132

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            thumbnail
            title
            channel
        }
        .frame(width: width)
        // カードの矩形全体をタップ領域にする。
        // これが無いと VStack は中身（絵・文字）の乗っている場所しかヒットせず、
        // 行間や短いタイトルの右側の余白を押しても反応しない。
        .contentShape(Rectangle())
    }

    // MARK: - サムネイル（9:16）

    private var thumbnail: some View {
        ZStack(alignment: .topLeading) {
            // キャッシュ対応のサムネ。読み込み済みなら最初のフレームから画像が出るので、
            // 県の切り替わり時にプレースホルダーを挟まずに済む（スクロールのカクつき対策）。
            CachedThumbnail(urlString: video.thumbnailUrl,
                            screenshotShelf: shelf,
                            screenshotPosition: position) {
                placeholder
            }
            .frame(width: width, height: width * 16 / 9)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // 要件D: サムネ隅の帰属アイコンは置かない。出典はフッターの
            // 「Developed with YouTube」ロゴ＋各カードのチャンネル名表示で担保する。

            // 尺表示（右下）
            //
            // 【重要】.padding は .frame の「前」に置くこと。
            // .frame(サムネと同じ高さ) の後に .padding(6) を付けると、パディングは
            // 外側に足されるのでこのオーバーレイだけが上下 6pt ずつ大きくなる。
            // SwiftUI の .frame はクリップしないため、はみ出した透明領域が
            // 下に重なったまま残り、カードの Button のヒットテストを奪う。
            // その結果「サムネの上側を押すと反応せず、下側だと開く」という
            // タップ位置依存の壊れ方をする。
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
            .padding(6)
            .frame(width: width, height: width * 16 / 9)
            // 絵の上に乗るだけの装飾。タップはカード全体の Button に通す。
            .allowsHitTesting(false)
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
