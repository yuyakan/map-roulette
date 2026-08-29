//
//  JapanMapView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/20.
//

import SwiftUI

struct JapanMapView: View {
    /// 統合タブ内で表示されているか。true のとき、上部に重なる切替帯のぶんだけ
    /// コンテンツを下げる余白を確保する（帯自体は IntegratedMapView が描画する）。
    /// false（単独利用時）は余白ゼロで既存挙動を一切変えない。
    var isIntegrated: Bool = false

    @State private var selectedPrefecture: Prefecture? = nil
    @State private var isSpinning = false
    @State private var spinTimer: Timer?
    @State private var currentSpinInterval: TimeInterval = 0.1
    @State private var spinCount = 0
    @State private var isStopping = false
    @State private var showResultModal = false
    @State private var showSettings = false
    @State private var enabledPrefectures: Set<Prefecture> = RouletteSettingsStore.loadEnabledPrefectures()
    @StateObject private var weightManager = WeightManager()
    @State private var showTourismInfo = false
    @State private var tappedPrefecture: Prefecture? = nil
    @State private var displayMode: DisplayMode = RouletteSettingsStore.loadDisplayMode() // 表示モード追加
    
    let interstitial = InterstitialViewModel()
    
    // 表示モードに応じた利用可能な都道府県
    private var availablePrefectures: [Prefecture] {
        switch displayMode {
        case .tourism:
            return Prefecture.allCases
        case .onsen:
            return Prefecture.prefecturesWithOnsen
        }
    }
    
