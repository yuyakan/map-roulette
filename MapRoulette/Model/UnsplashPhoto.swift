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
    
    struct PhotoURLs: Codable {
        let regular: String
        let small: String
    }
    
    struct PhotoUser: Codable {
        let name: String
    }
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
                } catch {
                    print("写真の取得に失敗しました: \(error)")
                }
            }
        }.resume()
    }
}
