//
//  CustomPlanItemEditor.swift
//  MapRoulette
//
//  ユーザーが手動で追加する旅程項目（ホテル・移動手段・その他メモ）の
//  追加 / 編集フォームと、保存済み項目の表示画面。
//

import SwiftUI
import MapKit
import UIKit

// MARK: - 編集フォーム（追加・編集兼用）

struct CustomPlanItemEditor: View {
    let planID: UUID
    /// 編集対象。nil なら新規追加。
    let editing: PlanItem?
    /// 新規追加時に割り当てる日（日程セクションから追加した場合に指定）。
    let initialDay: Int?

    @ObservedObject private var store = TravelPlanStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var category: PlanItemCategory
    @State private var title: String
    @State private var detail: String
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var placeName: String?
    @State private var address: String?
    @State private var showingLocationPicker = false

    init(planID: UUID, editing: PlanItem? = nil, initialDay: Int? = nil) {
        self.planID = planID
        self.editing = editing
        self.initialDay = initialDay
        _placeName = State(initialValue: editing?.customPlaceName)
        _address = State(initialValue: editing?.customAddress)
        _category = State(initialValue: editing?.category ?? .hotel)
        _title = State(initialValue: editing?.name ?? "")
        _detail = State(initialValue: editing?.customDetail ?? "")
        _coordinate = State(initialValue: editing?.coordinate)
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        typeCard
                        titleCard
                        detailCard
                        locationCard
                        Button {
                            save()
                        } label: {
                            Text(NSLocalizedString("common.save", comment: ""))
                        }
                        .buttonStyle(PlanPrimaryButtonStyle())
                        .disabled(!canSave)
                        .opacity(canSave ? 1 : 0.5)
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString(editing == nil ? "plan.custom.add" : "plan.custom.edit", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(coordinate: $coordinate, placeName: $placeName, address: $address)
            }
        }
        .tint(PlanTheme.primary)
    }

    // MARK: - 種類選択

    private var typeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("plan.custom.type", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            HStack(spacing: 10) {
                ForEach(PlanItemCategory.customCases, id: \.self) { c in
                    Button {
                        category = c
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: c.icon)
                                .font(.system(size: 18, weight: .semibold))
                            Text(c.localizedName)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(category == c ? PlanTheme.color(for: c).opacity(0.18) : Color(.tertiarySystemGroupedBackground))
                        )
                        .foregroundColor(category == c ? PlanTheme.color(for: c) : .secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(category == c ? PlanTheme.color(for: c) : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("plan.custom.title.label", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            TextField(NSLocalizedString("plan.custom.title.placeholder", comment: ""), text: $title)
                .textFieldStyle(.plain)
                .font(.title3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("plan.custom.detail.label", comment: ""))
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)
            TextEditor(text: $detail)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var locationCard: some View {
        Button {
            showingLocationPicker = true
        } label: {
            HStack {
                Image(systemName: coordinate == nil ? "mappin.slash" : "mappin.circle.fill")
                    .foregroundColor(coordinate == nil ? .secondary : PlanTheme.primary)
                Text(locationCardLabel)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Spacer()
                if coordinate != nil {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                }
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .planCard()
    }

    /// 位置カードのラベル。施設名があればそれを、無ければ追加/変更の汎用文言を出す。
    private var locationCardLabel: String {
        if coordinate == nil {
            return NSLocalizedString("plan.custom.location.add", comment: "")
        }
        if let name = placeName, !name.isEmpty {
            return name
        }
        return NSLocalizedString("plan.custom.location.set", comment: "")
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let editing {
            var updated = editing
            updated.category = category
            updated.name = trimmed
            updated.customDetail = detail
            updated.customLatitude = coordinate?.latitude
            updated.customLongitude = coordinate?.longitude
            updated.customPlaceName = coordinate == nil ? nil : placeName
            updated.customAddress = coordinate == nil ? nil : address
            store.updateItem(updated, in: planID)
        } else {
            var item = PlanItem(
                customCategory: category,
                title: trimmed,
                detail: detail,
                coordinate: coordinate,
                dayNumber: initialDay
            )
            item.customPlaceName = coordinate == nil ? nil : placeName
            item.customAddress = coordinate == nil ? nil : address
            store.addItem(item, to: planID)
        }
        dismiss()
    }
}

// MARK: - 位置選択（地図中心をピンに）

struct LocationPickerView: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    /// 検索で選んだ地点名。ピンを動かすと nil になる。経路案内で座標の代わりに使う。
    var placeName: Binding<String?>? = nil
    /// 住所（表示用）。検索選択時は placemark.title、手動移動時は保存時に逆ジオで補完する。
    var address: Binding<String?>? = nil
    @Environment(\.dismiss) private var dismiss

    private let initialCenter: CLLocationCoordinate2D
    @State private var cameraPosition: MapCameraPosition
    /// 地図の現在の中心（onMapCameraChange で更新）。これを保存する。
    @State private var currentCenter: CLLocationCoordinate2D
    @State private var searchText = ""
    @State private var results: [MKMapItem] = []
    @State private var isSearching = false
    /// 検索で選んだ地点名（保持中）。地図を手で動かすとクリアされる。
    @State private var selectedName: String?
    /// 検索で選んだ住所（保持中）。地図を手で動かすとクリアされ、保存時に逆ジオで取り直す。
    @State private var selectedAddress: String?
    /// 検索選択直後の地図移動による onMapCameraChange を無視するためのフラグ
    @State private var ignoreNextCameraChange = false
    /// 保存時の逆ジオコーディング中フラグ（ボタン二度押し防止）
    @State private var isResolvingAddress = false

    init(coordinate: Binding<CLLocationCoordinate2D?>, placeName: Binding<String?>? = nil, address: Binding<String?>? = nil, initialCoordinate: CLLocationCoordinate2D? = nil) {
        _coordinate = coordinate
        self.placeName = placeName
        self.address = address
        // 地図の初期中心。呼び出し元が明示指定（initialCoordinate）した場合はそれを優先する。
        // .sheet(item:) 提示時にバインディングの更新が間に合わないケースへの保険。
        let center = initialCoordinate ?? coordinate.wrappedValue ?? CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)
        self.initialCenter = center
        _currentCenter = State(initialValue: center)
        _selectedName = State(initialValue: placeName?.wrappedValue)
        _selectedAddress = State(initialValue: address?.wrappedValue)
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition)
                    .ignoresSafeArea(edges: .bottom)
                    .onMapCameraChange(frequency: .continuous) { context in
                        let newCenter = context.region.center
                        // 地点名を持っている状態で、中心が実際に動いたら（ユーザー操作）名前をクリア。
                        // 初回表示や検索移動（ignoreNextCameraChange）では消さない。
                        if ignoreNextCameraChange {
                            ignoreNextCameraChange = false
                        } else if (selectedName != nil || selectedAddress != nil),
                                  Self.movedSignificantly(from: currentCenter, to: newCenter) {
                            // 手で動かしたら検索由来の名前・住所は破棄（保存時に逆ジオで取り直す）
                            selectedName = nil
                            selectedAddress = nil
                        }
                        currentCenter = newCenter
                    }

                // 画面中央に固定されたピン（地図を動かして位置を合わせる）
                VStack(spacing: 0) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white, PlanTheme.primary)
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 14))
                        .foregroundColor(PlanTheme.primary)
                        .offset(y: -6)
                }
                .offset(y: -20)
                .allowsHitTesting(false)

                // 検索（上部）と保存ボタン（下部・状態表示付き）
                VStack(spacing: 0) {
                    searchOverlay
                    Spacer()
                    saveButton
                }
            }
            .navigationTitle(NSLocalizedString("plan.custom.location.pick", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
            }
        }
    }

    /// 保存ボタン。検索地点名があれば「○○として保存」、無ければ「この地点を保存」。
    private var saveButton: some View {
        Button {
            commitSelection()
        } label: {
            if isResolvingAddress {
                ProgressView().tint(.white)
            } else if let name = selectedName {
                Label(String(format: NSLocalizedString("plan.location.saveas", comment: ""), name),
                      systemImage: "mappin.circle.fill")
                    .lineLimit(1)
            } else {
                Label(NSLocalizedString("plan.location.savepoint", comment: ""), systemImage: "mappin")
            }
        }
        .buttonStyle(PlanPrimaryButtonStyle())
        .disabled(isResolvingAddress)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    /// 保存確定。住所が未取得（ピン手動移動）なら逆ジオコーディングで補完してから閉じる。
    private func commitSelection() {
        // 検索選択済みで住所がある場合はそのまま確定
        if let addr = selectedAddress {
            finishSaving(address: addr)
            return
        }
        guard address != nil else {   // 住所バインディングが無い呼び出し元では従来通り即確定
            finishSaving(address: nil)
            return
        }
        isResolvingAddress = true
        let target = currentCenter
        CLGeocoder().reverseGeocodeLocation(
            CLLocation(latitude: target.latitude, longitude: target.longitude)
        ) { placemarks, _ in
            isResolvingAddress = false
            finishSaving(address: Self.formattedAddress(from: placemarks?.first))
        }
    }

    private func finishSaving(address resolved: String?) {
        coordinate = currentCenter
        placeName?.wrappedValue = selectedName
        address?.wrappedValue = resolved
        dismiss()
    }

    /// CLPlacemark を 1 行の住所文字列に整形（国・郵便番号は省く）。
    private static func formattedAddress(from placemark: CLPlacemark?) -> String? {
        guard let p = placemark else { return nil }
        // 日本式に都道府県→市区町村→番地の順で結合。nil/空は除外。
        let parts = [p.administrativeArea, p.locality, p.subLocality, p.thoroughfare, p.subThoroughfare]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        let joined = parts.joined()
        return joined.isEmpty ? nil : joined
    }

    /// 2 点が「ユーザーが動かした」と言える程度に離れているか（微小な揺れは無視）。
    private static func movedSignificantly(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Bool {
        let dLat = abs(a.latitude - b.latitude)
        let dLng = abs(a.longitude - b.longitude)
        return dLat > 0.0002 || dLng > 0.0002   // おおよそ 20m 以上
    }

    // MARK: - 検索 UI（地図上部にオーバーレイ）

    private var searchOverlay: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField(NSLocalizedString("plan.custom.location.search", comment: ""), text: $searchText)
                    .submitLabel(.search)
                    .onSubmit { runSearch() }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        results = []
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 6, y: 2)

            if !results.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(results, id: \.self) { item in
                            Button {
                                select(item)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "—")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.primary)
                                    if let addr = item.placemark.title {
                                        Text(addr)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: 240)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                .padding(.top, 6)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func runSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { results = []; return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: currentCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        isSearching = true
        MKLocalSearch(request: request).start { response, _ in
            isSearching = false
            results = response?.mapItems ?? []
        }
    }

    private func select(_ item: MKMapItem) {
        let coord = item.placemark.coordinate
        currentCenter = coord
        // 検索選択による地図移動では地点名をクリアしない
        ignoreNextCameraChange = true
        selectedName = item.name
        selectedAddress = item.placemark.title
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
        results = []
        searchText = item.name ?? searchText
    }
}

