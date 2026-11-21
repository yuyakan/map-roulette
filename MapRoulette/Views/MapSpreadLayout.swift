//
//  MapSpreadLayout.swift
//  MapRoulette
//
//  「見開き」表示（全タブ共通）。
//
//  【何をするか】
//  広くて横長の画面（iPhone Duo の内側画面・iPad の横向き）では、カードや県をタップしたとき
//  詳細を全画面で覆わず、タブの画面を左ページへ寄せて右ページに詳細を出す。
//  分割位置は iPhone Duo の折り目に合わせるので、本のように開いたガイドブックの見た目になり、
//  少し折った姿勢（ブックポーズ）でも折り目をまたぐ UI が無い。
//
//  【構成】
//  - 各タブを SpreadContainer で包む。見開きの状態（右ページに何を出すか）はここが持つ。
//  - 詳細を開く側は `detailCover(item:)` を使う。右ページの中なら右ページ内で次へ進み、
//    見開きが使えるなら右ページに出し、使えない（iPhone・Duo の外側画面・縦長）なら全画面で開く。
//  - 右ページは NavigationStack で、最初の詳細も「空の土台の上に積んだ 1 枚目」として出す。
//    こうすると詳細画面の既存の「戻る／✕」（dismiss）がそのまま 1 つ戻る操作になり、
//    土台まで戻ったら右ページを閉じる。詳細画面ごとに閉じ方を分ける必要が無い。
//

import SwiftUI

/// 見開きの右ページに出す詳細。
enum SpreadDetail: Identifiable, Equatable {
    case prefecture(Prefecture)
    case onsen(FixedOnsenItem)
    case nature(FixedNatureSpotItem)
    /// マップ以外のタブの詳細（祭り・近くのスポット・プラン・動画など）。
    case view(id: String, AnyView)

    var id: String {
        switch self {
        case .prefecture(let p): return "prefecture-\(p.rawValue)"
        case .onsen(let o): return "onsen-\(o.id)"
        case .nature(let s): return "nature-\(s.id)"
        case .view(let id, _): return id
        }
    }

    static func == (lhs: SpreadDetail, rhs: SpreadDetail) -> Bool { lhs.id == rhs.id }

    /// 右ページに出ている県（地図上で強調するため）。
    var prefecture: Prefecture? {
        if case .prefecture(let p) = self { return p }
        return nil
    }
}

/// 見開きを使うための窓口。SpreadContainer が環境値として配る。
struct SpreadPresenter {
    /// 見開きが使える画面か（regular 幅かつ横長）。false なら従来の全画面表示を使う。
    var isAvailable: Bool = false
    /// いま右ページに出ている詳細。
    var current: SpreadDetail? = nil
    /// 右ページに詳細を出す（すでに開いていれば中身だけ入れ替える）。
    var present: (SpreadDetail) -> Void = { _ in }
    /// 右ページを閉じて左ページを全幅に戻す。
    var close: () -> Void = {}
}

extension EnvironmentValues {
    @Entry var spreadPresenter = SpreadPresenter()
    /// 見開きの右ページの中で次の画面へ進む処理。nil なら右ページの外。
    @Entry var spreadPanePush: ((AnyView) -> Void)? = nil
    /// 右ページの最初の画面か（「戻る」の代わりに ✕ を見せるため。戻ると右ページが閉じる）。
    @Entry var isSpreadPaneRoot = false
}

// MARK: - 見開きの入れ物

/// タブの画面を包み、見開きが使えるときは左右に分けて右ページに詳細を出す。
struct SpreadContainer<Content: View>: View {
    /// 右ページの中身を下げる量（iPad の上に浮くタブバーを避けるため）。背景は下げない。
    var paneTopInset: CGFloat = 0
    @ViewBuilder let content: Content

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var detail: SpreadDetail? = nil

    var body: some View {
        GeometryReader { geo in
            // 見開きは「regular 幅かつ横長」のときだけ（Duo の内側画面・iPad 横向き）。
            let canSpread = horizontalSizeClass == .regular && geo.size.width > geo.size.height
            let isSpread = canSpread && detail != nil
            let splitX = SpreadFold.splitX(in: geo)

            // iPad の浮いたタブバーがセーフエリアに含まれているかはタブによって違う
            // （近く・ホームなどは含まれ、地図タブは含まれない）。含まれていないときだけ足す。
            let paneSafeAreaExtra = geo.safeAreaInsets.top < paneTopInset ? paneTopInset : 0
            HStack(spacing: 0) {
                content
                    .frame(width: isSpread ? splitX : geo.size.width)

                if isSpread, let detail {
                    SpreadDetailPane(detail: detail, headerInset: paneTopInset, safeAreaExtra: paneSafeAreaExtra, onClose: close)
                        .frame(width: geo.size.width - splitX)
                        .transition(.move(edge: .trailing))
                }
            }
            .environment(\.spreadPresenter, SpreadPresenter(
                isAvailable: canSpread,
                current: canSpread ? detail : nil,
                present: { newDetail in
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                        detail = newDetail
                    }
                },
                close: close
            ))
            // 見開きが使えなくなったら右ページの状態も捨てる
            // （残しておくと、次に使えるようになったとき勝手に右ページが出てしまう）。
            .onChange(of: canSpread) { _, available in
                if !available { detail = nil }
            }
        }
    }

    private func close() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
            detail = nil
        }
    }
}

