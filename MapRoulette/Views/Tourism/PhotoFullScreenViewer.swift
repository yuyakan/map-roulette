//
//  PhotoFullScreenViewer.swift
//  MapRoulette
//
//  県詳細画面のフォトカルーセルから、写真を全画面で表示するビューア。
//  - 黒背景に画像を全体が収まるように表示（scaledToFit）
//  - 左右スワイプで同じ県の他の写真へ切り替え（TabView のページング）
//  - ピンチでズーム、ダブルタップでズームのトグル
//  - 右上の閉じるボタンで閉じる
//

import SwiftUI

struct PhotoFullScreenViewer: View {
    /// 表示対象の写真つきスポット一覧（カルーセルと同じ並び）。
    let attractions: [LocalizedAttractionLocation]
    /// 最初に表示するスポットの index。
    @State private var selection: Int
    @Environment(\.dismiss) private var dismiss

    init(attractions: [LocalizedAttractionLocation], startIndex: Int) {
        self.attractions = attractions
        _selection = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $selection) {
                ForEach(Array(attractions.enumerated()), id: \.offset) { index, attraction in
                    ZoomablePhoto(image: AttractionPhoto.image(for: attraction.nameKey))
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: attractions.count > 1 ? .automatic : .never))

            // スポット名（下部・複数枚のときの現在位置も添える）
            VStack {
                Spacer()
                if selection < attractions.count {
                    Text(attractions[selection].name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.black.opacity(0.5)))
                        .padding(.bottom, 40)
                }
            }
            .allowsHitTesting(false)

            // 閉じるボタン
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Circle().fill(.black.opacity(0.5)))
            }
            .padding(.top, 8)
            .padding(.trailing, 16)
        }
    }
}

/// ピンチズーム／ダブルタップズームに対応した 1 枚の写真。
private struct ZoomablePhoto: View {
    let image: Image?

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(magnification)
                    .simultaneousGesture(scale > 1 ? drag : nil)
                    .onTapGesture(count: 2) { toggleZoom() }
            } else {
                // 画像が無い場合のプレースホルダ（通常は起きない）
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }

    private var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(lastScale * value, 1), 4)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1 { resetOffset() }
            }
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private func toggleZoom() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if scale > 1 {
                scale = 1; lastScale = 1
                resetOffset()
            } else {
                scale = 2.5; lastScale = 2.5
            }
        }
    }

    private func resetOffset() {
        offset = .zero
        lastOffset = .zero
    }
}
