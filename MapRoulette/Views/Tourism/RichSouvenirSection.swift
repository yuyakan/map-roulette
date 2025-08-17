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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // ヘッダー
            HStack {
                Image(systemName: "gift.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "souvenir.title"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(String(format: String(localized: "souvenir.memory"), prefecture.prefectureName))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // カテゴリフィルターボタン
                Menu {
                    Button("food_category_all".localized) {
                        selectedCategory = nil
                    }
                    
                    ForEach(SouvenirCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Label(category.rawValue.localized, systemImage: category.icon)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
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
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showAllItems = true
                    }
                }) {
                    HStack {
                        Text("load_more_groumet".localized)
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            .background(Color.blue.opacity(0.05))
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .sheet(item: $selectedItem) { item in
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
                    .lineLimit(1)
                
                Text(item.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // ボトム情報
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "calendar.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text(item.bestSeason)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // カテゴリータグ
                    Text(item.category.rawValue.localized)
                        .font(.caption2)
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ヘッダー画像風エリア
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        item.category.color.opacity(0.3),
                                        item.category.color.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 200)
                        
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(item.category.color)
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: item.imageSymbol)
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 4) {
                                Text(item.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text(prefecture.prefectureName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // 詳細情報
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "souvenir.about"))
                            .font(.headline)
                        
                        Text(item.description)
                            .font(.body)
                            .lineSpacing(4)
                        
                        // 詳細情報カード
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            SInfoCard(title: "souvenir.bestSeason".localized, value: item.bestSeason, icon: "calendar.circle.fill", color: .blue)
                            SInfoCard(title: "souvenir.category".localized, value: item.category.rawValue.localized, icon: item.category.icon, color: item.category.color)
                            SInfoCard(title: "souvenir.popularity".localized, value: "\(item.popularity)/5", icon: "star.fill", color: .yellow)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle(String(localized: "souvenir.detailTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("back".localized) {
                        dismiss()
                    }
                }
            }
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
