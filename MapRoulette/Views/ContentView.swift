//
//  ContentView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/06.
//


import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // メインコンテンツ
            Group {
                switch selectedTab {
                case 0:
                    JapanMapView()
                case 1:
                    OnsenMapView()
                case 2:
                    NatureSpotMapView()
                case 3:
                    AllFestivalsComparisonView()
                case 4:
                    MyPlansView()
                default:
                    JapanMapView()
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
            // 都道府県タブ
            // 都道府県タブ
            TabBarItem(
                icon: "map",
                title: NSLocalizedString("tab.prefecture", comment: ""),
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            // 温泉地タブ
            TabBarItem(
                icon: "thermometer.sun.fill",
                title: NSLocalizedString("tab.onsen", comment: ""),
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            // 自然タブ
            TabBarItem(
                icon: "leaf",
                title: NSLocalizedString("tab.nature", comment: ""),
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
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium)) // サイズを大きく設定
                    .foregroundColor(isSelected ? .orange : .gray)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? .orange : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
