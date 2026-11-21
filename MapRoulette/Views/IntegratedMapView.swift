//
//  IntegratedMapView.swift
//  MapRoulette
//
//  都道府県・温泉・自然の3マップを1タブに統合するコンテナ。
//  切替帯（MapModeBand）はこのコンテナが「1つだけ」保持し、
//  マップ（各自 NavigationStack）の最前面に ZStack オーバーレイとして重ねる。
//  こうすることで:
//   - 帯がマップ切替で差し替わらないので下線がスライドアニメーションできる
//   - VStack で NavigationStack を縦分割しないので詳細画面の全画面プッシュが壊れない
//

import SwiftUI

/// 統合タブ内で切り替えるマップの種類
enum MapMode: Int, CaseIterable {
    case prefecture
    case onsen
    case nature

    /// 切替帯に表示するローカライズ済みラベル（既存のタブ用キーを再利用）
    var title: String {
        switch self {
        case .prefecture:
            return NSLocalizedString("tab.prefecture", comment: "")
        case .onsen:
            return NSLocalizedString("tab.onsen", comment: "")
        case .nature:
            return NSLocalizedString("tab.nature", comment: "")
        }
    }
}

/// 切替帯の高さ。IntegratedMapView のオーバーレイと各マップの上部余白で共有する。
let mapModeBandHeight: CGFloat = 44

struct IntegratedMapView: View {
    /// regular 幅か（見開きの判定と、iPad の上に浮くタブバーの判定に使う）。
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // どのマップを実際にマウントするか（重い再構築を伴う）
    @State private var mapMode: MapMode = .prefecture
    // 下線の表示位置だけを司る状態（軽い）。タップ時に即アニメーションさせる。
    @State private var underlineMode: MapMode = .prefecture

    /// このタブが受け取っている上のセーフエリア。iPhone Duo では 0 になる（minimumTopSafeArea と同じ理由で補う）。
    @State private var safeTop: CGFloat = 0

    var body: some View {
        content
            // 上のセーフエリアを測る（帯とマップを下げる量 minimumTopExtra に使う）。
            .background {
                Color.clear.onGeometryChange(for: CGFloat.self, of: { $0.safeAreaInsets.top }) { safeTop = $0 }
            }
    }

    private var content: some View {
        // 見開き（Duo の内側画面・iPad 横向き）では、県や温泉地の詳細を右ページに出す。
        // iPad では右ページを上に浮くタブバーの下から始める。
        SpreadContainer(paneTopInset: bandTopInset) {
            mapPage
                // マップを切り替えたら右ページは閉じる（温泉マップで県詳細が残るのを防ぐ）。
                .modifier(CloseSpreadOnChange(value: mapMode))
        }
    }

    /// 左ページ（見開きでないときは全幅）。マップと切替帯。
    private var mapPage: some View {
        // マップを全面に敷き、その最前面に帯を1つだけ重ねる。
        // 帯はコンテナが保持するのでマップ切替で差し替わらない → 下線がスライドできる。
        // 詳細画面は、見開きが使えないときは各マップが fullScreenCover で開くので
        // ウインドウ全体を覆い、帯・下タブの上に出る（真の全画面）。
        ZStack(alignment: .top) {
            // 選択中のマップ（各自 NavigationStack を持つ。isIntegrated=true で
            // 帯ぶんの上部余白を確保するが、帯自体は描画しない）
            // iPad では帯をタブバーぶん下げているので、余白もその分だけ増やす。
            switch mapMode {
            case .prefecture:
                JapanMapView(isIntegrated: true, extraTopInset: bandTopInset + minimumTopExtra)
            case .onsen:
                OnsenMapView(isIntegrated: true, extraTopInset: bandTopInset + minimumTopExtra)
            case .nature:
                NatureSpotMapView(isIntegrated: true, extraTopInset: bandTopInset + minimumTopExtra)
            }

            // 帯（1つだけ。マップ切替では作り直されない）
            //
            // iPad（regular 幅）では TabView のタブバーがコンテンツの上に浮くので、
            // 帯を素の最上部に置くとタブバーと重なって両方とも押せなくなる。
            // タブバーぶんだけ下げて避ける。iPhone はタブバーが下にあるので 0。
            MapModeBand(underlineMode: $underlineMode, onSelect: select(_:))
                .padding(.top, bandTopInset + minimumTopExtra)
        }
    }

