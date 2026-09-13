//
//  YouTubeAttribution.swift
//  MapRoulette
//
//  要件D（YouTube 出典・ブランド表示）専用の共通コンポーネント。
//  ホームの出典フッターに付与し、「アプリが YouTube に依存している」こと、
//  「MapRoulette 発のコンテンツではない」ことを明示する。
//
//  ── 規約対応（YouTube API Services Branding Guidelines・一次情報で確認） ──
//  - 自作の「YouTube」テキスト／独自バッジは不可。公式ロゴ画像のみ使用可。
//  - 公式ロゴの色は改変不可（例外: 「Developed with YouTube」ロゴは単色ならOK）。
//  - ロゴはクリック可能で、YouTube コンテンツ or YouTube コンポーネントへ
//    リンクする必要がある。
//
//  出典の担保方針:
//   - ホーム: 下部フッターに公式「Developed with YouTube」ロゴ（本コンポーネント）。
//   - トレンドカード: チャンネル名を必ず表示（サムネ隅の帰属アイコンは置かない）。
//   - 再生画面: 公式埋め込みプレイヤー自体の YouTube ブランド＋チャンネル名で担保。
//
//  アセット（公式ブランドサイトから DL して Assets.xcassets に追加）:
//   - "developed-with-youtube" … 「Developed with YouTube」ロゴ（単色・テンプレート）。
//  画像が未追加でもビルド/実行が壊れないよう、無ければテキストにフォールバックする。
//

import SwiftUI
import UIKit

/// アセットの有無を判定するヘルパー。ロゴ画像が Assets に入っていれば true。
private enum YouTubeBrandAsset {
    static let developedWithName = "developed-with-youtube"
    static var hasDevelopedWith: Bool { UIImage(named: developedWithName) != nil }
}

/// 出典フッター用の「Developed with YouTube」ロゴ。
/// - Note: アプリ全体が YouTube 機能に依存することを示す、ガイドライン推奨のロゴ。
///   単色ロゴなので `.template` レンダリングで前景色を場面に合わせられる。
/// - Important: タップで YouTube（youtube.com）へリンクする（リンク必須要件）。
struct DevelopedWithYouTubeBadge: View {
    /// ロゴの高さ（pt）。幅はアスペクト比で自動。
    var height: CGFloat = 18
    /// 単色ロゴの前景色（背景に合わせて調整）。
    var tint: Color = .secondary
    /// タップ先。既定は YouTube トップ。
    var linkURL: URL = URL(string: "https://www.youtube.com")!

    var body: some View {
        Link(destination: linkURL) { logo }
            .accessibilityLabel(Text(NSLocalizedString("home.trend.source.developed", comment: "")))
    }

    @ViewBuilder
    private var logo: some View {
        if YouTubeBrandAsset.hasDevelopedWith {
            // 公式「Developed with YouTube」ロゴ（単色・テンプレート）。
            Image(YouTubeBrandAsset.developedWithName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: height)
                .foregroundColor(tint)
        } else {
            // 画像未追加時の中立プレースホルダ（テキスト出典・自作ロゴにはしない）。
            Text(NSLocalizedString("home.trend.source.developed", comment: ""))
                .font(.system(size: height * 0.72, weight: .semibold))
                .foregroundColor(tint)
        }
    }
}

#Preview {
    DevelopedWithYouTubeBadge()
        .padding()
}
