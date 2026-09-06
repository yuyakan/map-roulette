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
