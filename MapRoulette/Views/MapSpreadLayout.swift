//
//  MapSpreadLayout.swift
//  MapRoulette
//
//  マップタブの「見開き」表示。
//
//  【何をするか】
//  広くて横長の画面（iPhone Duo の内側画面・iPad の横向き）では、県や温泉地をタップしたとき
//  詳細を全画面で覆わず、地図を左ページへ寄せて右ページに詳細を出す。
//  分割位置は iPhone Duo の折り目に合わせるので、本のように開いたガイドブックの見た目になり、
//  少し折った姿勢（ブックポーズ）でも折り目をまたぐ UI が無い。
//
//  【構成】
//  - 見開きの状態（右ページに何を出すか）は IntegratedMapView が持つ。切替帯と同じく、
//    マップを切り替えても左右の配置は崩れない。
//  - 各マップは環境値 `spreadPresenter` を見て、見開きが使えるならそこへ詳細を出し、
//    使えない（iPhone・Duo の外側画面・縦長）なら従来どおり fullScreenCover で開く。
//  - 右ページの詳細は閉じるときに `dismiss()` が効かない（モーダルではない）ので、
//    環境値 `spreadPaneClose` を見て閉じ方を切り替える。
//

import SwiftUI

/// 見開きの右ページに出す詳細。
enum SpreadDetail: Identifiable, Equatable {
    case prefecture(Prefecture)
    case onsen(FixedOnsenItem)
    case nature(FixedNatureSpotItem)

    var id: String {
        switch self {
        case .prefecture(let p): return "prefecture-\(p.rawValue)"
        case .onsen(let o): return "onsen-\(o.id)"
        case .nature(let s): return "nature-\(s.id)"
        }
    }

    static func == (lhs: SpreadDetail, rhs: SpreadDetail) -> Bool { lhs.id == rhs.id }

    /// 右ページに出ている県（地図上で強調するため）。
    var prefecture: Prefecture? {
        if case .prefecture(let p) = self { return p }
        return nil
    }
}

/// マップが見開きを使うための窓口。IntegratedMapView が環境値として配る。
struct SpreadPresenter {
    /// 見開きが使える画面か（regular 幅かつ横長）。false なら従来の全画面表示を使う。
    var isAvailable: Bool = false
    /// いま右ページに出ている詳細。
    var current: SpreadDetail? = nil
    /// 右ページに詳細を出す（すでに開いていれば中身だけ入れ替える）。
    var present: (SpreadDetail) -> Void = { _ in }
    /// 右ページを閉じて地図を全幅に戻す。
    var close: () -> Void = {}
}

extension EnvironmentValues {
    @Entry var spreadPresenter = SpreadPresenter()
    /// 見開きの右ページで表示中のときだけ入る「閉じる」処理。nil ならモーダルなので dismiss() で閉じる。
    /// 右ページの最初の画面（県・温泉地・自然スポットの詳細）にだけ入り、そこから進んだ先では nil。
    @Entry var spreadPaneClose: (() -> Void)? = nil
    /// 見開きの右ページの中で次の画面へ進む処理。nil なら右ページの外なので全画面で開く。
    @Entry var spreadPanePush: ((AnyView) -> Void)? = nil
}

/// 右ページの中で進んだ先の画面。NavigationStack のパスに積むため、中身ごとに一意な ID を持たせる。
struct SpreadPaneRoute: Hashable {
    let id = UUID()
    let view: AnyView

    static func == (lhs: SpreadPaneRoute, rhs: SpreadPaneRoute) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - 折り目の位置

enum SpreadFold {
    /// 見開きの分割位置（左ページの幅）。
    ///
    /// iOS 27.1 以降は、画面を仕切る予約領域（Duo の折り目）を取得して、その中央で分ける。
    /// 全開のときは折り目の領域は「非アクティブ」なので `.includeInactive` を付けて問い合わせる。
    /// 縦に走る仕切りが見つからないとき（iPad など）は中央で分ける。
    static func splitX(in geo: GeometryProxy) -> CGFloat {
        let width = geo.size.width
        let fallback = width / 2
        guard #available(iOS 27.1, *) else { return fallback }
        let regions = geo.reservedRegions(kind: .division, options: .includeInactive)
        guard let fold = regions.first(where: { $0.frame.height > $0.frame.width }) else {
            return fallback
        }
        // 極端な位置で分けて片方が潰れないよう、念のため幅の 35〜65% に収める。
        return min(max(fold.frame.midX, width * 0.35), width * 0.65)
    }
}

// MARK: - 右ページ

/// 見開きの右ページ。詳細ビューを iPhone 幅（compact）として描く。
struct SpreadDetailPane: View {
    let detail: SpreadDetail
    let onClose: () -> Void

