//
//  HomeView.swift
//  MapRoulette
//
//  5 タブ目「ホーム」のルート画面。
//  ユーザーの行動（最近見た県 / お気に入りの県）を軸にパーソナライズした導線だけを置く。
//  各県ブロックは県名（→ 県詳細 TourismDetailView）＋その県の動画サムネ（→ Shorts 再生）を持つ。
//  「全県のトレンドを丸ごと並べる」構成は廃止した（県ごとの動画は県詳細で見られるため冗長）。
//
//  設計: docs/HomeTab_Renewal_Plan.md §3.4。
//  要件C: 動画は「最近見た県 / お気に入りの県」というアプリ独自の文脈（県＝独自データ）に
//  紐づけて出す。トレンド単独の画面は作らず、この画面には広告も置かない。
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

                    // ③ おすすめ（固定県・常に表示）
                    recommendedSection

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

    // MARK: - ③ おすすめ（固定県・常に表示）

    /// おすすめとして常に出す県（固定・表示順）。人気の高い定番エリア。
    private static let recommendedPrefectures: [Prefecture] =
        [.okinawa, .fukuoka, .kyoto, .hokkaido, .osaka]

    /// おすすめセクション。最近見た県／お気に入りが空でもホームが成立するよう常に表示する。
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(titleKey: "home.section.recommended", icon: "sparkles")
            ForEach(Self.recommendedPrefectures) { pref in
                prefectureRow(pref)
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