// MARK: - 表示画面（保存済みカスタム項目）

/// 保存済みカスタム項目（ホテル・移動・その他）の詳細画面。
/// デザインは観光・グルメ詳細と統一（ヒーローヘッダー／白カード群／地図カード）。
/// 基調色はカテゴリ色（ホテル＝藍、移動＝青緑 等）を使う。
struct CustomPlanItemView: View {
    let item: PlanItem
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false
    /// 住所コピー直後に「コピーしました」を一時表示するためのフラグ
    @State private var addressCopied = false

    /// この項目の基調色（カテゴリ色）。
    private var accent: Color { PlanTheme.color(for: item.category) }

    /// この項目が属するプランID（編集に必要）。store から逆引き。
    private var planID: UUID? {
        TravelPlanStore.shared.plans.first { $0.items.contains(where: { $0.id == item.id }) }?.id
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                // 上方向バウンス時にヘッダー背後へ白が出ないよう最背面に基調色を敷く。
                accent.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        VStack(alignment: .leading, spacing: 18) {
                            if let detail = item.customDetail?.trimmingCharacters(in: .whitespacesAndNewlines), !detail.isEmpty {
                                detailCard(detail)
                            }
                            if let coord = item.coordinate {
                                placeCard(coordinate: coord)
                            }
                        }
                        .padding(.horizontal, 18)
                    }
                    .padding(.bottom, 32)
                }
                .background(PlanTheme.backgroundGradient.ignoresSafeArea())
                .ignoresSafeArea(edges: .top)

                topButtons
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditor) {
                if let planID {
                    CustomPlanItemEditor(planID: planID, editing: item)
                }
            }
        }
        .tint(accent)
    }

    // MARK: - 右上のボタン（編集・閉じる）

    private var topButtons: some View {
        HStack(spacing: 12) {
            if planID != nil {
                circleButton(icon: "square.and.pencil") { showingEditor = true }
            }
            circleButton(icon: "xmark") { dismiss() }
        }
        .padding(.top, 56)
        .padding(.trailing, 18)
    }

    private func circleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(accent)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        }
    }

    // MARK: - ヒーローヘッダー

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.22))
                    .frame(width: 76, height: 76)
                Image(systemName: item.category.icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Label(item.category.localizedName, systemImage: "tag.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - メモ

    private func detailCard(_ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "note.text", title: "plan.memo.label".localized)
            Text(detail)
                .font(.body)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - 場所カード（施設名・住所・地図・マップ起動）

    @ViewBuilder
    private func placeCard(coordinate coord: CLLocationCoordinate2D) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "mappin.and.ellipse", title: "attraction.open_in_maps".localized)

            // 検索で施設名・地名を保存している場合のみ、その名前を表示
            if let placeName = item.customPlaceName, !placeName.isEmpty {
                Text(placeName)
                    .font(.subheadline.bold())
                    .foregroundColor(accent)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 住所があれば表示（検索選択・ピン手動移動の両方で保存される）
            if let address = item.effectiveAddress {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // タップで住所をクリップボードへコピー。直後は完了アイコンに切り替える。
                    Button {
                        UIPasteboard.general.string = address
                        withAnimation { addressCopied = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { addressCopied = false }
                        }
                    } label: {
                        Image(systemName: addressCopied ? "checkmark.circle.fill" : "doc.on.doc")
                            .font(.caption)
                            .foregroundColor(addressCopied ? .green : accent)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(NSLocalizedString("plan.address.copy", comment: ""))
                }
            }

            Map(initialPosition: .region(MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))) {
                Marker(item.customPlaceName ?? item.name, coordinate: coord)
                    .tint(accent)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Button {
                openInMaps(coordinate: coord)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(accent)
                        .frame(width: 32, height: 32)
                        .background(.white, in: Circle())
                    Text("attraction.open_in_maps".localized)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(accent))
                .shadow(color: accent.opacity(0.3), radius: 6, y: 3)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
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

    /// 保存済みの座標を Apple マップ（無ければ Google マップ）で開く。
    /// 施設名があればラベル付きで、無ければ座標で開く。
    private func openInMaps(coordinate coord: CLLocationCoordinate2D) {
        let lat = coord.latitude, lng = coord.longitude
        let name = (item.customPlaceName?.isEmpty == false) ? item.customPlaceName! : item.name
        if let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "http://maps.apple.com/?q=\(encoded)&ll=\(lat),\(lng)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "https://maps.google.com/maps?q=\(lat),\(lng)") {
            UIApplication.shared.open(url)
        }
    }
}