/// iPad で上に浮くタブバーの高さ（実測値）。上端に置くものはこのぶん下げる。
///
/// タブバーはコンテンツの上に重なって描かれ safe area には現れないので、インセットからは測れない。
/// 上に浮くタブバーは iPadOS だけの表示なので、iPad かどうかで判定する（regular 幅では判定できない：
/// iPhone Duo の内側画面も regular 幅だが、タブバーは右端に縦向きか下に出て、上には来ない）。
@MainActor
func iPadFloatingTabBarInset(_ horizontalSizeClass: UserInterfaceSizeClass?) -> CGFloat {
    UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular ? 60 : 0
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
    /// ヘッダーのアイコン・タイトルを下げる量（iPad の上に浮くタブバーを避けるため）。
    var headerInset: CGFloat = 0
    /// ボタンや文字を下げるために足すセーフエリア（タブバーがセーフエリアに含まれていないタブだけ）。
    var safeAreaExtra: CGFloat = 0
    let onClose: () -> Void

    var body: some View {
        // 別の項目に切り替えたら中身を作り直す（地図の初期位置などは init でしか決まらないため）。
        // 進んだ先の画面（パス）も一緒に捨てる。
        SpreadPaneStack(rootView: rootView, headerInset: headerInset, safeAreaExtra: safeAreaExtra, onClose: onClose)
            .id(detail.id)
        // 右ページの幅は iPhone 1 台ぶん。中の詳細は iPhone 向けのレイアウトで描かせる
        // （regular のままだと写真ヘッダーが高くなりすぎる等、広い画面用の調整が効いてしまう）。
        .environment(\.horizontalSizeClass, .compact)
        .background(Color(.systemBackground).ignoresSafeArea(edges: [.top, .trailing, .bottom]))
        // 左端（左ページとの境目）だけ切る。上・右・下は切らない：詳細画面の写真・色のヘッダーや背景は
        // ステータスバーや iPad の浮いたタブバーの下（上端）、iPhone Duo の右端のステータスバーと
        // 縦向きタブバーの列の下まで敷く。切ると白い帯が残る。文字やボタンはセーフエリア内のまま。
        .mask(Rectangle().padding(EdgeInsets(top: -1000, leading: 0, bottom: -1000, trailing: -1000)))
        // 左ページとの境目。本のノドのような薄い影で区切る。
        .overlay(alignment: .leading) {
            LinearGradient(colors: [.black.opacity(0.12), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: 8)
                .allowsHitTesting(false)
        }
    }

    private var rootView: AnyView {
        switch detail {
        case .prefecture(let prefecture):
            return AnyView(TourismDetailView(prefecture: prefecture))
        case .onsen(let onsen):
            return AnyView(OnsenDetailView(onsen: onsen))
        case .nature(let spot):
            return AnyView(NatureSpotDetailView(spot: spot))
        case .view(_, let view):
            return view
        }
    }
}

/// 右ページの中で積む画面。NavigationStack のパスに積むため、中身ごとに一意な ID を持たせる。
private struct SpreadPaneRoute: Hashable {
    let id = UUID()
    let view: AnyView
    let isRoot: Bool

    static func == (lhs: SpreadPaneRoute, rhs: SpreadPaneRoute) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// 右ページの中身。空の土台の上に最初の詳細を積み、そこから先の詳細も積んで進む。
/// 土台まで戻ったら（最初の詳細で「戻る／✕」を押したら）右ページを閉じる。
private struct SpreadPaneStack: View {
    let headerInset: CGFloat
    let safeAreaExtra: CGFloat
    let onClose: () -> Void
    @State private var path: [SpreadPaneRoute]

    init(rootView: AnyView, headerInset: CGFloat, safeAreaExtra: CGFloat, onClose: @escaping () -> Void) {
        self.headerInset = headerInset
        self.safeAreaExtra = safeAreaExtra
        self.onClose = onClose
        _path = State(initialValue: [SpreadPaneRoute(view: rootView, isRoot: true)])
    }

    var body: some View {
        let pathBinding = $path
        NavigationStack(path: $path) {
            Color(.systemBackground)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: SpreadPaneRoute.self) { route in
                    route.view
                        .environment(\.isSpreadPaneRoot, route.isRoot)
                        // iPad の上に浮くタブバーを避ける。
                        // - ボタンや文字：セーフエリアで下げる。タブバーがセーフエリアに含まれていない
                        //   タブ（地図）だけ足りないぶんを足す。余白ではなくセーフエリアなので、
                        //   写真・色のヘッダーや背景は上端まで敷かれ、白い帯は残らない。
                        //   NavigationStack の外から足すと中まで伝わらないので、積む画面ごとに付ける。
                        // - ヘッダーのアイコン・タイトル：詳細画面のスクロールは写真をステータスバーの下まで
                        //   敷くためにセーフエリアを無視して上端から並べるので、ヘッダー側で下げる。
                        //   右上の閉じるボタンはタブバーと重ならないので、そのぶん戻して元の高さに置く。
                        .safeAreaPadding(.top, safeAreaExtra)
                        .environment(\.headerExtraTopInset, headerInset)
                }
        }
        .environment(\.spreadPanePush, { view in
            pathBinding.wrappedValue.append(SpreadPaneRoute(view: view, isRoot: false))
        })
        .onChange(of: path.isEmpty) { _, isEmpty in
            if isEmpty { onClose() }
        }
    }
}

// MARK: - 詳細の開き方

/// `fullScreenCover(item:)` の代わり。
/// - 見開きの右ページの中なら、右ページ内で次の画面へ進む
/// - 見開きが使える画面なら、右ページに出す
/// - それ以外（iPhone・Duo の外側画面・縦長）は、従来どおり全画面で開く
///
/// 【なぜ navigationDestination を各所に付けないか】
/// 詳細を開くボタンの多くは横スクロールの Lazy コンテナの中にあり、そこに付けた
/// navigationDestination は SwiftUI に無視される。右ページのスタックに積む方式なら置き場所を選ばない。
private struct SpreadAwareItemPresentation<Item: Identifiable, Destination: View>: ViewModifier {
    @Binding var item: Item?
    let destination: (Item) -> Destination
    @Environment(\.spreadPanePush) private var push
    @Environment(\.spreadPresenter) private var spread

    func body(content: Content) -> some View {
        if push != nil || spread.isAvailable {
            content.onChange(of: item?.id) { _, _ in
                guard let value = item else { return }
                let view = AnyView(destination(value))
                if let push {
                    push(view)
                } else {
                    spread.present(.view(id: "\(Item.self)-\(value.id)", view))
                }
                // 出したら選択は戻す（同じ項目をもう一度タップしても開けるように）。
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
    @Environment(\.spreadPresenter) private var spread

    func body(content: Content) -> some View {
        if push != nil || spread.isAvailable {
            content.onChange(of: isPresented) { _, presented in
                guard presented else { return }
                let view = AnyView(destination())
                if let push {
                    push(view)
                } else {
                    spread.present(.view(id: UUID().uuidString, view))
                }
                isPresented = false
            }
        } else {
            content.fullScreenCover(isPresented: $isPresented, content: destination)
        }
    }
}

extension View {
    /// 詳細画面を開く。右ページの中なら右ページ内で進み、見開きなら右ページに出し、それ以外は全画面で開く。
    func detailCover<Item: Identifiable, Destination: View>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Destination
    ) -> some View {
        modifier(SpreadAwareItemPresentation(item: item, destination: content))
    }

    /// 詳細画面を開く（Bool 版）。振る舞いは item 版と同じ。
    func detailCover<Destination: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Destination
    ) -> some View {
        modifier(SpreadAwareFlagPresentation(isPresented: isPresented, destination: content))
    }
}

/// NavigationLink（プッシュ遷移）の代わり。見開きが使えるときは右ページに出す。
/// 右ページの中や見開きが使えない画面では、従来どおり NavigationLink でプッシュする。
struct SpreadAwareLink<Label: View, Destination: View>: View {
    /// 右ページで同じ項目かどうかを見分ける ID。
    let id: String
    @ViewBuilder let destination: () -> Destination
    @ViewBuilder let label: () -> Label
    @Environment(\.spreadPresenter) private var spread
    @Environment(\.spreadPanePush) private var push

    var body: some View {
        if push == nil && spread.isAvailable {
            Button {
                spread.present(.view(id: id, AnyView(destination())))
            } label: {
                label()
            }
        } else {
            NavigationLink(destination: destination, label: label)
        }
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
