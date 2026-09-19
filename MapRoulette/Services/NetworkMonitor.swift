//
//  NetworkMonitor.swift
//  MapRoulette
//
//  端末がネットワークに繋がっているかの監視。
//
//  【なぜ必要か】
//  Shorts の再生は YouTube 公式の埋め込みプレイヤー（WKWebView）に委ねているが、
//  このプレイヤーはローカルの HTML 文字列を loadHTMLString で読み込む方式のため、
//  オフラインでも「ページの読み込み自体は成功」してしまう。
//  結果、WKWebView のナビゲーション失敗（didFailProvisionalNavigation 等）は発火せず、
//  iframe の中身が取れないまま ready も error も来ずに固まる＝画面が黒いだけになる。
//
//  プレイヤーからのイベントを待つ方式では offline を検知できないので、
//  到達性そのものをアプリ側で見る。
//

import Foundation
import Network
import Combine

/// 端末の接続状態を監視する共有モニタ。
@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    /// 接続されているか。
    ///
    /// 初期値は true。まだ最初の経路評価が届いていない段階で false を配ると、
    /// 起動直後に一瞬だけ「オフライン」表示が出てしまうため、
    /// 「繋がっている」前提から始めて、実際に途切れたときだけ false にする。
    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            Task { @MainActor in
                guard let self else { return }
                if self.isConnected != connected {
                    self.isConnected = connected
                }
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
