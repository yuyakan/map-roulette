//
//  UnsplashPhoto.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/19.
//

import SwiftUI
import Combine

// Unsplash API用の写真データ構造
struct UnsplashPhoto: Codable, Identifiable {
    let id: String
    let urls: PhotoURLs
    let alt_description: String?
    let user: PhotoUser
    let links: PhotoLinks

    struct PhotoURLs: Codable {
        let regular: String
        let small: String
    }

    struct PhotoUser: Codable {
        let name: String
        let username: String
        let links: UserLinks

        struct UserLinks: Codable {
            let html: String
        }
    }

    struct PhotoLinks: Codable {
        // 写真を「使用」したときに通知するエンドポイント（API ガイドライン要件）
        let download_location: String
    }

    /// Unsplash API ガイドラインに沿った撮影者プロフィールURL（utm パラメータ付き）。
    var photographerURL: URL? {
        URL(string: "\(user.links.html)?utm_source=\(UnsplashConfig.appName)&utm_medium=referral")
    }

    /// クレジット内の "Unsplash" リンク先（utm パラメータ付き）。
    var unsplashURL: URL? {
        URL(string: "https://unsplash.com/?utm_source=\(UnsplashConfig.appName)&utm_medium=referral")
    }
}

enum UnsplashConfig {
    /// utm_source に用いるアプリ名（Unsplash 登録アプリ名に合わせる）。
    static let appName = "tabisaki_choice"
}

struct UnsplashResponse: Codable {
    let results: [UnsplashPhoto]
}

// 写真取得管理クラス
class PhotoManager: ObservableObject {
    @Published var photos: [UnsplashPhoto] = []
    @Published var isLoading = false
    
    private let accessKey = "-HMongpC8DFVk3LtePbJdIA3jzvSaWHg-tPwFWTpJDQ" // 実際のAPIキーに置き換え
    
    func fetchPhotos(for keyword: String) {
        isLoading = true
        guard let url = URL(string: "https://api.unsplash.com/search/photos?query=\(keyword)&per_page=10&client_id=\(accessKey)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                guard let data = data, error == nil else { return }
                
                do {
                    let result = try JSONDecoder().decode(UnsplashResponse.self, from: data)
                    self.photos = result.results
                    // API ガイドライン: 取得した写真を表示（使用）する際は download_location を叩く。
                    result.results.forEach { self.trackDownload(for: $0) }
                } catch {
                    print("写真の取得に失敗しました: \(error)")
                }
            }
        }.resume()
    }

    /// Unsplash API ガイドラインで required の「ダウンロードトリガー」。
    /// 写真を表示・使用するたびに links.download_location へリクエストを送る。
    private func trackDownload(for photo: UnsplashPhoto) {
        guard var components = URLComponents(string: photo.links.download_location) else { return }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: "client_id", value: accessKey))
        components.queryItems = items
        guard let url = components.url else { return }
        URLSession.shared.dataTask(with: url).resume()
    }
}
