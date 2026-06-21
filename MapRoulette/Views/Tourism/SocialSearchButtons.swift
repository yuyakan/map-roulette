//
//  SocialSearchButtons.swift
//  MapRoulette
//
//  各詳細画面（グルメ・観光・温泉・祭り）から、
//  施設名で YouTube / Instagram の検索結果を外部アプリ（なければブラウザ）で開く。
//
//  実装方針:
//  - 公開URL（Universal Links）を UIApplication.shared.open で開くだけ。
//    アプリがインストールされていれば各アプリが、なければSafariが開く。
//  - 公式ロゴ画像は使わず SF Symbols + テキストにする（ブランドガイドライン対策）。
//

import SwiftUI
import UIKit

/// 施設名で YouTube / Instagram を検索する2つのボタンを縦に並べた共通コンポーネント。
struct SocialSearchButtons: View {
    /// 検索に使うキーワード（基本は施設名）。
    let query: String

    var body: some View {
        VStack(spacing: 12) {
            SocialSearchButton(
                title: NSLocalizedString("social.search_youtube", comment: "YouTubeで検索"),
                systemImage: "play.rectangle.fill",
                color: .red
            ) {
                openYouTube()
            }

            SocialSearchButton(
                title: NSLocalizedString("social.search_instagram", comment: "Instagramで検索"),
                systemImage: "camera.circle.fill",
                color: .pink
            ) {
                openInstagram()
            }
        }
    }

    private func openYouTube() {
        let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        // YouTube検索結果ページ(/results)はUniversal Links非対応のため https:// だと
        // ブラウザで開いてしまう。まず youtube:// スキームでアプリ起動を試み、
        // 未インストール時のみ Web にフォールバックする。
        if let appURL = URL(string: "youtube://results?search_query=\(q)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = URL(string: "https://www.youtube.com/results?search_query=\(q)") {
            UIApplication.shared.open(webURL)
        }
    }

    private func openInstagram() {
        // ハッシュタグ検索: スペースを除去してタグ化する。
        let tag = query
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "") // 全角スペースも除去
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        if let url = URL(string: "https://www.instagram.com/explore/tags/\(tag)/") {
            UIApplication.shared.open(url)
        }
    }
}

/// 既存の「外部マップで開く」ボタンと揃えた、枠線スタイルの外部遷移ボタン。
private struct SocialSearchButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(color)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundColor(color)
            }
            .padding()
            .background(Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: 1.5)
            )
        }
    }
}
