//
//  ThumbnailLoader.swift
//  MapRoulette
//
//  トレンド動画サムネの読み込みとメモリキャッシュ。
//
//  AsyncImage はキャッシュを持たず、ビューが作り直されるたびに取得し直す。
//  ホームの県カード列はスクロールで主役の県が切り替わるたびに動画行ごと差し替わるため、
//  AsyncImage のままだと「切り替わるたびに再取得 → スクロールがカクつく」ことになる。
//  そこで
//   - 一度読んだ画像はメモリに残す（再訪時は即表示・再取得なし）
//   - 画面に出ていない県のサムネを先読みしておく（切り替わった瞬間には既に手元にある）
//  の 2 点を担う。
//
//  デコード（UIImage 化）はバックグラウンドで行い、メインスレッドを塞がない。
//

import SwiftUI
import UIKit

/// サムネ画像のメモリキャッシュ + 先読み。
@MainActor
final class ThumbnailLoader {
    static let shared = ThumbnailLoader()

    /// 読み込み済み画像。URL 文字列 → 画像。
    ///
    /// `@Published` にはしない。1 枚入るたびに全 `CachedThumbnail` が無効化され、
    /// 先読みで数十枚が同時に着弾すると通知が洪水になって、次のレイアウトパス
    /// （＝スクロール）まで反映が遅れるため。
    /// 代わりに、URL ごとの購読者（`observers`）にピンポイントで通知する。
    private(set) var images: [String: UIImage] = [:]

    /// URL ごとの「届いたら教えてほしい」購読者（トークン → ハンドラ）。
    /// 同じ URL のカードが複数並ぶことがあるので URL ごとに複数持てるようにする。
    private var observers: [String: [Int: (UIImage) -> Void]] = [:]

    /// 取得中の URL。同じ URL への二重リクエストを防ぐ。
    private var inFlight: Set<String> = []

    /// メモリを無制限に食わないための上限。超えたら古いものから捨てる。
    /// サムネは 1 枚あたり数十 KB 程度なので、200 枚でも実用上は十分小さい。
    private let capacity = 200
    /// 挿入順（capacity 超過時に古い順で捨てるため）。
    private var insertionOrder: [String] = []

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        // ディスク/メモリの URL キャッシュも効かせる（アプリ再起動後の初回を速くする）。
        config.urlCache = URLCache(memoryCapacity: 8 * 1024 * 1024,
                                   diskCapacity: 64 * 1024 * 1024,
                                   diskPath: "trend_thumbnails")
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()

    /// キャッシュ済みなら即返す（同期）。表示側はまずこれを見る。
    func cachedImage(for urlString: String) -> UIImage? {
        images[urlString]
    }

    /// 1 枚ぶんの購読。届いた時点で `handler` を呼ぶ。
    /// 既にキャッシュ済みならその場で同期的に呼び、購読は張らない。
    /// 戻り値は購読解除用のトークン（ビューが消えるときに `cancel` へ渡す）。
    @discardableResult
    func observe(_ urlString: String, handler: @escaping (UIImage) -> Void) -> Int {
        if let image = images[urlString] {
            handler(image)
            return Self.noToken
        }
        let token = nextToken
        nextToken += 1
        observers[urlString, default: [:]][token] = handler
        tokenURLs[token] = urlString
        load(urlString)
        return token
    }

    /// 購読解除。ビューが画面から消えたときに呼ぶ。
    func cancel(_ token: Int) {
        guard let urlString = tokenURLs.removeValue(forKey: token) else { return }
        observers[urlString]?.removeValue(forKey: token)
        if observers[urlString]?.isEmpty == true {
            observers.removeValue(forKey: urlString)
        }
    }

    /// 「購読していない」ことを表すトークン（キャッシュ命中時に返る）。
    static let noToken = -1

    private var nextToken = 0
    /// トークン → URL。解除時にどの URL の購読かを引くため。
    private var tokenURLs: [Int: String] = [:]

