//
//  SettlementCalculator.swift
//  MapRoulette
//
//  割り勘の精算ロジック。各項目の「支払者」「分担者」から各メンバーの純収支を求め、
//  送金回数を最小化した「誰が誰にいくら払うか」のリストを算出する。
//
//  分担額は切り捨てで各分担者に配り、割り切れない端数は支払者の受け取りに寄せる
//  （合計が必ず一致する）。
//

import Foundation

/// メンバー 1 人分の収支。
/// balance > 0: 受け取る（立て替え超過）／ balance < 0: 支払う。
struct MemberBalance: Identifiable {
    let id: UUID          // メンバー ID
    let name: String
    let balance: Int      // 純収支（円）
}

/// 1 件の送金（from が to へ amount 円払う）。
struct SettlementTransfer: Identifiable {
    let id = UUID()
    let fromID: UUID
    let fromName: String
    let toID: UUID
    let toName: String
    let amount: Int
}

enum SettlementCalculator {

    /// プランの精算を計算する。
    /// - Returns: (各メンバーの収支, 送金リスト)。メンバーが居ない／集計不能なら空。
    static func settle(for plan: TravelPlan) -> (balances: [MemberBalance], transfers: [SettlementTransfer]) {
        guard !plan.members.isEmpty else { return ([], []) }

        // メンバー ID → 純収支（銭単位ではなく円の整数で扱う）
        var net: [UUID: Int] = [:]
        for m in plan.members { net[m.id] = 0 }

        // 割り勘対象＝費用一覧に含める項目のうち、金額・支払者・分担者が揃うもの。
        for item in plan.costItems {
            guard let cost = item.cost, cost > 0, let payer = item.payerID,
                  net[payer] != nil else { continue }
            let sharers = plan.effectiveSplitMemberIDs(for: item)
            guard !sharers.isEmpty else { continue }

            let base = cost / sharers.count      // 1 人あたり（切り捨て）
            let remainder = cost - base * sharers.count   // 端数（支払者が吸収）

            // 支払者は全額を立て替え（+cost）
            net[payer, default: 0] += cost
            // 各分担者は自分の負担分だけ引く
            for s in sharers {
                net[s, default: 0] -= base
            }
            // 端数は支払者の負担に足す（結果として支払者の受け取りが端数分減る）
            net[payer, default: 0] -= remainder
        }

        // 収支リスト（メンバー登場順）
        let balances = plan.members.map { m in
            MemberBalance(id: m.id, name: m.name, balance: net[m.id] ?? 0)
        }

        let transfers = minimizeTransfers(net: net, plan: plan)
        return (balances, transfers)
    }

    /// 純収支から送金リストを Greedy 法で最小化する。
    /// 毎回「最大の債務者」から「最大の債権者」へまとめて払い、片方を精算して繰り返す。
    private static func minimizeTransfers(net: [UUID: Int], plan: TravelPlan) -> [SettlementTransfer] {
        // 0 でない収支だけを取り出す（(id, amount)）
        var debtors: [(id: UUID, amount: Int)] = []   // amount < 0
        var creditors: [(id: UUID, amount: Int)] = [] // amount > 0
        for (id, amount) in net {
            if amount < 0 { debtors.append((id, amount)) }
            else if amount > 0 { creditors.append((id, amount)) }
        }
        guard !debtors.isEmpty, !creditors.isEmpty else { return [] }

        // 金額の大きい順に処理すると送金回数が減りやすい
        debtors.sort { $0.amount < $1.amount }        // より負（大きい債務）が先頭
        creditors.sort { $0.amount > $1.amount }      // より正（大きい債権）が先頭

        var result: [SettlementTransfer] = []
        var di = 0, ci = 0
        while di < debtors.count && ci < creditors.count {
            let debt = -debtors[di].amount            // 正の値に
            let credit = creditors[ci].amount
            let pay = min(debt, credit)

            if pay > 0 {
                result.append(SettlementTransfer(
                    fromID: debtors[di].id,
                    fromName: plan.memberName(for: debtors[di].id) ?? "",
                    toID: creditors[ci].id,
                    toName: plan.memberName(for: creditors[ci].id) ?? "",
                    amount: pay
                ))
            }

            debtors[di].amount += pay
            creditors[ci].amount -= pay
            if debtors[di].amount == 0 { di += 1 }
            if creditors[ci].amount == 0 { ci += 1 }
        }
        return result
    }

    /// 精算が意味を持つ状態か（メンバーが居て、支払者・分担が揃う金額付き項目が 1 件以上ある）。
    static func hasSettlementData(for plan: TravelPlan) -> Bool {
        guard !plan.members.isEmpty else { return false }
        return plan.costItems.contains { item in
            guard let cost = item.cost, cost > 0, item.payerID != nil else { return false }
            return !plan.effectiveSplitMemberIDs(for: item).isEmpty
        }
    }
}
