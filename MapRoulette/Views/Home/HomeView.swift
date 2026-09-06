//
//  HomeView.swift
//  MapRoulette
//
//  5 タブ目「ホーム」のルート画面。
//  トレンド（YouTube Shorts）セクションと、MapRoulette 独自コンテンツを縦に並べる。
//
//  要件C（重要）: トレンドは「ホームの一機能」として MapRoulette 独自コンテンツと
//  同一画面に共存させ、独自価値を担保する。トレンド単独の広告画面は作らない。
//  （このホーム画面には現状 AdMob 広告を置いていない。将来置く場合も独自コンテンツと併設する。）
//

import SwiftUI

struct HomeView: View {
    /// Firestore `trends` の読み取り（P3で結線）。
    @StateObject private var repository = TrendRepository()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    welcomeHeader

                    // 要件C: 独自コンテンツ（ホームからの導線）
                    quickActionsSection

                    Divider()
                        .padding(.horizontal, 16)

                    // トレンドセクション（YouTube Shorts・要件A〜E）
                    trendSection

                    footerNote
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(NSLocalizedString("tab.home", comment: "ホーム"))
            .navigationBarTitleDisplayMode(.large)
            .task {
                // 初回表示時のみ。キャッシュ優先＋1日1回だけ Firestore 取得（TrendRepository.load 内で制御）。
                if case .idle = repository.state {
                    await repository.load()
                }
            }
            // 引っ張って更新は提供しない。再取得は失敗時の「再試行」ボタンのみ（1日1回の自動取得に限定）。
        }
    }

    // MARK: - トレンドセクション（状態出し分け）

    @ViewBuilder
    private var trendSection: some View {
        switch repository.state {
        case .idle, .loading:
            trendLoading
        case .loaded(let groups):
            if groups.isEmpty {
                trendEmpty
            } else {
                TrendSectionView(groups: groups)
            }
        case .failed(let kind):
            // 読み込み失敗時も画面全体は独自コンテンツで成立させる（要件C）。
            // トレンド部分にはメッセージ＋「再試行」を出す（成功時は再取得手段を出さない）。
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

    // MARK: - ウェルカム見出し（独自コンテンツ）

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(NSLocalizedString("home.welcome.title", comment: ""))
                .font(.system(size: 24, weight: .bold))
            Text(NSLocalizedString("home.welcome.subtitle", comment: ""))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - クイックアクション（独自コンテンツ・要件C）

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("home.quick.title", comment: ""))
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    quickCard(
                        icon: "map.fill",
                        title: NSLocalizedString("home.quick.explore", comment: ""),
                        tint: PlanTheme.primary
                    )
                    quickCard(
                        icon: "location.circle.fill",
                        title: NSLocalizedString("home.quick.nearby", comment: ""),
                        tint: PlanTheme.accent
                    )
                    quickCard(
                        icon: "sparkles",
                        title: NSLocalizedString("home.quick.festival", comment: ""),
                        tint: Color(red: 0.70, green: 0.40, blue: 0.95)
                    )
                    quickCard(
                        icon: "suitcase.rolling.fill",
                        title: NSLocalizedString("home.quick.plan", comment: ""),
                        tint: Color(red: 0.30, green: 0.55, blue: 0.98)
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func quickCard(icon: String, title: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(tint)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(width: 130, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
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
