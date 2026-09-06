//
//  YouTubeAttribution.swift
//  MapRoulette
//
//  要件D（YouTube 出典・ブランド表示）専用の共通コンポーネント。
//  すべてのトレンドカード・再生画面に付与し、「YouTube が出典」であること、
//  「MapRoulette 発のコンテンツではない」ことを明示する。
//
//  YouTube Branding Guidelines に沿い、赤地に「YouTube」文字＋再生アイコンで表現。
//  （ロゴ画像アセットは P3 で正式版に差し替え予定。ここでは SF Symbol で代替。）
//

import SwiftUI

/// 小型の「YouTube」バッジ。カードの隅などに重ねて使う。
struct YouTubeBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 11, weight: .bold))
            Text("YouTube")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color(red: 1.0, green: 0.0, blue: 0.0))
        .clipShape(Capsule())
        .accessibilityLabel(Text(NSLocalizedString("home.trend.source.youtube", comment: "")))
    }
}

/// 「YouTubeで見る」導線ラベル。再生画面下部などで使用。
struct WatchOnYouTubeLabel: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 14, weight: .bold))
            Text(NSLocalizedString("home.trend.watch.youtube", comment: "YouTubeで見る"))
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(red: 1.0, green: 0.0, blue: 0.0))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 16) {
        YouTubeBadge()
        WatchOnYouTubeLabel()
    }
    .padding()
}
