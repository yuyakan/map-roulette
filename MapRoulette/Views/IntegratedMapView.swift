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
    // どのマップを実際にマウントするか（重い再構築を伴う）
    @State private var mapMode: MapMode = .prefecture
    // 下線の表示位置だけを司る状態（軽い）。タップ時に即アニメーションさせる。
    @State private var underlineMode: MapMode = .prefecture

    var body: some View {
        // マップを全画面で敷き、その最前面に帯を1つだけ重ねる。
        // 帯はコンテナが保持するのでマップ切替で差し替わらない → 下線がスライドできる。
        // 詳細画面は各マップが fullScreenCover で開くのでウインドウ全体を覆い、
        // 帯・下タブの上に出る（真の全画面）。帯を隠す配線は不要。
        ZStack(alignment: .top) {
            // 選択中のマップ（各自 NavigationStack を持つ。isIntegrated=true で
            // 帯ぶんの上部余白を確保するが、帯自体は描画しない）
            switch mapMode {
            case .prefecture:
                JapanMapView(isIntegrated: true)
            case .onsen:
                OnsenMapView(isIntegrated: true)
            case .nature:
                NatureSpotMapView(isIntegrated: true)
            }

            // 帯（1つだけ。マップ切替では作り直されない）
            MapModeBand(underlineMode: $underlineMode, onSelect: select(_:))
        }
    }

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
