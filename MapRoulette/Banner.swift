//
//  Banner.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/27.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {

        let banner = BannerView(adSize: AdSizeBanner)

        banner.adUnitID = prodIdBanner

        banner.rootViewController = UIApplication.shared.connectedScenes

            .compactMap { $0 as? UIWindowScene }

            .first?.windows.first?.rootViewController

        banner.load(Request())

        return banner

    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

}
