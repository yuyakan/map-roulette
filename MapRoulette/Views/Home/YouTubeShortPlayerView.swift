//
//  YouTubeShortPlayerView.swift
//  MapRoulette
//
//  YouTube 公式埋め込みプレイヤー（YouTubePlayerKit）を用いた縦型(9:16) Shorts ラッパー。
//
//  規約対応（計画書 §1）:
//  - 要件B: 再生は公式の埋め込みプレイヤーのみ。ダウンロード/キャッシュ/音声分離は一切しない。
//           プレイヤーの UI（ボタン等）は隠さない・改造しない。
//  - 要件C: この再生画面には広告（AdMob）を一切配置しない。
//  - 要件E: 縦型 Shorts 用に 9:16 で表示し、表示中のページのみ再生する。
//
//  【なぜ YouTubePlayerKit か】
//  自前の WKWebView + iframe 方式は、iOS WKWebView が Referer/Origin を正しく付与できず
//  YouTube の埋め込み検証で onError 152/153 になる既知の制約がある（WebKit Bug 169846）。
//  単純な Referer 付与では直らないことが一次情報で確認済み。YouTubePlayerKit は
//  この Origin 問題を内部で正しく処理しており、公式埋め込みプレイヤーで安定再生できる。
//

import SwiftUI
import YouTubePlayerKit

struct YouTubeShortPlayerView: View {
    let videoId: String
    /// 表示中（フィードで前面）のときだけ再生する。
    let isActive: Bool
    /// ロード中に映像の代わりに見せるサムネ URL（カードと同じ絵）。黒画面待ちを避ける。
    let thumbnailUrl: String?

    @State private var player: YouTubePlayer

    init(videoId: String, isActive: Bool, thumbnailUrl: String? = nil) {
        self.videoId = videoId
        self.isActive = isActive
        self.thumbnailUrl = thumbnailUrl
        // 縦型 Shorts 向けの初期パラメータ。
        // 自動再生はページ表示状態(isActive)で制御するため、初期は autoPlay=false。
        _player = State(
            initialValue: YouTubePlayer(
                source: .video(id: videoId),
                parameters: .init(
                    autoPlay: false,
                    loopEnabled: true,
                    showControls: true,                          // 要件B: プレイヤー UI を隠さない
                    // cc_load_policy=0 相当。字幕をデフォルトで強制表示しない。
                    // ※端末側の字幕アクセシビリティ設定が ON の場合はこれでは消せない（埋め込みの既知制約）。
                    showCaptions: false,
                    restrictRelatedVideosToSameChannel: true
                )
            )
        )
    }

    var body: some View {
        YouTubePlayerView(player) { state in
            // ロード中/失敗時のプレースホルダ。
            switch state {
            case .idle:
                // ロード中は黒ではなくサムネを見せる（体感ラグ低減）。
                // タップ直後、映像が出るまでカードと同じ絵で埋める。
                thumbnailPlaceholder
            case .ready:
                // 再生準備完了後は映像を覆わない（覆うと音だけ聞こえて映像が見えなくなる）。
                Color.clear
            case .error:
                Color.black
            }
        }
        .onChange(of: isActive) { _, active in
            Task { await applyActive(active) }
        }
        .onAppear {
            Task { await applyActive(isActive) }
        }
        .onChange(of: videoId) { _, newId in
            Task { try? await player.load(source: .video(id: newId)) }
        }
    }

    /// ロード完了までのつなぎ表示。サムネがあればそれを、無ければ黒地。
    @ViewBuilder
    private var thumbnailPlaceholder: some View {
        if let urlString = thumbnailUrl, let url = URL(string: urlString) {
            ZStack {
                Color.black
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.black
                }
                // プレイヤー本体がタップを受けられるよう、絵はタップを透過させる。
                .allowsHitTesting(false)
            }
        } else {
            Color.black
        }
    }

    /// 表示中なら再生、外れたら一時停止（音声が残らないように）。
    private func applyActive(_ active: Bool) async {
        if active {
            try? await player.play()
        } else {
            try? await player.pause()
        }
    }
}
