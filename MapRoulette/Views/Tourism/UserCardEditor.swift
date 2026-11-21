//
//  UserCardEditor.swift
//  MapRoulette
//
//  カードの作成 / 編集画面。カードの詳細画面と同じ構成（表紙のヒーローヘッダー／
//  説明／URL／地図）のまま、その場で直接入力できるようにしたもの。
//

import SwiftUI
import PhotosUI
import MapKit

struct UserCardEditor: View {
    let prefecture: Prefecture
    let kind: UserCardKind
    /// 編集対象。nil なら新規作成。
    let editing: UserCard?

    @ObservedObject private var store = UserCardStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var description: String
    @State private var urlText: String
    @State private var coverImage: UIImage?
    /// 写真を選び直した・外したか。false の間は保存済みの写真をそのまま使う。
    @State private var didChangePhoto = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var placeName: String?
    @State private var address: String?
    @State private var showingLocationPicker = false
    @FocusState private var isNameFocused: Bool

    init(prefecture: Prefecture, kind: UserCardKind, editing: UserCard? = nil) {
        self.prefecture = prefecture
        self.kind = kind
        self.editing = editing
        _name = State(initialValue: editing?.name ?? "")
        _description = State(initialValue: editing?.description ?? "")
        _urlText = State(initialValue: editing?.urlString ?? "")
        _coverImage = State(initialValue: UserCardStore.shared.photo(named: editing?.photoFileName))
        _coordinate = State(initialValue: editing?.coordinate)
        _placeName = State(initialValue: editing?.placeName)
        _address = State(initialValue: editing?.address)
    }

    private var accent: Color { kind.accent }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedURL: String {
        urlText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isURLValid: Bool {
        trimmedURL.isEmpty || UserCard.normalizedURL(from: trimmedURL) != nil
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && isURLValid && !isLoadingPhoto
    }

    var body: some View {
        ZStack(alignment: .top) {
            accent.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    VStack(alignment: .leading, spacing: 18) {
                        descriptionCard
                        urlCard
                        locationCard
                    }
                    .padding(.horizontal, 18)
                }
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemBackground).ignoresSafeArea())
            .ignoresSafeArea(edges: .top)

