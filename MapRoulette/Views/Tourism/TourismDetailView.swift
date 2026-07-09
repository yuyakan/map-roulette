//
//  TourismDetailView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/19.
//

import SwiftUI
import MapKit

struct TourismDetailView: View {
    let prefecture: Prefecture
    @State private var cameraPosition: MapCameraPosition
    @State private var isPressed = false
    @State private var selectedAttraction: LocalizedAttractionLocation? = nil
    @Environment(\.dismiss) private var dismiss

    init(prefecture: Prefecture) {
        self.prefecture = prefecture
        let tourismInfo = prefecture.tourismInfo
        self._cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: tourismInfo.region,
            span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        )))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // ヘッダー
                    VStack(spacing: 0) {
                        Text(prefecture.prefectureName)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 34)
                    
                    // 観光地マップ
                    VStack(alignment: .leading, spacing: 16) {
                        RichSectionHeader(
                            icon: "map.fill",
                            title: "tourism_detail_map".localized,
                            accent: PlanTheme.primary
                        )

                        Map(position: $cameraPosition) {
                            ForEach(prefecture.tourismInfo.attractions) { attraction in
                                Annotation(attraction.name, coordinate: attraction.coordinate) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.red)
                                            .background(Color.white)
                                            .clipShape(Circle())

                                        Text(attraction.name)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.white.opacity(0.9))
                                            .cornerRadius(4)
                                            .shadow(radius: 2)
                                    }
                                    .onTapGesture {
                                        selectedAttraction = attraction
                                    }
                                }
                            }
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // 観光地リスト
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 8) {
                                ForEach(prefecture.tourismInfo.attractions) { attraction in
                                    VStack(alignment: .leading, spacing: 6) {
                                        // アイコンとタイトル
                                        HStack(alignment: .top, spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.6)]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 24, height: 24)
                                                
                                                Image(systemName: "location.circle.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text(attraction.name)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.primary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)

                                            Spacer()
                                        }
                                        
                                        // 説明文
                                        Text(attraction.description)
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                            .lineLimit(3)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.leading, 8)
                                    .padding(.horizontal, 8)
                                    .frame(height: 80)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(
                                                color: Color.black.opacity(0.08),
                                                radius: 8,
                                                x: 0,
                                                y: 2
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                Color.blue.opacity(0.1),
                                                                Color.purple.opacity(0.05)
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 6)
                                    .onTapGesture {
                                        selectedAttraction = attraction
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        BannerAdView()
                            .frame(width: 320, height: 50)
                        Spacer()
                    }
                    
                    RichGourmetSection(prefecture: prefecture)
                    
                    HStack {
                        Spacer()
                        BannerAdView()
                            .frame(width: 320, height: 50)
                        Spacer()
                    }
                    
                    RichOnsenSection(prefecture: prefecture)
                    
                    RichSouvenirSection(prefecture: prefecture)
                        .padding(.top, prefecture.onsenItems.isEmpty ? 0 : 4)
                    
                    HStack {
                        Spacer()
                        BannerAdView()
                            .frame(width: 320, height: 50)
                        Spacer()
                    }
                    
                    RichFestivalSection(prefecture: prefecture)

                    RichOtherFestivalSection(prefecture: prefecture)

                    // 実写フォトカルーセル（写真があるスポットのみ・CC0で帰属不要）
                    photoCarousel

                    // 最下部に余白を入れてスクロールに余裕を持たせる
                    Color.clear.frame(height: 40)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedAttraction) { attraction in
                AttractionDetailView(attraction: attraction, prefecture: prefecture)
            }

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
                               Text("tourism_detail_back".localized)
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

    // MARK: - 実写フォトカルーセル

    /// 県内で写真を持つスポットを横スクロールで見せる。
    /// 写真が 1 枚も無い県では、セクションごと表示しない（従来通りの見た目）。
    @ViewBuilder
    private var photoCarousel: some View {
        let photographed = AttractionPhoto.photographedAttractions(in: prefecture)
        if !photographed.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                RichSectionHeader(
                    icon: "photo.on.rectangle.angled",
                    title: "tourism_detail_photos".localized,
                    accent: PlanTheme.primary
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(photographed) { attraction in
                            photoCard(for: attraction)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            .padding(.horizontal)
        }
    }

    /// カルーセル内の 1 枚（写真＋スポット名）。
    private func photoCard(for attraction: LocalizedAttractionLocation) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let photo = AttractionPhoto.image(for: attraction.nameKey) {
                photo
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 260, height: 180)
                    .clipped()
            }

            Text(attraction.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(width: 260, alignment: .leading)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

}