    // 実際にルーレットで使用される都道府県（有効＋利用可能）
    private var activeEnabledPrefectures: Set<Prefecture> {
        return enabledPrefectures.intersection(Set(availablePrefectures))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !isSpinning {
                    VStack {
                        // 統合タブ表示中は、最前面に重なる切替帯のぶんだけ設定ボタン行を下げる
                        if isIntegrated {
                            Spacer().frame(height: mapModeBandHeight)
                        }
                        HStack {
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                            }
                            .disabled(isSpinning)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                //                            HStack(spacing: 4) {
                                //                                Image(systemName: displayMode.icon)
                                //                                    .font(.caption2)
                                //                                    .foregroundColor(displayMode == .onsen ? .orange : .blue)
                                //                                Text("\(displayMode.rawValue)")
                                //                                    .font(.caption2)
                                //                                    .foregroundColor(.secondary)
                                //                            }
                                
                                Text(String(format: NSLocalizedString("target_prefecture_count", comment: ""),
                                            activeEnabledPrefectures.count))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // 重み付けがデフォルトでない場合に表示
                                if hasCustomWeights {
                                    Text("重み付け: 有効")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(3)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
                
                VStack {
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(Prefecture.allCases, id: \.self) { prefecture in
                                Group {
                                    if selectedPrefecture == prefecture {
                                        PrefectureShape(points: normalizePoints(prefecture.points, to: geometry.size))
                                            .fill(Color("selectedColor2").opacity(0.9))
                                            .background(
                                                PrefectureShape(points: normalizePoints(prefecture.points, to: geometry.size))
                                                    .fill(.black.opacity(0.8))
                                                    .offset(x: 4, y: 4)
                                                    .blur(radius: 2)
                                            )
                                            .zIndex(1)
                                            .onTapGesture {
                                                if !isSpinning && !isStopping {
                                                    tappedPrefecture = prefecture
                                                    showTourismInfo = true
                                                }
                                            }
                                    } else {
                                        PrefectureShape(points: normalizePoints(prefecture.points, to: geometry.size))
                                            .fill(getStylishFillColor(for: prefecture))
                                            .stroke(.white.opacity(0.6), lineWidth: 0.6)
                                            .opacity(getOpacity(for: prefecture))
                                            .zIndex(0)
                                            .onTapGesture {
                                                if !isSpinning && !isStopping {
                                                    tappedPrefecture = prefecture
                                                    showTourismInfo = true
                                                }
                                            }
                                    }
                                    
                                    if prefecture == .okinawa {
                                        Path { path in
                                            let linePoints = normalizePoints(prefecture.okinawaLinePoints, to: geometry.size)
                                            if linePoints.count >= 2 {
                                                path.move(to: linePoints[0])
                                                for point in linePoints.dropFirst() {
                                                    path.addLine(to: point)
                                                }
                                            }
                                        }
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.blue.opacity(0.4)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                                        )
                                        .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 1)
                                        .opacity(getOpacity(for: prefecture))
                                    }
                                }
                            }
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.top, 100)
                    
                    if isStopping {
                        if let selected = selectedPrefecture, isSpinning {
                            VStack {
                                Text(selected.prefectureName)
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.orange, Color.red]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                    .shadow(color: .orange.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .frame(height: 55)
                        } else {
                            Text(" ")
                            .frame(height: 55)
                        }
                    }  else {
                        Text(" ")
                        .frame(height: 55)
                    }
                }
                
                if !isStopping && !showResultModal {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                if isSpinning {
                                    stopSpin()
                                } else {
                                    if activeEnabledPrefectures.count < 2 {
                                        return
                                    }
                                    startSpin()
                                }
                            }, label: {
                                HStack(spacing: 10) {
                                    Image(systemName: getButtonIcon())
                                        .font(.title3)
                                        .foregroundColor(.black)
                                }
                                .frame(width: 55, height: 55)
                                .background(getButtonGradient())
                                .cornerRadius(27.5)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                                .opacity(activeEnabledPrefectures.count < 2 ? 0.5 : 1.0)
                            })
                            .disabled(activeEnabledPrefectures.count < 2)
                            .padding(.trailing, 30)
                        }
                        .padding(.bottom, 40)
                    }
                
                }
                
                // 結果モーダル
                if showResultModal {
                    VStack(spacing: 30) {
                        Spacer()
                        if let selected = selectedPrefecture {
                            VStack(spacing: 20) {
                                Text(selected.prefectureName)
                                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.orange, Color.red.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .multilineTextAlignment(.center)
                                    .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 0)
                                    .padding(.top, 40)
                                    .padding(.bottom, 10)
                                
                                // 温泉地モードの場合の特別表示
                                if displayMode == .onsen && selected.hasOnsen {
                                    VStack(spacing: 8) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "thermometer.sun.fill")
                                                .foregroundColor(.orange)
                                            Text("\(selected.onsenItems.count)つの温泉地")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.orange)
                                        }
                                        
                                        // 代表的な温泉地を1-2つ表示
                                        let topOnsens = selected.onsenItems.prefix(2)
                                        ForEach(Array(topOnsens), id: \.id) { onsen in
                                            Text("• \(onsen.name)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal)
                                } else {
                                    normalResult(selected: selected)
                                }
                                
                                // 観光情報ボタン
                                Button(action: {
                                    tappedPrefecture = selected
                                    showTourismInfo = true
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: displayMode == .onsen ? "thermometer.sun.fill" : "map.fill")
                                            .font(.system(size: 17))
                                        Text("tourism.info".localized)
                                            .font(.system(size: 17))
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 154, height: 44)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.red.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(25)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                }
                                .padding(.top, 10)
                            }
                        }
                        Spacer()
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    resetGame()
                                    interstitial.registerRouletteSpin()
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.title3)
                                            .padding(.bottom, 2)
                                       
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(27.5)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 140)
                    .background(Color.white.opacity(0.7))
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    enabledPrefectures: $enabledPrefectures,
                    weightManager: weightManager,
                    displayMode: $displayMode
                )
                .largeSheet()
            }
            // 詳細はウインドウ全体を覆う fullScreenCover で表示（下タブ・帯の上に出るので真の全画面）
            .fullScreenCover(isPresented: $showTourismInfo) {
                    if let prefecture = tappedPrefecture ?? selectedPrefecture {
                        TourismDetailView(prefecture: prefecture)
                    }
                }
            .onChange(of: showTourismInfo) { isShowing in
                if !isShowing {
                    tappedPrefecture = nil
                }
            }
            .onChange(of: displayMode) { newMode in
                // 表示モード変更時に選択済み都道府県を調整
                updateEnabledPrefecturesForMode()
                // 表示モードを永続化
                RouletteSettingsStore.saveDisplayMode(newMode)
            }
            .onChange(of: enabledPrefectures) { newValue in
                // 有効な都道府県を永続化
                RouletteSettingsStore.saveEnabledPrefectures(newValue)
            }
            .onAppear {
                interstitial.handleMapAppear()
            }

            
        }
    }
    
    private func normalResult(selected: Prefecture) -> some View {
        // 通常の観光情報表示
        VStack(spacing: 12) {
            
            // 代表的な観光スポットを表示
    
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text("tourism.spot".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    let topSpots = selected.tourismInfo.attractions.prefix(2)
                    ForEach(topSpots.indices, id: \.self) { index in
                        let spot = selected.tourismInfo.attractions[index]
                        HStack(spacing: 8) {
                            Text("• \(spot.name)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            
        }
        .padding(.horizontal)
    }

    // 重み付けがカスタマイズされているかチェック
    private var hasCustomWeights: Bool {
        return weightManager.weights.values.contains { $0 != 1.0 }
    }
    
    // 都道府県の透明度を取得
    private func getOpacity(for prefecture: Prefecture) -> Double {
        switch displayMode {
        case .tourism:
            return enabledPrefectures.contains(prefecture) ? 1.0 : 0.3
        case .onsen:
            if !prefecture.hasOnsen {
                return 0.1 // 温泉地がない都道府県は非常に薄く
            }
            return enabledPrefectures.contains(prefecture) ? 1.0 : 0.3
        }
    }
    
    // 表示モード変更時の都道府県選択状態を更新
    private func updateEnabledPrefecturesForMode() {
        let newAvailablePrefectures = Set(availablePrefectures)
        enabledPrefectures = enabledPrefectures.intersection(newAvailablePrefectures)
        
        // 有効な都道府県がない場合は自動的に全選択
        if enabledPrefectures.isEmpty {
            enabledPrefectures = newAvailablePrefectures
        }
    }

    // ゲームをリセット
    private func resetGame() {
        showResultModal = false
        selectedPrefecture = nil
        isStopping = false
    }
    
    // ボタンのテキストを取得
    private func getButtonText() -> some View {
        if isStopping {
            return Text("")
                .font(.title3)
                .fontWeight(.semibold)
        } else if isSpinning {
            return Text("Stop")
                .font(.title3)
                .foregroundColor(.black)
                .fontWeight(.semibold)
        } else {
            return Text("Start")
                .font(.title3)
                .foregroundColor(.black)
                .fontWeight(.semibold)
        }
    }
    
    // ボタンのアイコンを取得
    private func getButtonIcon() -> String {
        if isStopping {
            return "stop.circle"
        } else if isSpinning {
            return "stop.fill"
        } else {
            return "play.fill"
        }
    }
      
    // ボタンのグラデーションを取得
    private func getButtonGradient() -> LinearGradient {
        if isStopping {
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else if isSpinning {
            return LinearGradient(
                gradient: Gradient(colors: [.white]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [.white]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // スピン開始
    private func startSpin() {
        guard !isSpinning && !activeEnabledPrefectures.isEmpty else { return }
        
        isSpinning = true
        isStopping = false
        currentSpinInterval = 0.05
        spinCount = 0
        
        startSpinTimer()
    }
    
    // スピン停止
    private func stopSpin() {
        guard isSpinning && !isStopping else { return }
        
        isStopping = true
        startStoppingSequence()
    }
    
    // スピンタイマーを開始
    private func startSpinTimer() {
        spinTimer?.invalidate()
        
        spinTimer = Timer.scheduledTimer(withTimeInterval: currentSpinInterval, repeats: false) { _ in
            selectedPrefecture = weightManager.selectRandomPrefecture(from: activeEnabledPrefectures)
            spinCount += 1
            
            if !isStopping {
                startSpinTimer()
            }
        }
    }
    
    // 停止シーケンスを開始
    private func startStoppingSequence() {
        spinTimer?.invalidate()
        
        var stopSpinCount = 0
        var stopInterval: TimeInterval = currentSpinInterval
        
        func stopSpinTimer() {
            Timer.scheduledTimer(withTimeInterval: stopInterval, repeats: false) { _ in
                selectedPrefecture = weightManager.selectRandomPrefecture(from: activeEnabledPrefectures)
                
                stopSpinCount += 1
                
                // だんだんゆっくりにする（22回転で停止）
                if stopSpinCount < 22 {
                    // スピンの間隔を徐々に長くする
                    if stopSpinCount > 20 {
                        stopInterval += 0.5
                    } else if stopSpinCount > 17 {
                        stopInterval += 0.2
                    } else if stopSpinCount > 15 {
                        stopInterval += 0.1
                    } else if stopSpinCount > 12 {
                        stopInterval += 0.075
                    } else if stopSpinCount > 8 {
                        stopInterval += 0.05
                    } else if stopSpinCount > 5 {
                        stopInterval += 0.02
                    }
                    stopSpinTimer()
                } else {
                    // 最終的に停止
                    isSpinning = false
                    
                    // 最終選択をアニメーション付きで実行
                    selectedPrefecture = weightManager.selectRandomPrefecture(from: activeEnabledPrefectures)
                    
                    // 0.5秒後にモーダル表示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showResultModal = true
                        }
                    }
                }
            }
        }
        
        stopSpinTimer()
    }
    
    // 座標を画面サイズに正規化
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
    
    // おしゃれな塗りつぶし色を取得
    private func getStylishFillColor(for prefecture: Prefecture) -> LinearGradient {
        if displayMode == .onsen {
            if prefecture.hasOnsen {
                // 温泉地モードで温泉がある都道府県は温泉色
                return LinearGradient(
                    gradient: Gradient(colors: [
                        Color.orange.opacity(0.4),
                        Color.red.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                return LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        } else {
            // 通常の観光モード色
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.4),
                    Color.teal.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

