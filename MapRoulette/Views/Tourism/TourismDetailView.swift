//
//  TourismDetailView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/19.
//

import SwiftUI
import MapKit

struct TourismDetailView: View {
    let prefecture: Prefecture
    /// この県を開いた直後に、続けて開く詳細（あれば）。ホームの「テーマで探す」から
    /// 名所／お土産／ビーチのカードをタップしたときに使う:
    /// 県詳細 → そのままその項目の詳細まで一気に開く。nil のときは県詳細だけを開く。
    let autoOpen: TourismAutoOpen?
    @State private var cameraPosition: MapCameraPosition
    @State private var isPressed = false
    @State private var selectedAttraction: LocalizedAttractionLocation? = nil
    /// 自動で開くお土産詳細（テーマの「人気のおみやげ」カード経由）。
    @State private var autoSouvenir: SouvenirItem? = nil
    /// 自動で開く自然スポット詳細（テーマの「ビーチ」カード経由）。
    @State private var autoNatureSpot: FixedNatureSpotItem? = nil
    /// フォト全画面ビューアを開くための、タップした写真の開始位置。
    @State private var photoViewerStart: PhotoViewerStart? = nil
    /// お気に入り都道府県ストア（ホームの「お気に入りの県」セクションの元データ）。
    @ObservedObject private var favorites = FavoritePrefectureStore.shared
    /// トレンド動画（アプリ共有インスタンス。ホームと結果を共有）。
    @ObservedObject private var trends = TrendRepository.shared
    /// この県の Shorts フィードを開く（動画配列 + 開始位置）。
    @State private var shortsFeed: PrefShortsFeed? = nil
    @Environment(\.dismiss) private var dismiss

