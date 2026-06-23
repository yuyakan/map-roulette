//
//  RichSouvenirSection.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/27.
//

import SwiftUI

struct RichSouvenirSection: View {
    let prefecture: Prefecture
    @State private var selectedCategory: SouvenirCategory? = nil
    @State private var showAllItems = false
    @State private var selectedItem: SouvenirItem? = nil
    
    var filteredItems: [SouvenirItem] {
        let items = prefecture.souvenirItems
        if let category = selectedCategory {
            return items.filter { $0.category == category }
        }
        return showAllItems ? items : Array(items.prefix(4))
    }
    
    /// お土産セクションの基調色。
    private let accent = Color(red: 0.86, green: 0.35, blue: 0.58)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ヘッダー（統一スタイル＋フィルターメニュー）
            RichSectionHeader(
                icon: "gift.fill",
                title: String(localized: "souvenir.title"),
                subtitle: String(format: String(localized: "souvenir.memory"), prefecture.prefectureName),
                accent: accent,
                trailing: AnyView(
                    Menu {
                        Button("food_category_all".localized) { selectedCategory = nil }
                        ForEach(SouvenirCategory.allCases, id: \.self) { category in
                            Button(action: { selectedCategory = category }) {
                                Label(category.rawValue.localized, systemImage: category.icon)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.title3)
                            .foregroundColor(accent)
                    }
                )
            )
            
            // カテゴリタグ（選択中の場合）
            if let category = selectedCategory {
                HStack {
                    Label(category.rawValue.localized, systemImage: category.icon)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(category.color.opacity(0.2))
                        .foregroundColor(category.color)
                        .clipShape(Capsule())
                    
                    Button("groumet_clear".localized) {
                        selectedCategory = nil
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            // お土産アイテムのグリッド
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(filteredItems) { item in
                    SouvenirItemCard(item: item) {
                        selectedItem = item
                    }
                }
            }
            
            // もっと見るボタン
            if !showAllItems && prefecture.souvenirItems.count > 4 && selectedCategory == nil {
                LoadMoreButton(title: "load_more_groumet".localized, accent: accent) {
                    withAnimation(.easeInOut(duration: 0.3)) { showAllItems = true }
                }
            }
        }
        .padding(.horizontal)
        .fullScreenCover(item: $selectedItem) { item in
            SouvenirDetailView(item: item, prefecture: prefecture)
        }
    }
}

// 個別のお土産アイテムカード
struct SouvenirItemCard: View {
    let item: SouvenirItem
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // トップセクション（アイコンと人気度）
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    item.category.color.opacity(0.8),
                                    item.category.color
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.imageSymbol)
                        .font(.title3)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 人気度スター
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= item.popularity ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(star <= item.popularity ? .yellow : .gray.opacity(0.3))
                    }
                }
            }
            
            // メイン情報
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // ボトム情報
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text(item.bestSeason)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Spacer()

                    // カテゴリータグ
                    Text(item.category.tagName)
                        .font(.caption2)
                        .lineLimit(1)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.category.color.opacity(0.2))
                        .foregroundColor(item.category.color)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: isPressed ? 2 : 8,
                    x: 0,
                    y: isPressed ? 1 : 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            item.category.color.opacity(0.3),
                            item.category.color.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // タップ時のアクション
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                // 詳細画面を表示
                onTap()
            }
        }
    }
}

// お土産詳細ビュー
struct SouvenirDetailView: View {
    let item: SouvenirItem
    let prefecture: Prefecture
    @Environment(\.dismiss) private var dismiss

    private var accent: Color { item.category.color }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            accent.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    VStack(alignment: .leading, spacing: 18) {
                        actionCard
                        descriptionCard
                        infoCard
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

    private var closeButton: some View {
        Button { dismiss() } label: {
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle().fill(.white.opacity(0.22)).frame(width: 76, height: 76)
                Image(systemName: item.imageSymbol)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(prefecture.prefectureName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
            }

            HStack(spacing: 10) {
                Label(item.category.rawValue.localized, systemImage: item.category.icon)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(.white.opacity(0.22), in: Capsule())
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= item.popularity ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(star <= item.popularity ? .white : .white.opacity(0.4))
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 22).padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        // ヘッダー自身は背景を持たず、最背面の accent をそのまま透かす（段差を出さない）。
    }

    private var actionCard: some View {
        VStack(spacing: 14) {
            AddToPlanButton {
                PlanItem(category: .souvenir, prefecture: prefecture, name: item.name)
            }
            HStack(spacing: 6) {
                Text("gourmet.explore_more".localized)
                    .font(.caption.weight(.bold)).foregroundColor(.secondary)
                Spacer()
            }
            SocialSearchButtons(query: item.name)
        }
        .planCard()
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "text.quote", title: String(localized: "souvenir.about"))
            Text(item.description).font(.body).lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(icon: "info.circle", title: "basic_info".localized)
                .padding(.bottom, 14)
            InfoRow(icon: "yensign.circle.fill", title: "price_range".localized, value: item.price, color: accent)
            Divider().padding(.leading, 52)
            InfoRow(icon: "calendar.circle.fill", title: "souvenir.bestSeason".localized, value: item.bestSeason, color: accent)
            Divider().padding(.leading, 52)
            InfoRow(icon: item.category.icon, title: "souvenir.category".localized, value: item.category.rawValue.localized, color: accent)
            Divider().padding(.leading, 52)
            InfoRow(icon: "trophy.fill", title: "souvenir.popularity".localized, value: "\(item.popularity)/5", color: accent)
        }
        .planCard()
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2, style: .continuous).fill(accent).frame(width: 4, height: 18)
            Image(systemName: icon).font(.subheadline.weight(.semibold)).foregroundColor(accent)
            Text(title).font(.system(.headline, design: .rounded)).fontWeight(.bold)
        }
    }
}

// 情報カードコンポーネント
struct SInfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
