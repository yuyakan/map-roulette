//
//  PlanPlaceMapCard.swift
//  MapRoulette
//
//  プラン項目に保存した位置（customCoordinate）を表示する地図カード。
//  カスタム項目（ホテル等）の詳細画面と、グルメ・お土産の詳細画面で共用する。
//  地点名・住所・地図プレビュー・「マップで開く」ボタンをまとめる。
//

import SwiftUI
import MapKit
import UIKit

struct PlanPlaceMapCard: View {
    let coordinate: CLLocationCoordinate2D
    /// 検索で選んだ地点名（任意）。マーカー・マップ起動のラベルに使う。
    var placeName: String?
    /// 表示用の住所（任意）。
    var address: String?
    /// マップ起動時のフォールバック名（地点名が無いときに使う項目名）。
    let fallbackName: String
    /// カード内アクセントカラー（カテゴリ色に合わせる）。
    let accent: Color

    /// 住所コピー直後に「コピーしました」を一時表示するためのフラグ
    @State private var addressCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader

            // 検索で施設名・地名を保存している場合のみ、その名前を表示
            if let placeName, !placeName.isEmpty {
                Text(placeName)
                    .font(.subheadline.bold())
                    .foregroundColor(accent)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 住所があれば表示（検索選択・ピン手動移動の両方で保存される）
            if let address, !address.isEmpty {
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
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))) {
                Marker(placeName ?? fallbackName, coordinate: coordinate)
                    .tint(accent)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Button {
                openInMaps()
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

    private var sectionHeader: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(accent)
                .frame(width: 4, height: 18)
            Image(systemName: "mappin.and.ellipse")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(accent)
            Text("attraction.open_in_maps".localized)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
        }
    }

    /// 保存済みの座標を Apple マップ（無ければ Google マップ）で開く。
    /// 地点名があればラベル付きで、無ければ座標で開く。
    private func openInMaps() {
        let lat = coordinate.latitude, lng = coordinate.longitude
        let name = (placeName?.isEmpty == false) ? placeName! : fallbackName
        if let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "http://maps.apple.com/?q=\(encoded)&ll=\(lat),\(lng)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "https://maps.google.com/maps?q=\(lat),\(lng)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - プラン項目の位置を store から追って表示するラッパー
/// グルメ・お土産の詳細画面へ差し込む地図スロット。
/// 対象プラン項目に位置（customCoordinate）が設定されているときだけ地図カードを描画し、
/// 未設定なら何も表示しない。store を監視するので、位置の保存・変更・削除に追従する。
struct PlanItemPlaceMap: View {
    let itemID: UUID
    let accent: Color
    @ObservedObject private var store = TravelPlanStore.shared

    private var item: PlanItem? {
        for plan in store.plans {
            if let found = plan.items.first(where: { $0.id == itemID }) { return found }
        }
        return nil
    }

    var body: some View {
        if let item, let coord = item.customCoordinate {
            PlanPlaceMapCard(
                coordinate: coord,
                placeName: item.effectivePlaceName,
                address: item.effectiveAddress,
                fallbackName: item.name,
                accent: accent
            )
        }
    }
}
