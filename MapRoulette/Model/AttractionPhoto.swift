//
//  AttractionPhoto.swift
//  MapRoulette
//
//  観光スポットに紐づく「実写写真」を提供する。
//
//  写真は Assets.xcassets/Attractions/ 配下に、スポットの nameKey と
//  同名の imageset として同梱する（例: attraction_tokyo_skytree）。
//  すべて CC0（パブリックドメイン）素材のみを使用しているため、
//  クレジット表記・帰属は一切不要。API 通信も発生しない。
//
//  以前の Unsplash 版は「検索で無関係な写真が出る」「クレジット義務」で
//  削除した。本方式は人が選んだ CC0 画像を nameKey に固定で紐づけるため、
//  紐づき精度は 100%、写真が無いスポットは自動的に非表示になる。
//

import SwiftUI
import UIKit

enum AttractionPhoto {
    /// スポットの nameKey に対応する同梱画像の Asset 名を返す。
    ///
    /// 現状は「imageset 名 = nameKey」の規約なので nameKey をそのまま返すが、
    /// 命名規則を将来変えても呼び出し側を触らずに済むよう一段挟んでいる。
    private static func assetName(for nameKey: String) -> String {
        nameKey
    }

    /// そのスポットに同梱写真があるかどうか。
    /// 無ければ写真セクションを丸ごと非表示にする判定に使う。
    static func hasPhoto(for nameKey: String) -> Bool {
        UIImage(named: assetName(for: nameKey)) != nil
    }

    /// そのスポットの同梱写真。無ければ nil。
    static func image(for nameKey: String) -> Image? {
        guard UIImage(named: assetName(for: nameKey)) != nil else { return nil }
        return Image(assetName(for: nameKey))
    }

    /// 県内で「同梱写真を持つスポット」だけを、元の並び順を保って返す。
    /// 県詳細画面のフォトカルーセルに流し込む用途。写真が 1 枚も無ければ空配列。
    static func photographedAttractions(in prefecture: Prefecture) -> [LocalizedAttractionLocation] {
        prefecture.tourismInfo.attractions.filter { hasPhoto(for: $0.nameKey) }
    }
}
