//
//  GourmetDetailView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/20.
//

import SwiftUI

struct GourmetDetailView: View {
    let item: GourmetItem
    let prefecture: Prefecture
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ヘッダーセクション（画像なし）
                    VStack(spacing: 20) {
                        // 大きなアイコンヘッダー
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
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: item.imageSymbol)
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        
                        // タイトル情報
                        VStack(spacing: 8) {
                            Text(item.name)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [item.category.color, item.category.color.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .multilineTextAlignment(.center)
                            
                            Text(String(format: "prefecture_specialties_format".localized, prefecture.prefectureName))
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            // 人気度表示
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= item.popularity ? "star.fill" : "star")
                                        .font(.title3)
                                        .foregroundColor(star <= item.popularity ? .yellow : .gray.opacity(0.3))
                                }
                            }
                            .padding(.top, 8)

                            AddToPlanButton {
                                PlanItem(
                                    category: .gourmet,
                                    prefecture: prefecture,
                                    name: item.name
                                )
                            }
                            .padding(.top, 4)
                        }

                        // カテゴリータグ
                        Label(item.category.rawValue.localized, systemImage: item.category.icon)
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(item.category.color.opacity(0.2))
                            .foregroundColor(item.category.color)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // 説明文
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.quote")
                                    .foregroundColor(.blue)
                                Text("detailed_info".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(item.description)
                                .font(.body)
                                .lineSpacing(6)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                        .stroke(item.category.color.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // 詳細情報カード
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.green)
                                Text("basic_info".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                InfoCard(icon: "yensign.circle.fill", title: "price_range".localized, value: item.price, color: .green)
                                InfoCard(icon: "calendar.circle.fill", title: "best_season".localized, value: item.bestSeason, color: .orange)
                                InfoCard(icon: item.category.icon, title: item.category.rawValue.localized, value: item.category.rawValue.localized, color: item.category.color)
                                InfoCard(icon: "trophy.fill", title: "popularity_rank".localized, value: getPopularityText(item.popularity), color: .purple)
                            }
                        }
                        
                        // おすすめの楽しみ方
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("recommended_enjoyment".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(getRecommendations(for: item), id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                            .padding(.top, 2)
                                        
                                        Text(recommendation)
                                            .font(.subheadline)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }

                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // 閉じるボタン
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    Spacer()
                }
            )
        }
    }
    
    private func getPopularityText(_ popularity: Int) -> String {
        switch popularity {
        case 5: return "★★★★★"
        case 4: return "★★★★☆"
        case 3: return "★★★☆☆"
        case 2: return "★★☆☆☆"
        case 1: return "★☆☆☆☆"
        default: return "☆☆☆☆☆"
        }
    }
    
    private func getRecommendations(for item: GourmetItem) -> [String] {
        switch item.category {
        case .ramen:
            return [
                NSLocalizedString("ramen_tip_1", comment: "Tip for enjoying ramen"),
                NSLocalizedString("ramen_tip_2", comment: "Tip for eating ramen hot"),
                NSLocalizedString("ramen_tip_3", comment: "Tip for finding popular ramen shops")
            ]
        case .seafood:
            return [
                NSLocalizedString("seafood_tip_1", comment: "Tip for enjoying seasonal seafood"),
                NSLocalizedString("seafood_tip_2", comment: "Tip for buying at local markets"),
                NSLocalizedString("seafood_tip_3", comment: "Tip for various cooking methods")
            ]
        case .meat:
            return [
                NSLocalizedString("meat_tip_1", comment: "Tip for specialty meat restaurants"),
                NSLocalizedString("meat_tip_2", comment: "Tip for local cooking methods"),
                NSLocalizedString("meat_tip_3", comment: "Tip for casual enjoyment")
            ]
        case .sweets:
            return [
                NSLocalizedString("sweets_tip_1", comment: "Tip for taking as souvenirs"),
                NSLocalizedString("sweets_tip_2", comment: "Tip for enjoying with tea"),
                NSLocalizedString("sweets_tip_3", comment: "Tip for traditional sweet shops")
            ]
        case .local:
            return [
                NSLocalizedString("local_tip_1", comment: "Tip for authentic local cuisine"),
                NSLocalizedString("local_tip_2", comment: "Tip for learning culture"),
                NSLocalizedString("local_tip_3", comment: "Tip for choosing restaurants")
            ]
        case .drinks:
            return [
                NSLocalizedString("drinks_tip_1", comment: "Tip for brewery tours"),
                NSLocalizedString("drinks_tip_2", comment: "Tip for pairing with food"),
                NSLocalizedString("drinks_tip_3", comment: "Tip for taking as souvenirs")
            ]
        case .vegetables:
            return [
                NSLocalizedString("vegetables_tip_1", comment: "Tip for buying fresh produce"),
                NSLocalizedString("vegetables_tip_2", comment: "Tip for seasonal enjoyment"),
                NSLocalizedString("vegetables_tip_3", comment: "Tip for processed products")
            ]
        }
    }
}

// 情報カードコンポーネント
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
