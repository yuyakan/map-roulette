//
//  FeativalTabView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/08/04.
//

import SwiftUI
import MapKit

// MARK: - 統合祭りカテゴリー（既存のFestivalCategoryとOtherFestivalCategoryを統合）
enum IntegratedFestivalCategory: String, CaseIterable {
    // 既存のFestivalCategory
    case summer
    case fireworks
    case traditional
    case dance
    case food
    case seasonal
    case religious
    
    // OtherFestivalCategory
    case spring
    case autumn
    case winter
    case sakura
    case illumination
    case snow
    case traditionalOther
    
    var localizedName: String {
        switch self {
        case .summer:
            return NSLocalizedString("festival.summer", comment: "夏祭り")
        case .fireworks:
            return NSLocalizedString("festival.fireworks", comment: "花火大会")
        case .traditional:
            return NSLocalizedString("festival.traditional", comment: "伝統祭り")
        case .dance:
            return NSLocalizedString("festival.dance", comment: "踊り祭り")
        case .food:
            return NSLocalizedString("festival.food", comment: "食の祭り")
        case .seasonal:
            return NSLocalizedString("festival.seasonal", comment: "季節祭り")
        case .religious:
            return NSLocalizedString("festival.religious", comment: "宗教祭り")
        case .spring:
            return NSLocalizedString("otherFestival.spring", comment: "春祭り")
        case .autumn:
            return NSLocalizedString("otherFestival.autumn", comment: "秋祭り")
        case .winter:
            return NSLocalizedString("otherFestival.winter", comment: "冬祭り")
        case .sakura:
            return NSLocalizedString("otherFestival.sakura", comment: "桜まつり")
        case .illumination:
            return NSLocalizedString("otherFestival.illumination", comment: "イルミネーション")
        case .snow:
            return NSLocalizedString("otherFestival.snow", comment: "雪まつり")
        case .traditionalOther:
            return NSLocalizedString("otherFestival.traditional", comment: "伝統行事")
        }
    }
    
    var icon: String {
        switch self {
        case .summer: return "sun.max.fill"
        case .fireworks: return "sparkles"
        case .traditional, .traditionalOther: return "building.columns.fill"
        case .dance: return "figure.dance"
        case .food: return "fork.knife"
        case .seasonal: return "leaf.fill"
        case .religious: return "building.fill"
        case .spring: return "leaf.fill"
        case .autumn: return "leaf.arrow.circlepath"
        case .winter: return "snowflake"
        case .sakura: return "tree.fill"
        case .illumination: return "lightbulb.fill"
        case .snow: return "cloud.snow.fill"
        }
    }
    
    /// カテゴリ色。白文字を載せても読めるよう明度・彩度を手調整した値に統一。
    var color: Color {
        switch self {
        case .summer:                       return Color(red: 0.93, green: 0.45, blue: 0.13) // オレンジ
        case .fireworks:                    return Color(red: 0.55, green: 0.38, blue: 0.78) // パープル
        case .traditional, .traditionalOther: return Color(red: 0.60, green: 0.42, blue: 0.28) // ブラウン
        case .dance:                        return Color(red: 0.86, green: 0.35, blue: 0.58) // ピンク
        case .food:                         return Color(red: 0.24, green: 0.62, blue: 0.40) // グリーン
        case .seasonal:                     return Color(red: 0.16, green: 0.50, blue: 0.85) // ブルー
        case .religious:                    return Color(red: 0.40, green: 0.40, blue: 0.78) // インディゴ
        case .spring:                       return Color(red: 0.24, green: 0.62, blue: 0.40) // グリーン
        case .autumn:                       return Color(red: 0.85, green: 0.45, blue: 0.20) // オレンジ
        case .winter:                       return Color(red: 0.16, green: 0.50, blue: 0.85) // ブルー
        case .sakura:                       return Color(red: 0.86, green: 0.35, blue: 0.58) // ピンク
        case .illumination:                 return Color(red: 0.82, green: 0.58, blue: 0.13) // アンバー
        case .snow:                         return Color(red: 0.13, green: 0.58, blue: 0.66) // ティール
        }
    }
}