    /// 1 枚読み込む。既にキャッシュ済み／取得中なら何もしない。
    func load(_ urlString: String) {
        guard images[urlString] == nil,
              !inFlight.contains(urlString),
              let url = URL(string: urlString) else { return }

        inFlight.insert(urlString)
        Task { [weak self] in
            guard let self else { return }
            let image = await Self.fetch(url, session: self.session)
            self.inFlight.remove(urlString)
            guard let image else { return }
            self.store(image, for: urlString)
        }
    }

    /// まとめて先読みする（画面に出ていない県のサムネを事前に用意しておく用）。
    func prefetch(_ urlStrings: [String]) {
        for url in urlStrings { load(url) }
    }

    private func store(_ image: UIImage, for key: String) {
        images[key] = image
        insertionOrder.append(key)
        // 上限を超えたぶんだけ古い順に捨てる。
        // 表示中のカードが購読している URL は捨てない（捨てると絵が消えるため）。
        while insertionOrder.count > capacity,
              let oldest = insertionOrder.first(where: { observers[$0] == nil }) {
            insertionOrder.removeAll { $0 == oldest }
            images.removeValue(forKey: oldest)
        }

        // この URL を待っているカードにだけ届ける。
        if let waiting = observers.removeValue(forKey: key) {
            for (token, handler) in waiting {
                tokenURLs.removeValue(forKey: token)
                handler(image)
            }
        }
    }

    /// 取得とデコードをバックグラウンドで行う。
    /// UIImage はデコードが重いので、表示前にここで済ませておく（描画時の一瞬の固まりを防ぐ）。
    private static func fetch(_ url: URL, session: URLSession) async -> UIImage? {
        guard let (data, _) = try? await session.data(from: url) else { return nil }
        return await Task.detached(priority: .utility) {
            guard let image = UIImage(data: data) else { return nil }
            // 実際に描画されるときのデコードを先に済ませておく。
            return image.preparingForDisplay() ?? image
        }.value
    }
}

/// キャッシュ対応のサムネ表示。`AsyncImage` の置き換え。
/// キャッシュ済みなら最初のフレームから画像が出るので、スクロール中に
/// プレースホルダー → 画像の差し替えが起きない。
///
/// 画像は自分の `@State` に持ち、`ThumbnailLoader` へは URL 単位で購読する。
/// ローダー全体を `@ObservedObject` で見ると、先読みで別の県のサムネが 1 枚届くたびに
/// 画面上の全カードが無効化され、通知が詰まって反映が次のスクロールまで遅れていた。
struct CachedThumbnail<Placeholder: View>: View {
    let urlString: String
    /// 絵の収め方。カード（枠いっぱいに敷く）は fill、
    /// Shorts のページ（絵の全体を見せる）は fit。
    var contentMode: ContentMode = .fill
    @ViewBuilder let placeholder: () -> Placeholder

    /// 表示中の画像。購読が届いた時点でここに入る。
    @State private var image: UIImage?
    /// 現在の購読トークン（解除用）。
    @State private var token: Int = ThumbnailLoader.noToken

    var body: some View {
        Group {
            if ScreenshotMode.isEnabled {
                // App Store スクショ撮影モード: 他社コンテンツを写さないよう、
                // サムネを自前のモック画像に差し替える（Release では無効）。
                // ここ一箇所で差し替えれば、ホームも県詳細も Shorts のプレースホルダも
                // まとめて置き換わる（すべてこのビューを経由している）。
                Image(ScreenshotMode.mockAssetName(for: urlString))
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder()
            }
        }
        // URL が変わるたびに購読を張り替える。onAppear ではなくこれを使うのは、
        // 行の中身だけが差し替わる（ビューは作り直されない）ケースを拾うため。
        .onChange(of: urlString, initial: true) { _, newValue in
            subscribe(to: newValue)
        }
        .onDisappear {
            ThumbnailLoader.shared.cancel(token)
            token = ThumbnailLoader.noToken
        }
    }

    private func subscribe(to urlString: String) {
        let loader = ThumbnailLoader.shared
        loader.cancel(token)
        // キャッシュ済みならこの場で同期的に入るので、最初のフレームから絵が出る。
        image = loader.cachedImage(for: urlString)
        guard image == nil else {
            token = ThumbnailLoader.noToken
            return
        }
        token = loader.observe(urlString) { loaded in
            image = loaded
        }
    }
}
