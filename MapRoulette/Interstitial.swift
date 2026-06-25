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
    /// App Store の write-review URL に使うアプリ ID。
    static let appStoreID = "6748571599"

    /// 前回広告を表示した時刻。クールダウン判定に使う。
    private static var lastAdShownAt: Date?
    /// 初回の発火でレビューを出したかどうか（UserDefaults で永続化）。
    private static let reviewShownKey = "InterstitialViewModel.reviewShown"
    private static var hasShownReview: Bool {
        get { UserDefaults.standard.bool(forKey: reviewShownKey) }
        set { UserDefaults.standard.set(newValue, forKey: reviewShownKey) }
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
        maybePresent()
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
        guard InterstitialViewModel.count >= InterstitialViewModel.threshold else { return false }

        // クールダウン中は発火しない（count は維持し、次の機会に持ち越す）。
        if let last = InterstitialViewModel.lastAdShownAt,
           Date().timeIntervalSince(last) < InterstitialViewModel.cooldown {
            return false
        }

        InterstitialViewModel.count = 0
        InterstitialViewModel.lastAdShownAt = Date()

        // 初回の発火だけは広告の代わりにレビューダイアログを出す。
        if !InterstitialViewModel.hasShownReview {
            InterstitialViewModel.hasShownReview = true
            InterstitialViewModel.presentReviewPrompt()
        } else {
            showAd()
        }
        return true
    }

    // MARK: - レビュー誘導

    /// 自作の確認ダイアログを出し、「はい」なら App Store のレビュー投稿ページを開く。
    static func presentReviewPrompt() {
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return }

        // 最前面の VC を取得（シート等が乗っている場合に対応）。
        var top = root
        while let presented = top.presentedViewController { top = presented }

        let alert = UIAlertController(
            title: NSLocalizedString("review.prompt.title", comment: ""),
            message: NSLocalizedString("review.prompt.message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("review.prompt.no", comment: ""),
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("review.prompt.yes", comment: ""),
            style: .default
        ) { _ in
            openWriteReview()
        })
        top.present(alert, animated: true)
    }

    /// App Store のレビュー投稿ページを開く。
    static func openWriteReview() {
        guard let url = URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review") else { return }
        UIApplication.shared.open(url)
    }

    func loadAd() async {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: prodIdInter, request: Request())
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
