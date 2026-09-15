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
//  【スワイプで真っ黒になる問題への対処（重要）】
//  プレイヤーの ready は「iframe の準備ができた」だけで、その時点では play() を投げても
//  取りこぼされることがある。isActive を State に控えておき、ready になった/再生状態が
//  変わったタイミングで「本当に再生されているか」を照合して play を打ち直す。
//  また、実際に映像が出た（playing/buffering を観測した）までサムネを剥がさないことで、
//  「音だけ鳴って黒」「何も映らない黒」を防ぐ。
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
    /// プレイヤーが ready になったか。ready 前の play() は無視されるので、ここで待ち合わせる。
    @State private var isReady = false
    /// 実際に映像が動き出したか（playing を一度でも観測した）。サムネを剥がす判断に使う。
    @State private var hasStartedPlayback = false

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
        YouTubePlayerView(player) { _ in
            // プレースホルダは state ではなく「実際に再生が始まったか」で外す。
            // ready でも最初のフレームが出るまでは黒なので、ready を剥がす条件にしない。
            if hasStartedPlayback {
                Color.clear
            } else {
                thumbnailPlaceholder
            }
        }
        // ready になったら、そのとき前面なら再生を開始する。
        // （onChange(of: isActive) だけだと、ready 前に来た play が捨てられて黒のままになる）
        .onReceive(player.statePublisher) { state in
            let ready = state.isReady
            isReady = ready
            if ready && isActive {
                Task { await play() }
            }
            if state.isError {
                // 失敗したページを黙って黒のままにしない。サムネに戻して再試行できる状態にする。
                hasStartedPlayback = false
            }
        }
        // 再生状態を監視し、前面なのに止まっていたら play を打ち直す。
        // YouTube 側の自動再生ブロックや、スワイプ直後の取りこぼしをここで吸収する。
        .onReceive(player.playbackStatePublisher) { playbackState in
            switch playbackState {
            case .playing, .buffering:
                // 映像が動き出した。ここで初めてサムネを剥がす。
                if !hasStartedPlayback { hasStartedPlayback = true }
            case .unstarted, .cued, .paused, .ended:
                // 前面なのに再生されていないなら、もう一度 play する。
                if isActive && isReady {
                    Task { await play() }
                }
            default:
                break
            }
        }
        .onChange(of: isActive) { _, active in
            Task { await apply(active: active) }
        }
        .onAppear {
            // 生成直後に ready 済みのことがある（再利用時）。その場合ここで再生を掛ける。
            if isActive && player.state.isReady {
                Task { await play() }
            }
        }
        .onDisappear {
            // ページがフィードから外れたら必ず止める。音が残るのを防ぐ。
            Task { try? await player.pause() }
        }
        .onChange(of: videoId) { _, newId in
            // 動画が差し替わったら、待ち合わせフラグも巻き戻す。
            // （これを忘れると前の動画の hasStartedPlayback が残り、次の動画で黒画面になる）
            isReady = false
            hasStartedPlayback = false
            Task {
                try? await player.load(source: .video(id: newId))
            }
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
    private func apply(active: Bool) async {
        if active {
            await play()
        } else {
            try? await player.pause()
        }
    }

    /// 再生を要求する。ready 前なら statePublisher 側の待ち合わせに任せる。
    private func play() async {
        guard player.state.isReady else { return }
        try? await player.play()
    }
}
