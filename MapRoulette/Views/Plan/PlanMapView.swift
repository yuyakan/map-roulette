//
//  PlanMapView.swift
//  MapRoulette
//
//  プラン内の項目を地図で見る画面。
//  - 日程ごとにピンを色分けし、同じ日の項目を順にルート線でつなぐ
//  - 日フィルタ（全て / Day1 / Day2 …）
//  - ピンタップでその項目の詳細へ
//  - 選択した項目から外部マップで経路案内
//

import SwiftUI
import MapKit

struct PlanMapView: View {
    let plan: TravelPlan
    @Environment(\.dismiss) private var dismiss

    @State private var cameraPosition: MapCameraPosition
    @State private var selectedDay: Int? = nil   // nil = 全日表示
    @State private var detailItem: PlanItem?      // 詳細シート用

    init(plan: TravelPlan) {
        self.plan = plan
        _cameraPosition = State(initialValue: .region(Self.regionFitting(plan.mappableItems)))
    }

    /// 日程モードかどうか（フラットなら色分け・ルートは出さない）
    private var isDayMode: Bool { plan.groupingMode == .day }

    /// 表示対象の項目（日フィルタ適用後・座標ありのみ）
    private var visibleItems: [PlanItem] {
        let mappable = plan.mappableItems
        guard isDayMode, let day = selectedDay else { return mappable }
        return mappable.filter { $0.dayNumber == day }
    }

    /// 日ごとのルート（同じ日の項目を登場順に並べた座標列）
    private var routesByDay: [(day: Int, coords: [CLLocationCoordinate2D])] {
        guard isDayMode else { return [] }
        var result: [(Int, [CLLocationCoordinate2D])] = []
        for day in 1...max(1, plan.dayCount) {
            if let sel = selectedDay, sel != day { continue }
            let coords = plan.mappableItems
                .filter { $0.dayNumber == day }
                .compactMap { $0.coordinate }
            if coords.count >= 2 { result.append((day, coords)) }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                map
                if isDayMode {
                    dayFilterBar
                }
                // 特定の日を選択中で、その日に2地点以上あれば「経路案内」ボタンを下部に表示
                if let day = selectedDay, dayItems(for: day).count >= 2 {
                    VStack {
                        Spacer()
                        Button {
                            openDayRoute(day: day)
                        } label: {
                            Label(
                                String(format: NSLocalizedString("plan.map.route.day", comment: ""), day),
                                systemImage: "arrow.triangle.turn.up.right.diamond.fill"
                            )
                        }
                        .buttonStyle(PlanPrimaryButtonStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
            }
            .navigationTitle(plan.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.close", comment: "")) { dismiss() }
                }
            }
            .sheet(item: $detailItem) { item in
                PlanItemDetailRouter(item: item)
            }
        }
    }

    // MARK: - 経路案内（Google Maps でその日を一括経路）

    /// 指定日の、座標を持つ項目を登場順に並べたもの。
    private func dayItems(for day: Int) -> [PlanItem] {
        plan.mappableItems.filter { $0.dayNumber == day }
    }

    /// Google Maps に渡す地点表現。
    /// - カスタム項目（ホテル・駅など）: ユーザーが置いた正確な座標を渡す（自由入力名は解決に失敗しやすいため）
    /// - アプリ項目（観光・温泉など）: 「地点名 県名」で渡し、同名地の誤解決を減らす
    private func placeQuery(for item: PlanItem) -> String {
        if item.category.isCustom {
            if let c = item.coordinate { return "\(c.latitude),\(c.longitude)" }
            return item.name
        }
        if let pref = item.prefecture {
            return "\(item.name) \(pref.prefectureName)"
        }
        return item.name
    }

    /// その日の全スポットを経由地として Google Maps の経路を開く。
    /// 先頭を出発地、末尾を目的地、間を waypoints（最大 9）にする。
    private func openDayRoute(day: Int) {
        let items = dayItems(for: day)
        guard items.count >= 2 else { return }

        let origin = placeQuery(for: items.first!)
        let destination = placeQuery(for: items.last!)
        // 中間地点（Google Maps の上限に合わせ最大 9）
        let middle = Array(items.dropFirst().dropLast()).prefix(9)
        var components = URLComponents(string: "https://www.google.com/maps/dir/")!
        var query = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "destination", value: destination),
            URLQueryItem(name: "travelmode", value: "driving")
        ]
        if !middle.isEmpty {
            query.append(URLQueryItem(name: "waypoints", value: middle.map(placeQuery).joined(separator: "|")))
        }
        components.queryItems = query
        guard let url = components.url else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - 地図

