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

/// 食べログ検索のパラメータ。エリアは URL パス、キーワードは sw= に渡す。
struct TabelogSearch {
    /// 食べログのエリアスラッグ（例: "mie", "fukuoka"）。Prefecture.rawValue と一致する。
    let areaSlug: String
    /// フリーワード（グルメ名）。
    let keyword: String
}

// 食べログの多言語版UI（/en/ /cn/ /tw/ /kr/）は掲載店舗が極端に少なく（外国語対応店のみ収録）、
// 日本語版の数百件に対し数件しかヒットしないため使わない。
// 検索は常に日本語版UI（tabelog.com/{area}/）＋日本語のグルメ名で行い、全言語でボタンを表示する。

/// 施設名で YouTube / Instagram を検索するボタンを縦に並べた共通コンポーネント。
/// グルメなど店探しに使える対象では、`tabelog` を渡すと食べログ検索も表示する。
struct SocialSearchButtons: View {
    /// 検索に使うキーワード（基本は施設名）。
    let query: String
    /// 食べログ検索（エリア＋キーワード）。nil のときは食べログボタンを表示しない。
    var tabelog: TabelogSearch? = nil

    var body: some View {
        VStack(spacing: 12) {
            if let tabelog {
                SocialSearchButton(
                    title: NSLocalizedString("social.search_tabelog", comment: "食べログでお店を探す"),
                    systemImage: "fork.knife",
                    color: Color(red: 0.18, green: 0.62, blue: 0.55) // 食べログ用ティール（主ボタンと色を分ける）
                ) {
                    openTabelog(tabelog)
                }
            }

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

    private func openTabelog(_ search: TabelogSearch) {
        let q = search.keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        // エリアを URL パス（例: /mie/）に置くと「全国」が外れ、その県スコープで
        // sw= のフリーワード検索が効く。rstLst が sw= の絞り込みに対応している
        // （rst/rstsearch は sw= が効かず全国全件になる）。
        // 常に日本語版UI（プレフィックスなし）を開く。keyword は日本語のグルメ名。
        if let url = URL(string: "https://tabelog.com/\(search.areaSlug)/rstLst/?sw=\(q)") {
            UIApplication.shared.open(url)
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

/// ブランド色のベタ塗りで、はっきりボタンと分かる外部遷移ボタン。
private struct SocialSearchButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 先頭の白丸アイコンチップ
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(.white, in: Circle())

                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color)
            )
            .shadow(color: color.opacity(0.3), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}
