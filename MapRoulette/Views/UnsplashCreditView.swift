//
//  UnsplashCreditView.swift
//  MapRoulette
//
//  Unsplash API ガイドラインで required の撮影者・Unsplash クレジット表示。
//  「Photo by [撮影者] on Unsplash」形式で、撮影者名と Unsplash をそれぞれ
//  utm パラメータ付きのリンクにする。
//

import SwiftUI

struct UnsplashCreditView: View {
    let photo: UnsplashPhoto
    /// 暗い背景（全画面表示）の上に置くときは true にして文字色を明るくする。
    var onDark: Bool = false

    @Environment(\.openURL) private var openURL

    private var mutedColor: Color { onDark ? .white.opacity(0.85) : .secondary }
    private var linkColor: Color { onDark ? .white : .accentColor }

    var body: some View {
        HStack(spacing: 0) {
            Text("Photo by ")
                .foregroundColor(mutedColor)
            Text(photo.user.name)
                .foregroundColor(linkColor)
                .underline()
                .onTapGesture {
                    if let url = photo.photographerURL { openURL(url) }
                }
            Text(" on ")
                .foregroundColor(mutedColor)
            Text("Unsplash")
                .foregroundColor(linkColor)
                .underline()
                .onTapGesture {
                    if let url = photo.unsplashURL { openURL(url) }
                }
        }
        .font(.caption2)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Photo by \(photo.user.name) on Unsplash")
    }
}
