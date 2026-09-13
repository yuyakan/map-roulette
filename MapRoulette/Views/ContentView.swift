//
//  ContentView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/06.
//


import SwiftUI

struct ContentView: View {
    // タブ選択・画面またぎ遷移の唯一の共有状態（起動時のデフォルトはホーム＝index 2）。
    // 標準 TabView に selection をバインドすることで、iOS 26 では下タブに
    // Liquid Glass の見た目が自動で適用される（自前タブバーでは効かなかった）。
    // tag は従来のタブ番号（0:マップ 1:近く 2:ホーム 3:祭 4:マイプラン）と一致させ、
    // AppRouter 側のロジックには手を入れない。
    @ObservedObject private var router = AppRouter.shared

    // 下タブアイコンの表示サイズ（pt）。標準（約 25pt）より小さくして軽い印象にする。
    // tabItem は SF Symbol へ .font 等でのサイズ指定が効かず、pointSize 指定の
    // UIImage を渡しても標準サイズに再レンダリングされてしまうため、
    // 画像を実際にこのサイズへ描き直して実寸を固定する（tabLabel 参照）。
    private static let tabIconPointSize: CGFloat = 28

    var body: some View {
        TabView(selection: $router.selectedTab) {
            // 統合マップタブ（都道府県・温泉・自然）
            IntegratedMapView()
                .tabItem {
                    tabLabel(NSLocalizedString("tab.map", comment: ""), systemImage: "map")
                }
                .tag(0)

            // 近くのスポットタブ
            NearbyView()
                .tabItem {
                    tabLabel(NSLocalizedString("tab.nearby", comment: ""), systemImage: "location.circle")
                }
                .tag(1)

            // ホームタブ（トレンド / YouTube Shorts）＝真ん中
            HomeView()
                .tabItem {
                    tabLabel(NSLocalizedString("tab.home", comment: ""), systemImage: "house")
                }
                .tag(2)

            // 祭・イベントタブ
            AllFestivalsComparisonView()
                .tabItem {
                    tabLabel(NSLocalizedString("tab.festival", comment: ""), systemImage: "sparkles")
                }
                .tag(3)

            // マイプランタブ
            MyPlansView()
                .tabItem {
                    tabLabel(NSLocalizedString("tab.plan", comment: ""), systemImage: "suitcase.rolling")
                }
                .tag(4)
        }
        .tint(PlanTheme.primary)
    }

    /// 指定サイズに縮小した SF Symbol 画像を使うタブラベル。
    /// tint（選択色）が効くようテンプレート描画にする。
    private func tabLabel(_ title: String, systemImage: String) -> some View {
        return Label {
            Text(title)
        } icon: {
            if let image = Self.tabIcon(systemImage) {
                Image(uiImage: image)
            } else {
                Image(systemName: systemImage)
            }
        }
    }

    /// SF Symbol を tabIconPointSize の実寸に描き直したテンプレート画像を返す。
    /// pointSize 指定だけだと tabItem 側で標準サイズに戻されるため、
    /// アスペクト比を保ったまま tabIconPointSize の正方形に収まるよう実描画でリサイズする。
    private static func tabIcon(_ systemName: String) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: tabIconPointSize)
        guard let symbol = UIImage(systemName: systemName, withConfiguration: config) else { return nil }

        // アスペクト比を保って tabIconPointSize 四方に収める。
        let maxSide = tabIconPointSize
        let ratio = min(maxSide / symbol.size.width, maxSide / symbol.size.height)
        let target = CGSize(width: symbol.size.width * ratio, height: symbol.size.height * ratio)

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let resized = UIGraphicsImageRenderer(size: target, format: format).image { _ in
            symbol.draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.withRenderingMode(.alwaysTemplate)
    }
}
