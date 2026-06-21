//
//  AttractionDetailView.swift
//  MapRoulette
//
//  観光スポットの詳細画面。
//  地図表示・外部マップ起動・「プランに追加」を行う。
//

import SwiftUI
import MapKit

struct AttractionDetailView: View {
    let attraction: LocalizedAttractionLocation
    let prefecture: Prefecture
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion

    init(attraction: LocalizedAttractionLocation, prefecture: Prefecture) {
        self.attraction = attraction
        self.prefecture = prefecture
        _region = State(initialValue: MKCoordinateRegion(
            center: attraction.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.6)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 24)

                        Text(attraction.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(prefecture.prefectureName)
                            .font(.title3)
                            .foregroundColor(.secondary)

                        AddToPlanButton {
                            PlanItem(
                                category: .attraction,
                                prefecture: prefecture,
                                name: attraction.name
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // 説明
                    if !attraction.description.isEmpty {
                        Text(attraction.description)
                            .font(.body)
                            .lineSpacing(4)
                    }

                    // 地図
                    Map(coordinateRegion: $region, annotationItems: [attraction]) { spot in
                        MapMarker(coordinate: spot.coordinate, tint: .orange)
                    }
                    .frame(height: 220)
                    .cornerRadius(16)

                    // 外部マップで開く
                    Button {
                        openInMaps()
                    } label: {
                        Label(NSLocalizedString("attraction.open_in_maps", comment: ""), systemImage: "map.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .cornerRadius(12)
                    }

                    // YouTube / Instagram で検索
                    SocialSearchButtons(query: attraction.name)

                    // プランから開いたときの下部フローティングボタンを避ける余白
                    Color.clear.frame(height: 40)
                }
                .padding()
            }
            .navigationTitle(attraction.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.close", comment: "")) { dismiss() }
                }
            }
        }
    }

    private func openInMaps() {
        let encoded = attraction.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let appleMaps = "http://maps.apple.com/?q=\(encoded)"
        let googleMaps = "https://maps.google.com/maps?q=\(encoded)"
        if let url = URL(string: appleMaps), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: googleMaps), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "https://www.google.com/maps/search/\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}
