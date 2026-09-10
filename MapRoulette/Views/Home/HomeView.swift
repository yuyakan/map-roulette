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
    /// Shorts フィードを開く（動画配列 + 開始位置）。
    @State private var shortsFeed: PrefShortsFeed? = nil

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
    private static let recommendedPrefectures: [Prefecture] =
        [.okinawa, .fukuoka, .kyoto, .hokkaido, .osaka]

    /// おすすめセクション。最近見た県／お気に入りが空でもホームが成立するよう常に表示する。
    /// 他セクションと同じ県ビジュアルカードの横スクロールで統一する（動画は県詳細に一本化）。
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(titleKey: "home.section.recommended", icon: "sparkles")
            prefectureCardRow(Self.recommendedPrefectures)
        }
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
        HStack(spacing: 6) {
            YouTubeBadge()
            Text(NSLocalizedString("home.trend.source.note", comment: ""))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}

#Preview {
    HomeView()
}
