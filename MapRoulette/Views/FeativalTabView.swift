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
    
    var color: Color {
        switch self {
        case .summer: return .orange
        case .fireworks: return .purple
        case .traditional, .traditionalOther: return .brown
        case .dance: return .pink
        case .food: return .green
        case .seasonal: return .blue
        case .religious: return .indigo
        case .spring: return .green
        case .autumn: return .orange
        case .winter: return .blue
        case .sakura: return .pink
        case .illumination: return .yellow
        case .snow: return .cyan
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
                    
                    // 検索バー
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField(NSLocalizedString("search.placeholder", comment: "検索プレースホルダー"), text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                
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
            .sheet(item: $selectedFestival) { selected in
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
                if InterstitialViewModel.count >= 10 {
                    interstitial.showAd()
                    InterstitialViewModel.count = 0
                }
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // ヘッダーセクション
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
                            
                            Text(String(format: "festival.of_prefecture".localized, prefecture.prefectureName))
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            // 規模表示
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= item.scale ? "star.fill" : "star")
                                        .font(.title3)
                                        .foregroundColor(star <= item.scale ? .orange : .gray.opacity(0.3))
                                }
                            }
                            .padding(.top, 8)

                            AddToPlanButton {
                                PlanItem(
                                    category: .festival,
                                    prefecture: prefecture,
                                    name: item.name
                                )
                            }
                            .padding(.top, 4)
                        }

                        // カテゴリータグ
                        Label(item.category.localizedName, systemImage: item.category.icon)
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
                                Text("detail_info".localized)
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
                                Text("festival.event_info".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                IntegratedFestivalInfoCard(icon: "calendar.circle.fill", title: "festival.period".localized, value: item.month, color: .blue)
                                IntegratedFestivalInfoCard(icon: "clock.circle.fill", title: "festival.duration".localized, value: item.duration, color: .green)
                                IntegratedFestivalInfoCard(icon: "location.circle.fill", title: "festival.location".localized, value: item.location, color: .red)
                                IntegratedFestivalInfoCard(icon: "trophy.fill", title: "festival.scale".localized, value: getScaleText(item.scale), color: .orange)
                            }
                        }
                        
                        // 特徴・見どころ
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("festival.highlights".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(item.features, id: \.self) { feature in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                            .padding(.top, 2)
                                        
                                        Text(feature)
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

                        // 楽しみ方の提案
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("festival.tips".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(getRecommendations(for: item), id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "heart.circle.fill")
                                            .foregroundColor(.pink)
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
                                    .fill(Color(.systemGray6))
                                    .stroke(item.category.color.opacity(0.3), lineWidth: 1)
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
                            InterstitialViewModel.count += 2
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
            .onDisappear {
                onDismiss()
            }
            .padding(.bottom, 10)
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
