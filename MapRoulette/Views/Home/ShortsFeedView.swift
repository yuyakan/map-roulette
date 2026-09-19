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

    /// 端末の通信状態。オフラインで開いたときに案内を出すために見る。
    @ObservedObject private var network = NetworkMonitor.shared
    /// オフライン案内を出しているか。
    @State private var showOfflineAlert = false

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

    /// プレイヤーを破棄するまでの距離。preloadRadius より広く取る。
    /// 生成と破棄の閾値を同じにすると、境界をまたぐ小さなスワイプのたびに
    /// WebView の生成→破棄→生成が起きて、戻ったときに毎回ロードし直しになる。
    /// ここにヒステリシスを持たせ、少し離れたくらいでは生かしたままにする。
    private let evictRadius = 4

    /// 一度でもプレイヤーを生成したページ（動画 ID）。
    /// evictRadius の外に出るまでは生かし続け、戻ってきたときに即再生できるようにする。
    @State private var materialized: Set<String> = []

    var body: some View {
        GeometryReader { geo in
            TabView(selection: $currentIndex) {
                ForEach(Array(videos.enumerated()), id: \.element.id) { index, video in
                    ShortsPage(
                        video: video,
                        isActive: index == currentIndex,
                        // 近傍ページはプレイヤーを先に生成（プリロード）。
                        // 一度生成したページは evictRadius の外に出るまで生かし続ける。
                        isPreloaded: shouldMaterialize(index: index, video: video)
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                    .rotationEffect(.degrees(-90))          // TabView を縦ページ化する定番手法
                    .tag(index)
                }
            }
            .onChange(of: currentIndex) { _, index in
                updateMaterialized(around: index)
            }
            .onAppear {
                updateMaterialized(around: currentIndex)
            }
            .frame(width: geo.size.height, height: geo.size.width)
            .rotationEffect(.degrees(90), anchor: .topLeading)
            .offset(x: geo.size.width)                        // 回転後の位置補正
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.black)
        .ignoresSafeArea()
        .overlay(alignment: .topLeading) { closeButton }
        // オフラインなら、埋め込みプレイヤーが黙って黒のままになる前に案内する。
        //
        // 埋め込みプレイヤーはローカルの HTML を読み込む方式のため、通信が無くても
        // 「ページの読み込みは成功」してしまい、再生できないことを検知できない。
        // かといってプレイヤーの上にエラー表示を重ねるのは要件B（プレイヤーの
        // 一部・機能を覆わない）に触れるので、案内はプレイヤーの外側＝この画面の
        // 標準アラートで出し、閉じてフィードごと戻す。
        .alert(
            NSLocalizedString("shorts.offline.title", comment: ""),
            isPresented: $showOfflineAlert
        ) {
            Button(NSLocalizedString("common.ok", comment: "")) { dismiss() }
        } message: {
            Text(NSLocalizedString("shorts.offline.message", comment: ""))
        }
        .onAppear {
            if !network.isConnected { showOfflineAlert = true }
        }
        // 開いている最中に切れた場合も拾う。
        .onChange(of: network.isConnected) { _, connected in
            if !connected { showOfflineAlert = true }
        }
    }

    /// このページでプレイヤーを実体化するか。
    /// 近傍（preloadRadius 以内）か、すでに生成済みで破棄されていないページ。
    private func shouldMaterialize(index: Int, video: TrendVideo) -> Bool {
        if materialized.contains(video.videoId) { return true }
        return abs(index - currentIndex) <= preloadRadius
    }

    /// 現在位置を中心に、生かしておくプレイヤーの集合を更新する。
    /// - preloadRadius 以内: 生成する（まだなら追加）
    /// - evictRadius より外: 破棄する（WebView を解放してメモリを戻す）
    /// - その間: 現状維持（ヒステリシス。往復スワイプでの作り直しを防ぐ）
    private func updateMaterialized(around index: Int) {
        var next = materialized

        for (i, video) in videos.enumerated() {
            let distance = abs(i - index)
            if distance <= preloadRadius {
                next.insert(video.videoId)
            } else if distance > evictRadius {
                next.remove(video.videoId)
            }
        }

        if next != materialized {
            materialized = next
        }
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

            // 遠いページはサムネのみ（メモリ節約）。近づいたらプレイヤーを載せる。
            //
            // 【重要】if/else でプレイヤーごと差し替えないこと。
            // 分岐を切り替えると SwiftUI がビュー ID を変えるため、せっかく先に
            // 作った WebView が破棄され、前面に来たときゼロからロードし直しになる
            // （＝スワイプ後に黒いまま待たされる原因）。プレイヤーは一度作ったら
            // 生かしたまま、サムネを上に重ねる/外すだけにする。
            if isPreloaded {
                // 要件B/E: 公式埋め込みを 9:16 で。表示中ページのみ再生。
                // ロード中はサムネでつなぎ、黒画面待ちを避ける。
                YouTubeShortPlayerView(
                    videoId: video.videoId,
                    isActive: isActive,
                    thumbnailUrl: video.thumbnailUrl
                )
                .aspectRatio(9.0 / 16.0, contentMode: .fit)
                // 動画ごとに固定 ID を与え、TabView の再構築でプレイヤーが
                // 作り直されないようにする。
                .id(video.videoId)
            } else {
                // プレイヤー未生成のページ。サムネだけ出しておく。
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
                    // 要件D: 出典は公式埋め込みプレイヤー自体の YouTube ブランドに委ねる。
                    // 自作の赤い「YouTubeで見る」ラベルはブランドガイドライン違反のため撤去。
                    // 追加の帰属アイコンも置かず、プレイヤーのブランド＋チャンネル名表示で担保する。
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
    ///
    /// AsyncImage ではなく CachedThumbnail を使う。カード一覧で読み込み済みの絵を
    /// 再利用できるので、オフラインでも黒一色にならない。
    private var thumbnailOnly: some View {
        CachedThumbnail(urlString: video.thumbnailUrl, contentMode: .fit) {
            Color.black
        }
        .aspectRatio(9.0 / 16.0, contentMode: .fit)
    }
}
