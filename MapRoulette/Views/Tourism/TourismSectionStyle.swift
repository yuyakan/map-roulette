//
//  TourismSectionStyle.swift
//  MapRoulette
//
//  県の観光まとめ画面（TourismDetailView）の各セクションで共通利用する
//  見出し・「もっと見る」ボタンのスタイル。詳細画面のデザイン言語に揃える。
//

import SwiftUI

/// セクション見出し（アクセントバー＋アイコン＋タイトル＋サブタイトル）。
/// 詳細画面の sectionHeader と同じ表現で、観光まとめの各セクションを統一する。
struct RichSectionHeader: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let accent: Color
    /// 見出し右側に置くトレーリング要素（フィルターメニューなど）。
    var trailing: AnyView? = nil

    var body: some View {
        HStack(spacing: 12) {
            // アクセントバー
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(accent)
                .frame(width: 4, height: 34)

            // アイコンチップ
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(accent)
                .frame(width: 38, height: 38)
                .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 11, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer(minLength: 0)

            if let trailing {
                trailing
            }
        }
    }
}

/// 「もっと見る」ボタン。セクションのアクセント色のソフト塗りで統一する。
struct LoadMoreButton: View {
    let title: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(accent)
            )
            .shadow(color: accent.opacity(0.3), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}
