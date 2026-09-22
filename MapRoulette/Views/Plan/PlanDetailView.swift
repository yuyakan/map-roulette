//
//  PlanDetailView.swift
//  MapRoulette
//
//  旅行プランの詳細画面。ブランド統一のカードベース UI。
//  「日程ごとに分ける」トグルで表示を切り替え、
//  日程モードではカードをドラッグ&ドロップして各 Day に割り当てる。
//

import SwiftUI
import MapKit
import UniformTypeIdentifiers

/// プラン詳細内の上タブ（旅程 / 費用）
private enum PlanDetailSection: Int, CaseIterable {
    case itinerary   // 旅程（既存の内容）
    case cost        // 費用（メンバー・金額一覧・合計）

    var title: String {
        switch self {
        case .itinerary: return NSLocalizedString("plan.section.itinerary", comment: "")
        case .cost:      return NSLocalizedString("plan.section.cost", comment: "")
        }
    }
}

struct PlanDetailView: View {
    let planID: UUID
    @ObservedObject private var store = TravelPlanStore.shared
    @State private var showingMapSheet = false
    @State private var showingMemoEditor = false
    @State private var showingCustomEditor = false
    /// タイトル編集アラートの表示状態（タイトルは 1 行なので alert で完結させる）。
    @State private var showingTitleEditor = false
    @State private var titleDraft = ""
    @State private var memoDraft = ""
    @State private var section: PlanDetailSection = .itinerary
    /// 編集モード。false（通常）では旅程リストと県だけを静かに表示し、
    /// 設定カード・削除ボタン・ドラッグハンドル・各種追加ボタンをすべて隠す。
    /// true のとき初めて編集系 UI を出す。右上「編集」⇄「完了」で切り替える。
    @State private var isEditing = false
    /// タップした県。セット時に県詳細（TourismDetailView）を全画面表示する。
    @State private var openedPrefecture: Prefecture?
    /// 県を複数選択して追加するシートの表示状態。
    @State private var showingPrefecturePicker = false
    /// 県→スポットカード一覧から直接プランへ追加するシートの表示状態。
    @State private var showingSpotQuickAdd = false

    private var plan: TravelPlan? {
        store.plans.first { $0.id == planID }
    }

