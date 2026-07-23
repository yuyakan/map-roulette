//
//  Interstitial.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/27.
//

import SwiftUI
import StoreKit
import GoogleMobileAds

class InterstitialViewModel: NSObject, FullScreenContentDelegate {
    static var count = 0
    private var interstitialAd: InterstitialAd?
    static var isShowAd = false

    // MARK: - 表示制御の設定

    /// 発火しきい値。count がこの値以上になると広告（または初回レビュー）を出す。
    static let threshold = 10
    /// 広告のクールダウン秒数。前回広告からこの秒数未満は count がしきい値を超えても発火しない。
    static let cooldown: TimeInterval = 90

    /// 前回広告を表示した時刻。クールダウン判定に使う。
    private static var lastAdShownAt: Date?
    /// 初回の発火でレビューを出したかどうか（UserDefaults で永続化）。
    private static let reviewShownKey = "InterstitialViewModel.reviewShown"
    private static var hasShownReview: Bool {
        get { UserDefaults.standard.bool(forKey: reviewShownKey) }
        set { UserDefaults.standard.set(newValue, forKey: reviewShownKey) }
    }

    // MARK: - 標準レビュー（SKStoreReviewController）の設定

    /// 累計スピン回数がこの値以上になると、標準レビューダイアログの表示を毎スピン試行する。
    /// 実際に表示されるかは OS 任せ（システムが 365 日で最大 3 回に間引くため呼びすぎの害はない）。
    static let requestReviewSpinThreshold = 7
    /// 累計スピン回数（UserDefaults で永続化）。
    private static let reviewSpinCountKey = "InterstitialViewModel.reviewSpinCount"
    private static var reviewSpinCount: Int {
        get { UserDefaults.standard.integer(forKey: reviewSpinCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: reviewSpinCountKey) }
    }

    // MARK: - 発火の集約ロジック

    /// ルーレットを回したときに呼ぶ。直前に広告を出していれば二重発火を避けて加算をスキップし、
    /// そうでなければ +5 して発火判定を行う。
    func registerRouletteSpin() {
        if InterstitialViewModel.isShowAd {
            InterstitialViewModel.isShowAd = false
        } else {
            InterstitialViewModel.count += 5
        }

        // 累計スピン数を加算。標準レビューのしきい値判定に使う。
        InterstitialViewModel.reviewSpinCount += 1

        // 自作ダイアログ／広告が発火したフレームでは標準レビューを呼ばない（二重発火の回避）。
        if maybePresent() { return }

        // 何も発火していないフレームでのみ、累計スピンがしきい値以上なら標準レビューを試行する。
        // 実際に表示するかは OS 任せ（システムが 365 日で最大 3 回に間引く）。
        if InterstitialViewModel.reviewSpinCount >= InterstitialViewModel.requestReviewSpinThreshold {
            InterstitialViewModel.requestSystemReview()
        }
    }

    /// マップ画面に戻ってきたとき（onAppear）に呼ぶ。発火したら次のルーレットで二重発火しないよう
    /// isShowAd を立てる。あわせて次の広告を先読みする。
    func handleMapAppear() {
        if maybePresent() {
            InterstitialViewModel.isShowAd = true
        }
        Task { await loadAd() }
    }

    /// しきい値・クールダウンを満たしていれば広告（初回はレビュー）を出して count をリセットする。
    /// 実際に発火したら true を返す。
    @discardableResult
    func maybePresent() -> Bool {
        // スクショ撮影用に広告・レビュー誘導を一切発火させない。
        if adsHidden { return false }

        guard InterstitialViewModel.count >= InterstitialViewModel.threshold else { return false }

        // クールダウン中は発火しない（count は維持し、次の機会に持ち越す）。
        if let last = InterstitialViewModel.lastAdShownAt,
           Date().timeIntervalSince(last) < InterstitialViewModel.cooldown {
            return false
        }

        InterstitialViewModel.count = 0
        InterstitialViewModel.lastAdShownAt = Date()

        // 初回の発火だけは広告の代わりに標準レビュー（アプリ内で完結）を試行する。
        if !InterstitialViewModel.hasShownReview {
            InterstitialViewModel.hasShownReview = true
            InterstitialViewModel.requestSystemReview()
        } else {
            showAd()
        }
        return true
    }

    // MARK: - レビュー誘導

    /// 標準のレビュー依頼（アプリ内で完結）を試行する。実際に表示されるかは OS 任せ。
    static func requestSystemReview() {
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
        else { return }

        if #available(iOS 16.0, *) {
            AppStore.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    func loadAd() async {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: adUnitIdInter, request: Request())
            interstitialAd?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func ad(
      _ ad: FullScreenPresentingAd,
      didFailToPresentFullScreenContentWithError error: Error
    ) {
      print("\(#function) called")
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
      print("\(#function) called")
      // Clear the interstitial ad.
      interstitialAd = nil
        
    }
    
    func showAd() {
      guard let interstitialAd = interstitialAd else {
        return print("Ad wasn't ready.")
      }
      interstitialAd.present(from: nil)
    }
}
