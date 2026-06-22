//
//  OnsenMapView.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/08/02.
//

import SwiftUI
import Combine
import MapKit

struct OnsenMapView: View {
    @State private var selectedOnsen: FixedOnsenItem? = nil
    @State private var isSpinning = false
    @State private var spinTimer: Timer?
    @State private var currentSpinInterval: TimeInterval = 0.1
    @State private var spinCount = 0
    @State private var isStopping = false
    @State private var showResultModal = false
    @State private var showSettings = false
    @State private var enabledOnsens: Set<FixedOnsenItem> = Set(OnsenDataRepository.shared.allFixedOnsens)
    @StateObject private var onsenWeightManager = OnsenWeightManager()
    @State private var showOnsenInfo = false
    @State private var tappedOnsen: FixedOnsenItem? = nil
    @State private var isListView = false // 地図表示とリスト表示の切り替え
    
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width

    class OrientationObserver: ObservableObject {
        @Published var orientation = UIDevice.current.orientation
        
        init() {
            NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                self.orientation = UIDevice.current.orientation
            }
        }
    }
    // Viewで使用
    @StateObject private var orientationObserver = OrientationObserver()

    private var columnCount: Int {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return screenWidth > 1200 ? 8 : (screenWidth > 1000 ? 7 : 5)
        } else {
            return 3
        }
    }

    let interstitial = InterstitialViewModel()
    
    // 有効な温泉地の取得
    private var availableOnsens: [FixedOnsenItem] {
        return Array(enabledOnsens)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 設定ボタンなどのヘッダー要素（最上位zIndex）
                if !isSpinning {
                    VStack {
                        HStack {
                            Button(action: {
                                showSettings = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "gearshape.fill")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                    Text("roulette_settings".localized)
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.white)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                            }
                            .disabled(isSpinning)
                            
                            Spacer()
                            
                            // 地図・リスト切り替えボタン
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isListView.toggle()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isListView ? "map.fill" : "list.bullet")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.white)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                            }
                            .disabled(isSpinning)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                    .zIndex(99) // 最高zIndex
                }
                
                VStack {
                    if isListView {
                        // リスト表示
                        onsenListView
                    } else {
                        // 地図表示
                        mapView
                        if !isListView && isStopping {
                            if let selected = selectedOnsen, isSpinning {
                                    HStack(spacing: 0) {
                                        Text(selected.name)
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
                        } else {
                            Text(" ")
                                .frame(height: 55)
                        }
                    }
                }
                
                if isListView {
                    if isStopping {
                        if let selected = selectedOnsen, isSpinning {
                            VStack() {
                                Spacer()
                                HStack(spacing: 0) {
                                    Text(selected.name)
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
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Spacer()
                            }
                        }
                    } else if !showResultModal {
                        VStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Spacer()
                                Button(action: {
                                    if isSpinning {
                                        stopSpin()
                                    } else {
                                        if availableOnsens.count < 2 {
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
                                    .opacity(availableOnsens.count < 2 ? 0.5 : 1.0)
                                })
                                .disabled(availableOnsens.count < 2)
                                .padding(.trailing, 30)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                } else {
                    if !isStopping && !showResultModal {
                        VStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Spacer()
                                Button(action: {
                                    if isSpinning {
                                        stopSpin()
                                    } else {
                                        if availableOnsens.count < 2 {
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
                                    .opacity(availableOnsens.count < 2 ? 0.5 : 1.0)
                                })
                                .disabled(availableOnsens.count < 2)
                                .padding(.trailing, 30)
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
    
                // 結果モーダル
                if showResultModal {
                    VStack(spacing: 30) {
                        Spacer()
                        if let selected = selectedOnsen {
                            VStack(spacing: 20) {
                                // 温泉地名
                                Text(selected.name)
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
                                
                                // 温泉の詳細情報
                                VStack(spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: selected.onsenType.icon)
                                            .foregroundColor(selected.onsenType.color)
                                        Text(selected.onsenType.localizedName)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(selected.onsenType.color)
                                    }
                                    
                                    Text(selected.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    // 人気度表示
                                    HStack(spacing: 2) {
                                        ForEach(0..<5) { index in
                                            Image(systemName: index < selected.popularity ? "star.fill" : "star")
                                                .foregroundColor(.orange)
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                                
                                // 詳細情報ボタン
                                Button(action: {
                                    tappedOnsen = selected
                                    showOnsenInfo = true
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "thermometer.sun.fill")
                                            .font(.system(size: 17))
                                        Text("detail_info".localized)
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
                        resetButton
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 140)
                    .background(Color.white.opacity(0.7))
                    .zIndex(100)
                }
            }
            .sheet(isPresented: $showSettings) {
                OnsenSettingsView(
                    enabledOnsens: $enabledOnsens,
                    onsenWeightManager: onsenWeightManager
                )
            }
            .navigationDestination(isPresented: $showOnsenInfo) {
                if let onsen = tappedOnsen {
                    OnsenDetailView(onsen: onsen)
                }
            }
            .onChange(of: showOnsenInfo) { isShowing in
                if !isShowing {
                    tappedOnsen = nil
                }
            }
            .onAppear {
                if InterstitialViewModel.count >= 10 {
                    interstitial.showAd()
                    InterstitialViewModel.isShowAd = true
                    InterstitialViewModel.count = 0
                }

                Task {
                    await interstitial.loadAd()
                }
            }
        }
    }
    
    // 地図表示
    private var mapView: some View {
        GeometryReader { geometry in
            ZStack {
                // 都道府県の背景を薄く表示
                ForEach(Prefecture.allCases, id: \.self) { prefecture in
                    PrefectureShape(points: normalizePoints(prefecture.points, to: geometry.size))
                        .fill(getBackgroundColor(for: prefecture))
                        .stroke(.white.opacity(0.3), lineWidth: 0.5)
                        .zIndex(0)
                    
                    // 沖縄の線
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
                                gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.orange.opacity(0.3)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 1.0, dash: [4, 3])
                        )
                        .opacity(0.4)
                    }
                }
                
                // 温泉地のアイコンを表示
                ForEach(availableOnsens, id: \.id) { onsen in
                    let position = getOnsenPosition(for: onsen, in: geometry.size)
                    
                    Button(action: {
                        if !isSpinning && !isStopping {
                            tappedOnsen = onsen
                            showOnsenInfo = true
                        }
                    }) {
                        ZStack {
                            // 選択された温泉地の背景効果
                            if selectedOnsen?.id == onsen.id {
                                Circle()
                                    .fill(Color.orange.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .blur(radius: 8)
                                    .animation(.easeInOut(duration: 0.3), value: selectedOnsen?.id)
                            }
                            
                            // アイコンの背景円
                            Circle()
                                .fill(
                                    selectedOnsen?.id == onsen.id
                                    ? LinearGradient(
                                        gradient: Gradient(colors: [Color.orange, Color.red]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        gradient: Gradient(colors: [onsen.onsenType.color.opacity(0.8), onsen.onsenType.color]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: selectedOnsen?.id == onsen.id ? 32 : 20, height: selectedOnsen?.id == onsen.id ? 32 : 20)
                                .shadow(
                                    color: selectedOnsen?.id == onsen.id ? .orange.opacity(0.5) : .black.opacity(0.2),
                                    radius: selectedOnsen?.id == onsen.id ? 4 : 2,
                                    x: 0,
                                    y: selectedOnsen?.id == onsen.id ? 2 : 1
                                )
                                .opacity(selectedOnsen?.id == onsen.id ? 1 : 0.8)

                            
                            // 温泉アイコン
                            Image(systemName: "thermometer.sun.fill")
                                .font(.system(size: selectedOnsen?.id == onsen.id ? 16 : 10, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .position(position)
                    .zIndex(selectedOnsen?.id == onsen.id ? 10 : 5)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.top, 100)
        .zIndex(1) // メインコンテンツは中間レベル
    }
    
    // リスト表示
    private var onsenListView: some View {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(Region.allCases, id: \.self) { region in
                        let regionOnsens = getOnsensForRegion(region)
                        
                        if !regionOnsens.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                // 地方名ヘッダー
                                HStack {
                                    Text(getLocalizedRegionName(region))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(region.color)
                                    
                                    Text("region_count_format".localized(regionOnsens.count))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, region == Region.allCases.first ? 80 : 0)
                                
                                // 地方の温泉地をグリッド表示
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount), spacing: 10) {
                                    ForEach(regionOnsens, id: \.id) { onsen in
                                        Button(action: {
                                            if !isSpinning && !isStopping {
                                                tappedOnsen = onsen
                                                showOnsenInfo = true
                                            }
                                        }) {
                                            OnsenCardView(onsen: onsen, selectedOnsen: selectedOnsen)
                                        }
                                        .disabled(isSpinning)
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            .onChange(of: orientationObserver.orientation) {
                screenWidth = UIScreen.main.bounds.width
            }
            .zIndex(1) // メインコンテンツは中間レベル
        }
        
        // 地方ごとの温泉地を取得
        private func getOnsensForRegion(_ region: Region) -> [FixedOnsenItem] {
            return availableOnsens.filter { onsen in
                Region.getRegion(for: onsen) == region
            }.sorted(by: { $0.name < $1.name })
        }
    
    private var resetButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    resetGame()
                    if InterstitialViewModel.isShowAd {
                        InterstitialViewModel.isShowAd = false
                    } else {
                        InterstitialViewModel.count += 5
                    }
                    if InterstitialViewModel.count >= 10 {
                        interstitial.showAd()
                        InterstitialViewModel.count = 0
                    }
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
            .padding(.trailing, 30)
        }
    }
    
    // 重み付けがカスタマイズされているかチェック
    private var hasCustomWeights: Bool {
        return onsenWeightManager.weights.values.contains { $0 != 1.0 }
    }
    
    // ローカライズされた地方名を取得
    private func getLocalizedRegionName(_ region: Region) -> String {
        switch region {
        case .hokkaido:
            return "region.hokkaido".localized
        case .tohoku:
            return "region.tohoku".localized
        case .kanto:
            return "region.kanto".localized
        case .chubu:
            return "region.koshinetsu".localized + "・" + "region.tokai".localized + "・" + "region.hokuriku".localized
        case .kansai:
            return "region.kinki".localized
        case .chugoku:
            return "region.chugoku".localized
        case .shikoku:
            return "region.shikoku".localized
        case .kyushu:
            return "region.kyushu".localized + "・" + "region.okinawa".localized
        }
    }
    
    // 温泉地の位置を取得（実際の温泉地の位置に基づく）
    private func getOnsenPosition(for onsen: FixedOnsenItem, in size: CGSize) -> CGPoint {
        // 温泉地名に基づいて大まかな位置を決定
        // 実際のアプリでは、より正確な座標データを使用することを推奨
        let mapWidth: CGFloat = 500
        let mapHeight: CGFloat = 500
        
        var position = CGPoint(x: 250, y: 250) // デフォルト位置
        
        switch onsen.name {
            // 北海道
            case NSLocalizedString("onsen.noboribetsu", comment: ""):
                position = CGPoint(x: 365, y: 102)
            case NSLocalizedString("onsen.toyako", comment: ""):
                position = CGPoint(x: 355, y: 105)
            case NSLocalizedString("onsen.jozankei", comment: ""):
                position = CGPoint(x: 360, y: 90)
            case NSLocalizedString("onsen.yunokawa", comment: ""):
                position = CGPoint(x: 350, y: 130)
                
            // 東北
            case NSLocalizedString("onsen.nyuto", comment: ""):
                position = CGPoint(x: 340, y: 200)
            case NSLocalizedString("onsen.ginzan", comment: ""):
                position = CGPoint(x: 335, y: 240)
            case NSLocalizedString("onsen.zao", comment: ""):
                position = CGPoint(x: 330, y: 250)
            case NSLocalizedString("onsen.hanamaki", comment: ""):
                position = CGPoint(x: 365, y: 210)
            case NSLocalizedString("onsen.naruko", comment: ""):
                position = CGPoint(x: 355, y: 245)
            case NSLocalizedString("onsen.iizaka", comment: ""):
                position = CGPoint(x: 345, y: 280)
                
            // 関東
            case NSLocalizedString("onsen.hakone", comment: ""):
                position = CGPoint(x: 315, y: 340)
            case NSLocalizedString("onsen.kusatsu", comment: ""):
                position = CGPoint(x: 300, y: 310)
            case NSLocalizedString("onsen.ikaho", comment: ""):
                position = CGPoint(x: 305, y: 305)
            case NSLocalizedString("onsen.atami", comment: ""):
                position = CGPoint(x: 305, y: 350)
            case NSLocalizedString("onsen.shuzenji", comment: ""):
                position = CGPoint(x: 290, y: 355)
            case NSLocalizedString("onsen.atagawa", comment: ""):
                position = CGPoint(x: 295, y: 360)
            case NSLocalizedString("onsen.isawa", comment: ""):
                position = CGPoint(x: 290, y: 335)
                
            // 中部
            case NSLocalizedString("onsen.nozawa", comment: ""):
                position = CGPoint(x: 280, y: 320)
            case NSLocalizedString("onsen.kamisuwa", comment: ""):
                position = CGPoint(x: 275, y: 330)
            case NSLocalizedString("onsen.gero", comment: ""):
                position = CGPoint(x: 255, y: 335)
            case NSLocalizedString("onsen.unazuki", comment: ""):
                position = CGPoint(x: 265, y: 290)
                
            // 北陸
            case NSLocalizedString("onsen.yamanaka", comment: ""):
                position = CGPoint(x: 245, y: 305)
            case NSLocalizedString("onsen.wakura", comment: ""):
                position = CGPoint(x: 250, y: 285)
            case NSLocalizedString("onsen.yamashiro", comment: ""):
                position = CGPoint(x: 248, y: 300)
            case NSLocalizedString("onsen.katayamazu", comment: ""):
                position = CGPoint(x: 252, y: 295)
                
            // 関西
            case NSLocalizedString("onsen.arima", comment: ""):
                position = CGPoint(x: 200, y: 350)
            case NSLocalizedString("onsen.kinosaki", comment: ""):
                position = CGPoint(x: 185, y: 340)
            case NSLocalizedString("onsen.yumura", comment: ""):
                position = CGPoint(x: 180, y: 335)
            case NSLocalizedString("onsen.shirahama", comment: ""):
                position = CGPoint(x: 220, y: 390)
            case NSLocalizedString("onsen.katsuura", comment: ""):
                position = CGPoint(x: 235, y: 385)
                
            // 中国
            case NSLocalizedString("onsen.misasa", comment: ""):
                position = CGPoint(x: 175, y: 345)
            case NSLocalizedString("onsen.tamatsukuri", comment: ""):
                position = CGPoint(x: 155, y: 350)
                
            // 四国
            case NSLocalizedString("onsen.dogo", comment: ""):
                position = CGPoint(x: 160, y: 390)
                
            // 九州
            case NSLocalizedString("onsen.beppu", comment: ""):
                position = CGPoint(x: 120, y: 405)
            case NSLocalizedString("onsen.yufuin", comment: ""):
                position = CGPoint(x: 115, y: 400)
            case NSLocalizedString("onsen.ibusuki", comment: ""):
                position = CGPoint(x: 95, y: 450)
            case NSLocalizedString("onsen.kurokawa", comment: ""):
                position = CGPoint(x: 100, y: 420)
            case NSLocalizedString("onsen.unzen", comment: ""):
                position = CGPoint(x: 80, y: 415)
            case NSLocalizedString("onsen.ureshino", comment: ""):
                position = CGPoint(x: 82, y: 408)
            case NSLocalizedString("onsen.takeo", comment: ""):
                position = CGPoint(x: 85, y: 405)

            
        default:
            // デフォルトの場合、所属する都道府県の中心付近に配置
            if let prefecture = Prefecture.allCases.first(where: { $0.onsenItems.contains(where: { $0.id.uuidString == onsen.id }) }) {
                let prefectureCenter = getPrefectureCenter(prefecture)
                position = prefectureCenter
            }
        }
        
        return CGPoint(
            x: (position.x / mapWidth) * size.width,
            y: (position.y / mapHeight) * size.height
        )
    }
    
    // 都道府県の中心座標を取得
    private func getPrefectureCenter(_ prefecture: Prefecture) -> CGPoint {
        let points = prefecture.points
        guard !points.isEmpty else { return CGPoint(x: 250, y: 250) }
        
        let sumX = points.reduce(0) { $0 + $1.x }
        let sumY = points.reduce(0) { $0 + $1.y }
        
        return CGPoint(
            x: sumX / CGFloat(points.count),
            y: sumY / CGFloat(points.count)
        )
    }
    
    // 都道府県の背景色を取得
    private func getBackgroundColor(for prefecture: Prefecture) -> LinearGradient {
        if prefecture.hasOnsen {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.2),
                    Color.red.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // ゲームをリセット
    private func resetGame() {
        showResultModal = false
        selectedOnsen = nil
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
        guard !isSpinning && !availableOnsens.isEmpty else { return }
        
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
            selectedOnsen = selectRandomOnsen()
            spinCount += 1
            
            if !isStopping {
                startSpinTimer()
            }
        }
    }
    
    // ランダムな温泉地を選択
    private func selectRandomOnsen() -> FixedOnsenItem {
        guard !enabledOnsens.isEmpty else {
            return FixedOnsenItem(name: "温泉なし", description: "", imageSymbol: "thermometer.sun.fill", onsenType: .therapeutic, popularity: 1, coordinate: CLLocationCoordinate2D())
        }
        
        return onsenWeightManager.selectRandomOnsen(from: enabledOnsens) ?? enabledOnsens.first!
    }
    
    // 停止シーケンスを開始
    private func startStoppingSequence() {
        spinTimer?.invalidate()
        
        var stopSpinCount = 0
        var stopInterval: TimeInterval = currentSpinInterval
        
        func stopSpinTimer() {
            Timer.scheduledTimer(withTimeInterval: stopInterval, repeats: false) { _ in
                selectedOnsen = selectRandomOnsen()
                
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
                    selectedOnsen = selectRandomOnsen()
                    
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
}

// MARK: - OnsenDetailView (Localized)
struct OnsenDetailView: View {
    let onsen: FixedOnsenItem
    @State private var region: MKCoordinateRegion
    @Environment(\.dismiss) private var dismiss
    
    init(onsen: FixedOnsenItem) {
        self.onsen = onsen
        // 温泉地を中心とした地図領域を設定
        self._region = State(initialValue: MKCoordinateRegion(
            center: onsen.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        ))
    }
    
    /// 温泉タイプの基調色。
    private var accent: Color { onsen.onsenType.color }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 上方向バウンス時にヘッダー背後へ白が出ないよう最背面に基調色を敷く。
            accent.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    VStack(alignment: .leading, spacing: 18) {
                        actionCard
                        descriptionCard
                        mapCard
                    }
                    .padding(.horizontal, 18)
                }
                .padding(.bottom, 32)
            }
            .background(PlanTheme.backgroundGradient.ignoresSafeArea())
            .ignoresSafeArea(edges: .top)

            closeButton
        }
        .navigationBarHidden(true)
    }

    // MARK: - 閉じるボタン（ブランドの白丸フローティング・グルメと統一）

    private var closeButton: some View {
        Button {
            InterstitialViewModel.count += 2
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
        .padding(.top, 56)
        .padding(.trailing, 18)
    }

    // MARK: - ヒーローヘッダー

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.22))
                    .frame(width: 76, height: 76)
                Image(systemName: onsen.imageSymbol)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(onsen.name)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                Label(onsen.onsenType.localizedName, systemImage: onsen.onsenType.icon)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                    .background(.white.opacity(0.22), in: Capsule())

                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < onsen.popularity ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(index < onsen.popularity ? .white : .white.opacity(0.4))
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        // ヘッダー自身は背景を持たず、最背面の accent をそのまま透かす（段差を出さない）。
    }

    // MARK: - アクション白カード

    private var actionCard: some View {
        VStack(spacing: 14) {
            AddToPlanButton {
                PlanItem(
                    category: .onsen,
                    prefecture: Prefecture.containingOnsen(named: onsen.name) ?? Prefecture.nearest(to: onsen.coordinate),
                    name: onsen.name
                )
            }

            HStack(spacing: 6) {
                Text("gourmet.explore_more".localized)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                Spacer()
            }

            SocialSearchButtons(query: onsen.name)
        }
        .planCard()
    }

    // MARK: - 説明

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "text.quote", title: "onsen_features".localized)
            Text(onsen.description)
                .font(.body)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .planCard()
    }

    // MARK: - 地図カード

    private var mapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "map", title: "onsen_map".localized)

            Map(coordinateRegion: $region, annotationItems: [onsen]) { onsenItem in
                MapAnnotation(coordinate: onsenItem.coordinate) {
                    Image(systemName: "thermometer.sun.fill")
                        .font(.title3)
                        .foregroundColor(accent)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 3)
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .onAppear { region.center = onsen.coordinate }

            Button(action: { openInExternalMaps() }) {
                HStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(accent)
                        .frame(width: 32, height: 32)
                        .background(.white, in: Circle())
                    Text("open_external_map".localized)
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

    private func openInExternalMaps() {
        // 温泉名での検索クエリを作成
        let searchQuery = onsen.name
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Apple Maps検索URL
        let appleMapsSearchURL = "http://maps.apple.com/?q=\(encodedQuery)"
        
        // Google Maps検索URL
        let googleMapsSearchURL = "https://maps.google.com/maps?q=\(encodedQuery)"
        
        if let url = URL(string: appleMapsSearchURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let url = URL(string: googleMapsSearchURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // フォールバック: ブラウザでGoogle Maps
            let webURL = "https://www.google.com/maps/search/\(encodedQuery)"
            if let url = URL(string: webURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - OnsenCardView (Localized)
struct OnsenCardView: View {
    let onsen: FixedOnsenItem
    let selectedOnsen: FixedOnsenItem?
    
    private var isSelected: Bool {
        selectedOnsen?.id == onsen.id
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 温泉アイコン
            ZStack {
                // 選択された温泉地の背景効果
                if isSelected {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 55, height: 55)
                        .blur(radius: 8)
                }
                
                Circle()
                    .fill(
                        isSelected
                        ? LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            gradient: Gradient(colors: [onsen.onsenType.color.opacity(0.8), onsen.onsenType.color]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isSelected ? 48 : 42, height: isSelected ? 48 : 42)
                    .shadow(
                        color: isSelected ? .orange.opacity(0.5) : .black.opacity(0.15),
                        radius: isSelected ? 4 : 2,
                        x: 0,
                        y: isSelected ? 2 : 1
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Image(systemName: "thermometer.sun.fill")
                    .font(.system(size: isSelected ? 22 : 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                // 温泉地名
                Text(onsen.name)
                    .font(.system(size: 12, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? .orange : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28)
                
                // 都道府県情報
                Text(getPrefectureName(for: onsen))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                
                // 温泉タイプと人気度を横並びに
                HStack(spacing: 6) {
                    // 温泉タイプ
                    Text(onsen.onsenType.localizedName)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(onsen.onsenType.color.opacity(0.1))
                        .cornerRadius(3)
                    
                    // 人気度
                    HStack(spacing: 1) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < onsen.popularity ? "star.fill" : "star")
                                .foregroundColor(.orange)
                                .font(.system(size: 7))
                        }
                    }
                }
            }
        }
        .padding(10)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isSelected
                    ? LinearGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.red.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        gradient: Gradient(colors: [Color.white]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .stroke(
                    isSelected ? Color.orange.opacity(0.4) : Color.gray.opacity(0.2),
                    lineWidth: isSelected ? 2 : 1
                )
                .shadow(
                    color: isSelected ? .orange.opacity(0.2) : .black.opacity(0.05),
                    radius: isSelected ? 4 : 2,
                    x: 0,
                    y: isSelected ? 2 : 1
                )
        )
        .frame(height: 150)
    }
    
    // 温泉地から都道府県名を取得（ローカライズ対応）
    func getPrefectureName(for onsen: FixedOnsenItem) -> String {
        // Prefecture enumの中から該当する温泉地を含む都道府県を探す
        for prefecture in Prefecture.allCases {
            if prefecture.onsenItems.contains(where: { $0.id.uuidString == onsen.id }) {
                return prefecture.localizedPrefectureName
            }
        }
        
        // 見つからない場合は温泉地名から推測（ローカライズ対応）
        return inferLocalizedPrefectureFromName(onsen.name)
    }
    
    // 温泉地名から都道府県を推測（ローカライズ対応）
    private func inferLocalizedPrefectureFromName(_ onsenName: String) -> String {
        switch onsenName {
            // 北海道
        case let name where
            name.contains("登別") || name.contains("Noboribetsu") || name.contains("登别") || name.contains("노보리베츠") ||
            name.contains("洞爺湖") || name.contains("Toyako") || name.contains("洞爷湖") || name.contains("도야코") ||
            name.contains("定山渓") || name.contains("Jozankei") || name.contains("定山溪") || name.contains("조잔케이") ||
            name.contains("函館") || name.contains("Hakodate") || name.contains("函馆") || name.contains("하코다테"):
            return "prefecture.hokkaido".localized
            
            // 東北
        case let name where
            name.contains("乳頭") || name.contains("Nyuto") || name.contains("乳头") || name.contains("뉴토") ||
            name.contains("田沢湖") || name.contains("Tazawako") || name.contains("田泽湖") || name.contains("타자와코"):
            return "prefecture.akita".localized
            
        case let name where
            name.contains("銀山") || name.contains("Ginzan") || name.contains("银山") || name.contains("긴잔") ||
            name.contains("蔵王") || name.contains("Zao") || name.contains("藏王") || name.contains("자오"):
            return "prefecture.yamagata".localized
            
        case let name where
            name.contains("花巻") || name.contains("Hanamaki") || name.contains("花卷") || name.contains("하나마키"):
            return "prefecture.iwate".localized
            
        case let name where
            name.contains("鳴子") || name.contains("Naruko") || name.contains("鸣子") || name.contains("나루코"):
            return "prefecture.miyagi".localized
            
        case let name where
            name.contains("飯坂") || name.contains("Iizaka") || name.contains("饭坂") || name.contains("이이자카"):
            return "prefecture.fukushima".localized
            
            // 関東
        case let name where
            name.contains("箱根") || name.contains("Hakone") || name.contains("箱根") || name.contains("하코네") ||
            name.contains("熱海") || name.contains("Atami") || name.contains("热海") || name.contains("아타미") ||
            name.contains("修善寺") || name.contains("Shuzenji") || name.contains("修善寺") || name.contains("슈젠지") ||
            name.contains("熱川") || name.contains("Atagawa") || name.contains("热川") || name.contains("아타가와"):
            return "prefecture.shizuoka".localized
            
        case let name where
            name.contains("草津") || name.contains("Kusatsu") || name.contains("草津") || name.contains("구사츠") ||
            name.contains("伊香保") || name.contains("Ikaho") || name.contains("伊香保") || name.contains("이카호"):
            return "prefecture.gunma".localized
            
        case let name where
            name.contains("石和") || name.contains("Isawa") || name.contains("石和") || name.contains("이사와"):
            return "prefecture.yamanashi".localized
            
            // 中部
        case let name where
            name.contains("野沢") || name.contains("Nozawa") || name.contains("野泽") || name.contains("노자와"):
            return "prefecture.nagano".localized
            
        case let name where
            name.contains("上諏訪") || name.contains("Kamisuwa") || name.contains("上诏访") || name.contains("카미스와"):
            return "prefecture.nagano".localized
            
        case let name where
            name.contains("下呂") || name.contains("Gero") || name.contains("下吕") || name.contains("게로"):
            return "prefecture.gifu".localized
            
        case let name where
            name.contains("宇奈月") || name.contains("Unazuki") || name.contains("宇奈月") || name.contains("우나즈키"):
            return "prefecture.toyama".localized
            
            // 北陸
        case let name where
            name.contains("山中") || name.contains("Yamanaka") || name.contains("山中") || name.contains("야마나카") ||
            name.contains("山代") || name.contains("Yamashiro") || name.contains("山代") || name.contains("야마시로") ||
            name.contains("片山津") || name.contains("Katayamazu") || name.contains("片山津") || name.contains("카타야마즈"):
            return "prefecture.ishikawa".localized
            
        case let name where
            name.contains("和倉") || name.contains("Wakura") || name.contains("和仓") || name.contains("와쿠라"):
            return "prefecture.ishikawa".localized
            
            // 関西
        case let name where
            name.contains("有馬") || name.contains("Arima") || name.contains("有马") || name.contains("아리마"):
            return "prefecture.hyogo".localized
            
        case let name where
            name.contains("城崎") || name.contains("Kinosaki") || name.contains("城崎") || name.contains("키노사키") ||
            name.contains("湯村") || name.contains("Yumura") || name.contains("汤村") || name.contains("유무라"):
            return "prefecture.hyogo".localized
            
        case let name where
            name.contains("白浜") || name.contains("Shirahama") || name.contains("白滨") || name.contains("시라하마") ||
            name.contains("勝浦") || name.contains("Katsuura") || name.contains("胜浦") || name.contains("카츠우라"):
            return "prefecture.wakayama".localized
            
            // 中国
        case let name where
            name.contains("三朝") || name.contains("Misasa") || name.contains("三朝") || name.contains("미사사"):
            return "prefecture.tottori".localized
            
        case let name where
            name.contains("玉造") || name.contains("Tamatsukuri") || name.contains("玉造") || name.contains("타마츠쿠리"):
            return "prefecture.shimane".localized
            
            // 四国
        case let name where
            name.contains("道後") || name.contains("Dogo") || name.contains("道后") || name.contains("도고"):
            return "prefecture.ehime".localized
            
            // 九州
        case let name where
            name.contains("別府") || name.contains("Beppu") || name.contains("别府") || name.contains("벳푸") ||
            name.contains("湯布院") || name.contains("Yufuin") || name.contains("汤布院") || name.contains("유후인"):
            return "prefecture.oita".localized
            
        case let name where
            name.contains("指宿") || name.contains("Ibusuki") || name.contains("指宿") || name.contains("이부스키"):
            return "prefecture.kagoshima".localized
            
        case let name where
            name.contains("黒川") || name.contains("Kurokawa") || name.contains("黑川") || name.contains("구로카와"):
            return "prefecture.kumamoto".localized
            
        case let name where
            name.contains("雲仙") || name.contains("Unzen") || name.contains("云仙") || name.contains("운젠"):
            return "prefecture.nagasaki".localized
            
        case let name where
            name.contains("嬉野") || name.contains("Ureshino") || name.contains("嬉野") || name.contains("우레시노") ||
            name.contains("武雄") || name.contains("Takeo") || name.contains("武雄") || name.contains("타케오"):
            return "prefecture.saga".localized
            
        default:
            return "japan".localized
        }
    }
}
// MARK: - Prefecture Extension for Localization
extension Prefecture {
    var localizedPrefectureName: String {
        switch self {
        case .hokkaido: return "prefecture.hokkaido".localized
        case .aomori: return "prefecture.aomori".localized
        case .iwate: return "prefecture.iwate".localized
        case .akita: return "prefecture.akita".localized
        case .miyagi: return "prefecture.miyagi".localized
        case .yamagata: return "prefecture.yamagata".localized
        case .fukushima: return "prefecture.fukushima".localized
        case .ibaraki: return "prefecture.ibaraki".localized
        case .chiba: return "prefecture.chiba".localized
        case .tochigi: return "prefecture.tochigi".localized
        case .gunma: return "prefecture.gunma".localized
        case .saitama: return "prefecture.saitama".localized
        case .tokyo: return "prefecture.tokyo".localized
        case .kanagawa: return "prefecture.kanagawa".localized
        case .niigata: return "prefecture.niigata".localized
        case .nagano: return "prefecture.nagano".localized
        case .yamanashi: return "prefecture.yamanashi".localized
        case .shizuoka: return "prefecture.shizuoka".localized
        case .aichi: return "prefecture.aichi".localized
        case .mie: return "prefecture.mie".localized
        case .gifu: return "prefecture.gifu".localized
        case .fukui: return "prefecture.fukui".localized
        case .ishikawa: return "prefecture.ishikawa".localized
        case .toyama: return "prefecture.toyama".localized
        case .shiga: return "prefecture.shiga".localized
        case .kyoto: return "prefecture.kyoto".localized
        case .hyogo: return "prefecture.hyogo".localized
        case .nara: return "prefecture.nara".localized
        case .wakayama: return "prefecture.wakayama".localized
        case .osaka: return "prefecture.osaka".localized
        case .tottori: return "prefecture.tottori".localized
        case .okayama: return "prefecture.okayama".localized
        case .hiroshima: return "prefecture.hiroshima".localized
        case .yamaguchi: return "prefecture.yamaguchi".localized
        case .shimane: return "prefecture.shimane".localized
        case .kagawa: return "prefecture.kagawa".localized
        case .tokushima: return "prefecture.tokushima".localized
        case .kochi: return "prefecture.kochi".localized
        case .ehime: return "prefecture.ehime".localized
        case .fukuoka: return "prefecture.fukuoka".localized
        case .oita: return "prefecture.oita".localized
        case .miyazaki: return "prefecture.miyazaki".localized
        case .kagoshima: return "prefecture.kagoshima".localized
        case .kumamoto: return "prefecture.kumamoto".localized
        case .saga: return "prefecture.saga".localized
        case .nagasaki: return "prefecture.nagasaki".localized
        case .okinawa: return "prefecture.okinawa".localized
        }
    }
}

// MARK: - 地方区分のEnum（ローカライズ対応）
enum Region: String, CaseIterable {
    case hokkaido = "北海道"
    case tohoku = "東北"
    case kanto = "関東"
    case chubu = "中部"
    case kansai = "関西"
    case chugoku = "中国"
    case shikoku = "四国"
    case kyushu = "九州・沖縄"
    
    var localizedName: String {
        switch self {
        case .hokkaido: return "region.hokkaido".localized
        case .tohoku: return "region.tohoku".localized
        case .kanto: return "region.kanto".localized
        case .chubu:
            // 中部は甲信越・東海・北陸の組み合わせ
            let koshinetsu = "region.koshinetsu".localized
            let tokai = "region.tokai".localized
            let hokuriku = "region.hokuriku".localized
            return "\(koshinetsu)・\(tokai)・\(hokuriku)"
        case .kansai: return "region.kinki".localized
        case .chugoku: return "region.chugoku".localized
        case .shikoku: return "region.shikoku".localized
        case .kyushu:
            let kyushu = "region.kyushu".localized
            let okinawa = "region.okinawa".localized
            return "\(kyushu)・\(okinawa)"
        }
    }
    
    var color: Color {
        switch self {
        case .hokkaido:
            return .blue
        case .tohoku:
            return .green
        case .kanto:
            return .red
        case .chubu:
            return .orange
        case .kansai:
            return .purple
        case .chugoku:
            return .brown
        case .shikoku:
            return .mint
        case .kyushu:
            return .pink
        }
    }
    
    // 温泉地が属する地方を判定（ローカライズ対応）
    static func getRegion(for onsen: FixedOnsenItem) -> Region {
        let prefectureName = OnsenCardView(onsen: onsen, selectedOnsen: onsen).getPrefectureName(for: onsen)
        
        switch prefectureName {
        case "prefecture.hokkaido".localized:
            return .hokkaido
        case "prefecture.aomori".localized, "prefecture.iwate".localized, "prefecture.miyagi".localized,
             "prefecture.akita".localized, "prefecture.yamagata".localized, "prefecture.fukushima".localized:
            return .tohoku
        case "prefecture.ibaraki".localized, "prefecture.tochigi".localized, "prefecture.gunma".localized,
             "prefecture.saitama".localized, "prefecture.chiba".localized, "prefecture.tokyo".localized,
             "prefecture.kanagawa".localized, "prefecture.shizuoka".localized, "prefecture.yamanashi".localized:
            return .kanto
        case "prefecture.niigata".localized, "prefecture.toyama".localized, "prefecture.ishikawa".localized,
             "prefecture.fukui".localized, "prefecture.nagano".localized, "prefecture.gifu".localized,
             "prefecture.aichi".localized:
            return .chubu
        case "prefecture.mie".localized, "prefecture.shiga".localized, "prefecture.kyoto".localized,
             "prefecture.osaka".localized, "prefecture.hyogo".localized, "prefecture.nara".localized,
             "prefecture.wakayama".localized:
            return .kansai
        case "prefecture.tottori".localized, "prefecture.shimane".localized, "prefecture.okayama".localized,
             "prefecture.hiroshima".localized, "prefecture.yamaguchi".localized:
            return .chugoku
        case "prefecture.tokushima".localized, "prefecture.kagawa".localized, "prefecture.ehime".localized,
             "prefecture.kochi".localized:
            return .shikoku
        case "prefecture.fukuoka".localized, "prefecture.saga".localized, "prefecture.nagasaki".localized,
             "prefecture.kumamoto".localized, "prefecture.oita".localized, "prefecture.miyazaki".localized,
             "prefecture.kagoshima".localized, "prefecture.okinawa".localized:
            return .kyushu
        default:
            return .kanto // デフォルト
        }
    }
}
