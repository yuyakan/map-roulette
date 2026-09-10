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

    /// マイプランタブを開いたら新規作成シートを起動する、という予約フラグ。
    /// MyPlansView が消化したら false に戻す（多重起動を防ぐ）。
    @Published var pendingNewPlan: Bool = false

    private init() {}

    /// マイプランタブへ切り替える。newPlan=true なら新規作成シートも予約する。
    func openMyPlans(newPlan: Bool = false) {
        pendingNewPlan = newPlan
        selectedTab = 4
    }
}
