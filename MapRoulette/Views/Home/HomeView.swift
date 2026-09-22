//
//  HomeView.swift
//  MapRoulette
//
//  5 タブ目「ホーム」のルート画面。
//  ユーザーの行動（最近見た県 / お気に入りの県）を軸にパーソナライズした導線だけを置く。
//
//  見せ方の方針（UI で機能を見せる・説明しない）:
//   - セクションは「大きなアイコン付き見出し」を置かない。小さなオーバーライン 1 行だけを
//     写真の列に添え、何の列かは写真そのものに語らせる。
//   - 説明文（テーマの出典など）はカード表面から外す。文字はカードの主役名だけに絞る。
//   - 階層は文字サイズや枠線ではなく「写真の大きさと余白」で作る。
//     最近見た県＝大（主役）／お気に入り・おすすめ＝小（一覧）。
//   - 動画は必ず「県」に紐づけて出す（要件C: 県という独自文脈に紐づける）。ホームでは
//     県カード列で主役になっている県の動画だけを、その列の直下に出す。
//     トレンド単独の一覧は作らない。
//
//  設計: docs/HomeTab_Renewal_Plan.md §3.4。
//  要件C: 動画は「アプリ独自の文脈（県＝独自データ）」に紐づけて出す。トレンド単独の
//  画面は作らず、この画面には広告も置かない。
//

import SwiftUI

struct HomeView: View {
    /// Firestore トレンドの読み取り（アプリ共有インスタンス。県詳細と結果を共有）。
    @ObservedObject private var repository = TrendRepository.shared
    /// 最近見た県 / お気に入りの県（パーソナライズの軸）。
    @ObservedObject private var recents = RecentPrefectureStore.shared
    @ObservedObject private var favorites = FavoritePrefectureStore.shared
    /// 旅行プラン（進行中の旅カード用）。
    @ObservedObject private var plans = TravelPlanStore.shared

    /// 県詳細を全画面で開く（メモリ: 詳細は NavigationStack ではなく fullScreenCover）。
    @State private var detailPrefecture: Prefecture? = nil
    /// テーマの名所カード経由で、県詳細を開いた直後にその名所の詳細まで自動で開く用。
    /// （固定指標テーマ＝三景/三名泉/三名園/三大夜景。名所カードのタップ先）
    @State private var themeDetailTarget: ThemeDetailTarget? = nil
    /// Shorts フィードを開く（動画配列 + 開始位置）。
    @State private var shortsFeed: PrefShortsFeed? = nil
    /// テーマ別紹介（②）で展開中のテーマ。タップでその場に県リストを開く（画面遷移しない）。
    @State private var expandedTheme: PrefectureTheme? = nil
    /// 県カード列の絞り込み（最近見た / お気に入り / おすすめ）。
    /// 3 つの列を 1 つに統合したので、どれを出すかはこの状態で切り替える。
    @State private var selectedFilter: PrefectureFilter = .recent

    /// 県カード列で「いま主役になっている県」。この県の動画を列の下に出す。
    /// 横スクロールに追従して切り替わる。
    ///
    /// 可視率そのものは @State に持たない。スクロール中は毎フレーム更新されるため、
    /// @State に書くと毎フレーム HomeView 全体が再描画されてカクつく。
    /// 可視率は下の visibilityTracker（ObservableObject ではない素のクラス）に溜め、
    /// 主役の県が実際に変わったときだけこの @State を更新する。
    @State private var focusedPrefecture: Prefecture? = nil

    /// 可視率の集計だけを持つ箱。SwiftUI の再描画とは切り離す（毎フレーム書いても再描画しない）。
    @State private var visibilityTracker = VisibilityTracker()

