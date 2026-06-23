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

    /// 温泉セクションの基調色。
    private let accent = Color(red: 0.13, green: 0.58, blue: 0.66)

    var body: some View {
        let onsens = prefecture.onsenItems

        if !onsens.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                RichSectionHeader(
                    icon: "thermometer.sun.fill",
                    title: "hot_spring_info".localized,
                    accent: accent
                )

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
            // ヘッダー部分（アイコンを上段に置き、タイトルはカード全幅を使えるようにする）
            HStack {
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

                Spacer()

                // 人気度スター
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= onsen.popularity ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(star <= onsen.popularity ? .yellow : .gray.opacity(0.3))
                    }
                }
            }

            // タイトル＋カテゴリタグ（カード全幅を使える独立行）
            VStack(alignment: .leading, spacing: 6) {
                Text(onsen.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)

                // カテゴリータグ
                Label(onsen.onsenType.tagName, systemImage: onsen.onsenType.icon)
                    .font(.caption2)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(onsen.onsenType.color.opacity(0.2))
                    .foregroundColor(onsen.onsenType.color)
                    .clipShape(Capsule())
            }

            // 説明文
            Text(onsen.description)
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
                OnsenDetailView(onsen: fixedOnsen)
            }
        }
    }
}