            topButtons
        }
        .sheet(isPresented: $showingLocationPicker) {
            // 未設定なら、この県の地域中心から探し始める。
            LocationPickerView(
                coordinate: $coordinate,
                placeName: $placeName,
                address: $address,
                initialCoordinate: coordinate ?? prefecture.tourismInfo.region
            )
            .largeSheet()
        }
        // 名前が未入力なら、検索で選んだ地点名をそのまま使えるようにする。
        .onChange(of: placeName) { _, newValue in
            if trimmedName.isEmpty, let newValue {
                name = newValue
            }
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else { return }
            loadPhoto(from: newItem)
        }
        .task {
            guard editing == nil else { return }
            // 画面の表示アニメーションが終わってからキーボードを出す。
            try? await Task.sleep(for: .milliseconds(400))
            isNameFocused = true
        }
    }

    // MARK: - 上部のボタン（閉じる・保存）

    private var topButtons: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(accent)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
            }
            .accessibilityLabel("common.cancel".localized)

            Spacer()

            Button {
                save()
            } label: {
                Text("common.save".localized)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(accent)
                    .padding(.horizontal, 18)
                    .frame(height: 36)
                    .background(.white, in: Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
            }
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.5)
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
    }

    // MARK: - ヒーローヘッダー（表紙写真・名前）

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            photoButtons

            VStack(alignment: .leading, spacing: 6) {
                TextField(
                    "",
                    text: $name,
                    prompt: Text("usercard.name.placeholder".localized).foregroundColor(.white.opacity(0.7)),
                    axis: .vertical
                )
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .tint(.white)
                .focused($isNameFocused)

                Text(prefecture.prefectureName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .shadow(color: .black.opacity(coverImage == nil ? 0 : 0.35), radius: 6, y: 1)
        }
        .padding(.horizontal, 22)
        .photoHeaderTopPadding()
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            // 背景（写真・色）は左右のセーフエリアまで敷く。見開きの右ページでは、右端の
            // ステータスバー・縦向きタブバーの列の下まで写真が続く（文字やボタンはセーフエリア内のまま）。
            Group {
                if let coverImage {
                    // .fill は容器より大きく描画されるため、背景側ではサイズを決めず
                    // 外側で clipped() してヘッダー矩形に収める。
                    Image(uiImage: coverImage)
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

    private var photoButtons: some View {
        HStack(spacing: 10) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                HStack(spacing: 6) {
                    if isLoadingPhoto {
                        ProgressView().tint(.white).controlSize(.small)
                    } else {
                        Image(systemName: "photo.badge.plus")
                    }
                    Text((coverImage == nil ? "usercard.photo.add" : "usercard.photo.change").localized)
                }
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .background(.white.opacity(0.22), in: Capsule())
            }

            if coverImage != nil {
                Button {
                    coverImage = nil
                    didChangePhoto = true
                    pickerItem = nil
                } label: {
                    Image(systemName: "trash")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.22), in: Circle())
                }
                .accessibilityLabel("usercard.photo.remove".localized)
            }
        }
    }

    private func loadPhoto(from item: PhotosPickerItem) {
        isLoadingPhoto = true
        Task {
            let data = try? await item.loadTransferable(type: Data.self)
            if let data, let image = UIImage(data: data) {
                coverImage = image
                didChangePhoto = true
            }
            isLoadingPhoto = false
        }
    }

    // MARK: - カード

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "text.quote", title: "detailed_info".localized)
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text("usercard.description.placeholder".localized)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $description)
                    .font(.body)
                    .frame(minHeight: 110)
                    .scrollContentBackground(.hidden)
                    .tint(accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var urlCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "link", title: "usercard.url.label".localized)
            TextField("usercard.url.placeholder".localized, text: $urlText)
                .keyboardType(.URL)
                .textContentType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .tint(accent)
            if !isURLValid {
                Text("usercard.url.invalid".localized)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "mappin.and.ellipse", title: "attraction.open_in_maps".localized)

            Button {
                showingLocationPicker = true
            } label: {
                HStack {
                    Image(systemName: coordinate == nil ? "mappin.slash" : "mappin.circle.fill")
                        .foregroundColor(coordinate == nil ? .secondary : accent)
                    Text(locationLabel)
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

            if coordinate != nil {
                Button(role: .destructive) {
                    coordinate = nil
                    placeName = nil
                    address = nil
                } label: {
                    Text("plan.custom.location.clear".localized)
                        .font(.footnote)
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    /// 位置カードのラベル。施設名があればそれを、無ければ追加/変更の汎用文言を出す。
    private var locationLabel: String {
        if coordinate == nil {
            return "plan.custom.location.add".localized
        }
        if let placeName, !placeName.isEmpty {
            return placeName
        }
        return "plan.custom.location.set".localized
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2, style: .continuous).fill(accent).frame(width: 4, height: 18)
            Image(systemName: icon).font(.subheadline.weight(.semibold)).foregroundColor(accent)
            Text(title).font(.system(.headline, design: .rounded)).fontWeight(.bold)
        }
    }

    // MARK: - 保存

    private func save() {
        guard canSave else { return }
        var photoFileName = editing?.photoFileName
        if didChangePhoto {
            photoFileName = coverImage.flatMap(store.savePhoto)
        }
        let card = UserCard(
            id: editing?.id ?? UUID(),
            prefecture: prefecture,
            kind: kind,
            name: trimmedName,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            urlString: trimmedURL.isEmpty ? nil : trimmedURL,
            photoFileName: photoFileName,
            coordinate: coordinate,
            placeName: placeName,
            address: address,
            createdAt: editing?.createdAt ?? Date()
        )
        if editing == nil {
            store.add(card)
        } else {
            store.update(card)
        }
        dismiss()
    }
}
