//
//  AttractionDetailView.swift
//  MapRoulette
//
//  観光スポットの詳細画面。
//  地図表示・外部マップ起動・「プランに追加」を行う。
//  デザインはグルメ詳細と統一（ヒーローヘッダー／アクション白カード／カード群）。
//  観光にはカテゴリ色がないため、ブランドカラー（PlanTheme）を基調にする。
//

import SwiftUI
import MapKit

struct AttractionDetailView: View {
    let attraction: LocalizedAttractionLocation
    let prefecture: Prefecture
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion

    /// 観光の基調色（ブランドのオレンジ）。
    private var accent: Color { PlanTheme.primary }

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
            ZStack(alignment: .topTrailing) {
                // 上方向バウンス時にヘッダー背後へ白が出ないよう最背面に基調色を敷く。
                accent.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        VStack(alignment: .leading, spacing: 18) {
                            actionCard
                            if !attraction.description.isEmpty {
                                descriptionCard
                            }
                            mapCard
                        }
                        .padding(.horizontal, 18)
                    }
                    .padding(.bottom, 32)
                }
                .background(PlanTheme.backgroundGradient.ignoresSafeArea())
                .ignoresSafeArea(edges: .top)

                closeButton
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - 閉じるボタン

    private var closeButton: some View {
        Button {
            InterstitialViewModel.count += 2
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(accent)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        }
        .padding(.top, 56)
        .padding(.trailing, 18)
    }

    // MARK: - ヒーローヘッダー

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.22))
                    .frame(width: 76, height: 76)
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(attraction.name)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Label(prefecture.prefectureName, systemImage: "location.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        // ヘッダー自身は背景を持たず、最背面の accent をそのまま透かす（段差を出さない）。
    }

    // MARK: - アクション白カード

    private var actionCard: some View {
        VStack(spacing: 14) {
            AddToPlanButton {
                PlanItem(
                    category: .attraction,
                    prefecture: prefecture,
                    name: attraction.name
                )
            }

            HStack(spacing: 6) {
                Text("gourmet.explore_more".localized)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                Spacer()
            }

            SocialSearchButtons(query: attraction.name)
        }
        .planCard()
    }

    // MARK: - 説明

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "text.quote", title: "detailed_info".localized)
            Text(attraction.description)
                .font(.body)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - 地図カード

    private var mapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "map", title: "attraction.open_in_maps".localized)

            Map(coordinateRegion: $region, annotationItems: [attraction]) { spot in
                MapMarker(coordinate: spot.coordinate, tint: accent)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Button {
                openInMaps()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(accent)
                        .frame(width: 32, height: 32)
                        .background(.white, in: Circle())
                    Text("attraction.open_in_maps".localized)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(accent))
                .shadow(color: accent.opacity(0.3), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - 共通

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(accent)
                .frame(width: 4, height: 18)
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(accent)
            Text(title)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
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
