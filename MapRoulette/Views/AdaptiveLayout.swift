//
//  AdaptiveLayout.swift
//  MapRoulette
//
//  画面サイズへの追従（iPhone / iPad / iPhone Duo）に使う共通部品。
//
//  【方針】
//  iPhone Duo は開閉でアプリの大きさがその場で変わり、内側画面では Info.plist の
//  縦固定も効かない。そのためレイアウトは「端末が何か」「画面の向き」ではなく、
//  **置かれたコンテナの大きさと size class** だけで決める。
//  - `UIScreen.main` / `UIDevice.current.orientation` / `userInterfaceIdiom` でレイアウトを分岐しない
//    （例外は iPad だけのシステム表示を避けるとき。IntegratedMapView の bandTopInset）
//  - `horizontalSizeClass == .regular` を「iPad」と読み替えない（Duo の内側画面も regular）
//

import SwiftUI

enum AdaptiveGrid {
    /// カード（写真タイル・祭りカードなど）のグリッド列。
    ///
    /// 列数は幅から自動で決まる。iPhone では従来どおり 2 列、
    /// iPad や iPhone Duo の内側画面のように広いときは列が増える。
    /// 最小幅 150pt は、幅の狭い iPhone（約 320pt の表示幅）でも 2 列を保てる値。
    static func cardColumns(spacing: CGFloat = 12) -> [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: spacing)]
    }
}

/// 広い画面（regular 幅）で本文が横に伸びすぎないよう、読みやすい最大幅で中央に寄せる。
///
/// compact 幅（iPhone・Duo の外側画面）では何もしない。
/// 写真ヘッダーなど「端まで敷きたいもの」には付けず、本文のまとまりにだけ付けること。
private struct ReadableContentWidth: ViewModifier {
    let maxWidth: CGFloat
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

extension View {
    /// regular 幅のときだけ本文を `maxWidth` 以内に収めて中央寄せにする。
    func readableContentWidth(_ maxWidth: CGFloat = 720) -> some View {
        modifier(ReadableContentWidth(maxWidth: maxWidth))
    }
}

/// 上側の余白を最低 `minimum` だけ確保する。
///
/// iPhone Duo は時計などのステータスバーが画面の右上の角にあるので、上のセーフエリアが 0 になる。
/// 普通の iPhone ではステータスバーのぶん自然に空いていた余白が無くなり、各タブの上タブや
/// カードが画面の上端に張り付く。足りないぶんだけ足すので、上のセーフエリアが十分ある端末では何も変わらない。
private struct MinimumTopSafeArea: ViewModifier {
    let minimum: CGFloat
    /// このビューが受け取っている上のセーフエリア（足す前の値）。
    @State private var currentTop: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: max(0, minimum - currentTop))
            }
            // 背景は safeAreaInset の外側にあるので、足す前の値を測れる。
            .background {
                Color.clear.onGeometryChange(for: CGFloat.self, of: { $0.safeAreaInsets.top }) { top in
                    currentTop = top
                }
            }
    }
}

extension View {
    /// 上側の余白を最低 `minimum` だけ確保する（iPhone Duo のように上のセーフエリアが無い画面用）。
    func minimumTopSafeArea(_ minimum: CGFloat = 20) -> some View {
        modifier(MinimumTopSafeArea(minimum: minimum))
    }
}
