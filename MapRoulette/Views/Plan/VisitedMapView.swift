//
//  VisitedMapView.swift
//  MapRoulette
//
//  訪問済みマップ。マイプランタブ内の「訪問済み」上タブで表示する。
//  「旅行済み」にしたプランに含まれる都道府県を日本地図上で塗り分け、
//  47 都道府県の踏破率を可視化する。地図の描画は JapanMapView と同じ
//  PrefectureShape + Prefecture.points を流用し、ルーレット等のロジックは持ち込まない。
//  構成: 地図（中央寄せ）＋踏破率リングのオーバーレイ、その下に地方別の進捗。
//

import SwiftUI

struct VisitedMapView: View {
    @ObservedObject private var visitedStore = VisitedPrefectureStore.shared
    /// 地方別集計の開閉。常時は畳んでおき、見たい人だけ開く。
    @State private var showRegionBreakdown = false
    /// 県タップで開く詳細シートの対象（訪問済みトグル＋紐づくプラン一覧を出す）。
    @State private var selectedPrefecture: Prefecture?

    /// 訪問済み都道府県（保存ストアが唯一の情報源）。
    private var visited: Set<Prefecture> {
        visitedStore.visited
    }

    /// 踏破率（0.0〜1.0）。全 47 県に対する訪問済みの割合。
    private var completionRatio: Double {
        Double(visited.count) / Double(Prefecture.allCases.count)
    }

    var body: some View {
        // 地図＋リングを縦中央に置き、右下に地方別集計を開くアイコンボタン（FAB）を重ねる。
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 12)

                    // 地図は縦横比 1:1 の中で中央寄せに置く。
                    mapArea
                        .padding(.horizontal, 16)

                    if visited.isEmpty {
                        emptyHint
                    }