    var body: some View {
        NavigationStack {
            ScrollView {
                // セクション間の余白。広すぎると 1 画面に入る情報が減るので、
                // 「別のかたまりだと分かる」最小限まで詰める。
                VStack(alignment: .leading, spacing: 22) {
                    // ⓪ 進行中の旅（あるときだけ最上部に 1 件）
                    ongoingPlanSection

                    // ① ルーレット導線（プラン導線のすぐ下）
                    rouletteSection

                    // ② 県カード（最近見た／お気に入り／おすすめ を 1 つに統合）
                    prefectureSection

                    // ③ テーマ（ピル選択 → 下に展開）
                    themedSections

                    footerNote
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // 初回表示時のみ。キャッシュ優先＋1日1回だけ Firestore 取得（TrendRepository.load 内で制御）。
                if case .idle = repository.state {
                    await repository.load()
                }
            }
            .fullScreenCover(item: $detailPrefecture) { pref in
                TourismDetailView(prefecture: pref)
            }
            .fullScreenCover(item: $themeDetailTarget) { target in
                // 県詳細を開き、そのままその項目の詳細まで自動で開く（テーマのカード用）。
                TourismDetailView(
                    prefecture: target.prefecture,
                    autoOpen: target.autoOpen
                )
            }
            .fullScreenCover(item: $shortsFeed) { feed in
                ShortsFeedView(videos: feed.videos, startIndex: feed.startIndex)
            }
        }
    }

    // MARK: - ① ルーレット導線

    /// 「ルーレットで行き先を決める」導線。プラン導線のすぐ下に 1 行で置く。
    /// アプリの主機能（マップタブの県ルーレット）はホームからは見えないので導線を出すが、
    /// これ自体は常設のリンクなので、カードにはせずテキスト行に留める
    /// （塗り・影を持たせるとプラン帯＝ユーザー自身の旅より目立ってしまう）。
    private var rouletteSection: some View {
        RouletteEntryRow {
            AppRouter.shared.openRouletteMap()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - ⓪ 進行中・計画中の旅（帯カード）

    /// ホーム最上部の「次の旅」枠。常に表示する。
    /// - 進行中 or 計画中プランがある: 横長の帯カード（タップでプラン詳細へ）。
    ///   進行中を優先し、無ければ計画中を出す（TravelPlanStore.featuredPlan）。
    /// - どちらも無い: プレースホルダー＋ボタン（マイプランタブへ。
    ///   プランが 1 つも無ければ新規作成シートも自動で開く）。
    @ViewBuilder
    private var ongoingPlanSection: some View {
        if let plan = plans.featuredPlan {
            NavigationLink {
                PlanDetailView(planID: plan.id)
            } label: {
                ongoingPlanBanner(plan)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        } else {
            ongoingPlanEmpty
                .padding(.horizontal, 20)
        }
    }

    /// 帯カードに出すプランの状態に応じた見出しラベル（文言・アイコン）。
    private func bannerLabel(for status: PlanStatus) -> (titleKey: String, icon: String) {
        switch status {
        case .ongoing:   return ("home.section.ongoing", "airplane")
        case .upcoming:  return ("home.section.upcoming", "calendar")
        // 帯には ongoing / upcoming しか出さないが、網羅のため completed も一応返す。
        case .completed: return ("home.section.ongoing", "checkmark.seal.fill")
        }
    }

    /// 進行中・計画中プランが無いときのプレースホルダー。
    /// ボタンでマイプランタブへ切り替え、プランが 0 件なら新規作成シートも開く。
    private var ongoingPlanEmpty: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "airplane")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(PlanTheme.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString("home.ongoing.empty.title", comment: ""))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(NSLocalizedString("home.ongoing.empty.subtitle", comment: ""))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            Button {
                // プランが 1 つも無ければ新規作成シートを開き、あれば一覧を出すだけ。
                AppRouter.shared.openMyPlans(newPlan: plans.plans.isEmpty)
            } label: {
                Text(NSLocalizedString("home.ongoing.empty.action", comment: ""))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(PlanTheme.primary)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                .stroke(PlanTheme.primary.opacity(0.12), lineWidth: 1)
        )
    }

    /// 進行中・計画中プランの帯カード本体。プランの先頭県の代表写真を背景に敷く。
    private func ongoingPlanBanner(_ plan: TravelPlan) -> some View {
        // 背景写真: プランに含まれる県のうち、写真を持つ最初の代表スポット。
        let heroImage = plan.prefectures
            .lazy
            .compactMap { AttractionPhoto.photographedAttractions(in: $0).first }
            .first
            .flatMap { AttractionPhoto.image(for: $0.nameKey) }
        let label = bannerLabel(for: plan.status)

        return ZStack(alignment: .leading) {
            Group {
                if let heroImage {
                    heroImage.resizable().aspectRatio(contentMode: .fill)
                } else {
                    PlanTheme.brandGradient
                }
            }
            .frame(height: 96)
            .frame(maxWidth: .infinity)
            .clipped()

            LinearGradient(
                colors: [.black.opacity(0.55), .black.opacity(0.15)],
                startPoint: .leading,
                endPoint: .trailing
            )

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(NSLocalizedString(label.titleKey, comment: ""),
                          systemImage: label.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.95))
                    Text(plan.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(16)
        }
        .frame(height: 96)
        .clipShape(RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous))
        .shadow(color: PlanTheme.cardShadow, radius: 6, x: 0, y: 2)
    }

    // MARK: - ① 県カード（最近見た／お気に入り／おすすめ の統合）

    /// 県カードの出し分け。旧「最近見た県」「お気に入りの県」「おすすめ」は
    /// どれも *県カードを押す → 県詳細* で機能が同じで、出す県が違うだけだった。
    /// 3 本の横スクロール列に分けると同じ見た目が 3 回続くので、
    /// 1 本の列＋切り替えに統合し、画面から列の繰り返しを減らす。
    private enum PrefectureFilter: CaseIterable {
        case recent, favorite, recommended

        /// タブに出す短縮ラベル。3 つを横に並べるので、
        /// 「最近見た県」ではなく「最近見た」のように最短の語にする。
        var titleKey: String {
            switch self {
            case .recent:      return "home.tab.recent"
            case .favorite:    return "home.tab.favorite"
            case .recommended: return "home.tab.recommended"
            }
        }
    }

    /// 現在の絞り込みで出す県。
    private func prefectures(for filter: PrefectureFilter) -> [Prefecture] {
        switch filter {
        case .recent:
            return recents.recents
        case .favorite:
            // 順序は Prefecture.allCases 準拠で安定させる。
            return Prefecture.allCases.filter { favorites.isFavorite($0) }
        case .recommended:
            return PrefectureTheme.popularPrefectureList
        }
    }

    /// 中身が空の絞り込みは出さない（「最近見た県」が無い新規ユーザーに空タブを見せない）。
    /// おすすめは常に中身があるので、最低 1 つは必ず残る。
    private var availableFilters: [PrefectureFilter] {
        PrefectureFilter.allCases.filter { !prefectures(for: $0).isEmpty }
    }

    /// 実際に選択されている絞り込み。選択中のものが空になったら先頭に落とす。
    private var activeFilter: PrefectureFilter {
        let available = availableFilters
        if available.contains(selectedFilter) { return selectedFilter }
        return available.first ?? .recommended
    }

    private var prefectureSection: some View {
        let filters = availableFilters
        let active = activeFilter
        return VStack(alignment: .leading, spacing: 14) {
            // 絞り込みが 1 つだけ（＝新規ユーザーで「おすすめ」しか無い）なら、
            // 押しても何も起きないタブを並べても意味がないのでラベル 1 行にする。
            if filters.count > 1 {
                HStack(spacing: 18) {
                    ForEach(filters, id: \.self) { filter in
                        filterTab(filter, isActive: filter == active)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
            } else {
                overline(active.titleKey)
            }

            prefectureCardRow(prefectures(for: active))

            // 列で主役になっている県の動画（人気スポット／グルメ）。
            focusedTrendRows
        }
        // 列に並ぶ県のサムネを先読みしておく。スクロールで主役が切り替わった時点では
        // 既に手元にあるので、切り替わりで読み込み待ちが発生しない。
        .task(id: prefectures(for: active)) {
            prefetchThumbnails(for: prefectures(for: active))
        }
        // トレンドの取得が後から完了した場合にも先読みし直す。
        .task(id: repository.loadedGroups.count) {
            prefetchThumbnails(for: prefectures(for: active))
        }
        // 主役の県が変わったら、その県ぶんを最優先で読む。
        // 列全体の先読み（上の 2 つ）は列の顔ぶれが変わらないと再発火しないので、
        // 同じ列の中でスクロールして主役だけが変わった場合をここで拾う。
        .task(id: focusedPrefecture) {
            if let pref = focusedPrefecture {
                prefetchThumbnails(for: [pref])
            }
        }
    }

    /// 列に並ぶ県ぶんのサムネを先読みする。
    /// 主役の県 → その次の県… の順に投げるので、すぐ必要なものから埋まる。
    private func prefetchThumbnails(for prefs: [Prefecture]) {
        let urls = prefs
            .flatMap { trendGroups(for: $0) }
            .flatMap(\.videos)
            .map(\.thumbnailUrl)
        ThumbnailLoader.shared.prefetch(urls)
    }

    // MARK: - 主役の県のトレンド動画（人気スポット／グルメ）

    /// 県カード列で主役になっている県の Shorts を、カテゴリごとに 1 行ずつ出す。
    /// 出すのは spot（人気スポット）と gourmet（グルメ）だけ。カフェは県詳細に残す。
    /// 動画が 1 本も無い県では何も出さない（空の見出しを作らない）。
    ///
    /// 要件C: 動画は「県」という独自データに紐づけて出す（トレンド単独の画面は作らない）。
    /// 要件D: 出典はフッターの「Developed with YouTube」ロゴで明示している。
    @ViewBuilder
    private var focusedTrendRows: some View {
        if let pref = focusedPrefecture {
            let groups = trendGroups(for: pref)
            if !groups.isEmpty {
                VStack(alignment: .leading, spacing: 18) {
                    // 行の同一性はカテゴリ（spot / gourmet）で持つ。TrendGroup.id は
                    // 県を含む（"kyoto_spot"）ので、それで並べると県が変わるたびに
                    // 行が作り直しになる。カテゴリ固定なら中身の差し替えで済む。
                    ForEach(groups, id: \.categoryKey) { group in
                        trendRow(group)
                    }
                }
                .padding(.top, 2)
                // .id(pref) は付けない。付けるとビューの同一性が県ごとに変わり、
                // 切り替えのたびに行ごと作り直しになってスクロール中に引っかかる。
                // 同じビューの中身だけを差し替えれば、サムネがキャッシュ済みなので一瞬で入れ替わる。
                .animation(.easeInOut(duration: 0.18), value: pref)
            }
        }
    }

    /// 主役の県で出すトレンドのグループ（人気スポット → グルメ の順）。
    /// 動画が空のグループは除く。
    private func trendGroups(for pref: Prefecture) -> [TrendGroup] {
        let available = repository.groups(for: pref)
        return Self.homeTrendCategoryKeys.compactMap { key in
            available.first { $0.categoryKey == key && !$0.videos.isEmpty }
        }
    }

    /// ホームに出すカテゴリと、その並び順。カフェは県詳細だけに残す。
    private static let homeTrendCategoryKeys = ["spot", "gourmet"]

    /// トレンド 1 行（「◯◯県の人気スポット」＋サムネ横スクロール）。
    /// タップでその行の動画を頭から連続再生する（ShortsFeedView）。
    private func trendRow(_ group: TrendGroup) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.displayTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(group.videos.enumerated()), id: \.element.id) { index, video in
                        Button {
                            shortsFeed = PrefShortsFeed(videos: group.videos, startIndex: index)
                        } label: {
                            TrendCard(video: video, shelf: group.categoryKey, position: index)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                // 横 ScrollView の上端クリップでカード角丸が欠けるのを防ぐ余白。
                .padding(.vertical, 8)
            }
        }
    }

    /// 切り替えタブ。選択中は文字を濃く＋下線を引き、非選択はグレー。
    /// 枠や塗りを持たせるとテーマのピルと紛らわしくなるので、下線だけで示す。
    private func filterTab(_ filter: PrefectureFilter, isActive: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFilter = filter
            }
        } label: {
            VStack(spacing: 5) {
                Text(NSLocalizedString(filter.titleKey, comment: ""))
                    .font(.system(size: 15, weight: isActive ? .bold : .medium))
                    .foregroundColor(isActive ? .primary : .secondary)
                Rectangle()
                    .fill(isActive ? PlanTheme.primary : Color.clear)
                    .frame(height: 2)
            }
            .fixedSize()
        }
        .buttonStyle(.plain)
    }

    /// 県ビジュアルカードを横スクロールで並べる。
    /// 各カードは「画面内に見えている横幅の割合」を報告し、その結果で
    /// 下に出す動画の県（focusedPrefecture）が決まる。
    private func prefectureCardRow(_ prefs: [Prefecture]) -> some View {
        // 可視率はこの座標空間（＝スクロールの見えている窓）を基準に測る。
        // 窓の幅は ScrollView 自身の幅なので、外側の GeometryReader で測って渡す。
        let space = "prefRow"
        return GeometryReader { outer in
            let windowWidth = outer.size.width
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(prefs) { pref in
                        prefectureCard(pref)
                            .background(
                                visibilityReporter(for: pref, in: space, windowWidth: windowWidth)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)   // 角丸・影の上下欠け防止
            }
            .coordinateSpace(name: space)
        }
        // GeometryReader は高さを持たないので、カード列ぶんの高さを明示する
        // （カード高 + .padding(.vertical, 4) の上下ぶん）。
        .frame(height: Self.prefCardHeight + 8)
        .onPreferenceChange(CardVisibilityKey.self) { visibility in
            // 毎フレーム呼ばれる。主役の県が変わったときだけ @State を触る
            // （そうしないとスクロール中ずっと再描画が走ってカクつく）。
            visibilityTracker.merge(visibility)
            if let next = visibilityTracker.focused(among: prefs,
                                                    threshold: Self.focusVisibilityThreshold),
               next != focusedPrefecture {
                focusedPrefecture = next
            }
        }
        // 絞り込みを切り替えたら、新しい列の先頭を主役に付け替える。
        .onChange(of: prefs) { _, newPrefs in
            visibilityTracker.reset()
            focusedPrefecture = newPrefs.first
        }
        .onAppear {
            if focusedPrefecture == nil { focusedPrefecture = prefs.first }
        }
    }

    /// カード 1 枚の可視率（0…1）を測って preference に流すだけの透明ビュー。
    /// カードの背景に敷くので、レイアウトには影響しない。
    private func visibilityReporter(for pref: Prefecture,
                                    in space: String,
                                    windowWidth: CGFloat) -> some View {
        GeometryReader { geo in
            // 名前付き座標空間での位置。スクロールの見えている窓は x=0…windowWidth。
            let card = geo.frame(in: .named(space))
            Color.clear.preference(
                key: CardVisibilityKey.self,
                value: [pref: Self.visibleFraction(of: card, windowWidth: windowWidth)]
            )
        }
    }

    /// カードの可視率（0…1）。スクロール窓からはみ出した分を差し引いた幅の割合。
    static func visibleFraction(of card: CGRect, windowWidth: CGFloat) -> CGFloat {
        guard card.width > 0, windowWidth > 0 else { return 0 }
        let visible = min(card.maxX, windowWidth) - max(card.minX, 0)
        return max(0, min(1, visible / card.width))
    }

    /// 主役の県を切り替える可視率の閾値。先頭カードがこれ以下になったら次の県へ。
    private static let focusVisibilityThreshold: CGFloat = 0.7

    // MARK: - ③ テーマ別 都道府県紹介（日本三景・三名泉・人気の◯◯…）

    /// テーマは「選択中のフィルタ」として横一列のピルで見せ、選んだテーマの中身を
    /// すぐ下に写真カードで出す。見出し・説明文・chevron は置かず、
    /// 「選ぶと下が変わる」という UI の動きだけで機能を伝える。
    /// 常にどれか 1 つが選択されている（＝下に必ず写真が出る）状態にする。
    private var themedSections: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PrefectureTheme.displayOrder) { theme in
                        themePill(theme)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 2)
            }

            themeExpansion(selectedTheme)
        }
    }

    /// 現在選択中のテーマ。未選択なら先頭を既定にして、常に中身が見えている状態にする。
    private var selectedTheme: PrefectureTheme {
        expandedTheme ?? PrefectureTheme.displayOrder[0]
    }

    /// テーマのピル。選択中は塗り、非選択は地の薄いグレー。文字はテーマ名だけ。
    private func themePill(_ theme: PrefectureTheme) -> some View {
        let isSelected = selectedTheme == theme
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                expandedTheme = theme
            }
        } label: {
            Text(NSLocalizedString(theme.titleKey, comment: ""))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected
                              ? AnyShapeStyle(PlanTheme.primary)
                              : AnyShapeStyle(Color.primary.opacity(0.06)))
                )
        }
        .buttonStyle(.plain)
    }

    /// 選択テーマの中身を横スクロール。タップで県詳細（fullScreenCover）へ。
    /// テーマによって中身が「県」か「もの（おみやげ品・海の名所）」かで出し分ける。
    @ViewBuilder
    private func themeExpansion(_ theme: PrefectureTheme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                switch theme.content {
                case .prefectures(let prefs):
                    // 固定指標テーマ: 県カード（写真＝テーマの名所）。
                    ForEach(prefs) { pref in
                        themePrefectureCard(pref, theme: theme)
                    }
                case .items(let items):
                    // 人気のおみやげ / 海: 「もの」カード。タップでそのものがある県詳細へ。
                    ForEach(items) { item in
                        themeItemCard(item)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
        // 切り替え時に中身が差し替わったことが分かる程度のフェード。
        .id(theme)
        .transition(.opacity)
    }

    /// 「もの」カード（現在はビーチのみ）。タップでそのものがある県詳細へ。
    /// 写真があれば県カードと同じビジュアル（写真＋下部にもの名・県名）、
    /// 無ければアイコン主体のカードにフォールバックする。
    @ViewBuilder
    private func themeItemCard(_ item: ThemeItem) -> some View {
        Button {
            // 県詳細を開いた直後に、そのもの（お土産／ビーチ）の詳細まで自動で開く。
            // 詳細画面を持たないビーチ（.none）は従来どおり県詳細だけを開く。
            switch item.detailTarget {
            case .souvenir(let stableKey):
                themeDetailTarget = ThemeDetailTarget(
                    prefecture: item.prefecture,
                    autoOpen: .souvenir(stableKey: stableKey)
                )
            case .natureSpot(let nameKey):
                themeDetailTarget = ThemeDetailTarget(
                    prefecture: item.prefecture,
                    autoOpen: .natureSpot(nameKey: nameKey)
                )
            case .none:
                detailPrefecture = item.prefecture
            }
        } label: {
            if let photo = item.photo {
                // 写真あり: 固定指標の県カードと同じ縦長ビジュアル（もの名＝主役）。
                ZStack(alignment: .bottomLeading) {
                    photo
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 190)
                        .clipped()
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5)],
                        startPoint: .center, endPoint: .bottom
                    )
                    cardCaption(title: item.name,
                                subtitle: item.prefecture.prefectureName)
                        .frame(width: 150, alignment: .leading)
                }
                .frame(width: 150, height: 190)
                .clipShape(RoundedRectangle(cornerRadius: Self.cardRadius, style: .continuous))
            } else {
                // 写真なし: 写真カードと同じ形のまま、地をブランドグラデにするフォールバック。
                // （グレーの箱＋アイコンにすると 1 枚だけ質感が落ちて浮くため）
                ZStack(alignment: .bottomLeading) {
                    PlanTheme.brandGradient
                        .frame(width: 150, height: 190)
                    Image(systemName: item.icon)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white.opacity(0.35))
                        .frame(width: 150, height: 190, alignment: .center)
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.35)],
                        startPoint: .center, endPoint: .bottom
                    )
                    cardCaption(title: item.name,
                                subtitle: item.prefecture.prefectureName)
                        .frame(width: 150, alignment: .leading)
                }
                .frame(width: 150, height: 190)
                .clipShape(RoundedRectangle(cornerRadius: Self.cardRadius, style: .continuous))
            }
        }
        .buttonStyle(.plain)
    }

    /// 固定指標テーマ（日本三景など）の県カード（縦長 150×190）。
    /// 写真＝そのテーマが指す名所。下部は名所名（主役・大）＋県名（従・小）。タップで県詳細へ。
    private func themePrefectureCard(_ pref: Prefecture, theme: PrefectureTheme) -> some View {
        // ビジュアル＝「テーマが指すまさにそのスポット」を最優先（例: 日本三景×京都=天橋立）。
        // 無ければ県の写真つきスポットの先頭にフォールバック。
        let heroNameKey = theme.heroNameKey(for: pref)
            ?? AttractionPhoto.photographedAttractions(in: pref).first?.nameKey
        let heroImage = heroNameKey.flatMap { AttractionPhoto.image(for: $0) }
        let spotName = heroNameKey.map { NSLocalizedString($0, comment: "") }

        return Button {
            // 県詳細を開いた直後に、カードの主役スポット（heroNameKey）の詳細まで自動で開く。
            // heroNameKey が無い県は従来どおり県詳細だけを開く。
            if let heroNameKey {
                themeDetailTarget = ThemeDetailTarget(
                    prefecture: pref,
                    autoOpen: .attraction(nameKey: heroNameKey)
                )
            } else {
                detailPrefecture = pref
            }
        } label: {
            ZStack(alignment: .topLeading) {
                // 背景ビジュアル（テーマの名所→県代表写真→ブランドグラデ の順で解決）
                Group {
                    if let heroImage {
                        heroImage.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        PlanTheme.brandGradient
                    }
                }
                .frame(width: 150, height: 190)
                .clipped()

                // 下部を暗くして文字を読ませる
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // 名所名（主役・大）＋県名（従・小）。名所名が無い県は県名を主役に。
                cardCaption(title: spotName ?? pref.prefectureName,
                            subtitle: spotName == nil ? nil : pref.prefectureName)
                    .frame(width: 150, height: 190, alignment: .bottomLeading)
            }
            .frame(width: 150, height: 190)
            .clipShape(RoundedRectangle(cornerRadius: Self.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    /// 写真カードの上に重ねる文字（主役名＋必要なら県名）。カード間で見え方を揃える。
    private func cardCaption(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Spacer(minLength: 0)
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(14)
    }

    /// 県ビジュアルカード（最近見た県 / お気に入り用）。
    /// 代表観光地の CC0 写真をビジュアルにして、県名・地方をカード下部に重ねる。
    /// 写真が無い県はブランドグラデーションでフォールバックする。
    /// カード全体がタップ領域で、タップすると県詳細（TourismDetailView）を開く。
    private func prefectureCard(_ pref: Prefecture) -> some View {
        // 代表観光地: 県内で写真を持つ最初のスポット（=カルーセル先頭と一致）。
        let hero = AttractionPhoto.photographedAttractions(in: pref).first

        return Button {
            detailPrefecture = pref
        } label: {
            ZStack(alignment: .bottomLeading) {
                // 背景ビジュアル
                Group {
                    if let hero, let image = AttractionPhoto.image(for: hero.nameKey) {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        PlanTheme.brandGradient
                    }
                }
                .frame(width: Self.prefCardWidth, height: Self.prefCardHeight)
                .clipped()

                // 下部を暗くして白文字を読めるようにするグラデーション
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // 県名だけ。地方・スポット名の補足は出さない（説明で埋めない）。
                Text(pref.prefectureName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: Self.prefCardWidth, height: Self.prefCardHeight)
            .clipShape(RoundedRectangle(cornerRadius: Self.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 共通スタイル

    /// カードの角丸。カード全体で共通（ホーム内で 1 つの値に統一する）。
    private static let cardRadius: CGFloat = 18

    /// 県カードの大きさ。列を 1 本に統合したので、他の列と大きさを競わせる必要がなくなり
    /// 写真を大きく見せられる（テーマのカード 150 幅より一回り大きい）。
    private static let prefCardWidth: CGFloat = 230
    private static let prefCardHeight: CGFloat = 190

    /// セクションのラベル。アイコン付きの大きな見出しではなく、写真の列に添える
    /// 小さな 1 行だけにする（列が何かは写真そのものが示すので、文字は最小限でよい）。
    private func overline(_ titleKey: String) -> some View {
        Text(NSLocalizedString(titleKey, comment: ""))
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
    }

    // MARK: - フッター（要件D: 出典の補足）

    private var footerNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 要件D: 公式「Developed with YouTube」ロゴ（タップで YouTube へ）。
            // ロゴ自体が「Developed with YouTube」と読めるので主役として大きめに置く。
            DevelopedWithYouTubeBadge(height: 22)
            // 補足の一文（出典の説明）。ロゴの下に控えめに添える。
            Text(NSLocalizedString("home.trend.source.note", comment: ""))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

/// 県カードの可視率を溜めておくだけの箱。
///
/// あえて ObservableObject にしない（＝ @Published を持たない）。スクロール中は
/// 毎フレーム可視率が届くので、これを監視対象にすると毎フレーム再描画が走り、
/// スクロールがカクつく。ここには黙って書き込み、主役の県が実際に変わったときだけ
/// 呼び出し側が @State を更新する。
private final class VisibilityTracker {
    private var visibility: [Prefecture: CGFloat] = [:]

    func merge(_ new: [Prefecture: CGFloat]) {
        visibility.merge(new) { _, updated in updated }
    }

    func reset() {
        visibility.removeAll()
    }

    /// 主役の県。列の先頭から見て、可視率が閾値（70%）を超えている最初の県を選ぶ。
    /// 先頭カードが 70% 以下まで流れたら、次の県に切り替わる。
    /// どれも閾値に届かない（＝全部が見切れている）ときは、最も多く見えている県。
    func focused(among prefs: [Prefecture], threshold: CGFloat) -> Prefecture? {
        prefs.first { (visibility[$0] ?? 0) > threshold }
            ?? prefs.max { (visibility[$0] ?? 0) < (visibility[$1] ?? 0) }
    }
}

/// 県カード列の各カードが報告する「画面内に見えている横幅の割合」（0…1）。
/// 主役の県（＝下に動画を出す県）をスクロールに追従して決めるために使う。
private struct CardVisibilityKey: PreferenceKey {
    static let defaultValue: [Prefecture: CGFloat] = [:]
    static func reduce(value: inout [Prefecture: CGFloat],
                       nextValue: () -> [Prefecture: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// テーマのカードのタップ先。県詳細を開き、続けてその項目（名所／お土産／ビーチ）の
/// 詳細まで自動で開くためのコンテキスト（`fullScreenCover(item:)` 用）。
struct ThemeDetailTarget: Identifiable {
    let id = UUID()
    let prefecture: Prefecture
    /// 県詳細を開いた直後に自動で開く詳細。
    let autoOpen: TourismAutoOpen
}

#Preview {
    HomeView()
}
