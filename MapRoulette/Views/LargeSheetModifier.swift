//
//  LargeSheetModifier.swift
//  MapRoulette
//
//  シート（.sheet）の中身に付けて、iPad で小さく表示されるフォームシートを
//  大きめ（ページサイズ）にするためのヘルパー。
//  presentationSizing は iOS 18 以降の API なので、iOS 17 では従来どおりの
//  サイズにフォールバックする（何もしない）。
//

import SwiftUI

extension View {
    /// シートの中身に付けると、iOS 18 以降で `.presentationSizing(.page)` を適用し、
    /// iPad でも大きく表示する。iOS 17 では従来のサイズのまま。
    @ViewBuilder
    func largeSheet() -> some View {
        if #available(iOS 18, *) {
            self.presentationSizing(.page)
        } else {
            self
        }
    }
}