                    Spacer(minLength: 12)
                }
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
        // 踏破率リングは画面の左上に固定する（右下の地方別ボタンと対になる配置）。
        .overlay(alignment: .topLeading) {
            CompletionRing(
                ratio: completionRatio,
                visitedCount: visited.count,
                total: Prefecture.allCases.count
            )
            .frame(width: 100, height: 100)
            .padding(.top, 12)
            .padding(.leading, 16)
        }
        // 右下の地方別集計ボタン。押すとシートで一覧を出す。
        .overlay(alignment: .bottomTrailing) {
            Button {
                showRegionBreakdown = true
            } label: {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(PlanTheme.brandGradient))
                    .shadow(color: PlanTheme.primary.opacity(0.4), radius: 10, x: 0, y: 4)
            }
            .accessibilityLabel(NSLocalizedString("visited.region.header", comment: ""))
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showRegionBreakdown) {
            regionBreakdownSheet
        }
        // 県タップで開く詳細シート（訪問済みトグル＋紐づくプラン一覧）。
        .sheet(item: $selectedPrefecture) { prefecture in
            PrefectureDetailSheet(prefecture: prefecture)
        }
    }

    // MARK: - 地図＋踏破率リング

    /// 幅に追従する正方形の土台に日本地図を描く（踏破率リングは画面左上に別途固定）。
    private var mapArea: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .center) { japanMap }
    }

    private var japanMap: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Prefecture.allCases, id: \.self) { prefecture in
                    let isVisited = visited.contains(prefecture)
                    PrefectureShape(points: normalizePoints(prefecture.points, to: geometry.size))
                        .fill(isVisited
                              ? AnyShapeStyle(PlanTheme.brandGradient)
                              : AnyShapeStyle(Color(.systemGray5)))
                        .overlay(
                            PrefectureShape(points: normalizePoints(prefecture.points, to: geometry.size))
                                .stroke(.white.opacity(0.7), lineWidth: 0.6)
                        )
                        // 県タップで詳細シートを開く（訪問済みの切替と紐づくプラン一覧）。
                        .contentShape(PrefectureShape(points: normalizePoints(prefecture.points, to: geometry.size)))
                        .onTapGesture {
                            selectedPrefecture = prefecture
                        }
                }
            }
        }
    }

    // MARK: - 地方別の踏破集計（折りたたみ）

    private var regionBreakdownSheet: some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                        spacing: 10
                    ) {
                        ForEach(JapanRegion.allCases, id: \.self) { region in
                            RegionChip(region: region, visited: visited)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString("visited.region.header", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.done", comment: "")) {
                        showRegionBreakdown = false
                    }
                    .foregroundColor(PlanTheme.primary)
                }
            }
        }
        .tint(PlanTheme.primary)
        .presentationDetents([.medium, .large])
    }

    // MARK: - 案内（訪問済み 0 件のとき）

    private var emptyHint: some View {
        VStack(spacing: 6) {
            Text(NSLocalizedString("visited.empty.title", comment: ""))
                .font(.subheadline.bold())
            Text(NSLocalizedString("visited.empty.message", comment: ""))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    // MARK: - 座標正規化（JapanMapView と同じ 500×500 基準）

    private func normalizePoints(_ points: [CGPoint], to size: CGSize) -> [CGPoint] {
        let mapWidth: CGFloat = 500
        let mapHeight: CGFloat = 500
        return points.map { point in
            CGPoint(
                x: (point.x / mapWidth) * size.width,
                y: (point.y / mapHeight) * size.height
            )
        }
    }
}

// MARK: - CompletionRing
/// 踏破率を表すドーナツ型リング。中央に「訪問数 / 全県」と踏破率%を出す。

private struct CompletionRing: View {
    let ratio: Double          // 0.0〜1.0
    let visitedCount: Int
    let total: Int

    var body: some View {
        ZStack {
            // 背景の白円（地図に重ねても読めるように）
            Circle()
                .fill(.white)
                .shadow(color: PlanTheme.cardShadow, radius: 6, x: 0, y: 3)

            // トラック
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 9)
                .padding(10)

            // 進捗弧（12時方向から時計回り）
            Circle()
                .trim(from: 0, to: max(0.0001, ratio))
                .stroke(
                    PlanTheme.brandGradient,
                    style: StrokeStyle(lineWidth: 9, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .padding(10)

            // 中央のテキスト
            VStack(spacing: 0) {
                Text("\(Int((ratio * 100).rounded()))%")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(PlanTheme.primary)
                Text("\(visitedCount)/\(total)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - RegionChip
/// 1 地方分のコンパクトなピル。地方名と「M/N」を淡い背景で並べる。
/// 全県達成した地方はブランド色で塗って一目で分かるようにする。

private struct RegionChip: View {
    let region: JapanRegion
    let visited: Set<Prefecture>

    private var prefectures: [Prefecture] { region.prefectures }
    private var total: Int { prefectures.count }
    private var count: Int { prefectures.filter { visited.contains($0) }.count }
    private var isComplete: Bool { count == total && total > 0 }
    private var hasAny: Bool { count > 0 }

    var body: some View {
        HStack(spacing: 6) {
            Text(region.localizedName)
                .font(.caption.bold())
                .foregroundColor(isComplete ? .white : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 4)
            if isComplete {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(String(format: NSLocalizedString("visited.region.count.format", comment: ""), count, total))
                .font(.caption2.bold().monospacedDigit())
                .foregroundColor(isComplete ? .white.opacity(0.95) : (hasAny ? PlanTheme.primary : .secondary))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isComplete ? AnyShapeStyle(PlanTheme.brandGradient) : AnyShapeStyle(Color(.tertiarySystemGroupedBackground)))
        )
    }
}

// MARK: - PrefectureDetailSheet
/// 県タップで開く詳細シート。訪問済みの切替トグルと、その県を含むプラン一覧を出す。

private struct PrefectureDetailSheet: View {
    let prefecture: Prefecture
    @ObservedObject private var visitedStore = VisitedPrefectureStore.shared
    @ObservedObject private var planStore = TravelPlanStore.shared
    @Environment(\.dismiss) private var dismiss
    /// タップされたプラン。全画面（fullScreenCover）で詳細を出す。
    @State private var selectedPlan: TravelPlan?

    /// この県を含むプラン。
    private var relatedPlans: [TravelPlan] {
        planStore.plansContaining(prefecture: prefecture)
    }

    private var isVisitedBinding: Binding<Bool> {
        Binding(
            get: { visitedStore.isVisited(prefecture) },
            set: { newValue in
                // トグルは後勝ちで上書き（オン/オフをそのまま反映）。
                if newValue { visitedStore.markVisited(prefecture) }
                else if visitedStore.isVisited(prefecture) { visitedStore.toggle(prefecture) }
            }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PlanTheme.pageBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        // 訪問済みトグル
                        Toggle(isOn: isVisitedBinding) {
                            Label(NSLocalizedString("visited.state.toggle", comment: ""),
                                  systemImage: "checkmark.seal.fill")
                                .font(.subheadline.bold())
                        }
                        .tint(PlanTheme.primary)
                        .planCard()

                        // この県を含むプラン一覧
                        VStack(alignment: .leading, spacing: 10) {
                            Text(NSLocalizedString("visited.related.plans", comment: ""))
                                .font(.caption.bold())
                                .foregroundColor(PlanTheme.primary)

                            if relatedPlans.isEmpty {
                                Text(NSLocalizedString("visited.related.none", comment: ""))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                ForEach(relatedPlans) { plan in
                                    Button {
                                        selectedPlan = plan
                                    } label: {
                                        relatedPlanRow(plan)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .planCard()
                    }
                    .padding()
                }
            }
            .navigationTitle(prefecture.prefectureName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.done", comment: "")) { dismiss() }
                        .foregroundColor(PlanTheme.primary)
                }
            }
        }
        .tint(PlanTheme.primary)
        .presentationDetents([.medium, .large])
        // プランは全画面（fullScreenCover）で表示する。
        .fullScreenCover(item: $selectedPlan) { plan in
            NavigationStack {
                PlanDetailView(planID: plan.id)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(NSLocalizedString("common.close", comment: "")) {
                                selectedPlan = nil
                            }
                            .foregroundColor(PlanTheme.primary)
                        }
                    }
            }
            .tint(PlanTheme.primary)
        }
    }

    private func relatedPlanRow(_ plan: TravelPlan) -> some View {
        HStack(spacing: 12) {
            Image(systemName: plan.isCompleted ? "checkmark.seal.fill" : "suitcase.rolling.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(PlanTheme.brandGradient))
            VStack(alignment: .leading, spacing: 2) {
                Text(plan.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text(String(format: NSLocalizedString("plan.itemcount.format", comment: ""), plan.items.count))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
    }
}
