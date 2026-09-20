//
//  RouletteEntryRow.swift
//  MapRoulette
//
//  ホームの「マップタブ（＝県ルーレット）」への導線。プラン導線の下に置く。
//
//  見せ方の方針:
//   - 見た目（ブランドグラデの帯・白文字・角丸・影、白の扇形/リング/ハブの盤）は
//     元のカード版のまま。常設の遷移リンクなので、変えたのは「大きさ」だけ——
//     盤を 58 → 24pt、帯を 1 行ぶんの高さに詰めて、場所を取りすぎないようにしている。
//   - 「ルーレット機能だと分かる」ことは盤で担保する。盤の形（扇形＋指針）と、
//     表示時に 1 回だけ回って止まる動きがあれば、24pt でもルーレットだと読める。
//   - 文字は 1 行。帯全体がタップ領域で、押せることは chevron で示す。
//

import SwiftUI

/// ホームのルーレット導線（1 行のテキスト行）。タップでマップ（ルーレット）タブへ。
struct RouletteEntryRow: View {
    let action: () -> Void

    /// 盤の回転角。onAppear で 1 回だけ回して止める（spinOnce）。
    @State private var angle: Double = 0
    /// 押下中のハイライト。
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                rouletteDial

                Text(NSLocalizedString("home.roulette.title", comment: ""))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            // 帯の見た目は元のカード版のまま（ブランドグラデ＋角丸＋影）。
            // 高さだけを 1 行ぶんに詰めている。
            .background(
                ZStack {
                    PlanTheme.brandGradient
                    // 盤の側に光をためて、視線をルーレットへ寄せる。
                    RadialGradient(
                        colors: [.white.opacity(0.22), .clear],
                        center: .init(x: 0.08, y: 0.5),
                        startRadius: 2,
                        endRadius: 80
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: PlanTheme.primary.opacity(0.28), radius: 8, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain)
        // buttonStyle(.plain) は押下状態を渡さないので、長押しジェスチャで拾う。
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(NSLocalizedString("home.roulette.title", comment: ""))
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - ルーレット盤

    /// 回転する円盤＋固定の指針。円盤だけを回し、指針とハブは止めておくことで
    /// 「盤が回って指針の位置で止まる」＝ルーレットだと分かる形にする。
    ///
    /// 見た目は元のカード版のまま（白の扇形・白いリング・白いハブ）で、
    /// 大きさだけ行に合う 24pt に縮めている。
    /// 地のオレンジは帯（カード背景）が持つので、盤は自前の塗りを持たない。
    private var rouletteDial: some View {
        ZStack {
            RouletteWheel(segmentCount: Self.segmentCount)
                .rotationEffect(.degrees(angle))

            // 外周のリング
            Circle()
                .stroke(Color.white.opacity(0.9), lineWidth: 1)

            // ハブ（中央の白丸）
            Circle()
                .fill(Color.white)
                .frame(width: Self.hubSize, height: Self.hubSize)

            // 指針（上部・固定）
            Triangle()
                .fill(Color.white)
                .frame(width: 6, height: 5)
                .offset(y: -Self.dialSize / 2 + 1)
        }
        .frame(width: Self.dialSize, height: Self.dialSize)
        .onAppear { spinOnce() }
    }

    /// 表示のたびに 1 回だけ回して止める（回しっぱなしにしない）。
    /// 減速して止まる easeOut にすることで、ただ回る円ではなく
    /// 「ルーレットが出目に着地した」動きになる。
    /// 止まる角度は扇形の境界を避けて半コマぶんずらし、指針が区画の真ん中を指すようにする。
    private func spinOnce() {
        let step = 360.0 / Double(Self.segmentCount)
        let landing = Double(Int.random(in: 0..<Self.segmentCount)) * step + step / 2
        withAnimation(.easeOut(duration: Self.spinDuration)) {
            // 2 周ぶん回してから着地させる（1 周だと勢いが出ない）。
            angle = 720 + landing
        }
    }

    /// 回す時間。長いと目障りなので 2 秒で止める。
    private static let spinDuration: Double = 2.0

    /// 盤の大きさ。行のアイコンとして置くので、文字（15pt）より一回り大きい程度に留める。
    private static let dialSize: CGFloat = 24
    /// 中央のハブ（白丸）の径。
    /// 元のカード版は 58pt の盤に 34pt（≒6 割）だったが、その比率をこの径で使うと
    /// 扇形が 5pt の細い輪になり、8 分割が読めなくなる。
    /// 扇形が見える幅を残せる 10pt に留める。
    private static let hubSize: CGFloat = 10
    /// 扇形の数。元のカード版と同じ 8 枚。
    private static let segmentCount = 8
}

/// ルーレットの盤面（等分した扇形を交互の濃さで塗る）。
/// 下にブランド色の円が敷かれている前提で、白の濃淡で塗る。
private struct RouletteWheel: View {
    let segmentCount: Int

    var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width, geo.size.height) / 2
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let step = 360.0 / Double(segmentCount)

            ZStack {
                ForEach(0..<segmentCount, id: \.self) { index in
                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(Double(index) * step - 90),
                            endAngle: .degrees(Double(index + 1) * step - 90),
                            clockwise: false
                        )
                        path.closeSubpath()
                    }
                    .fill(index.isMultiple(of: 2)
                          ? Color.white.opacity(0.28)
                          : Color.white.opacity(0.08))
                }
            }
        }
    }
}

/// 指針用の上向き三角形。
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    RouletteEntryRow(action: {})
        .padding(20)
}
