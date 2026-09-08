//
//  ShortsFeedView.swift
//  MapRoulette
//
//  要件E: Shorts を TikTok 風に縦スワイプで次々に再生する全画面フィード。
//
//  規約対応:
//  - 要件B: 再生は YouTubeShortPlayerView（公式埋め込み）のみ。DL 手段は作らない。
//  - 要件C: この再生画面には AdMob 広告を配置しない。
//  - 要件D: 各ページに YouTube 出典・チャンネル名・「YouTubeで見る」を表示する。
//

import SwiftUI

struct ShortsFeedView: View {
    /// 再生対象の Shorts 群。
    let videos: [TrendVideo]
    /// 最初に表示する動画のインデックス（カードから開いた位置）。
    let startIndex: Int

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int

    init(videos: [TrendVideo], startIndex: Int = 0) {
        self.videos = videos
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }

    /// プレイヤー(WebView)を実体化しておく前後ページ数。
    /// currentIndex ± preloadRadius のページはタップ前に iframe を初期化しておき、
    /// スワイプ時のラグを消す。それより遠いページはサムネのみの軽量表示にしてメモリを節約する。
    /// 2 = 前後2本ずつ（同時最大5本のプレイヤーを保持）。途切れにくいがメモリ負荷は上がる。
    private let preloadRadius = 2

    var body: some View {
        GeometryReader { geo in
            TabView(selection: $currentIndex) {
                ForEach(Array(videos.enumerated()), id: \.element.id) { index, video in
                    ShortsPage(
                        video: video,
                        isActive: index == currentIndex,
                        // 近傍ページはプレイヤーを先に生成（プリロード）。遠いページはサムネのみ。
                        isPreloaded: abs(index - currentIndex) <= preloadRadius
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                    .rotationEffect(.degrees(-90))          // TabView を縦ページ化する定番手法
                    .tag(index)
                }
            }
            .frame(width: geo.size.height, height: geo.size.width)
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: geo.size.width)                        // 回転後の位置補正
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.black)
        .ignoresSafeArea()
        .overlay(alignment: .topLeading) { closeButton }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(12)
                .background(Color.black.opacity(0.4))
                .clipShape(Circle())
        }
        .padding(.top, 8)
        .padding(.leading, 16)
    }
}

/// 1 本の Shorts のページ。プレイヤー + 出典オーバーレイ。
private struct ShortsPage: View {
    let video: TrendVideo
    let isActive: Bool
    /// 近傍ページか。true のときだけプレイヤー(WebView)を実体化し、事前ロードしておく。
    let isPreloaded: Bool

    var body: some View {
        ZStack {
            Color.black

            if isPreloaded {
                // 要件B/E: 公式埋め込みを 9:16 で。表示中ページのみ再生。
                // ロード中はサムネでつなぎ、黒画面待ちを避ける。
                YouTubeShortPlayerView(
                    videoId: video.videoId,
                    isActive: isActive,
                    thumbnailUrl: video.thumbnailUrl
                )
                .aspectRatio(9.0 / 16.0, contentMode: .fit)
            } else {
                // 遠いページはプレイヤーを持たず、サムネのみ（メモリ節約）。
                // スワイプで近づいた時点でプレイヤーに差し替わる。
                thumbnailOnly
            }

            // 要件D: 出典オーバーレイ（下部）
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(video.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.white.opacity(0.9))
                            Text(video.channelTitle)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    Spacer()
                    // 「YouTubeで見る」導線（要件D）
                    if let url = video.watchURL {
                        Link(destination: url) {
                            WatchOnYouTubeLabel()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)
                )
            }
        }
    }

    /// 非プリロードページのサムネ表示（9:16）。プレイヤー未生成のプレースホルダ。
    private var thumbnailOnly: some View {
        AsyncImage(url: URL(string: video.thumbnailUrl)) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Color.black
        }
        .aspectRatio(9.0 / 16.0, contentMode: .fit)
    }
}
