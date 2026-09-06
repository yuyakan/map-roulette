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

    @State private var player: YouTubePlayer

    init(videoId: String, isActive: Bool) {
        self.videoId = videoId
        self.isActive = isActive
        // 縦型 Shorts 向けの初期パラメータ。
        // 自動再生はページ表示状態(isActive)で制御するため、初期は autoPlay=false。
        _player = State(
            initialValue: YouTubePlayer(
                source: .video(id: videoId),
                parameters: .init(
                    autoPlay: false,
                    loopEnabled: true,
                    showControls: true,                          // 要件B: プレイヤー UI を隠さない
                    restrictRelatedVideosToSameChannel: true
                )
            )
        )
    }

    var body: some View {
        YouTubePlayerView(player) { state in
            // ロード中/失敗時のプレースホルダ（黒地）。
            switch state {
            case .idle:
                // ロード中のみ黒プレースホルダ。
                Color.black
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

    /// 表示中なら再生、外れたら一時停止（音声が残らないように）。
    private func applyActive(_ active: Bool) async {
        if active {
            try? await player.play()
        } else {
            try? await player.pause()
        }
    }
}
