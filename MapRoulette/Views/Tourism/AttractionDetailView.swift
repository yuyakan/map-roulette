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

    /// このスポットの同梱写真（CC0・無ければ nil）。
    /// ある場合はヘッダー全面に敷き、無い場合は従来通りカラーヘッダーのまま。
    private var photo: Image? { AttractionPhoto.image(for: attraction.nameKey) }

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
                            MediumRectangleAdView(adUnitID: adUnitIdDetailBanner)
                            mapCard
                        }
                        .padding(.horizontal, 18)
                    }
                    .padding(.bottom, 32)
                }
                // グラデーションをやめ、カードと同じ系統のシステム背景色（ライト=白）。
                // ダークでも破綻しないよう固定色にはしない。
                .background(Color(.systemBackground).ignoresSafeArea())
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
        // 写真がある場合はヘッダー全面に写真を敷き、その上に暗いグラデーションを重ねて
        // 白文字の可読性を確保する。写真が無い場合は最背面の accent をそのまま透かす。
        titleBlock
            .padding(.horizontal, 22)
            .padding(.top, 150)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if let photo {
                    // .fill は容器より大きく描画されるため、背景側ではサイズを決めず
                    // 外側で clipped() してヘッダー矩形に収める（左右へのはみ出し防止）。
                    photo
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(headerScrim)
                } else {
                    // 写真が無い場合は従来のカラーヘッダー。本文背景が不透明色に
                    // なったため最背面の accent は透けない。ここで自前に敷く。
                    accent
                }
            }
            .clipped()
    }

    /// 写真の上でもタイトルが読めるようにする暗幕（下へ向かって濃くなる）。
    private var headerScrim: some View {
        LinearGradient(
            colors: [.black.opacity(0.1), .black.opacity(0.35), .black.opacity(0.65)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// スポット名＋県名（写真あり／なしで共通）。
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(attraction.name)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(prefecture.prefectureName)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .shadow(color: .black.opacity(photo == nil ? 0 : 0.35), radius: 6, y: 1)
    }

    // MARK: - カード枠線

    /// 背景を白（systemBackground）にしたため、白いカードが背景と同化する。
    /// planCard() の形状に合わせて枠線を重ね、モジュールの境界を明示する。
    /// 色は primary（ライト=黒／ダーク=白）でダークモードでも見える。
    /// planCard() 自体は他画面と共有のため、この画面内だけで上から重ねる。
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
            .stroke(Color.primary, lineWidth: 1)
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
        .overlay(cardBorder)
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
        .overlay(cardBorder)
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
        .overlay(cardBorder)
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
