//
//  MapRouletteApp.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/06.
//

import SwiftUI
import GoogleMobileAds

@main
struct MapRouletteApp: App {
    @State private var showSplash = true
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        MobileAds.shared.start()
                        // 必要に応じて初期化処理
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            showSplash = false
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}

struct SplashView: View {
    
    var body: some View {
        ZStack {
            Color("splashColor")
                .ignoresSafeArea(.all)
            Image("splash")
                .resizable()
                .scaledToFit()
        }
    }
}