    private var map: some View {
        Map(position: $cameraPosition) {
            // ルート線（日ごとに色分け）
            ForEach(routesByDay, id: \.day) { route in
                MapPolyline(coordinates: route.coords)
                    .stroke(Self.color(forDay: route.day), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [1, 6]))
            }
            // ピン
            ForEach(visibleItems) { item in
                if let coord = item.coordinate {
                    Annotation(item.name, coordinate: coord) {
                        Button {
                            detailItem = item
                        } label: {
                            pinView(for: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func pinView(for item: PlanItem) -> some View {
        let tint = isDayMode ? Self.color(forDay: item.dayNumber) : PlanTheme.color(for: item.category)
        return VStack(spacing: 2) {
            Image(systemName: item.category.icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(7)
                .background(Circle().fill(tint))
                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                .shadow(radius: 2)
            // 経路順バッジ（日程モードで、その日の中での訪問順を表示）
            if isDayMode, let order = routeOrder(for: item) {
                Text("\(order)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(tint)
                    .padding(.horizontal, 5).padding(.vertical, 1)
                    .background(Capsule().fill(.white))
                    .shadow(radius: 1)
            }
        }
    }

    /// その項目が、同じ日の中で何番目に訪れるか（1 始まり・登場順）。
    /// day が無い（未割当）項目は番号を付けない。
    private func routeOrder(for item: PlanItem) -> Int? {
        guard let day = item.dayNumber else { return nil }
        let sameDay = plan.mappableItems.filter { $0.dayNumber == day }
        guard let index = sameDay.firstIndex(where: { $0.id == item.id }) else { return nil }
        return index + 1
    }

    // MARK: - 日フィルタバー

    private var dayFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                dayChip(title: NSLocalizedString("plan.map.alldays", comment: ""), day: nil)
                ForEach(1...max(1, plan.dayCount), id: \.self) { day in
                    dayChip(title: String(format: NSLocalizedString("plan.day.format", comment: ""), day), day: day)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
    }

    private func dayChip(title: String, day: Int?) -> some View {
        let isSelected = selectedDay == day
        let tint = day.map { Self.color(forDay: $0) } ?? PlanTheme.primary
        return Button {
            withAnimation { selectedDay = day }
        } label: {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(isSelected ? .white : tint)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(Capsule().fill(isSelected ? tint : tint.opacity(0.15)))
        }
        .buttonStyle(.plain)
    }

    // MARK: - 日ごとの色

    private static let dayPalette: [Color] = [
        .red, .blue, .green, .orange, .purple, .pink, .teal, .indigo, .brown, .cyan
    ]

    static func color(forDay day: Int?) -> Color {
        guard let day, day >= 1 else { return .gray }
        return dayPalette[(day - 1) % dayPalette.count]
    }

    // MARK: - 表示領域

    private static func regionFitting(_ items: [PlanItem]) -> MKCoordinateRegion {
        let coords = items.compactMap { $0.coordinate }
        guard let first = coords.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529),
                span: MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 18)
            )
        }
        var minLat = first.latitude, maxLat = first.latitude
        var minLon = first.longitude, maxLon = first.longitude
        for c in coords {
            minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
        }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.4, 0.05),
            longitudeDelta: max((maxLon - minLon) * 1.4, 0.05)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}
