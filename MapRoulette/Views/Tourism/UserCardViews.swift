//
//  UserCardViews.swift
//  MapRoulette
//
//  ユーザーが作成したカードの共通部品。
//  各セクションのカード・「カードを追加」ボタンと、カードの詳細画面を持つ。
//

import SwiftUI

// MARK: - 追加ボタン

/// セクション見出しの右側に置く「カードを追加」ボタン。
struct AddUserCardButton: View {
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                Text("usercard.add.short".localized)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(accent, in: Capsule())
            .fixedSize()
        }
        .accessibilityLabel("usercard.add".localized)
    }
}

// MARK: - カード

/// セクションのグリッドに並べるカード。大きさは同じ列の既存カードに合わせて渡す。
/// 表紙写真があれば上半分に敷き、無ければセクションのアイコンを出す。
struct UserCardTile: View {
    let card: UserCard
    let height: CGFloat
    let onTap: () -> Void

    @ObservedObject private var store = UserCardStore.shared

    private var accent: Color { card.kind.accent }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                if let photo = store.photo(named: card.photoFileName) {
                    // Color.clear に重ねて枠の大きさを先に決め、写真のはみ出しを clipped で切る。
                    Color.clear
                        .frame(height: height * 0.55)
                        .overlay(
                            Image(uiImage: photo)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        )
                        .clipped()
                }

                VStack(alignment: .leading, spacing: 6) {
                    if store.photo(named: card.photoFileName) == nil {
                        Image(systemName: card.kind.icon)
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(accent))
                            .padding(.bottom, 6)
                    }

                    Text(card.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)

