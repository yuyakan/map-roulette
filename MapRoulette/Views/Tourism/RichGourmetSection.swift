//
//  RichGourmetSection.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/20.
//

import SwiftUI

// リッチなグルメセクションのView
struct RichGourmetSection: View {
    let prefecture: Prefecture
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showAllItems = false
    @State private var selectedItem: GourmetItem? = nil
    
    var filteredItems: [GourmetItem] {
        let items = prefecture.gourmetItems
        if let category = selectedCategory {
            return items.filter { $0.category == category }
        }
        return showAllItems ? items : Array(items.prefix(4))
    }
    
    /// グルメセクションの基調色。
    private let accent = Color(red: 0.93, green: 0.45, blue: 0.13)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ヘッダー（統一スタイル＋フィルターメニュー）
            RichSectionHeader(
                icon: "fork.knife",
                title: "famous_gourmet_title".localized,
                subtitle: String(format: NSLocalizedString("taste_prefecture_format", comment: "Prefecture taste format"), prefecture.prefectureName),
                accent: accent,
                trailing: AnyView(
                    Menu {
                        Button("food_category_all".localized) { selectedCategory = nil }
                        ForEach(FoodCategory.allCases, id: \.self) { category in
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
            
            // グルメアイテムのグリッド
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(filteredItems) { item in
                    GourmetItemCard(item: item) {
                        selectedItem = item
                    }
                }
            }
            
            // もっと見るボタン
            if !showAllItems && prefecture.gourmetItems.count > 4 && selectedCategory == nil {
                LoadMoreButton(title: "load_more_groumet".localized, accent: accent) {
                    withAnimation(.easeInOut(duration: 0.3)) { showAllItems = true }
                }
            }
        }
        .padding(.horizontal)
        .fullScreenCover(item: $selectedItem) { item in
            GourmetDetailView(item: item, prefecture: prefecture)
        }
    }
}

// 個別のグルメアイテムカード
struct GourmetItemCard: View {
    let item: GourmetItem
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
                HStack {
                    Image(systemName: "yensign.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text(item.price)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
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
