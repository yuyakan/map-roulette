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

    /// TabView の作り直し用の世代番号。変えると TabView が新しく作られる。
    @State private var tabViewGeneration = 0
    /// 画面サイズが落ち着くのを待ってから作り直すための予約。
    @State private var pendingRebuild: DispatchWorkItem?
    /// 直前の画面サイズ（サイズが変わったときだけ作り直すため）。
    @State private var lastWindowSize: CGSize?

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
        .id(tabViewGeneration)
        .onGeometryChange(for: CGSize.self, of: { $0.size }) { size in
            // 最初の 1 回（起動時）はサイズの「変化」ではないので作り直さない。
            defer { lastWindowSize = size }
            guard let last = lastWindowSize, last != size else { return }
            scheduleTabViewRebuild()
        }
    }

    /// 画面サイズが変わったら（iPhone Duo の開閉・回転）、落ち着いてから TabView を作り直す。
    ///
    /// 【なぜ作り直すか】
    /// iPhone Duo を開閉・回転すると、TabView が表示中のタブの中身へ壊れたセーフエリア
    /// （使える高さ 0、下余白が画面の高さ、横向きなのに上余白 82pt など）を渡したまま戻らなくなり、
    /// 画面が上に潰れたりずれたりする（iOS 27.2 シミュレータで確認。どのタブでも起きる）。
    /// 壊れ方が一定でなく検知しきれないうえ、中身の側で補正しても NavigationStack が壊れた値を
    /// 引き継ぐので直らない。起動直後は毎回正しく計算されるので、サイズが変わったら作り直す。
    /// 壊れた値は変化の直後に遅れて届くため、最後の変化から 0.25 秒待ってから行う。
    /// 選択中のタブは router が持つので保たれる（各タブのスクロール位置などは初期化される）。
    ///
    /// iPad はウインドウサイズを変えるたびに状態が消えるのを避けるため対象外。
    /// 普通の iPhone は縦固定でサイズが変わらないので、実質 iPhone Duo だけで動く。
    private func scheduleTabViewRebuild() {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        pendingRebuild?.cancel()
        let work = DispatchWorkItem { rebuildTabViewWhenNothingPresented() }
        pendingRebuild = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }

    /// 詳細画面などのモーダルが開いている間は作り直さず、閉じるのを待ってから作り直す。
    /// 作り直すとモーダルを出している画面ごと消えるので、開いていた詳細が勝手に閉じてしまうため。
    private func rebuildTabViewWhenNothingPresented() {
        let isPresenting = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .contains { $0.isKeyWindow && $0.rootViewController?.presentedViewController != nil }
        if isPresenting {
            let work = DispatchWorkItem { rebuildTabViewWhenNothingPresented() }
            pendingRebuild = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
        } else {
            tabViewGeneration += 1
        }
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
