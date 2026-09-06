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

    init() {
        // 起動時に 1 回だけ Firebase を初期化（ホームタブのトレンド機能で Firestore を使う）。
        FirebaseBootstrap.configureIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        // UMP で同意を取得 → ATT ダイアログ → AdMob 初期化、の順に進める。
                        // canRequestAds が立ったときだけ広告が配信される。
                        ConsentManager.shared.gatherConsentThenStartAds {}
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
