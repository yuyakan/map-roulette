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

    /// 一覧カードと色を揃えるためのカテゴリ色グラデーション。
    private var categoryGradient: LinearGradient {
        LinearGradient(
            colors: [item.category.color.opacity(0.85), item.category.color],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                // 上方向にバウンスしてもヘッダー背後に白が出ないよう、
                // 画面全体の最背面にヘッダーと同じカテゴリ色を敷く（同色なので境目が出ない）。
                item.category.color
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        VStack(alignment: .leading, spacing: 18) {
                            // アクションをまとめた白カード（カラー背景から浮かせる）
                            VStack(spacing: 14) {
                                // 主アクション：プランに追加（ブランド色で主従を明確に）
                                AddToPlanButton {
                                    PlanItem(
                                        category: .gourmet,
                                        prefecture: prefecture,
                                        name: item.name
                                    )
                                }

                                // 外部リンク見出し
                                HStack(spacing: 6) {
                                    Text("gourmet.explore_more".localized)
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }

                                SocialSearchButtons(
                                    query: item.name,
                                    tabelog: TabelogSearch(areaSlug: prefecture.rawValue, keyword: item.name)
                                )
                            }
                            .planCard()

                            descriptionCard
                            infoGrid
                            recommendationsCard
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

    // MARK: - 閉じるボタン（ブランドの白丸フローティング）

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(item.category.color)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        }
        .padding(.top, 56)
        .padding(.trailing, 18)
    }

    // MARK: - ヒーローヘッダー（ブランドグラデーション）

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 上部の余白（セーフエリア分）＋カテゴリアイコン
            ZStack {
                Circle()
                    .fill(.white.opacity(0.22))
                    .frame(width: 76, height: 76)
                Image(systemName: item.imageSymbol)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(String(format: "prefecture_specialties_format".localized, prefecture.prefectureName))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
            }

            // カテゴリ・評価（白系のガラス調チップ）
            HStack(spacing: 10) {
                Label(item.category.rawValue.localized, systemImage: item.category.icon)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
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
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        // ヘッダー自身は背景を持たず、最背面の category.color をそのまま透かす（段差を出さない）。
    }

    // MARK: - 説明

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "text.quote", title: "detailed_info".localized)
            Text(item.description)
                .font(.body)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - 基本情報（行リスト形式で密度を上げる）

    private var infoGrid: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(icon: "info.circle", title: "basic_info".localized)
                .padding(.bottom, 14)

            InfoRow(icon: "yensign.circle.fill",
                    title: "price_range".localized,
                    value: item.price,
                    color: item.category.color)
            Divider().padding(.leading, 52)
            InfoRow(icon: "calendar.circle.fill",
                    title: "best_season".localized,
                    value: item.bestSeason,
                    color: item.category.color)
            Divider().padding(.leading, 52)
            InfoRow(icon: item.category.icon,
                    title: "category".localized,
                    value: item.category.rawValue.localized,
                    color: item.category.color)
            Divider().padding(.leading, 52)
            InfoRow(icon: "trophy.fill",
                    title: "popularity_rank".localized,
                    value: getPopularityText(item.popularity),
                    color: item.category.color)
        }
        .planCard()
    }

    // MARK: - おすすめの楽しみ方

    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "lightbulb.fill", title: "recommended_enjoyment".localized)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(getRecommendations(for: item), id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(item.category.color)
                            .font(.caption)
                            .padding(.top, 2)
                        Text(recommendation)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - 共通

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            // カテゴリ色のアクセントバー＋アイコン
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(categoryGradient)
                .frame(width: 4, height: 18)
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(item.category.color)
            Text(title)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
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

// 情報行コンポーネント（アイコンチップ＋ラベル＋値で横幅を活かす）
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 11, style: .continuous))

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer(minLength: 12)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
    }
}
