//
//  PlanTheme.swift
//  MapRoulette
//
//  旅行プラン機能の共通デザインテーマ。
//  ブランドカラー（オレンジ→コーラル）と共通スタイルを一元管理し、
//  画面間の統一感を担保する。
//

import SwiftUI

enum PlanTheme {
    // MARK: - ブランドカラー
    /// メインのオレンジ（Assets: selectedColor2 #FF5100 相当）
    static let primary = Color(red: 1.0, green: 0.32, blue: 0.0)
    /// アクセントのコーラル（Assets: selectedColor #FF5F73 相当）
    static let accent = Color(red: 1.0, green: 0.37, blue: 0.45)

    /// ブランドの基調グラデーション（オレンジ→コーラル）
    static let brandGradient = LinearGradient(
        colors: [primary, accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// やわらかい背景グラデーション
    static let backgroundGradient = LinearGradient(
        colors: [
            primary.opacity(0.06),
            accent.opacity(0.04),
            Color(.systemGroupedBackground)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardCornerRadius: CGFloat = 20
    static let cardShadow = Color.black.opacity(0.06)

    /// カテゴリごとのアクセント色（ピンを地図・カードで揃える）
    static func color(for category: PlanItemCategory) -> Color {
        switch category {
        case .attraction: return Color(red: 0.30, green: 0.55, blue: 0.98)
        case .gourmet:    return Color(red: 0.95, green: 0.45, blue: 0.15)
        case .onsen:      return Color(red: 0.95, green: 0.35, blue: 0.45)
        case .festival:   return Color(red: 0.70, green: 0.40, blue: 0.95)
        case .nature:     return Color(red: 0.25, green: 0.70, blue: 0.45)
        case .souvenir:   return Color(red: 0.90, green: 0.55, blue: 0.20)
        case .hotel:      return Color(red: 0.45, green: 0.50, blue: 0.85)
        case .transport:  return Color(red: 0.30, green: 0.65, blue: 0.70)
        case .other:      return Color(red: 0.55, green: 0.55, blue: 0.60)
        }
    }
}

// MARK: - 共通カード装飾

extension View {
    /// ブランド統一のカード見た目（白地・角丸・やわらかい影）
    func planCard(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: PlanTheme.cardCornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .shadow(color: PlanTheme.cardShadow, radius: 10, x: 0, y: 4)
    }
}

// MARK: - ブランドボタンスタイル

struct PlanPrimaryButtonStyle: ButtonStyle {
    /// 塗りの色。nil のときはブランドグラデーション（既定）。
    /// 画面のカテゴリ色に合わせたいときだけ指定する。
    var tint: Color? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(fill)
            )
            .shadow(color: (tint ?? PlanTheme.primary).opacity(0.3), radius: 8, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var fill: AnyShapeStyle {
        if let tint {
            return AnyShapeStyle(tint)
        } else {
            return AnyShapeStyle(PlanTheme.brandGradient)
        }
    }
}
