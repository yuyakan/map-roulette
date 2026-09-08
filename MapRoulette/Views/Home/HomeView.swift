//
//  HomeView.swift
//  MapRoulette
//
//  5 タブ目「ホーム」のルート画面。
//  ユーザーの行動（最近見た県 / お気に入りの県）を軸にパーソナライズした動画棚を並べ、
//  最下部に全県横断のトレンドを置く。各県ブロックは県詳細（TourismDetailView）への導線も持つ。
//
//  設計: docs/HomeTab_Renewal_Plan.md §3.4。
//  要件C（重要）: トレンドは「ホームの一機能」として MapRoulette 独自コンテンツ（最近見た/
//  お気に入りの県）と同一画面に共存させ、独自価値を担保する。トレンド単独の広告画面は作らない。
//

import SwiftUI

struct HomeView: View {
    /// Firestore トレンドの読み取り（アプリ共有インスタンス。県詳細と結果を共有）。
    @ObservedObject private var repository = TrendRepository.shared
    /// 最近見た県 / お気に入りの県（パーソナライズの軸）。
    @ObservedObject private var recents = RecentPrefectureStore.shared
    @ObservedObject private var favorites = FavoritePrefectureStore.shared

    /// 県詳細を全画面で開く（メモリ: 詳細は NavigationStack ではなく fullScreenCover）。
    @State private var detailPrefecture: Prefecture? = nil
    /// Shorts フィードを開く（動画配列 + 開始位置）。
    @State private var shortsFeed: PrefShortsFeed? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // ① 最近見た県（最優先）
                    recentSection

                    // ② お気に入りの県
                    favoriteSection

                    // ③ 全県横断トレンド（YouTube Shorts・要件A〜E）
                    trendSection

                    footerNote
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
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

    // MARK: - ① 最近見た県

    @ViewBuilder
    private var recentSection: some View {
        // 動画があり、かつ最近見た県のうち、動画を持つものだけ行にする。
        let prefs = recents.recents.filter { !repository.videos(for: $0).isEmpty }
        if !prefs.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(titleKey: "home.section.recent", icon: "clock.arrow.circlepath")
                ForEach(prefs) { pref in
                    prefectureRow(pref)
                }
            }
        }
    }

    // MARK: - ② お気に入りの県

    @ViewBuilder
    private var favoriteSection: some View {
        // お気に入りのうち動画を持つ県。順序は Prefecture.allCases 準拠で安定させる。
        let prefs = Prefecture.allCases
            .filter { favorites.isFavorite($0) && !repository.videos(for: $0).isEmpty }
        if !prefs.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(titleKey: "home.section.favorite", icon: "heart.fill")
                ForEach(prefs) { pref in
                    prefectureRow(pref)
                }
            }
        }
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

    // MARK: - ③ トレンドセクション（状態出し分け）

    @ViewBuilder
    private var trendSection: some View {
        switch repository.state {
        case .idle, .loading:
            trendLoading
        case .loaded(let groups):
            if groups.isEmpty {
                trendEmpty
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    trendSectionHeader
                    TrendSectionView(groups: groups)
                }
            }
        case .failed(let kind):
            // 読み込み失敗時も画面全体は独自コンテンツ（最近見た/お気に入り）で成立させる（要件C）。
            trendError(kind)
        }
    }

    private var trendLoading: some View {
        VStack(alignment: .leading, spacing: 12) {
            trendSectionHeader
            HStack {
                Spacer()
                ProgressView()
                    .padding(.vertical, 40)
                Spacer()
            }
        }
    }

    private var trendEmpty: some View {
        VStack(alignment: .leading, spacing: 12) {
            trendSectionHeader
            Text(NSLocalizedString("home.trend.empty", comment: ""))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
        }
    }

    /// 取得失敗表示。種別に応じたメッセージ＋「再試行」ボタン。
    private func trendError(_ kind: TrendRepository.FailureKind) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            trendSectionHeader
            VStack(spacing: 12) {
                Image(systemName: kind == .network ? "wifi.slash" : "exclamationmark.triangle")
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)
                Text(NSLocalizedString(kind.messageKey, comment: ""))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button {
                    Task { await repository.retry() }
                } label: {
                    Text(NSLocalizedString("home.trend.retry", comment: "再試行"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(PlanTheme.primary)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
    }

    private var trendSectionHeader: some View {
        HStack(spacing: 8) {
            Text(NSLocalizedString("home.trend.section.title", comment: "トレンド"))
                .font(.system(size: 20, weight: .bold))
            YouTubeBadge()
            Spacer()
        }
        .padding(.horizontal, 16)
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
