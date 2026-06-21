//
//  RichOnsenSection.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/26.
//

import SwiftUI
import MapKit

struct RichOnsenSection: View {
    let prefecture: Prefecture
    
    var body: some View {
        let onsens = prefecture.onsenItems
        
        if !onsens.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "thermometer.sun.fill")
                        .foregroundColor(.red)
                    Text("hot_spring_info".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(onsens) { onsen in
                        OnsenCard(onsen: onsen, prefecture: prefecture)
                            .padding(.horizontal, 2)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - 温泉カードコンポーネント
import MapKit
import SwiftUI

// OnsenCardの修正版（FixedOnsenItemを使用）
struct OnsenCard: View {
    let onsen: OnsenItem
    let prefecture: Prefecture
    @State private var isPressed = false
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー部分
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    onsen.onsenType.color.opacity(0.8),
                                    onsen.onsenType.color
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: onsen.imageSymbol)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(onsen.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    // カテゴリータグ
                    Label(onsen.onsenType.localizedName, systemImage: onsen.onsenType.icon)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(onsen.onsenType.color.opacity(0.2))
                        .foregroundColor(onsen.onsenType.color)
                        .clipShape(Capsule())
                }
                
                Spacer()
            }
            
            // 説明文
            Text(onsen.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // 人気度のみ表示
            HStack {
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= onsen.popularity ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(star <= onsen.popularity ? .yellow : .gray.opacity(0.3))
                    }
                }
            }
        }
        .padding(16)
        .frame(height: 150, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(isPressed ? 0.15 : 0.08),
                    radius: isPressed ? 12 : 8,
                    x: 0,
                    y: isPressed ? 4 : 2
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    onsen.onsenType.color.opacity(0.3),
                                    onsen.onsenType.color.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            showingDetail = true
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
        .fullScreenCover(isPresented: $showingDetail) {
            if let fixedOnsen = OnsenDataRepository.shared.getFixedOnsen(name: onsen.name, type: onsen.onsenType) {
                OnsenDetailView2(onsen: fixedOnsen)
            }
        }
    }
}

// OnsenDetailViewの修正版（FixedOnsenItemを使用してアプリ内地図表示）
struct OnsenDetailView2: View {
    let onsen: FixedOnsenItem
    @State private var region: MKCoordinateRegion
    @Environment(\.dismiss) private var dismiss
    
    init(onsen: FixedOnsenItem) {
        self.onsen = onsen
        // 温泉地を中心とした地図領域を設定
        self._region = State(initialValue: MKCoordinateRegion(
            center: onsen.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー
                    VStack(spacing: 16) {
                        Image(systemName: onsen.imageSymbol)
                            .font(.system(size: 60))
                            .foregroundColor(onsen.onsenType.color)
                        
                        Text(onsen.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Image(systemName: onsen.onsenType.icon)
                                .foregroundColor(onsen.onsenType.color)
                            Text(onsen.onsenType.localizedName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(onsen.onsenType.color)
                        }
                        
                        // 人気度
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < onsen.popularity ? "star.fill" : "star")
                                    .foregroundColor(.orange)
                            }
                            Text("(\(onsen.popularity)/5)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }

                        AddToPlanButton {
                            PlanItem(
                                category: .onsen,
                                prefecture: Prefecture.containingOnsen(named: onsen.name) ?? Prefecture.nearest(to: onsen.coordinate),
                                name: onsen.name
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)

                    Divider()

                    // 説明
                    VStack(alignment: .leading, spacing: 12) {
                        Text("hot_spring_features".localized)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(onsen.description)
                            .font(.body)
                            .lineSpacing(4)
                    }
                    
                    Divider()
                    
                    // マップセクション
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "map")
                                .foregroundColor(.orange)
                            Text("hot_spring_area_map".localized)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        
                        Map(coordinateRegion: $region, annotationItems: [onsen]) { onsenItem in
                            MapAnnotation(coordinate: onsenItem.coordinate) {
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 40, height: 40)
                                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                                        
                                        Image(systemName: "thermometer.sun.fill")
                                            .font(.title2)
                                            .foregroundColor(.orange)
                                    }
                                    
                                    Text(onsenItem.name)
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white.opacity(0.9))
                                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                        )
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onAppear {
                            // 地図の中心を温泉地に設定
                            region.center = onsen.coordinate
                        }
                        
                        // 外部地図アプリを開くボタン
                        Button(action: {
                            openInExternalMaps()
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                    .foregroundColor(onsen.onsenType.color)
                                Text("open_in_external_map".localized)
                                    .foregroundColor(onsen.onsenType.color)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(onsen.onsenType.color)
                            }
                            .padding()
                            .background(Color.clear)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(onsen.onsenType.color, lineWidth: 1.5)
                            )
                        }
                    }

                    // YouTube / Instagram で検索
                    SocialSearchButtons(query: onsen.name)
                }
                .padding()
            }
            .navigationBarHidden(true)

            VStack() {
                HStack {
                    HStack {
                        Button(action: {
                            InterstitialViewModel.count += 2
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .frame(width: 10, height: 14)
                                Text("back".localized)
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
        }
    }
    
    private func openInExternalMaps() {
        // 温泉名での検索クエリを作成
        let searchQuery = onsen.name
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Apple Maps検索URL
        let appleMapsSearchURL = "http://maps.apple.com/?q=\(encodedQuery)"
        
        // Google Maps検索URL
        let googleMapsSearchURL = "https://maps.google.com/maps?q=\(encodedQuery)"
        
        if let url = URL(string: appleMapsSearchURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: googleMapsSearchURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // フォールバック: ブラウザでGoogle Maps
            let webURL = "https://www.google.com/maps/search/\(encodedQuery)"
            if let url = URL(string: webURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}
