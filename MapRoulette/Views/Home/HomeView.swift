//
//  HomeView.swift
//  MapRoulette
//
//  5 タブ目「ホーム」のルート画面。
//  ユーザーの行動（最近見た県 / お気に入りの県）を軸にパーソナライズした導線だけを置く。
//
//  セクションごとに見せ方を分けている:
//   - 最近見た県 / お気に入りの県 … 県の「ダイジェストカード」（地方・観光地・グルメ）。
//     カード全体をタップで県詳細（TourismDetailView）へ。動画は出さない。
//       理由: 動画は県詳細に一本化した。ホームで動画も出すと「どのセクションも動画が
//       並んでいるだけ」で県詳細と重複し、ホーム独自の価値（＝県への入口）が薄れるため。
//   - おすすめ … 従来どおり県名＋その県の動画サムネ横スクロール（→ Shorts 再生）。
//     入口としての即時性を残すため、ここだけ動画を出す。
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
    /// テーマ別紹介（④）で展開中のテーマ。タップでその場に県リストを開く（画面遷移しない）。
    @State private var expandedTheme: PrefectureTheme? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // ⓪ 進行中の旅（あるときだけ最上部に 1 件）
                    ongoingPlanSection

                    // ① 最近見た県（最優先）
                    recentSection

                    // ② お気に入りの県
                    favoriteSection

                    // ③ おすすめ（固定県・常に表示）
                    recommendedSection

                    // ④ テーマ別 都道府県紹介（日本三景・三名泉・人気の◯◯…）
                    themedSections

                    footerNote
                }
                .padding(.vertical, 16)
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
            .padding(.horizontal, 16)
        } else {
            ongoingPlanEmpty
                .padding(.horizontal, 16)
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

    // MARK: - ① 最近見た県

    @ViewBuilder
    private var recentSection: some View {
        // 最近見た県はそのまま（動画の有無に依存しない）。ビジュアルカードを横に流して県詳細へ誘導する。
        let prefs = recents.recents
        if !prefs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(titleKey: "home.section.recent", icon: "clock.arrow.circlepath")
                prefectureCardRow(prefs)
            }
        }
    }

    // MARK: - ② お気に入りの県

    @ViewBuilder
    private var favoriteSection: some View {
        // お気に入りの県。順序は Prefecture.allCases 準拠で安定させる（動画の有無に依存しない）。
        let prefs = Prefecture.allCases.filter { favorites.isFavorite($0) }
        if !prefs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(titleKey: "home.section.favorite", icon: "heart.fill")
                prefectureCardRow(prefs)
            }
        }
    }

    /// 県ビジュアルカードを横スクロールで並べる（最近見た県 / お気に入り用）。
    private func prefectureCardRow(_ prefs: [Prefecture]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(prefs) { pref in
                    prefectureCard(pref)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)   // 角丸・影の上下欠け防止
        }
    }

    // MARK: - ③ おすすめ（固定県・常に表示）

    /// おすすめとして常に出す県（固定・表示順）。人気の高い定番エリア。
    /// 実体は PrefectureTheme.popularPrefectureList（単一の真実の源）を参照する。
    private static var recommendedPrefectures: [Prefecture] {
        PrefectureTheme.popularPrefectureList
    }

    /// おすすめセクション。最近見た県／お気に入りが空でもホームが成立するよう常に表示する。
    /// 他セクションと同じ県ビジュアルカードの横スクロールで統一する（動画は県詳細に一本化）。
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(titleKey: "home.section.recommended", icon: "sparkles")
            prefectureCardRow(Self.recommendedPrefectures)
        }
    }

    // MARK: - ④ テーマ別 都道府県紹介（日本三景・三名泉・人気の◯◯…）

    /// 「切り口（テーマ）」を 2 列グリッドで並べる。上のセクション（横スクロール行）とは
    /// 見せ方を変え、テーマのタイルをタップすると **その行の下にその場で県が展開** する
    /// （画面遷移しないアコーディオン）。展開中の県カードをタップで県詳細へ。
    private var themedSections: some View {
        // 2 列に並べるため 2 個ずつの行に分割する。展開エリアは「展開中テーマを含む行」の直後に差し込む。
        let rows = PrefectureTheme.displayOrder.chunked(into: 2)
        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader(titleKey: "home.section.themes", icon: "square.grid.2x2.fill")

            VStack(spacing: 12) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 12) {
                        ForEach(row) { theme in
                            themeTile(theme)
                        }
                        // 行が 1 個しかないとき（奇数個）は右側を埋めて左寄せの幅を保つ。
                        if row.count == 1 { Color.clear.frame(maxWidth: .infinity) }
                    }

                    // この行に展開中テーマが含まれていれば、行の直下に県リストを差し込む。
                    if let expanded = expandedTheme, row.contains(expanded) {
                        themeExpansion(expanded)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    /// グリッドの 1 タイル（テーマの見出し）。タップで展開/折りたたみをトグル。
    private func themeTile(_ theme: PrefectureTheme) -> some View {
        let isExpanded = expandedTheme == theme
        return Button {
            withAnimation(.easeInOut(duration: 0.22)) {
                expandedTheme = isExpanded ? nil : theme
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: theme.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(PlanTheme.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                Text(NSLocalizedString(theme.titleKey, comment: ""))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                // 固定指標テーマは出典/根拠を添える（恣意的でないことを示す）。
                if let subtitleKey = theme.subtitleKey {
                    Text(NSLocalizedString(subtitleKey, comment: ""))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 78, alignment: .topLeading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                    .stroke(isExpanded ? PlanTheme.primary.opacity(0.6) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    /// 展開エリア: 選択テーマの中身を横スクロール。タップで県詳細（fullScreenCover）へ。
    /// テーマによって中身が「県」か「もの（おみやげ品・海の名所）」かで出し分ける。
    @ViewBuilder
    private func themeExpansion(_ theme: PrefectureTheme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
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
            .padding(.vertical, 4)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    /// 「もの」カード（おみやげ品・ビーチ）。タップでそのものがある県詳細へ。
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
                        colors: [.clear, .black.opacity(0.55)],
                        startPoint: .center, endPoint: .bottom
                    )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(item.prefecture.prefectureName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(10)
                    .frame(width: 150, alignment: .leading)
                }
                .frame(width: 150, height: 190)
                .clipShape(RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous))
                .shadow(color: PlanTheme.cardShadow, radius: 6, x: 0, y: 2)
            } else {
                // 写真なし: アイコン主体のカード（フォールバック）。
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: item.icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(PlanTheme.primary)
                    Spacer(minLength: 0)
                    Text(item.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(item.prefecture.prefectureName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(width: 140, height: 130, alignment: .topLeading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
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
                    colors: [.black.opacity(0.55), .clear, .black.opacity(0.35)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 名所名（主役・大）＋県名（従・小）。名所名が無い県は県名を主役に。
                VStack(alignment: .leading, spacing: 2) {
                    Spacer()
                    if let spotName {
                        Text(spotName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(pref.prefectureName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    } else {
                        Text(pref.prefectureName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(10)
                .frame(width: 150, height: 190, alignment: .bottomLeading)
            }
            .frame(width: 150, height: 190)
            .clipShape(RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous))
            .shadow(color: PlanTheme.cardShadow, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
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
                .frame(width: 220, height: 150)
                .clipped()

                // 下部を暗くして白文字を読めるようにするグラデーション
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // 県名・地方・代表スポット名
                VStack(alignment: .leading, spacing: 2) {
                    Text(pref.prefectureName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    HStack(spacing: 6) {
                        Text(pref.region)
                        if let hero {
                            Text("·")
                            Text(hero.name).lineLimit(1)
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 220, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous))
            .shadow(color: PlanTheme.cardShadow, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    /// 1 県ぶんの行: 県名（タップで県詳細）＋その県の動画サムネ横スクロール（タップで再生）。
    private func prefectureRow(_ pref: Prefecture) -> some View {
        let videos = repository.videos(for: pref)
        return VStack(alignment: .leading, spacing: 8) {
            Button {
                detailPrefecture = pref
            } label: {
                HStack(spacing: 4) {
                    Text(pref.prefectureName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(videos.enumerated()), id: \.element.id) { index, video in
                        Button {
                            shortsFeed = PrefShortsFeed(videos: videos, startIndex: index)
                        } label: {
                            TrendCard(video: video)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)   // 角丸の上端欠け防止
            }
        }
    }

    // MARK: - 共通セクション見出し

    private func sectionHeader(titleKey: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(PlanTheme.primary)
            Text(NSLocalizedString(titleKey, comment: ""))
                .font(.system(size: 20, weight: .bold))
            Spacer()
        }
        .padding(.horizontal, 16)
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
        .padding(.horizontal, 16)
        .padding(.top, 4)
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
