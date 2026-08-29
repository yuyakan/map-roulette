//
//  NearbyView.swift
//  MapRoulette
//
//  「近くのスポット」タブ。現在地（または手動選択した地域）を中心に
//  周辺の観光地・温泉・自然スポットを地図のピンで見せ、下に距離順リストを出す。
//  上部の種類切替タブ（すべて/観光/温泉/自然）で絞り込める。
//  位置情報が未許可/拒否のときは都道府県を手動選択して周辺を見られる。
//  各スポットの詳細は種類ごとの既存 Detail ビューへ fullScreenCover で飛ばす。
//

import SwiftUI
import MapKit
import CoreLocation

/// 種類切替タブの選択肢（「すべて」＋各 NearbySpotKind）。
private enum NearbyFilter: Hashable {
    case all
    case kind(NearbySpotKind)

    var title: String {
        switch self {
        case .all: return NSLocalizedString("nearby.filter.all", comment: "")
        case .kind(let k): return k.title
        }
    }

    static var allCases: [NearbyFilter] {
        [.all] + NearbySpotKind.allCases.map { .kind($0) }
    }
}

struct NearbyView: View {
    @StateObject private var locationManager = NearbyLocationManager()

    /// 全スポット（距離未計算）。初回に一度だけ収集する。
    @State private var allSpots: [NearbySpot] = []
    /// 基準点からの距離順に並べ替え済みスポット。
    @State private var sortedSpots: [NearbySpot] = []
    /// 現在の絞り込み。
    @State private var filter: NearbyFilter = .all
    /// 地図の表示領域。
    @State private var region = MKCoordinateRegion(
        center: NearbyView.tokyoCenter, // 東京（現在地なし/国外時の初期位置）
        span: MKCoordinateSpan(latitudeDelta: NearbyView.defaultSpanDelta,
                               longitudeDelta: NearbyView.defaultSpanDelta)
    )

    /// 初期位置（東京駅）。現在地なし/国外時のフォールバック中心。
    private static let tokyoCenter = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
    /// 初期・検索後で共通の地図ズーム幅（緯度経度デルタ）。
    private static let defaultSpanDelta: CLLocationDegrees = 0.5
    /// 実際の検索基準点。初回は現在地で決まり、以降は
    /// 「このエリアを探す」で地図中心に上書きできる（現在地の有無に依存しない）。
    @State private var searchCenter: CLLocationCoordinate2D?
    /// 初回検索が済んだか。初回のみ現在地を自動採用するための判定に使う。
    @State private var hasSearched = false

    // 詳細 fullScreenCover 用の選択スポット
    @State private var selectedSpot: NearbySpot?

    /// 検索基準の 100km 以内にスポットが無かったときに数秒出すトースト。
    @State private var showNoResultsToast = false
    /// トーストの自動非表示ワークアイテム（連続表示時にキャンセルするため保持）。
    @State private var noResultsToastWorkItem: DispatchWorkItem?

    /// 絞り込み適用後・距離順のスポット。
    private var visibleSpots: [NearbySpot] {
        switch filter {
        case .all:
            return sortedSpots
        case .kind(let k):
            return sortedSpots.filter { $0.kind == k }
        }
    }

    /// 地図に出すピンの上限件数と距離しきい値。
    /// 距離しきい値内でも件数が多い都市部は上限で頭打ちにし、地方はしきい値内だけ出す。
    private static let maxMappedPins = 20
    private static let mappedPinRadiusMeters: CLLocationDistance = 100_000 // 100 km

    /// 地図に出す近傍スポット。基準点から 100km 以内に限り、近い順に最大 20 件。
    private var mappedSpots: [NearbySpot] {
        visibleSpots
            .filter { ($0.distanceMeters ?? .greatestFiniteMagnitude) <= Self.mappedPinRadiusMeters }
            .prefix(Self.maxMappedPins)
            .map { $0 }
    }


