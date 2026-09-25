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
    /// 同意フロー（UMP → ATT → AdMob）を二重に開始しないためのフラグ。
    @State private var didStartConsentFlow = false

    init() {
        // 起動時に 1 回だけ Firebase を初期化（ホームタブのトレンド機能で Firestore を使う）。
        FirebaseBootstrap.configureIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView()
                    .onAppear {
                        // 必要に応じて初期化処理
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            showSplash = false
                        }
                    }
            } else {
                ContentView()
                    .task {
                        // UMP で同意を取得 → ATT ダイアログ → AdMob 初期化、の順に進める。
                        // canRequestAds が立ったときだけ広告が配信される。
                        //
                        // スプラッシュ表示中ではなく ContentView が出てから開始する。
                        // スプラッシュは 2 秒で差し替わるため、そこで UMP フォームや
                        // ATT ダイアログを出すとビュー遷移と競合して表示されないことがある。
                        guard !didStartConsentFlow else { return }
                        didStartConsentFlow = true
                        ConsentManager.shared.gatherConsentThenStartAds {}
                    }
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
