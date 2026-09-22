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
    ///
    /// 一覧・地図・エディタなど「中身が詰まっているシート」に付ける。
    /// iPad の既定はどんな中身でも小さめのフォームシートなので、付けないと
    /// 一覧が数行しか見えず、地図はほとんど操作できない大きさになる。
    @ViewBuilder
    func largeSheet() -> some View {
        if #available(iOS 18, *) {
            self.presentationSizing(.page)
        } else {
            self
        }
    }

    /// 入力欄が数個だけの小さなフォーム用。iPad で中央に収まりのよい大きさにする。
    ///
    /// `presentationDetents` は iPhone 向けの API で iPad ではほぼ無視されるため、
    /// 高さ指定だけでは iPad の見た目を整えられない。`.form` を併せて指定する。
    @ViewBuilder
    func formSheet() -> some View {
        if #available(iOS 18, *) {
            self.presentationSizing(.form)
        } else {
            self
        }
    }
}