    var body: some View {
        // 地図を全面に敷き、その上にフィルター・カード・ボタン・案内を重ねる。
        ZStack(alignment: .top) {
            map

            // 上部オーバーレイ: 種類切替フィルター（背景は地図が透ける）。
            filterBar

            // 検索基準の 100km 以内にスポットが無かったときの一時トースト（上部・数秒）。
            if showNoResultsToast {
                noResultsToast
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }

            // 下部オーバーレイ: 上に「このエリアを探す」ボタン、その下に横スクロールカード。
            VStack(spacing: 10) {
                searchThisAreaButton
                if !mappedSpots.isEmpty {
                    spotCards
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 12)
        }
        .onAppear(perform: setup)
        .onChange(of: locationManager.currentLocation?.latitude) { _ in adoptCurrentLocationIfNeeded() }
        .fullScreenCover(item: $selectedSpot) { spot in
            detailView(for: spot)
        }
    }

    // MARK: - サブビュー

    /// 上部の種類切替タブ（すべて/観光/温泉/自然）。地図の上に重ねるので背景は透過。
    /// チップは地図に被っても読めるよう、非選択も不透明カプセル＋影を持たせる。
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NearbyFilter.allCases, id: \.self) { f in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { filter = f }
                    } label: {
                        Text(f.title)
                            .font(.system(size: 14, weight: filter == f ? .semibold : .regular))
                            .foregroundColor(filter == f ? .white : PlanTheme.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(filter == f ? AnyShapeStyle(PlanTheme.brandGradient)
                                                             : AnyShapeStyle(Color(.systemBackground)))
                            )
                            .shadow(color: .black.opacity(0.15), radius: 3, y: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    /// 現在地/手動選択地を中心にピンを表示する地図。
    private var map: some View {
        Map(coordinateRegion: $region,
            showsUserLocation: locationManager.currentLocation != nil,
            annotationItems: mappedSpots) { spot in
            MapAnnotation(coordinate: spot.coordinate) {
                Button {
                    selectedSpot = spot
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: spot.icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(spot.color))
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 2)

                        // ピンの下にスポット名。白カプセル背景で地図上でも読めるようにする。
                        // 1 行固定（折り返さない）で、密集時も高さが揃うようにする。
                        Text(spot.name)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .fixedSize()
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(Color(.systemBackground).opacity(0.9))
                            )
                            .shadow(color: .black.opacity(0.15), radius: 1)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 上部セーフエリア（ステータスバー/ノッチ）まで地図を広げる。
        // フィルター等のオーバーレイはセーフエリア内に留まるので被らない。
        .ignoresSafeArea(edges: .top)
    }

    /// 現在地の 100km 以内にスポットが無かったときの一時トースト。
    private var noResultsToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 13, weight: .semibold))
            Text(NSLocalizedString("nearby.noResults", comment: ""))
                .font(.system(size: 13, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule().fill(Color.black.opacity(0.8))
        )
        // フィルター帯（上部オーバーレイ）の下に出す。
        .padding(.top, 60)
        .padding(.horizontal, 24)
    }

