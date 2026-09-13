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
import Combine

/// サムネ画像のメモリキャッシュ + 先読み。
@MainActor
final class ThumbnailLoader: ObservableObject {
    static let shared = ThumbnailLoader()

    /// 読み込み済み画像。URL 文字列 → 画像。
    /// NSCache ではなく辞書で持つのは、SwiftUI に「増えたこと」を伝えて
    /// 表示中のカードを更新する必要があるため（NSCache は変更通知を出せない）。
    @Published private(set) var images: [String: UIImage] = [:]

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
        while insertionOrder.count > capacity {
            let oldest = insertionOrder.removeFirst()
            images.removeValue(forKey: oldest)
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
struct CachedThumbnail<Placeholder: View>: View {
    let urlString: String
    @ViewBuilder let placeholder: () -> Placeholder

    @ObservedObject private var loader = ThumbnailLoader.shared

    var body: some View {
        Group {
            if let image = loader.cachedImage(for: urlString) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder()
            }
        }
        .task(id: urlString) {
            loader.load(urlString)
        }
    }
}