    init(prefecture: Prefecture, autoOpen: TourismAutoOpen? = nil) {
        self.prefecture = prefecture
        self.autoOpen = autoOpen
        let tourismInfo = prefecture.tourismInfo
        self._cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: tourismInfo.region,
            span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        )))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // ヘッダー
                    VStack(spacing: 0) {
                        Text(prefecture.prefectureName)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 34)

                    // 人気スポットの Shorts（県名の直下・この画面の先頭）。
                    trendCategoryRow(for: "spot")
                        .padding(.horizontal, 16)

                    // 観光地マップ
                    VStack(alignment: .leading, spacing: 16) {
                        RichSectionHeader(
                            icon: "map.fill",
                            title: "tourism_detail_map".localized,
                            accent: PlanTheme.primary
                        )

                        Map(position: $cameraPosition) {
                            ForEach(prefecture.tourismInfo.attractions) { attraction in
                                Annotation(attraction.name, coordinate: attraction.coordinate) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.red)
                                            .background(Color.white)
                                            .clipShape(Circle())

                                        Text(attraction.name)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.white.opacity(0.9))
                                            .cornerRadius(4)
                                            .shadow(radius: 2)
                                    }
                                    .onTapGesture {
                                        selectedAttraction = attraction
                                    }
                                }
                            }
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // 観光地リスト
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 8) {
                                ForEach(prefecture.tourismInfo.attractions) { attraction in
                                    VStack(alignment: .leading, spacing: 6) {
                                        // アイコンとタイトル
                                        HStack(alignment: .top, spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.6)]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 24, height: 24)
                                                
                                                Image(systemName: "location.circle.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text(attraction.name)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.primary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)

                                            Spacer()
                                        }
                                        
                                        // 説明文
                                        Text(attraction.description)
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                            .lineLimit(3)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .padding(.leading, 8)
                                    .padding(.horizontal, 8)
                                    .frame(height: 80)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(
                                                color: Color.black.opacity(0.08),
                                                radius: 8,
                                                x: 0,
                                                y: 2
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(
                                                        LinearGradient(
                                                            gradient: Gradient(colors: [
                                                                Color.blue.opacity(0.1),
                                                                Color.purple.opacity(0.05)
                                                            ]),
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 6)
                                    .onTapGesture {
                                        selectedAttraction = attraction
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // 観光地マップの下だけレクタングル(300x250)。eCPMが高い傾向のため試験的に採用。
                    MediumRectangleAdView()

                    RichGourmetSection(prefecture: prefecture)

                    // グルメの Shorts（グルメセクションの一番下）。
                    trendCategoryRow(for: "gourmet")
                        .padding(.horizontal, 16)

                    RichSouvenirSection(prefecture: prefecture)

                    // 温泉・自然はデータが無い県では丸ごと消える。両方消えると、この広告が
                    // 直下のカフェ Shorts と隣り合ってしまう（愛知・広島・茨城・香川・新潟・埼玉）。
                    // 広告と動画を隣接させないため、その6県ではこの1枚を出さない。
                    if hasSectionBelowAd {
                        AdaptiveBannerAdView()
                    }

                    RichOnsenSection(prefecture: prefecture)

                    // 自然（自然タブと同じスポットを県で絞り込んで表示。温泉の下）。
                    RichNatureSection(prefecture: prefecture)

                    // カフェの Shorts（自然セクションの下に独立セクション）。
                    trendCafeSection

                    RichFestivalSection(prefecture: prefecture)

                    RichOtherFestivalSection(prefecture: prefecture)

                    AdaptiveBannerAdView()

                    // 実写フォトカルーセル（写真があるスポットのみ）。
                    // 素材は CC0 だけではなく CC BY も含む（帰属義務あり）。
                    // 帰属は設定アプリの写真クレジット画面（PhotoCredits.plist）で
                    // 一括表記しているので、写真を足したら gen_credits.py を必ず実行する。
                    photoCarousel

                    // 最下部に余白を入れてスクロールに余裕を持たせる
                    Color.clear.frame(height: 40)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // ホームの「最近見た県」に記録する（この画面を開いた＝その県を見た）。
                // マップからの遷移・県検索からの遷移の両方がこの画面を通るため、ここ1箇所でカバーできる。
                RecentPrefectureStore.shared.record(prefecture)

                // テーマのカード経由なら、続けてその項目の詳細まで自動で開く。
                openAutoTargetIfNeeded()
            }
            .task {
                // ホームを経由せず直接この画面に来た場合でも動画を出せるよう、トレンドをロード。
                // load() はキャッシュ優先＋鮮度制御済み。既ロードなら何もしない（重複読み込みしない）。
                if case .idle = trends.state {
                    await trends.load()
                }
            }
            .fullScreenCover(item: $selectedAttraction) { attraction in
                AttractionDetailView(attraction: attraction, prefecture: prefecture)
            }
            .fullScreenCover(item: $autoSouvenir) { souvenir in
                SouvenirDetailView(item: souvenir, prefecture: prefecture)
            }
            .fullScreenCover(item: $autoNatureSpot) { spot in
                NatureSpotDetailView(spot: spot)
            }
            .fullScreenCover(item: $photoViewerStart) { start in
                PhotoFullScreenViewer(
                    attractions: AttractionPhoto.photographedAttractions(in: prefecture),
                    startIndex: start.index
                )
            }
            .fullScreenCover(item: $shortsFeed) { feed in
                ShortsFeedView(videos: feed.videos, startIndex: feed.startIndex)
            }

            VStack() {
                HStack {
                    HStack {
                        Button(action: {
                          InterstitialViewModel.count += 2
                            dismiss()
                       }) {
                           HStack(spacing: 8) {
                               Image(systemName: "chevron.left")
                                   .resizable()
                                   .frame(width: 10, height: 14)
                               Text("tourism_detail_back".localized)
                                   .font(.system(size: 16))
                                   .fontWeight(.medium)
                           }
                       }
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    Spacer()

                    // お気に入りトグル（ホームの「お気に入りの県」セクションに反映）。
                    Button(action: {
                        favorites.toggle(prefecture)
                    }) {
                        Image(systemName: favorites.isFavorite(prefecture) ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(favorites.isFavorite(prefecture) ? .pink : .gray)
                            .padding(10)
                            .background(.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                    .accessibilityLabel(favorites.isFavorite(prefecture) ? "tourism_detail_unfavorite".localized : "tourism_detail_favorite".localized)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
        }
    }

    // MARK: - テーマカード経由の自動遷移（県詳細 → その項目の詳細）

    /// autoOpen で指定された項目の詳細を、県詳細を開いた直後に自動で開く。
    /// 既にいずれかを開いている場合は何もしない（多重表示防止・再 onAppear 対策）。
    /// 対応する実体が見つからないときは県詳細だけを表示したまま（安全側）。
    private func openAutoTargetIfNeeded() {
        guard selectedAttraction == nil, autoSouvenir == nil, autoNatureSpot == nil,
              let autoOpen else { return }

        switch autoOpen {
        case .attraction(let nameKey):
            selectedAttraction = prefecture.tourismInfo.attractions
                .first { $0.nameKey == nameKey }
        case .souvenir(let stableKey):
            // UUID は不安定なので stableKey で県内から特定する。
            autoSouvenir = prefecture.souvenirItems
                .first { $0.stableKey == stableKey }
        case .natureSpot(let nameKey):
            autoNatureSpot = NatureSpotDataRepository.shared.allFixedSpots
                .first { $0.nameKey == nameKey }
        }
    }

    /// お土産下の広告と、その下のカフェ Shorts の間に実セクションが残るか。
    /// 温泉・自然はどちらもデータが無い県では丸ごと非表示になるため、両方空だと
    /// 広告と動画が直接隣り合う。AdMob の「広告を紛らわしい位置に置かない」方針に
    /// 反するので、その場合は広告自体を出さない。
    private var hasSectionBelowAd: Bool {
        !prefecture.onsenItems.isEmpty || !RichNatureSection.spots(in: prefecture).isEmpty
    }

    // MARK: - トレンド動画（YouTube Shorts・カテゴリ別に各セクションへ分散配置）

    /// 独立した「トレンド」セクションは作らず、カテゴリごとに対応する既存セクションへ配置する:
    ///   - spot（人気スポット） → 県名の直下（この画面の先頭）
    ///   - gourmet（グルメ）    → グルメセクションの一番下
    ///   - cafe（カフェ）       → 自然セクションの下に独立セクション（trendCafeSection）

    /// 指定 categoryKey の Shorts 行（見出し + 横スクロール）。動画が無ければ何も出さない。
    /// 画面先頭／グルメセクションの末尾に差し込む用（見出しはカテゴリ名）。
    @ViewBuilder
    private func trendCategoryRow(for categoryKey: String) -> some View {
        if let group = trends.groups(for: prefecture)
            .first(where: { $0.categoryKey == categoryKey && !$0.videos.isEmpty }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.categoryName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)

                trendScroll(for: group)
            }
            .padding(.top, 4)
        }
    }

    /// カフェの独立セクション（お土産下の広告の下）。見出し（アイコン付き）＋横スクロール。
    @ViewBuilder
    private var trendCafeSection: some View {
        if let group = trends.groups(for: prefecture)
            .first(where: { $0.categoryKey == "cafe" && !$0.videos.isEmpty }) {
            VStack(alignment: .leading, spacing: 16) {
                RichSectionHeader(
                    icon: "cup.and.saucer.fill",
                    title: group.categoryName,
                    accent: PlanTheme.primary
                )
                trendScroll(for: group)
            }
            .padding(.horizontal, 16)
        }
    }

    /// グループの動画サムネ横スクロール（タップで同カテゴリ内を連続再生）。共通部品。
    /// - Parameter sectionInset: このスクロールを内包するセクションが持つ左右 padding。
    ///   その ぶんだけ ScrollView 側で負の padding を当てて画面端まで広げ、代わりに
    ///   中身（カード列）の先頭・末尾へ同じ量のインセットを入れる。これで「見出しは
    ///   内側・スクロールは端いっぱい（端のカードは見切れずに次が覗く）」を実現する。
    private func trendScroll(for group: TrendGroup, sectionInset: CGFloat = 16) -> some View {
        // カード間の間隔と、開始/終了に足す“見た目の余白”（sectionInset に上乗せ）。
        let cardSpacing: CGFloat = 16
        let edgeSpacing: CGFloat = 4
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: cardSpacing) {
                ForEach(Array(group.videos.enumerated()), id: \.element.id) { index, video in
                    Button {
                        shortsFeed = PrefShortsFeed(videos: group.videos, startIndex: index)
                    } label: {
                        TrendCard(video: video, shelf: group.categoryKey, position: index)
                    }
                    .buttonStyle(.plain)
                }
            }
            // カード列の左右端インセット。sectionInset ぶんは見出しと縦を揃えるため、
            // edgeSpacing ぶんは開始/終了に少しゆとりを持たせるための上乗せ。
            .padding(.horizontal, sectionInset + edgeSpacing)
            // 横 ScrollView の上端クリップでカード角丸が欠けるのを防ぐ余白。
            .padding(.vertical, 8)
        }
        // 外側セクションの水平 padding を相殺し、スクロール自体は画面端まで広げる。
        .padding(.horizontal, -sectionInset)
    }

    // MARK: - 実写フォトカルーセル

    /// 県内で写真を持つスポットを横スクロールで見せる。
    /// 写真が 1 枚も無い県では、セクションごと表示しない（従来通りの見た目）。
    @ViewBuilder
    private var photoCarousel: some View {
        let photographed = AttractionPhoto.photographedAttractions(in: prefecture)
        if !photographed.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                RichSectionHeader(
                    icon: "photo.on.rectangle.angled",
                    title: "tourism_detail_photos".localized,
                    accent: PlanTheme.primary
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(photographed.enumerated()), id: \.element.id) { index, attraction in
                            photoCard(for: attraction)
                                .onTapGesture {
                                    photoViewerStart = PhotoViewerStart(index: index)
                                }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
            .padding(.horizontal)
        }
    }

    /// カルーセル内の 1 枚（写真＋スポット名）。
    private func photoCard(for attraction: LocalizedAttractionLocation) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let photo = AttractionPhoto.image(for: attraction.nameKey) {
                photo
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 260, height: 180)
                    .clipped()
            }

            Text(attraction.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(width: 260, alignment: .leading)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

}

/// 県詳細を開いた直後に自動で開く詳細の指定（ホームの「テーマで探す」カード用）。
/// 県詳細は共通の入口なので、どの項目の詳細に進むかだけをここで表す。
enum TourismAutoOpen {
    /// 観光名所詳細（LocalizedAttractionLocation の nameKey）。
    case attraction(nameKey: String)
    /// お土産詳細（SouvenirItem の stableKey）。
    case souvenir(stableKey: String)
    /// 自然スポット詳細（FixedNatureSpotItem の nameKey。ビーチ = 海カテゴリ）。
    case natureSpot(nameKey: String)
}

/// フォト全画面ビューアを `fullScreenCover(item:)` で開くための、開始位置ラッパー。
struct PhotoViewerStart: Identifiable {
    let id = UUID()
    let index: Int
}

/// 県詳細の Shorts フィードを `fullScreenCover(item:)` で開くためのコンテキスト。
struct PrefShortsFeed: Identifiable {
    let id = UUID()
    let videos: [TrendVideo]
    let startIndex: Int
}

