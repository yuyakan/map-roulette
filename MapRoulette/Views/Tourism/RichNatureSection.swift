//
//  RichNatureSection.swift
//  MapRoulette
//
//  県詳細（TourismDetailView）の「自然」セクション。
//  自然タブ（NatureSpotMapView）で扱っている固定スポット（夜景・星空・海・キャンプ）の
//  うち、その県に属するものだけを抜き出してカード表示する。
//  タップで自然タブと同じ詳細（NatureSpotDetailView）を全画面で開く。
//
//  データの出所は NatureSpotDataRepository.shared（自然タブと同一）。ここでは
//  prefecture でフィルタするだけで、スポット定義は複製しない（単一の真実の源）。
//

import SwiftUI

struct RichNatureSection: View {
    let prefecture: Prefecture
    /// お土産セクションと同じく、初期は先頭4件だけ表示し「もっと見る」で全件展開する。
    @State private var showAllItems = false

    /// 自然セクションの基調色（自然タブのキャンプ＝緑に寄せた、落ち着いた緑）。
    private let accent = Color(red: 0.20, green: 0.55, blue: 0.36)

    /// この県に属する自然スポット（自然タブと同じデータを prefecture で絞り込む）。
    /// 並びは自然タブのデータ定義順（夜景→星空→海→キャンプ）をそのまま踏襲する。
    static func spots(in prefecture: Prefecture) -> [FixedNatureSpotItem] {
        NatureSpotDataRepository.shared.allFixedSpots
            .filter { $0.prefecture == prefecture }
    }

    private var spots: [FixedNatureSpotItem] {
        Self.spots(in: prefecture)
    }

    /// 実際に表示する件数（他セクションと同じ「最初4件」ルール）。
    private var displayedSpots: [FixedNatureSpotItem] {
        showAllItems ? spots : Array(spots.prefix(4))
    }

    var body: some View {
        if !spots.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                RichSectionHeader(
                    icon: "leaf.fill",
                    title: "tourism_detail_nature".localized,
                    accent: accent
                )

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(displayedSpots) { spot in
                        NatureSectionCard(spot: spot)
                            .padding(.horizontal, 2)
                    }
                }

                // 5件以上ある県だけ「もっと見る」を出す（お土産セクションと同じ挙動）。
                if !showAllItems && spots.count > 4 {
                    LoadMoreButton(title: "load_more_groumet".localized, accent: accent) {
                        withAnimation(.easeInOut(duration: 0.3)) { showAllItems = true }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - 自然スポットカード（県詳細用）

/// 県詳細の自然セクションで使うカード。温泉セクション（OnsenCard）と同じ見た目・挙動に
/// 揃え、タップで自然タブと同じ NatureSpotDetailView を全画面で開く。
private struct NatureSectionCard: View {
    let spot: FixedNatureSpotItem
    @State private var isPressed = false
    @State private var showingDetail = false

    private var typeColor: Color { spot.spotType.color }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー部分（アイコン＋人気度スター）
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    typeColor.opacity(0.8),
                                    typeColor
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: spot.imageSymbol)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }

                Spacer()

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= spot.popularity ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(star <= spot.popularity ? .yellow : .gray.opacity(0.3))
                    }
                }
            }

            // タイトル＋カテゴリタグ
            VStack(alignment: .leading, spacing: 6) {
                Text(spot.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)

                Label(spot.spotType.localizedName, systemImage: spot.spotType.icon)
                    .font(.caption2)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(typeColor.opacity(0.2))
                    .foregroundColor(typeColor)
                    .clipShape(Capsule())
            }

            // 説明文
            Text(spot.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(height: 180, alignment: .top)
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
                                    typeColor.opacity(0.3),
                                    typeColor.opacity(0.1)
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
        // 押し込みアニメは onTapGesture 内で完結させる。DragGesture は使わない
        // （minimumDistance:0 の DragGesture は親 ScrollView の縦スクロールを奪うため）。
        // グルメ／祭りセクション（GourmetItemCard）と同じ方式に揃える。
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                showingDetail = true
            }
        }
        .fullScreenCover(isPresented: $showingDetail) {
            NatureSpotDetailView(spot: spot)
        }
    }
}
