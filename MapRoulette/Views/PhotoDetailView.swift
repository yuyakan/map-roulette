//
//  PhotoDetailView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/20.
//

import SwiftUI

struct PhotoDetailView: View {
    let photos: [UnsplashPhoto]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedIndex) {
                ForEach(0..<photos.count, id: \.self) { index in
                    let photo = photos[index]
                    
                    VStack {
                        AsyncImage(url: URL(string: photo.urls.regular)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        VStack(spacing: 4) {
                            Text(photo.alt_description ?? "美しい風景")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("撮影: \(photo.user.name)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