                    Text(card.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 0)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: height)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(accent.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 提示

extension View {
    /// セクションからカードの作成画面と詳細画面を開く。
    func userCardPresentation(
        prefecture: Prefecture,
        kind: UserCardKind,
        isAdding: Binding<Bool>,
        selected: Binding<UserCard?>
    ) -> some View {
        self
            .fullScreenCover(isPresented: isAdding) {
                UserCardEditor(prefecture: prefecture, kind: kind)
            }
            .detailCover(item: selected) { card in
                UserCardDetailView(card: card, prefecture: prefecture)
            }
    }
}

// MARK: - 詳細画面

/// カードの詳細画面。デザインは観光スポット詳細に揃え、表紙写真をヘッダー全面に敷く。
struct UserCardDetailView: View {
    /// 開いた時点のカード。編集後の最新値は store から引く。
    let card: UserCard
    let prefecture: Prefecture
    /// プラン経由で開いたときのプラン項目。その項目に設定した位置も地図に出す。
    var planItemID: UUID? = nil

    @ObservedObject private var store = UserCardStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditor = false
    @State private var showingDeleteConfirm = false

    /// 削除直後の閉じるアニメーション中は、開いた時点の値で表示を保つ。
    private var current: UserCard { store.card(id: card.id) ?? card }

    private var accent: Color { current.kind.accent }

    private var photo: UIImage? { store.photo(named: current.photoFileName) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 上方向バウンス時にヘッダー背後へ白が出ないよう最背面に基調色を敷く。
            accent.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    VStack(alignment: .leading, spacing: 18) {
                        actionCard
                        if !current.description.isEmpty {
                            descriptionCard
                        }
                        if let coordinate = current.coordinate {
                            PlanPlaceMapCard(
                                coordinate: coordinate,
                                placeName: current.placeName,
                                address: current.address,
                                fallbackName: current.name,
                                accent: accent
                            )
                        } else if let planItemID {
                            PlanItemPlaceMap(itemID: planItemID, accent: accent)
                        }
                    }
                    .padding(.horizontal, 18)
                    .readableContentWidth()
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .ignoresSafeArea(edges: .top)

            topButtons
        }
        // 見開きの右ページでは NavigationStack に積まれるので、自前の閉じるボタンと
        // 二重にならないようナビゲーションバーを隠す。
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showingEditor) {
            UserCardEditor(prefecture: prefecture, kind: current.kind, editing: current)
        }
        .confirmationDialog(
            "usercard.delete.confirm".localized,
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("common.delete".localized, role: .destructive) {
                store.delete(current)
                dismiss()
            }
            Button("common.cancel".localized, role: .cancel) {}
        }
    }

    // MARK: - 右上のボタン（メニュー・閉じる）

    private var topButtons: some View {
        HStack(spacing: 12) {
            Menu {
                Button {
                    showingEditor = true
                } label: {
                    Label("usercard.edit".localized, systemImage: "square.and.pencil")
                }
                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Label("usercard.delete".localized, systemImage: "trash")
                }
            } label: {
                circleLabel(icon: "ellipsis")
            }
            .accessibilityLabel("usercard.menu".localized)

            Button {
                InterstitialViewModel.count += 2
                dismiss()
            } label: {
                circleLabel(icon: "xmark")
            }
            .accessibilityLabel("tourism_detail_back".localized)
        }
        .closeButtonTopPadding()
        .padding(.trailing, 18)
    }

    private func circleLabel(icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(accent)
            .frame(width: 36, height: 36)
            .background(.ultraThinMaterial, in: Circle())
            .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
            .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
    }

    // MARK: - ヒーローヘッダー

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(current.name)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(prefecture.prefectureName)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .shadow(color: .black.opacity(photo == nil ? 0 : 0.35), radius: 6, y: 1)
        .padding(.horizontal, 22)
        .photoHeaderTopPadding()
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            // 背景（写真・色）は左右のセーフエリアまで敷く。見開きの右ページでは、右端の
            // ステータスバー・縦向きタブバーの列の下まで写真が続く（文字やボタンはセーフエリア内のまま）。
            Group {
                if let photo {
                    // .fill は容器より大きく描画されるため、背景側ではサイズを決めず
                    // 外側の photoHeaderClip() で上下を切る（左右はセーフエリアまで敷く）。
                    Image(uiImage: photo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(PhotoHeaderStyle.scrim)
                } else {
                    accent
                }
            }
            .ignoresSafeArea(edges: [.top, .horizontal])
        }
        .photoHeaderClip()
    }

    // MARK: - カード

    private var actionCard: some View {
        VStack(spacing: 14) {
            AddToPlanButton {
                PlanItem(category: current.kind.planCategory, prefecture: prefecture, name: current.name)
            }

            if let url = current.url {
                Link(destination: url) {
                    HStack(spacing: 12) {
                        Image(systemName: "safari.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(accent)
                            .frame(width: 32, height: 32)
                            .background(.white, in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("usercard.url.open".localized)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            // 長い URL は途中を省略して、ドメインと末尾の両方を見せる。
                            Text(current.urlString ?? url.absoluteString)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
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
            }

            HStack(spacing: 6) {
                Text("gourmet.explore_more".localized)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                Spacer()
            }

            SocialSearchButtons(
                query: current.name,
                tabelog: current.kind.isRestaurant
                    ? TabelogSearch(areaSlug: prefecture.rawValue, keyword: current.name)
                    : nil
            )
        }
        .planCard()
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2, style: .continuous).fill(accent).frame(width: 4, height: 18)
                Image(systemName: "text.quote").font(.subheadline.weight(.semibold)).foregroundColor(accent)
                Text("detailed_info".localized).font(.system(.headline, design: .rounded)).fontWeight(.bold)
            }
            Text(current.description)
                .font(.body)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }
}

// MARK: - カフェ

/// カフェセクションのカード列。カフェは同梱データを持たないので、作成したカードだけを並べる。
struct UserCafeCards: View {
    let prefecture: Prefecture
    /// 追加ボタンはセクション見出し側にあるので、状態は親が持つ。
    @Binding var isAdding: Bool

    @ObservedObject private var store = UserCardStore.shared
    @State private var selectedCard: UserCard? = nil

    var body: some View {
        LazyVGrid(columns: AdaptiveGrid.cardColumns(spacing: 12), spacing: 16) {
            ForEach(store.cards(in: prefecture, kind: .cafe)) { card in
                UserCardTile(card: card, height: 200) {
                    selectedCard = card
                }
            }
        }
        .userCardPresentation(prefecture: prefecture, kind: .cafe, isAdding: $isAdding, selected: $selectedCard)
    }
}
