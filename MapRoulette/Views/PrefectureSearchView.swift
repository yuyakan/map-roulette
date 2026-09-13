//
//  PrefectureSearchView.swift
//  MapRoulette
//
//  地図をタップしなくても目的の都道府県に辿り着くための検索・一覧導線。
//  都道府県マップ右上の検索ボタンから「全画面」で開き、県を選ぶと
//  既存の TourismDetailView を全画面表示する。
//  OS デフォルトの List/searchable ではなく、ブランド（PlanTheme）に寄せた
//  カスタムヘッダー・検索フィールド・カード行で構成する。
//

import SwiftUI

struct PrefectureSearchView: View {
    /// 画面を閉じるための dismiss（fullScreenCover で提示される前提）
    @Environment(\.dismiss) private var dismiss

    /// 検索キーワード（県名で絞り込み）
    @State private var searchText = ""
    /// 検索フィールドのフォーカス状態
    @FocusState private var searchFocused: Bool
    /// 選択された県。セット時に全画面で詳細を開く。
    @State private var selectedPrefecture: Prefecture?

    /// 検索キーワードに一致する県だけを残した地方リスト。
    /// 空検索時は全地方を返す。検索時は一致県のある地方だけを残す。
    /// 漢字表記・平仮名読み・ローマ字のいずれでもヒットする。
    /// カタカナ入力は平仮名に正規化してから照合する。
    private var filteredRegions: [(region: JapanRegion, prefectures: [Prefecture])] {
        let query = normalizedQuery
        return JapanRegion.allCases.compactMap { region in
            let matched = region.prefectures.filter { prefecture in
                query.isEmpty || matches(prefecture, query: query)
            }
            return matched.isEmpty ? nil : (region, matched)
        }
    }

    /// 入力を正規化（前後空白除去・カタカナ→平仮名）した検索クエリ。
    private var normalizedQuery: String {
        toHiragana(searchText.trimmingCharacters(in: .whitespaces))
    }

    /// 県が検索クエリに一致するか。各キーワードもカタカナ→平仮名に正規化して部分一致で判定。
    private func matches(_ prefecture: Prefecture, query: String) -> Bool {
        prefecture.searchKeywords.contains { keyword in
            toHiragana(keyword).localizedCaseInsensitiveContains(query)
        }
    }

    /// カタカナを平仮名へ変換する（平仮名・英字・漢字はそのまま）。
    /// hiraganaToKatakana を reverse:true で適用して カタカナ→平仮名 にする。
    private func toHiragana(_ text: String) -> String {
        text.applyingTransform(.hiraganaToKatakana, reverse: true) ?? text
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 背面はブランドのやわらかいグラデーション
            PlanTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if filteredRegions.isEmpty {
                    emptyState
                } else {
                    resultsList
                }
            }
        }
        // 県を選ぶと既存の詳細画面をそのまま全画面表示（地図タップと同じ導線）
        .fullScreenCover(item: $selectedPrefecture) { prefecture in
            TourismDetailView(prefecture: prefecture)
        }
    }

    // MARK: - ヘッダー（ブランドグラデーション＋閉じるボタン）

    private var header: some View {
        ZStack {
            PlanTheme.brandGradient
                .ignoresSafeArea(edges: .top)

            // 検索窓と閉じるボタンを同じ行に並べる（どちらもオレンジ帯の中）
            HStack(spacing: 12) {
                searchField

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(9)
                        .background(Color.white.opacity(0.22))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .padding(.top, 8)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - 検索フィールド（角丸カード風・OSデフォルトのバーは使わない）

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(searchFocused ? PlanTheme.primary : .secondary)

            TextField(
                NSLocalizedString("prefecture.search.placeholder", comment: ""),
                text: $searchText
            )
            .font(.system(size: 16))
            .focused($searchFocused)
            .submitLabel(.search)
            .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: PlanTheme.cardShadow, radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(searchFocused ? Color.white.opacity(0.9) : .clear, lineWidth: 1.5)
        )
        .animation(.easeOut(duration: 0.15), value: searchFocused)
    }

    // MARK: - 結果リスト（地方別セクション＋カード行）

    private var resultsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                ForEach(filteredRegions, id: \.region) { entry in
                    VStack(alignment: .leading, spacing: 10) {
                        RegionSectionLabel(title: entry.region.localizedName)
                            .padding(.horizontal, 20)

                        VStack(spacing: 10) {
                            ForEach(entry.prefectures) { prefecture in
                                Button {
                                    searchFocused = false
                                    selectedPrefecture = prefecture
                                } label: {
                                    PrefectureSearchRow(prefecture: prefecture)
                                }
                                .buttonStyle(PressableCardStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    // MARK: - 検索ヒットなし

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundColor(.secondary.opacity(0.5))
            Text(NSLocalizedString("prefecture.search.empty", comment: ""))
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 地方セクションの見出し（ブランドアクセントのバー付き）

private struct RegionSectionLabel: View {
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(PlanTheme.brandGradient)
                .frame(width: 4, height: 16)

            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - 一覧の各行（カード。県名・代表スポット・温泉チップ）

private struct PrefectureSearchRow: View {
    let prefecture: Prefecture

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(prefecture.prefectureName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            if prefecture.hasOnsen {
                HStack(spacing: 3) {
                    Image(systemName: "thermometer.sun.fill")
                        .font(.system(size: 10))
                    Text(NSLocalizedString("prefecture.search.onsen_chip", comment: ""))
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.orange.opacity(0.12)))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: PlanTheme.cardShadow, radius: 8, x: 0, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// 代表スポット名を最大2件まで「・」区切りで表示（回遊性を上げるためのヒント）。
    private var subtitle: String? {
        let names = prefecture.tourismInfo.attractions.prefix(2).map(\.name)
        return names.isEmpty ? nil : names.joined(separator: "・")
    }
}

// MARK: - 押下時に軽く沈むカード用ボタンスタイル

private struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