    var body: some View {
        ZStack {
            // プラン詳細は白基調（旅程・費用タブ共通の最背面）。カードは影・グレーで区別する。
            PlanTheme.pageBackground.ignoresSafeArea()
            if let plan {
                // 切替帯は詳細画面の内側最上部に置く。帯の下でタブ内容を差し替える。
                VStack(spacing: 0) {
                    PlanDetailSectionBand(section: $section)
                    switch section {
                    case .itinerary:
                        content(for: plan)
                    case .cost:
                        PlanCostView(planID: planID)
                    }
                }
            } else {
                Text(NSLocalizedString("plan.notfound", comment: ""))
                    .foregroundColor(.secondary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let plan {
                ToolbarItem(placement: .principal) {
                    // 編集モードではタイトルをタップでタイトル編集（鉛筆付きボタン）。
                    // 通常モードは素のタイトル表示。
                    if isEditing {
                        Button {
                            startEditingTitle(plan)
                        } label: {
                            HStack(spacing: 4) {
                                Text(plan.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Image(systemName: "pencil")
                                    .font(.caption.bold())
                                    .foregroundColor(PlanTheme.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text(plan.title).font(.headline)
                    }
                }
                // 共有は旅程タブの通常モードのときだけ（編集中は編集操作に集中させる）。
                if section == .itinerary, !isEditing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(item: PlanShareFormatter.text(for: plan)) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(PlanTheme.primary)
                        }
                        .accessibilityLabel(NSLocalizedString("plan.share", comment: ""))
                    }
                }
                // 旅程タブでだけ編集モードに入れる（費用タブは別 UI）。
                if section == .itinerary {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { isEditing.toggle() }
                        } label: {
                            Text(isEditing
                                 ? NSLocalizedString("common.done", comment: "")
                                 : NSLocalizedString("common.edit", comment: ""))
                                .font(isEditing ? .headline : .body)
                                .foregroundColor(PlanTheme.primary)
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // 右下の FAB 群（旅程タブのときだけ・費用タブでは隠す）。
            // 上から「スポット追加」→「地図」の順に縦積み。
            if section == .itinerary, let plan {
                VStack(spacing: 14) {
                    // スポット追加 FAB は編集モードのときだけ。日程モードでは各 Day に
                    // 追加ボタンがあるので、フラット表示（日程分けなし）のときだけ出す。
                    if isEditing, plan.groupingMode != .day {
                        fabButton(icon: "plus", accessibility: NSLocalizedString("plan.spot.add", comment: "")) {
                            showingSpotQuickAdd = true
                        }
                    }
                    // 地図 FAB は座標を持つ項目が 1 つ以上あるときだけ出す（閲覧にも使うので常時）。
                    if !plan.mappableItems.isEmpty {
                        fabButton(icon: "map.fill", accessibility: NSLocalizedString("plan.showmap", comment: "")) {
                            showingMapSheet = true
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingMapSheet) {
            if let plan { PlanMapView(plan: plan).largeSheet() }
        }
        .sheet(isPresented: $showingMemoEditor) {
            if let plan { memoEditor(for: plan).formSheet() }
        }
        // タイトル編集（1 行なので alert のテキストフィールドで完結）。
        .alert(NSLocalizedString("plan.title.label", comment: ""), isPresented: $showingTitleEditor) {
            TextField(NSLocalizedString("plan.title.placeholder", comment: ""), text: $titleDraft)
            Button(NSLocalizedString("common.cancel", comment: ""), role: .cancel) { }
            Button(NSLocalizedString("common.save", comment: "")) { saveTitle() }
        }
        .sheet(isPresented: $showingCustomEditor) {
            CustomPlanItemEditor(planID: planID).largeSheet()
        }
        // 県チップから県詳細（観光・グルメ・温泉などの全部入り）を全画面表示。
        // その画面内の「＋プランに追加」でスポットを直接このプランへ足せるので、
        // プラン詳細から一切抜けずに旅程を組み立てられる。
        .fullScreenCover(item: $openedPrefecture) { prefecture in
            TourismDetailView(prefecture: prefecture)
        }
        // 県を複数まとめて追加するシート。既にプランにある県は除外して提示する。
        .sheet(isPresented: $showingPrefecturePicker) {
            PrefecturePickerSheet(
                excluded: Set(plan?.prefectures ?? [])
            ) { selected in
                store.addPrefectures(selected, to: planID)
            }
            .largeSheet()
        }
        // 県→スポットカード一覧から詳細を開かずに直接追加するシート。
        // 起点は plan.prefectures（登録済みの県）を優先候補として提示する。
        .sheet(isPresented: $showingSpotQuickAdd) {
            SpotQuickAddSheet(planID: planID, suggestedPrefectures: plan?.prefectures ?? [])
                .largeSheet()
        }
        // 費用タブへ移ったら編集モードは抜ける（編集は旅程タブ専用）。
        .onChange(of: section) { _, newValue in
            if newValue != .itinerary { isEditing = false }
        }
        .tint(PlanTheme.primary)
    }

    /// 右下に積むフローティングボタン（地図・スポット追加で共通のブランド円形 FAB）。
    private func fabButton(icon: String, accessibility: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(PlanTheme.brandGradient))
                .shadow(color: PlanTheme.primary.opacity(0.4), radius: 10, x: 0, y: 4)
        }
        .accessibilityLabel(accessibility)
    }

    // MARK: - 本体

    @ViewBuilder
    private func content(for plan: TravelPlan) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // 県カードの「＋」「長押し削除」は編集モードのときだけ効かせる。
                prefectureCard(for: plan)

                // 日程トグル・日数などの設定カードは編集モードのときだけ出す。
                if isEditing {
                    controlCard(for: plan)
                }

                if !plan.memo.isEmpty {
                    // 通常モードではメモが長いと 3 行で畳み「続きを読む」で展開。
                    // 編集モードでは全文を出す（設定カードからメモ編集へ飛べる）。
                    PlanMemoCard(memo: plan.memo, collapsible: !isEditing)
                }

                if plan.groupingMode == .day {
                    // 日程モードでは項目が空でも各 Day のセクションを表示し、
                    // その日に直接ホテル・移動などを追加できるようにする。
                    dayGroups(for: plan)
                } else if plan.itineraryItems.isEmpty {
                    // 通常モードで空なら静かな案内だけ。追加導線は編集モードの emptyHint に集約。
                    if isEditing {
                        emptyHint
                    } else {
                        quietEmptyHint
                    }
                } else {
                    flatList(for: plan)
                }

                // スポット追加はフラット表示では右下のフローティングボタン（FAB）に集約。
                // 日程モードでは各 Day にスポット追加ボタンがある。

                // 進行状態の切り替えは編集モードでだけ出す（リスト末尾に控えめに）。
                if isEditing {
                    statusFooter(for: plan)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            // 末尾は右下 FAB 群（スポット追加＋地図＝56pt×2＋間隔14＋下20pt）と
            // 被らないよう広めに空ける。
            .padding(.bottom, 160)
        }
    }

    /// 通常モードで項目が空のときの静かな案内（追加導線は出さず、編集へ誘導するだけ）。
    private var quietEmptyHint: some View {
        VStack(spacing: 8) {
            Text(NSLocalizedString("plan.detail.empty", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            Text(NSLocalizedString("plan.detail.empty.edithint", comment: ""))
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .planCard()
    }

    // MARK: - 県カード（行き先候補 → 県詳細への起点）

    /// プランの行き先となる県を並べ、タップで県詳細（全部入り）へ飛べるカード。
    /// 県詳細内の「＋プランに追加」でスポットを直接このプランへ追加できるため、
    /// わざわざマップ／観光タブへ移動して戻る往復が不要になる。
    /// - 県が空: 「県を追加」ボタンのみ（見出し・説明は出さない）。
    /// - 県あり: チップ群 ＋ 右上の「＋」ボタン。
    @ViewBuilder
    private func prefectureCard(for plan: TravelPlan) -> some View {
        if plan.prefectures.isEmpty {
            // 県が無いとき: 編集モードなら追加ボタン、通常モードでは何も出さない。
            if isEditing {
                addPrefectureButton
                    .planCard()
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                FlowLayout(spacing: 8) {
                    ForEach(plan.prefectures) { prefecture in
                        prefectureChip(prefecture, in: plan)
                    }
                    // チップ列末尾の「＋」は編集モードのときだけ（通常はタップで県詳細のみ）。
                    if isEditing {
                        addPrefectureIconButton
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .planCard()
        }
    }

    /// 空状態の「県を追加」ボタン（破線枠・カード幅いっぱい）。
    private var addPrefectureButton: some View {
        Button {
            showingPrefecturePicker = true
        } label: {
            Label(NSLocalizedString("plan.prefectures.add", comment: ""), systemImage: "plus")
                .font(.subheadline.bold())
                .foregroundColor(PlanTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(PlanTheme.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                )
        }
        .buttonStyle(.plain)
    }

    // 県写真タイルの寸法（＋タイルも同じサイズに揃える）。
    private var prefectureTileWidth: CGFloat { 70 }
    private var prefectureTileHeight: CGFloat { 44 }
    private var prefectureTileRadius: CGFloat { 10 }

    /// チップ列の末尾に並べる「＋」タイル（正方形・破線枠・アイコンのみ）。
    private var addPrefectureIconButton: some View {
        Button {
            showingPrefecturePicker = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(PlanTheme.primary)
                // ＋ タイルは正方形（高さに合わせる）にして写真タイルの隣で自然に収める。
                .frame(width: prefectureTileHeight, height: prefectureTileHeight)
            .background(
                RoundedRectangle(cornerRadius: prefectureTileRadius, style: .continuous)
                    .strokeBorder(PlanTheme.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(NSLocalizedString("plan.prefectures.add", comment: ""))
    }

    /// 県タイル。その県の代表スポット写真を背景に敷き、暗いスクリムに白文字で県名を出す。
    /// 写真が無い県はブランドグラデーションで代替。タップで県詳細を開く。
    /// 手動追加した県は長押しで削除できる。
    private func prefectureChip(_ prefecture: Prefecture, in plan: TravelPlan) -> some View {
        // 手動登録した県だけ削除可能（旅程項目由来の県はスポットを消せば自動で消える）。
        let isRemovable = plan.plannedPrefectures.contains(prefecture)
        // 代表写真: 写真付きスポットの先頭（ホームのヒーロー画像と同じ引き方）。
        let heroImage = AttractionPhoto.photographedAttractions(in: prefecture)
            .first
            .flatMap { AttractionPhoto.image(for: $0.nameKey) }

        return Button {
            openedPrefecture = prefecture
        } label: {
            ZStack(alignment: .bottomLeading) {
                // 背景（写真 or ブランドグラデーション）
                Group {
                    if let heroImage {
                        heroImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        PlanTheme.brandGradient
                    }
                }
                .frame(width: prefectureTileWidth, height: prefectureTileHeight)
                .clipped()

                // 下部を暗くして白文字を読みやすくするスクリム
                LinearGradient(
                    colors: [.black.opacity(0.05), .black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // 県名（左下・白）
                Text(prefecture.prefectureName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: prefectureTileWidth, height: prefectureTileHeight)
            .clipShape(RoundedRectangle(cornerRadius: prefectureTileRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: prefectureTileRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5)
            )
            .shadow(color: PlanTheme.cardShadow, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        // 長押しメニューは編集モードのときだけ付ける。
        //
        // 【なぜ if で丸ごと外すか】
        // 中身が空の contextMenu を付けると、長押しでプレビューの拡大アニメーションだけ
        // 起きてメニューが出ない。ユーザーからは「反応しない・壊れている」ようにしか
        // 見えないので、出すものが無いときはモディファイア自体を付けない。
        .modifier(
            PrefectureChipMenu(
                isEnabled: isEditing,
                isRemovable: isRemovable,
                onDelete: { store.removePrefecture(prefecture, from: planID) }
            )
        )
    }

    // MARK: - コントロールカード（日程トグル・日数）

    private func controlCard(for plan: TravelPlan) -> some View {
        VStack(spacing: 14) {
            // メモの編集導線（編集モードの設定カード内）。タイトルはツールバーのタイトル部から編集。
            Button {
                startEditingMemo(plan)
            } label: {
                HStack {
                    Label(NSLocalizedString("plan.item.editmemo", comment: ""), systemImage: "note.text")
                        .font(.subheadline.bold())
                        .foregroundColor(PlanTheme.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
            .buttonStyle(.plain)

            Divider()

            Toggle(isOn: dayModeBinding(for: plan)) {
                Label(NSLocalizedString("plan.grouping.day.toggle", comment: ""), systemImage: "calendar")
                    .font(.subheadline.bold())
            }
            .tint(PlanTheme.primary)

            if plan.groupingMode == .day {
                Divider()
                HStack {
                    Text(String(format: NSLocalizedString("plan.daycount.format", comment: ""), plan.dayCount))
                        .font(.subheadline)
                    Spacer()
                    Stepper("", value: dayCountBinding(for: plan), in: 1...30)
                        .labelsHidden()
                }
            }
        }
        .planCard()
    }

    // MARK: - 進行状態フッター（リスト末尾の控えめなステータス切替）

    /// リストの一番下に置く進行状態（これから / 進行中 / 旅行済み）の切替。
    /// 常に目立つ位置を大きく占有しないよう、スクロール末尾に控えめに配置する。
    /// 「旅行済み」にすると訪問済みマップの集計対象になる。
    private func statusFooter(for plan: TravelPlan) -> some View {
        HStack {
            Label(NSLocalizedString("plan.status.label", comment: ""), systemImage: "flag.fill")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
            Spacer()
            Picker("", selection: statusBinding(for: plan)) {
                ForEach(PlanStatus.allCases, id: \.self) { status in
                    Label(status.localizedName, systemImage: status.icon).tag(status)
                }
            }
            .pickerStyle(.menu)
            .tint(PlanTheme.primary)
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    private var emptyHint: some View {
        VStack(spacing: 14) {
            Text(NSLocalizedString("plan.detail.empty", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // 項目が 1 つも無くてもホテル・移動などのカスタム項目は追加できる
            addCustomButton
        }
        .planCard()
    }

    /// ホテル・移動などのカスタム項目を追加するボタン（フラット表示・空状態で共用）。
    private var addCustomButton: some View {
        Button {
            showingCustomEditor = true
        } label: {
            Label(NSLocalizedString("plan.day.addcustom", comment: ""), systemImage: "plus")
                .font(.subheadline.bold())
                .foregroundColor(PlanTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(PlanTheme.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - フラット表示（日程分けなし）

    private func flatList(for plan: TravelPlan) -> some View {
        VStack(spacing: 12) {
            ForEach(plan.itineraryItems) { item in
                PlanItemCard(item: item, store: store, planID: planID, draggable: false, isEditing: isEditing)
            }

            // ホテル・移動などのカスタム項目の追加は編集モードのときだけ。
            if isEditing {
                addCustomButton
            }
        }
    }

    // MARK: - 日程グループ（ドラッグ&ドロップ）

    private func dayGroups(for plan: TravelPlan) -> some View {
        VStack(spacing: 16) {
            ForEach(plan.itemsByDay, id: \.day) { group in
                DayDropSection(
                    day: group.day,
                    items: group.items,
                    plan: plan,
                    store: store,
                    planID: planID,
                    isEditing: isEditing
                )
            }
        }
    }

    // MARK: - Bindings

    private func dayModeBinding(for plan: TravelPlan) -> Binding<Bool> {
        Binding(
            get: { plan.groupingMode == .day },
            set: { store.setGroupingMode($0 ? .day : .flat, for: planID) }
        )
    }

    private func dayCountBinding(for plan: TravelPlan) -> Binding<Int> {
        Binding(
            get: { plan.dayCount },
            set: { store.setDayCount($0, for: planID) }
        )
    }

    private func statusBinding(for plan: TravelPlan) -> Binding<PlanStatus> {
        Binding(
            get: { plan.status },
            set: { store.setStatus($0, for: planID) }
        )
    }

    // MARK: - タイトル編集（ツールバーのタイトル部から alert で）

    private func startEditingTitle(_ plan: TravelPlan) {
        titleDraft = plan.title
        showingTitleEditor = true
    }

    private func saveTitle() {
        guard var updated = plan else { return }
        let trimmed = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }   // 空タイトルは保存しない
        updated.title = trimmed
        store.updatePlan(updated)
    }

    // MARK: - メモ編集（メモ専用シート）

    private func startEditingMemo(_ plan: TravelPlan) {
        memoDraft = plan.memo
        showingMemoEditor = true
    }

    private func memoEditor(for plan: TravelPlan) -> some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    // メモ
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("plan.memo.label", comment: ""))
                            .font(.caption.bold())
                            .foregroundColor(PlanTheme.primary)
                        TextEditor(text: $memoDraft)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .planCard()

                    Spacer()
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("plan.item.editmemo", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        showingMemoEditor = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.save", comment: "")) {
                        var updated = plan
                        updated.memo = memoDraft
                        store.updatePlan(updated)
                        showingMemoEditor = false
                    }
                }
            }
        }
    }
}

// MARK: - PlanMemoCard
/// メモ表示カード。collapsible のとき、3 行を超えるメモは 3 行で畳み
/// 「続きを読む」/「折りたたむ」で展開・収納できる。
/// 切り詰めの有無は「3 行制限時の高さ」と「全文の高さ」を裏で測って比較し判定する。
private struct PlanMemoCard: View {
    let memo: String
    /// true のとき 3 行で畳む（通常モード）。false は常に全文表示（編集モード）。
    let collapsible: Bool

    @State private var isExpanded = false
    @State private var isTruncatable = false

    private let collapsedLineLimit = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(NSLocalizedString("plan.memo.label", comment: ""), systemImage: "note.text")
                .font(.caption.bold())
                .foregroundColor(PlanTheme.primary)

            Text(memo)
                .font(.subheadline)
                .lineLimit(showFull ? nil : collapsedLineLimit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(truncationProbe)

            // 3 行を超えるときだけ展開トグルを出す（collapsible のときのみ）。
            if collapsible && isTruncatable {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                } label: {
                    Text(isExpanded
                         ? NSLocalizedString("common.collapse", comment: "")
                         : NSLocalizedString("common.readmore", comment: ""))
                        .font(.caption.bold())
                        .foregroundColor(PlanTheme.primary)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    /// 全文を表示するか（展開中、または畳み対象でない＝編集モード）。
    private var showFull: Bool { !collapsible || isExpanded }

    /// 切り詰め判定用の裏測り。3 行制限した高さと全文高さを比較し、
    /// 全文の方が高ければ「3 行を超える」と判断する。表示はしない。
    private var truncationProbe: some View {
        Text(memo)
            .font(.subheadline)
            .lineLimit(collapsedLineLimit)
            .background(
                GeometryReader { limitedGeo in
                    Text(memo)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                        .background(
                            GeometryReader { fullGeo in
                                Color.clear
                                    .onAppear {
                                        isTruncatable = fullGeo.size.height > limitedGeo.size.height + 1
                                    }
                                    .onChange(of: fullGeo.size.height) { _, newHeight in
                                        isTruncatable = newHeight > limitedGeo.size.height + 1
                                    }
                            }
                        )
                        .hidden()
                }
            )
            .hidden()
    }
}

// MARK: - PlanDetailSectionBand
/// プラン詳細内の上タブ切替帯（旅程 / 費用）。
/// マイプランタブの PlanSectionBand と同じデザイン言語（文字＋ブランド下線）で統一する。
private struct PlanDetailSectionBand: View {
    @Binding var section: PlanDetailSection

    // 下線の左右インセット（セル幅からこの分だけ内側に縮める）
    private let underlineInset: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let count = CGFloat(PlanDetailSection.allCases.count)
            let cellWidth = geo.size.width / count
            let selectedIndex = CGFloat(section.rawValue)

            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    ForEach(PlanDetailSection.allCases, id: \.self) { item in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                section = item
                            }
                        } label: {
                            Text(item.title)
                                .font(.system(size: 15, weight: section == item ? .semibold : .regular))
                                .foregroundColor(section == item ? PlanTheme.primary : .gray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                // 下線（常に1本。offset で選択セルの位置へ移動）
                Rectangle()
                    .fill(PlanTheme.brandGradient)
                    .frame(width: cellWidth - underlineInset * 2, height: 2)
                    .offset(x: selectedIndex * cellWidth + underlineInset)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(height: 44)
        // 背景は敷かず透明にして、画面全体の背景グラデーションを透けさせる。
    }
}

// MARK: - DayDropSection
/// 1 日分のドロップゾーン。カードをドロップするとその日に割り当てる。

private struct DayDropSection: View {
    let day: Int?           // nil は「未割当」
    let items: [PlanItem]
    let plan: TravelPlan    // 時間ブロックの参照に必要
    let store: TravelPlanStore
    let planID: UUID
    let isEditing: Bool     // 編集モードのときだけ追加ボタン・ドラッグ&ドロップを出す
    @State private var isTargeted = false
    @State private var showingCustomEditor = false
    @State private var showingSpotQuickAdd = false   // 県→スポット一覧から直接追加するシート
    @State private var editingBlock: TimeBlock?   // 時刻編集シートの対象

    private var title: String {
        if let day {
            return String(format: NSLocalizedString("plan.day.format", comment: ""), day)
        } else {
            return NSLocalizedString("plan.day.unassigned", comment: "")
        }
    }

    /// 実日（day != nil）では時間ブロックごとに分けて表示する。
    private var blockSections: [(block: TimeBlock?, items: [PlanItem])] {
        guard let day else { return [(nil, items)] }
        return plan.blockSections(forDay: day)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(day == nil ? .secondary : PlanTheme.primary)
                Spacer()
                // この日にカスタム項目（ホテル・移動など）を追加。編集モード・実日のときだけ。
                if isEditing, day != nil {
                    Button {
                        showingCustomEditor = true
                    } label: {
                        Label(NSLocalizedString("plan.day.addcustom", comment: ""), systemImage: "plus")
                            .font(.caption.bold())
                            .foregroundColor(PlanTheme.primary)
                    }
                    .buttonStyle(.plain)
                }
            }

            if items.isEmpty && day == nil {
                Text(NSLocalizedString("plan.day.empty", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            } else if day == nil {
                // 未割当セクションはタイムライン無しのフラット表示（ドラッグは編集モードのみ）
                ForEach(items) { item in
                    PlanItemCard(
                        item: item,
                        store: store,
                        planID: planID,
                        draggable: isEditing,
                        isEditing: isEditing,
                        onDrop: { droppedID in
                            store.moveItem(droppedID, toDay: day, before: item.id, in: planID)
                        }
                    )
                }
            } else {
                // 実日: 時間ブロックごとのタイムライン表示
                ForEach(blockSections, id: \.block?.id) { section in
                    TimelineBlockRow(
                        day: day!,
                        block: section.block,
                        items: section.items,
                        store: store,
                        planID: planID,
                        isEditing: isEditing,
                        onEditBlock: { editingBlock = $0 }
                    )
                }

                // 時間ブロック・スポットの追加ボタンは編集モードのときだけ。
                if isEditing {
                    // この日に時間ブロックを追加
                    Button {
                        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
                        store.addTimeBlock(toDay: day!, startHour: now.hour, startMinute: now.minute, in: planID)
                    } label: {
                        Label(NSLocalizedString("plan.timeblock.add", comment: ""), systemImage: "clock.badge.plus")
                            .font(.caption.bold())
                            .foregroundColor(PlanTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(PlanTheme.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)

                    // この日に県→スポット一覧から直接スポットを追加（この Day に割り当てて入る）。
                    Button {
                        showingSpotQuickAdd = true
                    } label: {
                        Label(NSLocalizedString("plan.spot.add", comment: ""), systemImage: "plus.magnifyingglass")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(PlanTheme.brandGradient)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                        .strokeBorder(
                            isTargeted ? PlanTheme.primary : Color.clear,
                            style: StrokeStyle(lineWidth: 2, dash: [6])
                        )
                )
        )
        .shadow(color: PlanTheme.cardShadow, radius: 8, x: 0, y: 3)
        // セクション全体へのドロップは「その日の末尾へ移動」。カードへの個別ドロップが
        // 優先されるため、ここに来るのはカードの隙間や空き領域に落とした場合のみ。
        .dropDestination(for: String.self) { droppedIDs, _ in
            guard let idString = droppedIDs.first, let uuid = UUID(uuidString: idString) else { return false }
            store.moveItem(uuid, toDay: day, before: nil, in: planID)
            return true
        } isTargeted: { targeted in
            withAnimation(.easeOut(duration: 0.15)) { isTargeted = targeted }
        }
        .sheet(isPresented: $showingCustomEditor) {
            CustomPlanItemEditor(planID: planID, initialDay: day).largeSheet()
        }
        // この Day 起点のスポット追加。追加された項目は initialDay でこの日に割り当てられる。
        .sheet(isPresented: $showingSpotQuickAdd) {
            SpotQuickAddSheet(planID: planID, suggestedPrefectures: plan.prefectures, initialDay: day)
                .largeSheet()
        }
        .sheet(item: $editingBlock) { block in
            TimeBlockEditor(block: block, store: store, planID: planID).formSheet()
        }
    }
}

// MARK: - TimelineBlockRow
/// 1 つの時間ブロック行。左に時刻列＋接続線、右に項目カード群を並べる。
/// block == nil は「時間未割当」の受け皿（見出しは控えめ）。

private struct TimelineBlockRow: View {
    let day: Int
    let block: TimeBlock?
    let items: [PlanItem]
    let store: TravelPlanStore
    let planID: UUID
    let isEditing: Bool
    let onEditBlock: (TimeBlock) -> Void
    @State private var isTargeted = false
    @State private var showingDeleteConfirm = false

    private var blockID: UUID? { block?.id }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            timeColumn
            content
        }
        .padding(.vertical, 4)
        // ブロック全体へのドロップ＝そのブロックの末尾へ移動。
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isTargeted ? PlanTheme.primary.opacity(0.06) : .clear)
        )
        // 透明な余白部分もドロップ判定に含める（空ブロックの判定領域を広げる）。
        .contentShape(Rectangle())
        .dropDestination(for: String.self) { droppedIDs, _ in
            guard let idString = droppedIDs.first, let uuid = UUID(uuidString: idString) else { return false }
            store.moveItem(uuid, toDay: day, block: blockID, before: nil, in: planID)
            return true
        } isTargeted: { targeted in
            withAnimation(.easeOut(duration: 0.12)) { isTargeted = targeted }
        }
        // ブロック削除の確認。所属項目は「時間未割当」へ戻る（削除されない）。
        .alert(NSLocalizedString("plan.timeblock.delete.confirm", comment: ""), isPresented: $showingDeleteConfirm) {
            Button(NSLocalizedString("common.cancel", comment: ""), role: .cancel) { }
            Button(NSLocalizedString("common.delete", comment: ""), role: .destructive) {
                if let blockID { store.removeTimeBlock(blockID, in: planID) }
            }
        } message: {
            Text(NSLocalizedString("plan.timeblock.delete.message", comment: ""))
        }
    }

    // MARK: - 左の時刻列（ドット＋接続線）

    private var timeColumn: some View {
        VStack(spacing: 0) {
            // 時刻を設定していないブロックはラベルを出さず、ドットと接続線だけにする。
            Group {
                if let label = block?.timeLabel {
                    Text(label)
                        .font(.caption.bold().monospacedDigit())
                        .foregroundColor(PlanTheme.primary)
                } else {
                    Color.clear.frame(height: 1)
                }
            }
            .frame(width: 46)

            Circle()
                .fill(block == nil ? Color.secondary.opacity(0.5) : PlanTheme.primary)
                .frame(width: 9, height: 9)
                .padding(.top, 4)

            // 下方向へ伸びる接続線（このブロックの高さいっぱい）
            Rectangle()
                .fill((block == nil ? Color.secondary.opacity(0.3) : PlanTheme.primary.opacity(0.35)))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
                .padding(.top, 2)
        }
        .frame(width: 52)
    }

    // MARK: - 右の内容（見出し＋項目カード）

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ブロック見出し（時刻編集ボタン付き）。時間未割当ブロック（block == nil）には
            // 見出しラベルを一切出さず、項目だけを並べる（時間指定なしでも自然に使えるように）。
            if let block {
                HStack(spacing: 10) {
                    if !block.title.isEmpty {
                        Text(block.title)
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                    }
                    // 時刻編集・削除は編集モードのときだけ出す。
                    if isEditing {
                        Button {
                            onEditBlock(block)
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.caption)
                                .foregroundColor(PlanTheme.primary)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        // 時間ブロックの削除。誤タップ防止に確認アラートを挟む。
                        Button {
                            showingDeleteConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(NSLocalizedString("plan.timeblock.delete", comment: ""))
                    }
                }
            }

            if items.isEmpty {
                // 空ブロックのドロップ受け皿は編集モードのときだけ（通常は空なら何も出さない）。
                if isEditing {
                    Label(NSLocalizedString("plan.timeblock.empty", comment: ""), systemImage: "arrow.down.to.line")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(PlanTheme.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                        )
                        .contentShape(Rectangle())
                }
            } else {
                ForEach(items) { item in
                    PlanItemCard(
                        item: item,
                        store: store,
                        planID: planID,
                        draggable: isEditing,
                        isEditing: isEditing,
                        onDrop: { droppedID in
                            store.moveItem(droppedID, toDay: day, block: blockID, before: item.id, in: planID)
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - TimeBlockEditor
/// 時間ブロックの開始時刻・見出しの編集シート。削除もここから行う。

private struct TimeBlockEditor: View {
    let store: TravelPlanStore
    let planID: UUID
    @Environment(\.dismiss) private var dismiss

    private let blockID: UUID
    private let dayNumber: Int
    @State private var hasTime: Bool
    @State private var time: Date
    @State private var title: String

    init(block: TimeBlock, store: TravelPlanStore, planID: UUID) {
        self.store = store
        self.planID = planID
        self.blockID = block.id
        self.dayNumber = block.dayNumber
        _hasTime = State(initialValue: block.hasTime)
        _title = State(initialValue: block.title)
        var comps = DateComponents()
        comps.hour = block.startHour ?? 9
        comps.minute = block.startMinute ?? 0
        _time = State(initialValue: Calendar.current.date(from: comps) ?? Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $hasTime) {
                            Label(NSLocalizedString("plan.timeblock.settime", comment: ""), systemImage: "clock")
                                .font(.subheadline.bold())
                        }
                        .tint(PlanTheme.primary)

                        if hasTime {
                            Divider()
                            DatePicker(
                                NSLocalizedString("plan.timeblock.starttime", comment: ""),
                                selection: $time,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .planCard()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("plan.timeblock.title.label", comment: ""))
                            .font(.caption.bold())
                            .foregroundColor(PlanTheme.primary)
                        TextField(NSLocalizedString("plan.timeblock.title.placeholder", comment: ""), text: $title)
                            .textFieldStyle(.plain)
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .planCard()

                    Button(role: .destructive) {
                        store.removeTimeBlock(blockID, in: planID)
                        dismiss()
                    } label: {
                        Label(NSLocalizedString("plan.timeblock.delete", comment: ""), systemImage: "trash")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .foregroundColor(.red)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("plan.timeblock.edit", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.save", comment: "")) { save() }
                }
            }
        }
        .tint(PlanTheme.primary)
    }

    private func save() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
        let updated = TimeBlock(
            id: blockID,
            dayNumber: dayNumber,
            startHour: hasTime ? comps.hour : nil,
            startMinute: hasTime ? comps.minute : nil,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        store.updateTimeBlock(updated, in: planID)
        dismiss()
    }
}

// MARK: - PlanItemCard

private struct PlanItemCard: View {
    let item: PlanItem
    let store: TravelPlanStore
    let planID: UUID
    let draggable: Bool
    /// 編集モードか。false（通常）では削除ボタン・ドラッグハンドル・長押し削除を出さず、
    /// タップで詳細を開くだけの静かなカードにする。
    let isEditing: Bool
    /// このカードへドロップされたときの処理（ドロップ元の項目 ID を渡す）。日程モードのみ。
    var onDrop: ((UUID) -> Void)? = nil
    @State private var showingDetail = false
    @State private var isDropTargeted = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(PlanTheme.color(for: item.category)))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .lineLimit(1)
                if let memo = item.customDetail?.trimmingCharacters(in: .whitespacesAndNewlines), !memo.isEmpty {
                    // メモがあれば 1 行で表示（カスタム・アプリ項目とも共通）
                    Label(memo, systemImage: "note.text")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else if !item.category.isCustom {
                    HStack(spacing: 6) {
                        Text(item.category.localizedName)
                        if let pref = item.prefecture {
                            Text("·")
                            Text(pref.prefectureName)
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            if isEditing {
                // 編集モードでは削除を明示ボタンに（長押しは contextMenu と競合してドラッグを妨げるため付けない）
                Button {
                    store.removeItem(item, from: planID)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)

                // 並べ替えハンドルは日程モード（ドラッグ可能）のときだけ。
                if draggable {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(PlanTheme.primary.opacity(0.7))
                }
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(draggable ? Color(.tertiarySystemGroupedBackground) : Color(.secondarySystemGroupedBackground))
        )
        // ドロップ先がこのカードのとき、直前に挿入されることを示す青い線を上端に表示。
        .overlay(alignment: .top) {
            if isDropTargeted {
                Capsule()
                    .fill(PlanTheme.primary)
                    .frame(height: 3)
                    .padding(.horizontal, 4)
                    .offset(y: -6)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .modifier(PlanItemInteraction(draggable: draggable, isEditing: isEditing, payload: item.id.uuidString) {
            store.removeItem(item, from: planID)
        })
        // 日程モードでは各カードがドロップ先になり、ここへ落とすと「この項目の直前」へ挿入される。
        .modifier(PlanItemDropTarget(enabled: draggable && onDrop != nil, isTargeted: $isDropTargeted) { droppedID in
            onDrop?(droppedID)
        })
        .sheet(isPresented: $showingDetail) {
            PlanItemDetailRouter(item: item).largeSheet()
        }
    }
}

/// 日程モードでカードを個別のドロップ先にする修飾子。
/// onDrop が無いフラット表示などでは何もしない。
private struct PlanItemDropTarget: ViewModifier {
    let enabled: Bool
    @Binding var isTargeted: Bool
    let onDrop: (UUID) -> Void

    func body(content: Content) -> some View {
        if enabled {
            content.dropDestination(for: String.self) { droppedIDs, _ in
                guard let idString = droppedIDs.first, let uuid = UUID(uuidString: idString) else { return false }
                onDrop(uuid)
                return true
            } isTargeted: { targeted in
                withAnimation(.easeOut(duration: 0.12)) { isTargeted = targeted }
            }
        } else {
            content
        }
    }
}

/// 長押しジェスチャの競合を避けるための修飾子。
/// - draggable=true（日程モードの編集）: .draggable のみ。削除はカード上の明示ボタンで行う。
/// - draggable=false・isEditing=true（フラット表示の編集）: .contextMenu（長押しで削除）。
/// - isEditing=false（通常モード）: 何も付けない（タップで詳細を開くだけ）。
private struct PlanItemInteraction: ViewModifier {
    let draggable: Bool
    let isEditing: Bool
    let payload: String
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        if draggable {
            content.draggable(payload)
        } else if isEditing {
            content.contextMenu {
                Button(role: .destructive, action: onDelete) {
                    Label(NSLocalizedString("common.delete", comment: ""), systemImage: "trash")
                }
            }
        } else {
            content
        }
    }
}

// MARK: - PrefecturePickerSheet
/// 県を複数選択してプランに一括追加するシート。
/// PrefectureSearchView と同じデザイン言語（ブランドヘッダー・地方別カード）で、
/// 検索で絞り込み・チェックで複数選択し、「追加」で確定する。
private struct PrefecturePickerSheet: View {
    /// 既にプランにある県（選択肢から除外する）。
    let excluded: Set<Prefecture>
    /// 確定時に選択された県（選択順）を返す。
    let onAdd: ([Prefecture]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    /// 選択された県（選択順を保つため配列で保持）。
    @State private var selection: [Prefecture] = []

    /// 検索クエリに一致し、かつ未追加の県だけを残した地方リスト。
    private var filteredRegions: [(region: JapanRegion, prefectures: [Prefecture])] {
        let query = toHiragana(searchText.trimmingCharacters(in: .whitespaces))
        return JapanRegion.allCases.compactMap { region in
            let matched = region.prefectures.filter { prefecture in
                guard !excluded.contains(prefecture) else { return false }
                return query.isEmpty || matches(prefecture, query: query)
            }
            return matched.isEmpty ? nil : (region, matched)
        }
    }

    private func matches(_ prefecture: Prefecture, query: String) -> Bool {
        prefecture.searchKeywords.contains { toHiragana($0).localizedCaseInsensitiveContains(query) }
    }

    private func toHiragana(_ text: String) -> String {
        text.applyingTransform(.hiraganaToKatakana, reverse: true) ?? text
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    searchField
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    if filteredRegions.isEmpty {
                        emptyState
                    } else {
                        list
                    }
                }
            }
            .navigationTitle(NSLocalizedString("plan.prefectures.add", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(addButtonTitle) {
                        onAdd(selection)
                        dismiss()
                    }
                    .font(.headline)
                    .disabled(selection.isEmpty)
                }
            }
        }
        .tint(PlanTheme.primary)
    }

    /// 選択数を反映した追加ボタンの文言（0件時は素の「追加」）。
    private var addButtonTitle: String {
        selection.isEmpty
            ? NSLocalizedString("common.add", comment: "")
            : String(format: NSLocalizedString("plan.prefectures.add.count", comment: ""), selection.count)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField(NSLocalizedString("prefecture.search.placeholder", comment: ""), text: $searchText)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(filteredRegions, id: \.region) { entry in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(entry.region.localizedName)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        VStack(spacing: 8) {
                            ForEach(entry.prefectures) { prefecture in
                                row(prefecture)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private func row(_ prefecture: Prefecture) -> some View {
        let isSelected = selection.contains(prefecture)
        return Button {
            if isSelected {
                selection.removeAll { $0 == prefecture }
            } else {
                selection.append(prefecture)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? PlanTheme.primary : Color(.tertiaryLabel))
                Text(prefecture.prefectureName)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                Spacer()
                if prefecture.hasOnsen {
                    Image(systemName: "thermometer.sun.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(isSelected ? PlanTheme.primary : .clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text(NSLocalizedString("prefecture.search.empty", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SpotQuickAddSheet
/// 県を選ぶ → その県のスポットをカード一覧で見て、詳細を開かずに「＋」で
/// 直接プランへ追加するシート。観光・グルメ・温泉・お土産をカテゴリ切替で扱う。
private struct SpotQuickAddSheet: View {
    let planID: UUID
    /// プランに既に登録済みの県（先頭に「候補」として出す）。
    let suggestedPrefectures: [Prefecture]
    /// 日程モードの特定 Day から開いたときの割当先。nil はフラット追加（未割当）。
    var initialDay: Int? = nil

    @ObservedObject private var store = TravelPlanStore.shared
    @Environment(\.dismiss) private var dismiss

    /// 選択中の県。未選択なら県一覧を表示する。
    @State private var prefecture: Prefecture?
    @State private var category: QuickAddCategory = .attraction
    @State private var prefSearch = ""

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                if let prefecture {
                    spotList(for: prefecture)
                } else {
                    prefecturePicker
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.close", comment: "")) { dismiss() }
                }
                // 県選択済みなら、別の県へ戻れる導線を左上に置く。
                if prefecture != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation { prefecture = nil }
                        } label: {
                            Label(NSLocalizedString("plan.spot.change_prefecture", comment: ""), systemImage: "chevron.left")
                                .font(.subheadline.bold())
                        }
                    }
                }
            }
        }
        .tint(PlanTheme.primary)
    }

    private var navigationTitle: String {
        prefecture?.prefectureName ?? NSLocalizedString("plan.spot.add", comment: "")
    }

    // MARK: - 県選択ステップ

    private var prefecturePicker: some View {
        VStack(spacing: 0) {
            searchField
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    // 登録済みの県を最優先の候補として上に出す（検索が空のときだけ）。
                    if prefSearch.isEmpty, !suggestedPrefectures.isEmpty {
                        section(title: NSLocalizedString("plan.spot.suggested", comment: ""),
                                prefectures: suggestedPrefectures)
                    }
                    ForEach(filteredRegions, id: \.region) { entry in
                        section(title: entry.region.localizedName, prefectures: entry.prefectures)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    private func section(title: String, prefectures: [Prefecture]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            VStack(spacing: 8) {
                ForEach(prefectures) { pref in
                    Button {
                        withAnimation { prefecture = pref }
                    } label: {
                        HStack(spacing: 12) {
                            Text(pref.prefectureName)
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                            Spacer()
                            if pref.hasOnsen {
                                Image(systemName: "thermometer.sun.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)
                            }
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var filteredRegions: [(region: JapanRegion, prefectures: [Prefecture])] {
        let query = toHiragana(prefSearch.trimmingCharacters(in: .whitespaces))
        return JapanRegion.allCases.compactMap { region in
            let matched = region.prefectures.filter { query.isEmpty || matches($0, query: query) }
            return matched.isEmpty ? nil : (region, matched)
        }
    }

    private func matches(_ prefecture: Prefecture, query: String) -> Bool {
        prefecture.searchKeywords.contains { toHiragana($0).localizedCaseInsensitiveContains(query) }
    }

    private func toHiragana(_ text: String) -> String {
        text.applyingTransform(.hiraganaToKatakana, reverse: true) ?? text
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField(NSLocalizedString("prefecture.search.placeholder", comment: ""), text: $prefSearch)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !prefSearch.isEmpty {
                Button { prefSearch = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    // MARK: - スポット一覧ステップ

    private func spotList(for prefecture: Prefecture) -> some View {
        VStack(spacing: 0) {
            categoryBar
            let spots = category.spots(in: prefecture)
            if spots.isEmpty {
                emptySpots
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(spots) { spot in
                            spotCard(spot, prefecture: prefecture)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(QuickAddCategory.allCases, id: \.self) { c in
                    let selected = category == c
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) { category = c }
                    } label: {
                        Label(c.localizedName, systemImage: c.icon)
                            .font(.caption.bold())
                            .foregroundColor(selected ? .white : PlanTheme.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule().fill(selected ? AnyShapeStyle(PlanTheme.brandGradient)
                                                         : AnyShapeStyle(PlanTheme.primary.opacity(0.12)))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    /// 1 スポットのカード。右側の「＋」で直接プランに追加。追加済みはチェックで表示。
    private func spotCard(_ spot: QuickAddSpot, prefecture: Prefecture) -> some View {
        let added = isAdded(spot, prefecture: prefecture)
        return HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(PlanTheme.color(for: category.planCategory)))

            VStack(alignment: .leading, spacing: 3) {
                Text(spot.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .lineLimit(1)
                if let subtitle = spot.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 8)

            Button {
                store.addItem(
                    PlanItem(category: category.planCategory, prefecture: prefecture, name: spot.name, dayNumber: initialDay),
                    to: planID
                )
            } label: {
                Image(systemName: added ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(added ? .green : PlanTheme.primary)
            }
            .buttonStyle(.plain)
            .disabled(added)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .opacity(added ? 0.7 : 1)
    }

    /// このスポットが既にプランに入っているか（addItem と同じ名前＋種別で判定）。
    private func isAdded(_ spot: QuickAddSpot, prefecture: Prefecture) -> Bool {
        guard let plan = store.plans.first(where: { $0.id == planID }) else { return false }
        return plan.items.contains { $0.name == spot.name && $0.category == category.planCategory }
    }

    private var emptySpots: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: category.icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.4))
            Text(NSLocalizedString("plan.spot.empty_category", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - QuickAddSpot / QuickAddCategory
/// クイック追加で扱う 1 スポットの共通表現（各カテゴリのデータをこれに畳む）。
private struct QuickAddSpot: Identifiable {
    let id: String        // "index|name"。同名スポットが並んでも ForEach が衝突しないよう index を混ぜる。
    let name: String
    let subtitle: String?
}

/// クイック追加で選べるカテゴリ。県ごとにスポット配列を返す。
private enum QuickAddCategory: CaseIterable {
    case attraction, gourmet, onsen, souvenir

    var planCategory: PlanItemCategory {
        switch self {
        case .attraction: return .attraction
        case .gourmet:    return .gourmet
        case .onsen:      return .onsen
        case .souvenir:   return .souvenir
        }
    }

    var localizedName: String { planCategory.localizedName }
    var icon: String { planCategory.icon }

    /// 指定県のこのカテゴリのスポット一覧。
    func spots(in prefecture: Prefecture) -> [QuickAddSpot] {
        let pairs: [(name: String, subtitle: String?)]
        switch self {
        case .attraction:
            pairs = prefecture.tourismInfo.attractions.map { ($0.name, $0.description) }
        case .gourmet:
            pairs = prefecture.gourmetItems.map { ($0.name, $0.description) }
        case .onsen:
            pairs = prefecture.onsenItems.map { ($0.name, $0.description) }
        case .souvenir:
            pairs = prefecture.souvenirItems.map { ($0.name, $0.description) }
        }
        return pairs.enumerated().map { index, pair in
            QuickAddSpot(id: "\(index)|\(pair.name)", name: pair.name, subtitle: pair.subtitle)
        }
    }
}

// MARK: - 県タイルの長押しメニュー

/// 県タイルに付ける長押しメニュー。
///
/// 【解決した不具合】
/// 「＋の左隣の県だけ長押しで削除が出ない」ように見える症状があった。
/// 実際は位置ではなく**県の出どころ**が原因。`TravelPlan.prefectures` は
/// `plannedPrefectures`（手動追加）＋ `itemPrefectures`（旅程スポット由来）の順で並ぶため、
/// スポット由来の県は必ず末尾＝「＋」の隣に来る。そしてそれらは
/// `removePrefecture` の対象外なので、メニューの中身が空になっていた。
///
/// 中身が空の `contextMenu` は「長押しでプレビューだけ拡大して何も出ない」という
/// 壊れて見える挙動になる。そこで、
/// - 削除できる県 … 削除ボタンを出す
/// - スポット由来の県 … なぜ消せないかを説明する無効化項目を出す
/// - 編集モードでない … メニュー自体を付けない（タップで県詳細を開くだけ）
/// とし、長押しに対して必ず何らかの反応が返るようにした。
private struct PrefectureChipMenu: ViewModifier {
    let isEnabled: Bool
    let isRemovable: Bool
    let onDelete: () -> Void

    func body(content: Content) -> some View {
        if isEnabled {
            content.contextMenu {
                if isRemovable {
                    Button(role: .destructive, action: onDelete) {
                        Label(NSLocalizedString("common.delete", comment: ""), systemImage: "trash")
                    }
                } else {
                    // スポット由来の県。スポットを消せば自動的に消えることを伝える。
                    // 押せてしまうと「押したのに消えない」になるので無効化しておく。
                    Button {} label: {
                        Label(
                            NSLocalizedString("plan.prefectures.derived", comment: ""),
                            systemImage: "info.circle"
                        )
                    }
                    .disabled(true)
                }
            }
        } else {
            content
        }
    }
}

// PlanMapView は PlanMapView.swift に移動（日程色分け・ルート線・日フィルタ対応）