    /// 帯を下げる量。iPad の上部に浮くタブバーを避けるためだけに使う（iPadFloatingTabBarInset 参照）。
    private var bandTopInset: CGFloat {
        iPadFloatingTabBarInset(horizontalSizeClass)
    }

    /// 上のセーフエリアが足りないとき（iPhone Duo）に帯とマップを下げる量。最低 20pt 空ける。
    /// 各マップは自前の NavigationStack を持ち、外から足した余白が中まで伝わらないので、
    /// minimumTopSafeArea は使わず、帯とマップの両方に同じ量を直接足す。
    private var minimumTopExtra: CGFloat { max(0, 20 - safeTop) }

    /// 帯タップ時の処理。下線はアニメーション付きで即移動し、
    /// マップ本体の差し替え（重い）は次のランループへ遅延＆アニメーション無しで行う。
    /// これにより下線スライドのフレームと重いマップ再構築が競合せず、カクつきを防ぐ。
    private func select(_ mode: MapMode) {
        guard mode != underlineMode else { return }
        // 1. 下線だけ先にバネ式でスライド開始
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            underlineMode = mode
        }
        // 2. マップの差し替えは次のランループへ。アニメーションに乗せない。
        DispatchQueue.main.async {
            var tx = Transaction()
            tx.disablesAnimations = true
            withTransaction(tx) {
                mapMode = mode
            }
        }
    }
}

/// 値が変わったら見開きの右ページを閉じる（SpreadContainer の内側で使う）。
private struct CloseSpreadOnChange<Value: Equatable>: ViewModifier {
    let value: Value
    @Environment(\.spreadPresenter) private var spread

    func body(content: Content) -> some View {
        content.onChange(of: value) { _, _ in spread.close() }
    }
}

/// 統合タブ内でマップを切り替える帯。文字のみ・選択中はセル幅いっぱいのオレンジ下線。
/// 下線は「常に1本」だけ描き、選択インデックスに応じて offset で移動させる。
/// この帯は IntegratedMapView が1つだけ保持し、マップの最前面に重ねるため、
/// マップ切替で作り直されず、下線 offset がバネ式で補間されて滑らかにスライドする。
struct MapModeBand: View {
    /// 下線の表示位置を決める状態（マップの実マウント状態とは分離されている）
    @Binding var underlineMode: MapMode
    /// タップされたモードを親に通知する
    let onSelect: (MapMode) -> Void

    // 下線の左右インセット（セル幅からこの分だけ内側に縮める）
    private let underlineInset: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            let count = CGFloat(MapMode.allCases.count)
            let cellWidth = geo.size.width / count
            let selectedIndex = CGFloat(underlineMode.rawValue)

            VStack(spacing: 4) {
                // ラベル行（全セル等幅）
                HStack(spacing: 0) {
                    ForEach(MapMode.allCases, id: \.self) { mode in
                        Button {
                            onSelect(mode)
                        } label: {
                            Text(mode.title)
                                .font(.system(size: 15, weight: underlineMode == mode ? .semibold : .regular))
                                .foregroundColor(underlineMode == mode ? PlanTheme.primary : .gray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // 下線（常に1本。offset で選択セルの位置へ移動）
                // 祭・イベントヘッダーと同じブランドグラデーションで塗る
                Rectangle()
                    .fill(PlanTheme.brandGradient)
                    .frame(width: cellWidth - underlineInset * 2, height: 2)
                    .offset(x: selectedIndex * cellWidth + underlineInset)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(height: mapModeBandHeight)
        .background(Color(.systemBackground))
    }
}
