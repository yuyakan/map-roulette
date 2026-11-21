//
//  AppRouter.swift
//  MapRoulette
//
//  タブ切り替えなど「画面をまたぐ遷移」の唯一の共有状態。
//  各ビューは自分のタブ番号を知らなくてよいよう、ここ経由で遷移を依頼する。
//
//  現状の用途:
//   - ホームの「進行中の旅がありません」ボタン → マイプランタブへ切り替え、
//     プランが 1 つも無ければ新規作成シートも自動で開く。
//
//  ContentView が selectedTab をこの router にバインドし、
//  MyPlansView は pendingNewPlan を監視して新規作成シートを開く。
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    static let shared = AppRouter()

    /// 現在選択中のタブ（ContentView の並びと一致）。
    /// 0:マップ 1:近く 2:ホーム 3:祭・イベント 4:マイプラン
    @Published var selectedTab: Int = 2

    /// 開いてほしい県の詳細（Siri など外からの依頼）。ホームタブが受け取って開き、nil に戻す。
    @Published var pendingPrefecture: Prefecture?
    /// 近くタブで選んでほしい絞り込み（Siri など外からの依頼）。近くタブが受け取って nil に戻す。
    @Published var pendingNearby: NearbyRequest?
    /// 開いてほしいプラン（Siri など外からの依頼）。マイプランタブが受け取って開き、nil に戻す。
    @Published var pendingPlanID: UUID?

    /// 近くタブへの依頼。kind が nil ならすべての種類。
    struct NearbyRequest: Equatable {
        let kind: NearbySpotKind?
    }

    /// マイプランタブを開いたら新規作成シートを起動する、という予約フラグ。
    /// MyPlansView が消化したら false に戻す（多重起動を防ぐ）。
    @Published var pendingNewPlan: Bool = false

    private init() {
        #if DEBUG
        // 開発・検証用: 起動引数 `-MRInitialTab <0-4>` で最初に開くタブを指定できる。
        // シミュレータ（iPhone Duo の開閉確認など）でタブを手で切り替えずに画面を確認するため。
        // Release ビルドでは常にホームから始まる。
        if UserDefaults.standard.object(forKey: "MRInitialTab") != nil {
            let tab = UserDefaults.standard.integer(forKey: "MRInitialTab")
            if (0...4).contains(tab) { selectedTab = tab }
        }
        #endif
    }

    /// マイプランタブへ切り替える。newPlan=true なら新規作成シートも予約する。
    func openMyPlans(newPlan: Bool = false) {
        pendingNewPlan = newPlan
        selectedTab = 4
    }

    /// ホームタブで県の詳細を開く。
    func openPrefecture(_ prefecture: Prefecture) {
        selectedTab = 2
        pendingPrefecture = prefecture
    }

    /// 近くタブを開き、種類で絞り込む（nil ならすべて）。
    func openNearby(kind: NearbySpotKind?) {
        selectedTab = 1
        pendingNearby = NearbyRequest(kind: kind)
    }

    /// マイプランタブでプランの詳細を開く。
    func openPlan(_ planID: UUID) {
        pendingNewPlan = false
        selectedTab = 4
        pendingPlanID = planID
    }

    /// マップ（ルーレット）タブへ切り替える。
    /// ホームのルーレットカードから呼ぶ。統合マップの既定モードが県ルーレットなので、
    /// タブを切り替えるだけでルーレット画面に着く。
    func openRouletteMap() {
        selectedTab = 0
    }
}