// MARK: - 統合祭りアイテム
struct IntegratedFestivalItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let category: IntegratedFestivalCategory
    let month: String
    let duration: String
    let scale: Int
    let imageSymbol: String
    let location: String
    let features: [String]
    let festivalType: FestivalType
    let coordinate: CLLocationCoordinate2D? // 旅行プラン用の位置情報（変換元から引き継ぐ）

    enum FestivalType {
        case festival
        case other
    }
    
    static func == (lhs: IntegratedFestivalItem, rhs: IntegratedFestivalItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - 祭りと都道府県の組み合わせ（統合版）
struct IntegratedFestivalWithPrefecture: Identifiable {
    let festival: IntegratedFestivalItem
    let prefecture: Prefecture
    
    var id: UUID { festival.id }
}

// MARK: - メインビュー（全祭り比較表示・統合版）
struct AllFestivalsComparisonView: View {
    @State private var selectedFestival: IntegratedFestivalWithPrefecture?
    @State private var selectedCategory: IntegratedFestivalCategory? = nil
    @State private var selectedMonth: String? = nil
    @State private var selectedScale: Int? = nil
    @State private var selectedType: IntegratedFestivalItem.FestivalType? = nil
    @State private var searchText = ""
    @State private var modalDismissed = false
    
    let interstitial = InterstitialViewModel()
    
    // FestivalItemからIntegratedFestivalItemへの変換
    private func convertFestivalItem(_ item: FestivalItem, prefecture: Prefecture) -> IntegratedFestivalItem {
        let integratedCategory: IntegratedFestivalCategory
        switch item.category {
        case .summer: integratedCategory = .summer
        case .fireworks: integratedCategory = .fireworks
        case .traditional: integratedCategory = .traditional
        case .dance: integratedCategory = .dance
        case .food: integratedCategory = .food
        case .seasonal: integratedCategory = .seasonal
        case .religious: integratedCategory = .religious
        }
        
        return IntegratedFestivalItem(
            name: item.name,
            description: item.description,
            category: integratedCategory,
            month: item.month,
            duration: item.duration,
            scale: item.scale,
            imageSymbol: item.imageSymbol,
            location: item.location,
            features: item.features,
            festivalType: .festival,
            coordinate: item.coordinate
        )
    }
    
    // OtherFestivalItemからIntegratedFestivalItemへの変換
    private func convertOtherFestivalItem(_ item: OtherFestivalItem, prefecture: Prefecture) -> IntegratedFestivalItem {
        let integratedCategory: IntegratedFestivalCategory
        switch item.category {
        case .spring: integratedCategory = .spring
        case .autumn: integratedCategory = .autumn
        case .winter: integratedCategory = .winter
        case .sakura: integratedCategory = .sakura
        case .illumination: integratedCategory = .illumination
        case .snow: integratedCategory = .snow
        case .traditional: integratedCategory = .traditionalOther
        }
        
        return IntegratedFestivalItem(
            name: item.name,
            description: item.description,
            category: integratedCategory,
            month: item.month,
            duration: item.duration,
            scale: item.scale,
            imageSymbol: item.imageSymbol,
            location: item.location,
            features: item.features,
            festivalType: .other,
            coordinate: item.coordinate
        )
    }
    
    // 全祭りデータを取得（統合版）
    private var allFestivals: [IntegratedFestivalWithPrefecture] {
        var festivals: [IntegratedFestivalWithPrefecture] = []
        
        // 既存のFestivalItemを追加
        for prefecture in Prefecture.allCases {
            for festivalItem in prefecture.festivalItems {
                let integratedItem = convertFestivalItem(festivalItem, prefecture: prefecture)
                festivals.append(IntegratedFestivalWithPrefecture(festival: integratedItem, prefecture: prefecture))
            }
            
            // OtherFestivalItemを追加
            for otherFestivalItem in prefecture.otherFestivalItems {
                let integratedItem = convertOtherFestivalItem(otherFestivalItem, prefecture: prefecture)
                festivals.append(IntegratedFestivalWithPrefecture(festival: integratedItem, prefecture: prefecture))
            }
        }
        
        return festivals
    }
    
    // フィルタリングされた祭りデータ
    private var filteredFestivals: [IntegratedFestivalWithPrefecture] {
        var festivals = allFestivals
        
        // カテゴリーフィルター
        if let category = selectedCategory {
            festivals = festivals.filter { $0.festival.category == category }
        }
        
        // 月フィルター
        if let month = selectedMonth {
            festivals = festivals.filter { $0.festival.month == month || $0.festival.month.contains("-" + month) || $0.festival.month.hasPrefix(month + "-") || $0.festival.month.contains(month.prefix(2) + "-") || ($0.festival.month.contains(month.prefix(1) + "-") && (month.count != 3))}
        }
        
        // 規模フィルター
        if let scale = selectedScale {
            festivals = festivals.filter { $0.festival.scale >= scale }
        }
        
        // タイプフィルター
        if let type = selectedType {
            festivals = festivals.filter { $0.festival.festivalType == type }
        }
        
        // 検索フィルター
        if !searchText.isEmpty {
            festivals = festivals.filter {
                $0.festival.name.localizedCaseInsensitiveContains(searchText) ||
                $0.festival.description.localizedCaseInsensitiveContains(searchText) ||
                $0.prefecture.prefectureName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return festivals
    }
    
    // 利用可能な月の一覧
    private var availableMonths: [String] {
        return [
            "month_january".localized,
            "month_february".localized,
            "month_march".localized,
            "month_april".localized,
            "month_may".localized,
            "month_june".localized,
            "month_july".localized,
            "month_august".localized,
            "month_september".localized,
            "month_october".localized,
            "month_november".localized,
            "month_december".localized
        ]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ヘッダー
                VStack(spacing: 16) {
//                    Text("全国の祭・イベント")
//                        .font(.title)
//                        .fontWeight(.bold)
                    
                    // 統計情報
//                    HStack(spacing: 20) {
//                        StatBadge(title: "祭り総数", value: "\(allFestivals.count)", color: .blue)
//                        StatBadge(title: "表示中", value: "\(filteredFestivals.count)", color: .green)
//                        StatBadge(title: "都道府県", value: "\(Set(allFestivals.map { $0.prefecture }).count)", color: .orange)
//                        StatBadge(title: "カテゴリ", value: "\(IntegratedFestivalCategory.allCases.count)", color: .purple)
//                    }
                    
                    // 検索バー（ブランドカラーの土台に乗せた白いカプセル型）
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(PlanTheme.primary)

                        TextField(NSLocalizedString("search.placeholder", comment: "検索プレースホルダー"), text: $searchText)
                            .font(.system(size: 16))
                            .submitLabel(.search)
                            .autocorrectionDisabled()

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary.opacity(0.6))
                            }
                            .buttonStyle(.plain)
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                    )
                    .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
                    .padding(.horizontal)
                }
                .padding(.vertical, 18)
                // 土台にしっかりブランドのグラデーション（オレンジ→コーラル）を敷く
                .background(PlanTheme.brandGradient)
                
                // フィルターバー
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // 全体フィルターリセット
                        FilterButton(
                            title: "food_category_all".localized,
                            isSelected: selectedCategory == nil && selectedType == nil,
                            color: .gray
                        ) {
                            selectedCategory = nil
                            selectedType = nil
                        }
                        
                        Divider()
                            .frame(height: 20)
                        
                        // タイプフィルター
                        FilterButton(
                            title: NSLocalizedString("category.summer_festival", comment: "夏祭り系"),
                            isSelected: selectedType == .festival,
                            color: .red,
                            icon: "sun.max.fill"
                        ) {
                            selectedType = selectedType == .festival ? nil : .festival
                            selectedCategory = nil
                        }
                        
                        FilterButton(
                            title: NSLocalizedString("category.seasonal_festival", comment: "季節祭り系"),
                            isSelected: selectedType == .other,
                            color: .blue,
                            icon: "leaf.fill"
                        ) {
                            selectedType = selectedType == .other ? nil : .other
                            selectedCategory = nil
                        }
                        
                        Divider()
                            .frame(height: 20)
                        
                        // カテゴリーフィルター
                        ForEach(IntegratedFestivalCategory.allCases, id: \.self) { category in
                            FilterButton(
                                title: category.localizedName,
                                isSelected: selectedCategory == category,
                                color: category.color,
                                icon: category.icon
                            ) {
                                selectedCategory = selectedCategory == category ? nil : category
                                selectedType = nil
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 12)
                .padding(.bottom, 10)
                .background(Color(.systemBackground))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // 規模フィルター
                        ForEach([3, 4, 5], id: \.self) { scale in
                            FilterButton(
                                title: String(format: NSLocalizedString("filter.star_scale", comment: "%dつ星以上"), scale),
                                isSelected: selectedScale == scale,
                                color: .orange,
                                icon: "star.fill"
                            ) {
                                selectedScale = selectedScale == scale ? nil : scale
                            }
                        }
                        
                        Divider()
                            .frame(height: 20)
                        
                        // 月フィルター
                        ForEach(availableMonths, id: \.self) { month in
                            FilterButton(
                                title: month,
                                isSelected: selectedMonth == month,
                                color: .blue
                            ) {
                                selectedMonth = selectedMonth == month ? nil : month
                            }
                        }
                    
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
                
                // 祭りグリッド
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ], spacing: 12) {
                        ForEach(filteredFestivals, id: \.festival.id) { festivalWithPrefecture in
                            IntegratedFestivalCard(
                                festivalWithPrefecture: festivalWithPrefecture,
                                onTap: {
                                    selectedFestival = festivalWithPrefecture
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
                    
                    if filteredFestivals.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text(NSLocalizedString("filter.no_results", comment: "該当する祭りが見つかりません"))
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(NSLocalizedString("filter.change_filter", comment: "フィルターを変更してみてください"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedFestival) { selected in
                IntegratedFestivalDetailView(item: selected.festival, prefecture: selected.prefecture, interstitial: interstitial) {
                    modalDismissed = true
                }
            }
            .onAppear {
                Task {
                    await interstitial.loadAd()
                }
            }
            .onChange(of: modalDismissed) {
                interstitial.maybePresent()
                modalDismissed = false
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) 
    }
    
}

// MARK: - 統合祭りカード
struct IntegratedFestivalCard: View {
    let festivalWithPrefecture: IntegratedFestivalWithPrefecture
    let onTap: () -> Void
    
    private var festival: IntegratedFestivalItem { festivalWithPrefecture.festival }
    private var prefecture: Prefecture { festivalWithPrefecture.prefecture }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ヘッダー
            HStack(alignment: .top, spacing: 8) {
                // カテゴリーアイコン
                Image(systemName: festival.imageSymbol)
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(festival.category.color)
                    )
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(festival.category.localizedName)
                        .font(.caption2)
                        .foregroundColor(festival.category.color)
                        .fontWeight(.medium)
                    
                    // 規模表示
                    HStack(spacing: 1) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= festival.scale ? "star.fill" : "star")
                                .font(.system(size: 6))
                                .foregroundColor(star <= festival.scale ? .orange : .gray.opacity(0.3))
                        }
                    }
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    // 都道府県バッジ
                    Text(prefecture.prefectureName)
                        .font(.caption2)
                        .lineLimit(1)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray5))
                        )
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 6)
                    Spacer()
                }
            }
            
            // 祭り名
            Text(festival.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxHeight: .infinity, alignment: .top)
            
            // 説明
            Text(festival.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // 詳細情報
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Label(festival.month, systemImage: "calendar")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Label(festival.duration, systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
                
                Label(festival.location, systemImage: "location")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .lineLimit(1)
            }
            
            // 特徴タグ
            if !festival.features.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(festival.features.prefix(3), id: \.self) { feature in
                            Text(feature)
                                .font(.system(size: 8))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(festival.category.color.opacity(0.2))
                                )
                                .foregroundColor(festival.category.color)
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(minHeight: 250)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(festival.category.color.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - 統合祭り詳細ビュー
struct IntegratedFestivalDetailView: View {
    let item: IntegratedFestivalItem
    let prefecture: Prefecture
    @Environment(\.dismiss) private var dismiss
    let interstitial: InterstitialViewModel
    let onDismiss: () -> Void
    
    /// カテゴリ基調色。
    private var accent: Color { item.category.color }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 上方向バウンス時にヘッダー背後へ白が出ないよう最背面に基調色を敷く。
            accent.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    VStack(alignment: .leading, spacing: 18) {
                        actionCard
                        descriptionCard
                        infoCard
                        if !item.features.isEmpty { highlightsCard }
                        if item.coordinate != nil { mapCard }
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
        .onDisappear { onDismiss() }
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

                Text(String(format: "festival.of_prefecture".localized, prefecture.prefectureName))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
            }

            HStack(spacing: 10) {
                Label(item.category.localizedName, systemImage: item.category.icon)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(.white.opacity(0.22), in: Capsule())

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= item.scale ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(star <= item.scale ? .white : .white.opacity(0.4))
                    }
                }
                Spacer(minLength: 0)
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
                    category: .festival,
                    prefecture: prefecture,
                    name: item.name
                )
            }

            HStack(spacing: 6) {
                Text("gourmet.explore_more".localized)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                Spacer()
            }

            SocialSearchButtons(query: item.name)
        }
        .planCard()
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

    // MARK: - 基本情報（開催情報）

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(icon: "info.circle", title: NSLocalizedString("festival.event_info", comment: "開催情報"))
                .padding(.bottom, 14)

            FestivalInfoRow(icon: "calendar.circle.fill", title: NSLocalizedString("festival.period", comment: "開催時期"), value: item.month, color: accent)
            Divider().padding(.leading, 52)
            FestivalInfoRow(icon: "clock.circle.fill", title: NSLocalizedString("festival.duration", comment: "期間"), value: item.duration, color: accent)
            Divider().padding(.leading, 52)
            FestivalInfoRow(icon: "location.circle.fill", title: NSLocalizedString("festival.location", comment: "開催地"), value: item.location, color: accent)
            Divider().padding(.leading, 52)
            FestivalInfoRow(icon: "trophy.fill", title: NSLocalizedString("festival.scale", comment: "規模"), value: getScaleText(item.scale), color: accent)
        }
        .planCard()
    }

    // MARK: - 見どころ

    private var highlightsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "star.fill", title: NSLocalizedString("festival.highlights", comment: "見どころ・特徴"))
            VStack(alignment: .leading, spacing: 10) {
                ForEach(item.features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(accent)
                            .font(.caption)
                            .padding(.top, 2)
                        Text(feature)
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

    // MARK: - 地図カード（座標がある祭りのみ）

    @ViewBuilder
    private var mapCard: some View {
        if let coordinate = item.coordinate {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(icon: "map", title: NSLocalizedString("festival.location", comment: "開催地"))
                FestivalMapView(coordinate: coordinate, name: item.name, accent: accent)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .planCard()
        }
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

    private func getScaleText(_ scale: Int) -> String {
        switch scale {
        case 5: return "★★★★★"
        case 4: return "★★★★☆"
        case 3: return "★★★☆☆"
        case 2: return "★★☆☆☆"
        case 1: return "★☆☆☆☆"
        default: return "☆☆☆☆☆"
        }
    }
    
    private func getRecommendations(for item: IntegratedFestivalItem) -> [String] {
        switch item.category {
        case .summer:
            return [
                NSLocalizedString("tips.summer.1", comment: ""),
                NSLocalizedString("tips.summer.2", comment: ""),
                NSLocalizedString("tips.summer.3", comment: "")
            ]
        case .fireworks:
            return [
                NSLocalizedString("tips.fireworks.1", comment: ""),
                NSLocalizedString("tips.fireworks.2", comment: ""),
                NSLocalizedString("tips.fireworks.3", comment: "")
            ]
        case .traditional, .traditionalOther:
            return [
                NSLocalizedString("tips.traditional.1", comment: ""),
                NSLocalizedString("tips.traditional.2", comment: ""),
                NSLocalizedString("tips.traditional.3", comment: "")
            ]
        case .dance:
            return [
                NSLocalizedString("tips.dance.1", comment: ""),
                NSLocalizedString("tips.dance.2", comment: ""),
                NSLocalizedString("tips.dance.3", comment: "")
            ]
        case .food:
            return [
                NSLocalizedString("tips.food.1", comment: ""),
                NSLocalizedString("tips.food.2", comment: ""),
                NSLocalizedString("tips.food.3", comment: "")
            ]
        case .seasonal:
            return [
                NSLocalizedString("tips.seasonal.1", comment: ""),
                NSLocalizedString("tips.seasonal.2", comment: ""),
                NSLocalizedString("tips.seasonal.3", comment: "")
            ]
        case .religious:
            return [
                NSLocalizedString("tips.religious.1", comment: ""),
                NSLocalizedString("tips.religious.2", comment: ""),
                NSLocalizedString("tips.religious.3", comment: "")
            ]
        case .spring:
            return [
                NSLocalizedString("tips.spring.1", comment: ""),
                NSLocalizedString("tips.spring.2", comment: ""),
                NSLocalizedString("tips.spring.3", comment: "")
            ]
        case .autumn:
            return [
                NSLocalizedString("tips.autumn.1", comment: ""),
                NSLocalizedString("tips.autumn.2", comment: ""),
                NSLocalizedString("tips.autumn.3", comment: "")
            ]
        case .winter:
            return [
                NSLocalizedString("tips.winter.1", comment: ""),
                NSLocalizedString("tips.winter.2", comment: ""),
                NSLocalizedString("tips.winter.3", comment: "")
            ]
        case .sakura:
            return [
                NSLocalizedString("tips.sakura.1", comment: ""),
                NSLocalizedString("tips.sakura.2", comment: ""),
                NSLocalizedString("tips.sakura.3", comment: "")
            ]
        case .illumination:
            return [
                NSLocalizedString("tips.illumination.1", comment: ""),
                NSLocalizedString("tips.illumination.2", comment: ""),
                NSLocalizedString("tips.illumination.3", comment: "")
            ]
        case .snow:
            return [
                NSLocalizedString("tips.snow.1", comment: ""),
                NSLocalizedString("tips.snow.2", comment: ""),
                NSLocalizedString("tips.snow.3", comment: "")
            ]
        }
    }
}

// MARK: - 祭り詳細の情報行（グルメ InfoRow と同じ見た目）
struct FestivalInfoRow: View {
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

// MARK: - 祭りの開催地マップ
struct FestivalMapView: View {
    let coordinate: CLLocationCoordinate2D
    let name: String
    let accent: Color
    @State private var region: MKCoordinateRegion

    init(coordinate: CLLocationCoordinate2D, name: String, accent: Color) {
        self.coordinate = coordinate
        self.name = name
        self.accent = accent
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }

    private struct Pin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [Pin(coordinate: coordinate)]) { pin in
            MapAnnotation(coordinate: pin.coordinate) {
                Image(systemName: "party.popper.fill")
                    .font(.title3)
                    .foregroundColor(accent)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white))
                    .shadow(radius: 3)
            }
        }
    }
}

// MARK: - 統合祭り情報カードコンポーネント
struct IntegratedFestivalInfoCard: View {
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

// MARK: - 統計バッジ（再利用）
struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - フィルターボタン（再利用）
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : Color(.systemGray5))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
