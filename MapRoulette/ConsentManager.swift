//
//  ConsentManager.swift
//  MapRoulette
//
//  Created by Claude on 2026/07/23.
//

import AppTrackingTransparency
import GoogleMobileAds
import UserMessagingPlatform

/// UMP（Google User Messaging Platform）の同意取得と ATT（App Tracking Transparency）を
/// まとめて扱うマネージャ。
///
/// Google 公式が推奨する順序に従う:
///   1. UMP で同意情報を更新し、必要なら同意フォーム（GDPR 圏など）を表示する。
///   2. UMP フォーム完了後に ATT のトラッキング許可ダイアログを表示する。
///   3. `canRequestAds` が立ったら AdMob SDK を初期化して広告配信を開始する。
///
/// ATT で許可され、かつ UMP で同意が得られたときにパーソナライズ広告が配信される。
/// いずれかが拒否された場合も非パーソナライズ広告は表示される。
@MainActor
final class ConsentManager {
    static let shared = ConsentManager()
    private init() {}

    /// AdMob の初期化を一度だけ行うためのフラグ。
    private var didStartMobileAds = false

    /// アプリ起動時に呼ぶ。同意情報を更新し、必要なら同意フォームを出したうえで
    /// ATT ダイアログを表示し、最終的に AdMob を初期化する。
    /// - Parameter onReady: 広告リクエスト可能（`canRequestAds`）になったら呼ばれる。
    func gatherConsentThenStartAds(onReady: @escaping () -> Void) {
        let parameters = RequestParameters()
        // 子ども向けではないので tag を明示しない（デフォルトのまま）。
        // デバッグ時に地域を強制したい場合は下記コメントを参照。
        #if DEBUG
        // テスト用の設定。実機で一度起動するとコンソールにテストデバイス ID が出るので、
        // それを testDeviceIdentifiers に登録すると EEA（GDPR 圏）の挙動を再現できる。
        let debugSettings = DebugSettings()
        // debugSettings.geography = .EEA
        // debugSettings.testDeviceIdentifiers = ["ここにテストデバイスIDを入れる"]
        parameters.debugSettings = debugSettings
        #endif

        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] error in
            guard let self else { return }

            if let error {
                // 同意情報の更新に失敗しても、ATT を出して可能な範囲で先へ進める。
                print("UMP requestConsentInfoUpdate failed: \(error.localizedDescription)")
                self.requestATTThenStartAds(onReady: onReady)
                return
            }

            // 必要なら同意フォームを読み込んで表示する（不要なら即クロージャが返る）。
            self.loadAndPresentConsentFormIfRequired(onReady: onReady)
        }
    }

    /// 同意フォームが必要なら表示し、完了後に ATT → AdMob 初期化へ進む。
    private func loadAndPresentConsentFormIfRequired(onReady: @escaping () -> Void) {
        guard let rootViewController = Self.rootViewController else {
            // 表示先が取れない場合でも ATT だけは試みる。
            requestATTThenStartAds(onReady: onReady)
            return
        }

        ConsentForm.loadAndPresentIfRequired(from: rootViewController) { [weak self] error in
            guard let self else { return }
            if let error {
                print("UMP loadAndPresentIfRequired failed: \(error.localizedDescription)")
            }
            // フォームの有無・成否にかかわらず、続けて ATT を出す。
            self.requestATTThenStartAds(onReady: onReady)
        }
    }

    /// ATT のトラッキング許可ダイアログを表示し、その後 AdMob を初期化する。
    /// ATT の結果に関わらず、`canRequestAds` が立っていれば広告リクエストは可能。
    private func requestATTThenStartAds(onReady: @escaping () -> Void) {
        ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
            Task { @MainActor in
                self?.startMobileAdsIfNeeded(onReady: onReady)
            }
        }
    }

    /// `canRequestAds` が立っていれば AdMob を一度だけ初期化する。
    private func startMobileAdsIfNeeded(onReady: @escaping () -> Void) {
        guard ConsentInformation.shared.canRequestAds else {
            // 同意が得られていない（広告リクエスト不可）。何もしない。
            return
        }
        guard !didStartMobileAds else {
            onReady()
            return
        }
        didStartMobileAds = true
        MobileAds.shared.start { _ in
            onReady()
        }
    }

    /// フォーム表示に使う最前面の rootViewController。
    private static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .windows.first { $0.isKeyWindow }?
            .rootViewController
    }
}
