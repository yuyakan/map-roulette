//
//  Banner.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/27.
//

import SwiftUI
import GoogleMobileAds

/// コンテンツ内に埋め込むインライン型アダプティブバナー広告。
///
/// 固定サイズ(320x50)より表示面積が広く広告在庫が増えるため、
/// AdMob が推奨する形式であり収益(eCPM)が上がりやすい。
///
/// アンカー型は `rootViewController` 経由で画面全幅に描画されてしまい
/// 左右に余白を付けられないため、コンテンツ内に余白付きで配置する用途には
/// インライン型を使う。インライン型は指定幅に収まり、高さは可変なので
/// ロード完了後に実サイズを受け取って高さを確定する。
struct AdaptiveBannerAdView: View {
    /// 使用する広告ユニット ID。既定はセクション間バナー用。
    /// 詳細画面では `adUnitIdDetailBanner` を渡して収益を分けて計測する。
    var adUnitID: String = adUnitIdBanner
    /// バナー左右に確保する余白。
    var horizontalPadding: CGFloat = 8
    /// バナー上下に確保する余白。前後のセクションと詰まらないようにする。
    var verticalPadding: CGFloat = 8

    /// ロード完了後に確定するバナー高さ。初期は幅から算出した推定値。
    @State private var height: CGFloat
    /// 取得に失敗したか。失敗したら枠ごと畳んで空白を残さない。
    /// 取得できるまでは推定高さで枠を確保しておく（BannerView を正しいサイズで生成するため）。
    @State private var didFail = false

    init(
        adUnitID: String = adUnitIdBanner,
        horizontalPadding: CGFloat = 8,
        verticalPadding: CGFloat = 8
    ) {
        self.adUnitID = adUnitID
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        let width = UIScreen.main.bounds.width - horizontalPadding * 2
        let estimated = currentOrientationInlineAdaptiveBanner(width: width).size.height
        _height = State(initialValue: estimated > 0 ? estimated : 50)
    }

    private var adWidth: CGFloat {
        UIScreen.main.bounds.width - horizontalPadding * 2
    }

    var body: some View {
        // スクショ撮影用に広告を枠ごと非表示にする（余白も出さない）。
        if adsHidden {
            EmptyView()
        } else if didFail {
            // 取得に失敗したら枠ごと消して空白を残さない。
            EmptyView()
        } else {
            // 取得できるまでは推定高さで枠を確保する（BannerView を正しいサイズで
            // 生成するため）。成功したら実サイズに合わせ、失敗したら枠ごと畳む。
            InlineBannerContainer(
                width: adWidth,
                adUnitID: adUnitID,
                onHeightChange: { newHeight in
                    if newHeight > 0, abs(newHeight - height) > 1 {
                        height = newHeight
                    }
                    didFail = false
                },
                onFailure: {
                    didFail = true
                }
            )
            .frame(height: height)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
    }
}

/// インライン型 `BannerView` を SwiftUI に載せるコンテナ。
/// ロード完了時に実際の高さを親へ通知する。
private struct InlineBannerContainer: UIViewRepresentable {
    let width: CGFloat
    let adUnitID: String
    let onHeightChange: (CGFloat) -> Void
    /// 取得に失敗したときの通知。呼び出し側で枠を畳んで空白を消すために使う。
    let onFailure: () -> Void

    func makeUIView(context: Context) -> BannerView {
        let adSize = currentOrientationInlineAdaptiveBanner(width: width)
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onHeightChange: onHeightChange, onFailure: onFailure)
    }

    class Coordinator: NSObject, BannerViewDelegate {
        let onHeightChange: (CGFloat) -> Void
        let onFailure: () -> Void

        init(onHeightChange: @escaping (CGFloat) -> Void, onFailure: @escaping () -> Void) {
            self.onHeightChange = onHeightChange
            self.onFailure = onFailure
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            let h = bannerView.adSize.size.height
            DispatchQueue.main.async { self.onHeightChange(h) }
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("Banner failed to load: \(error.localizedDescription)")
            DispatchQueue.main.async { self.onFailure() }
        }
    }
}

/// ミディアムレクタングル(300x250)広告。
///
/// バナー(320x50)より大きく eCPM が高い傾向があるが、画面占有が大きい分
/// 誤クリックのリスクも高い。AdMob 公式ガイドに従い、上下に十分な余白を取り
/// 周囲のタップ要素と明確に離して配置すること。サイズは固定なので高さ確定は不要。
struct MediumRectangleAdView: View {
    /// 使用する広告ユニット ID。既定はセクション間バナー用。
    /// 詳細画面では `adUnitIdDetailBanner` を渡して収益を分けて計測する。
    var adUnitID: String = adUnitIdBanner
    /// 上下に確保する余白。周囲のカード等と誤タップしないよう最低限は確保する。
    var verticalPadding: CGFloat = 8

    /// 取得に失敗したか。失敗したら枠ごと畳んで空白を残さない。
    @State private var didFail = false

    var body: some View {
        // スクショ撮影用に広告を枠ごと非表示にする（余白も出さない）。
        if adsHidden {
            EmptyView()
        } else if didFail {
            // 取得に失敗したら枠ごと消して空白を残さない。
            EmptyView()
        } else {
            // 取得できるまでは 300x250 の枠を確保しておき、失敗したら枠ごと畳む。
            MediumRectangleContainer(
                adUnitID: adUnitID,
                onLoad: { didFail = false },
                onFailure: { didFail = true }
            )
            .frame(width: 300, height: 250)
            .frame(maxWidth: .infinity) // 水平中央に配置
            .padding(.vertical, verticalPadding)
        }
    }
}

private struct MediumRectangleContainer: UIViewRepresentable {
    let adUnitID: String
    /// 取得成功／失敗の通知。呼び出し側で枠を出す・畳むために使う。
    let onLoad: () -> Void
    let onFailure: () -> Void

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeMediumRectangle)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onLoad: onLoad, onFailure: onFailure)
    }

    class Coordinator: NSObject, BannerViewDelegate {
        let onLoad: () -> Void
        let onFailure: () -> Void

        init(onLoad: @escaping () -> Void, onFailure: @escaping () -> Void) {
            self.onLoad = onLoad
            self.onFailure = onFailure
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            DispatchQueue.main.async { self.onLoad() }
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("MediumRectangle failed to load: \(error.localizedDescription)")
            DispatchQueue.main.async { self.onFailure() }
        }
    }
}