    var body: some View {
        // 別の県に切り替えたら中身を作り直す（地図の初期位置などは init でしか決まらないため）。
        // 進んだ先の画面（パス）も一緒に捨てる。
        SpreadPaneStack(detail: detail, onClose: onClose)
            .id(detail.id)
        // 右ページの幅は iPhone 1 台ぶん。中の詳細は iPhone 向けのレイアウトで描かせる
        // （regular のままだと写真ヘッダーが高くなりすぎる等、広い画面用の調整が効いてしまう）。
        .environment(\.horizontalSizeClass, .compact)
        .background(Color(.systemBackground).ignoresSafeArea(edges: [.trailing, .bottom]))
        // 左端（地図との境目）と上だけ切る。右端・下端は切らない：iPhone Duo では右端に
        // ステータスバーと縦向きタブバーの列（セーフエリア外）があり、詳細画面の写真・色の
        // ヘッダーや背景はそこまで敷かれる。切ると白い帯が残る。文字やボタンはセーフエリア内のまま。
        .mask(Rectangle().padding(EdgeInsets(top: 0, leading: 0, bottom: -1000, trailing: -1000)))
        // 左ページ（地図）との境目。本のノドのような薄い影で区切る。
        .overlay(alignment: .leading) {
            LinearGradient(colors: [.black.opacity(0.12), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: 8)
                .allowsHitTesting(false)
        }
    }
}

/// 右ページの中身。観光スポット詳細などへは、全画面で覆わずこのスタックに積んで進む。
private struct SpreadPaneStack: View {
    let detail: SpreadDetail
    let onClose: () -> Void
    @State private var path: [SpreadPaneRoute] = []

    var body: some View {
        let pathBinding = $path
        NavigationStack(path: $path) {
            root
                .environment(\.spreadPaneClose, onClose)
                .navigationDestination(for: SpreadPaneRoute.self) { route in
                    // 進んだ先の「閉じる」は右ページ全体ではなく 1 つ戻る（dismiss = pop）。
                    route.view
                        .environment(\.spreadPaneClose, nil)
                }
        }
        .environment(\.spreadPanePush, { view in
            pathBinding.wrappedValue.append(SpreadPaneRoute(view: view))
        })
    }

    @ViewBuilder
    private var root: some View {
        switch detail {
        case .prefecture(let prefecture):
            TourismDetailView(prefecture: prefecture)
        case .onsen(let onsen):
            OnsenDetailView(onsen: onsen)
        case .nature(let spot):
            NatureSpotDetailView(spot: spot)
        }
    }
}

// MARK: - 詳細の開き方（右ページなら進む・それ以外は全画面）

/// `fullScreenCover(item:)` の代わり。見開きの右ページの中なら右ページ内で次の画面へ進み、
/// それ以外（iPhone・Duo の外側画面など）では従来どおり全画面で開く。
///
/// 【なぜ navigationDestination を各所に付けないか】
/// 詳細を開くボタンの多くは横スクロールの Lazy コンテナの中にあり、そこに付けた
/// navigationDestination は SwiftUI に無視される。右ページのスタックに積む方式なら置き場所を選ばない。
private struct SpreadAwareItemPresentation<Item: Identifiable, Destination: View>: ViewModifier {
    @Binding var item: Item?
    let destination: (Item) -> Destination
    @Environment(\.spreadPanePush) private var push

    func body(content: Content) -> some View {
        if let push {
            content.onChange(of: item?.id) { _, _ in
                guard let value = item else { return }
                push(AnyView(destination(value)))
                // 積んだら選択は戻す（同じ項目をもう一度タップしても開けるように）。
                item = nil
            }
        } else {
            content.fullScreenCover(item: $item, content: destination)
        }
    }
}

/// `fullScreenCover(isPresented:)` の代わり。振る舞いは SpreadAwareItemPresentation と同じ。
private struct SpreadAwareFlagPresentation<Destination: View>: ViewModifier {
    @Binding var isPresented: Bool
    let destination: () -> Destination
    @Environment(\.spreadPanePush) private var push

    func body(content: Content) -> some View {
        if let push {
            content.onChange(of: isPresented) { _, presented in
                guard presented else { return }
                push(AnyView(destination()))
                isPresented = false
            }
        } else {
            content.fullScreenCover(isPresented: $isPresented, content: destination)
        }
    }
}

extension View {
    /// 詳細画面を開く。見開きの右ページ内なら右ページの中で進み、それ以外は全画面で開く。
    func detailCover<Item: Identifiable, Destination: View>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Destination
    ) -> some View {
        modifier(SpreadAwareItemPresentation(item: item, destination: content))
    }

    /// 詳細画面を開く（Bool 版）。見開きの右ページ内なら右ページの中で進み、それ以外は全画面で開く。
    func detailCover<Destination: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Destination
    ) -> some View {
        modifier(SpreadAwareFlagPresentation(isPresented: isPresented, destination: content))
    }
}

/// 詳細画面が自前で持っていた NavigationStack の代わり。
/// 右ページの中ではすでに右ページのスタックがあるので包まない（スタックの入れ子は SwiftUI が扱えない）。
struct DetailNavigationContainer<Content: View>: View {
    @Environment(\.spreadPanePush) private var push
    @ViewBuilder let content: Content

    var body: some View {
        if push != nil {
            content
        } else {
            NavigationStack { content }
        }
    }
}

/// 詳細画面の「閉じる」。見開きの右ページなら右ページを閉じ、モーダルなら dismiss する。
@MainActor
func closeDetail(paneClose: (() -> Void)?, dismiss: DismissAction) {
    if let paneClose {
        paneClose()
    } else {
        dismiss()
    }
}
