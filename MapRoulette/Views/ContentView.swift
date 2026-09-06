//
//  ContentView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/06.
//


import SwiftUI

struct ContentView: View {
    // 起動時のデフォルトはホームタブ（真ん中＝index 2）
    @State private var selectedTab = 2

    var body: some View {
        VStack(spacing: 0) {
            // メインコンテンツ
            Group {
                switch selectedTab {
                case 0:
                    // 都道府県・温泉・自然を1タブに統合
                    IntegratedMapView()
                case 1:
                    NearbyView()
                case 2:
                    // ホームタブ（トレンド / YouTube Shorts）を真ん中に配置
                    HomeView()
                case 3:
                    AllFestivalsComparisonView()
                case 4:
                    MyPlansView()
                default:
                    HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // カスタムタブバー
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // 統合マップタブ（都道府県・温泉・自然）
            TabBarItem(
                icon: "map",
                title: NSLocalizedString("tab.map", comment: ""),
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            // 近くのスポットタブ
            TabBarItem(
                icon: "location.circle",
                title: NSLocalizedString("tab.nearby", comment: ""),
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            // ホームタブ（トレンド / YouTube Shorts）＝真ん中
            TabBarItem(
                icon: "house",
                title: NSLocalizedString("tab.home", comment: ""),
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }

            // 祭・イベントタブ
            TabBarItem(
                icon: "sparkles",
                title: NSLocalizedString("tab.festival", comment: ""),
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }

            // マイプランタブ
            TabBarItem(
                icon: "suitcase.rolling",
                title: NSLocalizedString("tab.plan", comment: ""),
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // SF Symbol ごとに描画高さが異なるため、固定高さの枠に入れて中央揃えし、
                // アイコン下端（＝テキスト位置）をタブ間で揃える。
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .frame(height: 24)
                    .foregroundColor(isSelected ? PlanTheme.primary : .gray)

                // タイトルは常に 1 行に固定。言語により折り返して高さがずれるのを防ぐ。
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(isSelected ? PlanTheme.primary : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