    /// 地図中心を基準に再検索するフローティングボタン（初回検索以降・常時表示）。
    private var searchThisAreaButton: some View {
        Button {
            search(around: region.center)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 13, weight: .semibold))
                Text(NSLocalizedString("nearby.searchThisArea", comment: ""))
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(PlanTheme.primary)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.18), radius: 6, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    /// 地図の上に重ねる、距離順スポットの横スクロールカード。
    private var spotCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(mappedSpots) { spot in
                    Button {
                        selectedSpot = spot
                    } label: {
                        spotCard(spot)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
    }

    /// 横スクロール内の 1 枚のカード。
    private func spotCard(_ spot: NearbySpot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: spot.icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(spot.color))
                Text(spot.kind.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer(minLength: 0)
            }

            Text(spot.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            if let d = spot.distanceMeters {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                    Text(d.nearbyDisplayString)
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(PlanTheme.primary)
            }
        }
        .padding(12)
        .frame(width: 180, height: 120, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        )
    }

    // MARK: - 詳細遷移

    @ViewBuilder
    private func detailView(for spot: NearbySpot) -> some View {
        switch spot.source {
        case .tourism(let attraction, let prefecture):
            AttractionDetailView(attraction: attraction, prefecture: prefecture)
        case .onsen(let onsen):
            OnsenDetailView(onsen: onsen)
        case .nature(let natureSpot):
            NatureSpotDetailView(spot: natureSpot)
        }
    }

    // MARK: - ロジック

    /// 日本のおおよその範囲（離島含む）。現在地がこの外なら国外扱いにする。
    private static let japanLatRange: ClosedRange<Double> = 24.0...46.0
    private static let japanLonRange: ClosedRange<Double> = 122.0...154.0

    /// 座標が日本の範囲内か。国外の現在地は採用せず初期位置（東京）にフォールバックする。
    private func isInJapan(_ coordinate: CLLocationCoordinate2D) -> Bool {
        Self.japanLatRange.contains(coordinate.latitude)
            && Self.japanLonRange.contains(coordinate.longitude)
    }

    private func setup() {
        if allSpots.isEmpty {
            allSpots = NearbySpotRepository.allSpots()
        }
        locationManager.requestWhenInUse()
        // 起動時点で現在地が取れていて日本国内ならそれで初回検索する。
        // 取れていない/国外なら、まず東京で暫定検索して結果を出しておく（初期表示から検索済み）。
        // 暫定検索は committed=false なので、あとから日本国内の現在地が来たら上書きされる。
        if let loc = locationManager.currentLocation, isInJapan(loc) {
            search(around: loc)
        } else {
            search(around: Self.tokyoCenter, committed: false)
        }
    }

    /// ユーザー操作でまだ検索確定していないうちに、現在地が日本国内なら上書き検索する。
    /// 東京の暫定検索（committed=false）は上書き対象。ユーザーが地点を選んだ後（committed=true）は追従しない。
    private func adoptCurrentLocationIfNeeded() {
        guard !hasSearched, let loc = locationManager.currentLocation, isInJapan(loc) else { return }
        search(around: loc)
    }

    /// 指定した基準点で距離を計算し、地図を寄せ、ヒットなしなら通知する。
    /// 現在地/地図中心のいずれの起点でもここを通す。
    /// committed=true は「確定検索」（現在地採用・ユーザー操作）で、以降は現在地に自動追従しない。
    /// committed=false は起動時の東京暫定検索で、あとから日本国内の現在地が来たら上書きされる。
    /// また暫定検索ではヒットなしトーストを出さない。
    private func search(around center: CLLocationCoordinate2D, committed: Bool = true) {
        searchCenter = center
        if committed { hasSearched = true }
        sortedSpots = NearbySpotRepository.sortedByDistance(allSpots, from: center)
        withAnimation(.easeInOut(duration: 0.4)) {
            region = MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: Self.defaultSpanDelta,
                                       longitudeDelta: Self.defaultSpanDelta)
            )
        }

        // 基準点の 100km 以内が 1 件も無ければヒットなしトーストを出す（暫定検索では出さない）。
        guard committed else { return }
        let hasNearby = sortedSpots.contains {
            ($0.distanceMeters ?? .greatestFiniteMagnitude) <= Self.mappedPinRadiusMeters
        }
        if !hasNearby {
            presentNoResultsToast()
        }
    }

    /// 「近くにヒットなし」トーストを数秒表示して自動で消す。
    private func presentNoResultsToast() {
        noResultsToastWorkItem?.cancel()
        withAnimation(.easeInOut(duration: 0.25)) {
            showNoResultsToast = true
        }
        let item = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.25)) {
                showNoResultsToast = false
            }
        }
        noResultsToastWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: item)
    }
}
