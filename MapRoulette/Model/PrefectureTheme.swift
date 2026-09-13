//
//  PrefectureTheme.swift
//  MapRoulette
//
//  ホームタブの「切り口（テーマ）別 都道府県紹介」のデータ層。
//
//  1 テーマ = 「ある視点で選んだ県の並び」。ホームはこれを見出し＋県カード横スクロールで
//  描画し、タップで県詳細（TourismDetailView）へ送る。テーマを増やしたいときは
//  このファイルに case を 1 つ足すだけで済むよう、表示ロジックから完全に独立させている。
//
//  2 系統ある:
//   - 固定指標（japanThreeViews など）… 歴史的・文献的に確立して「変わらない」もの。
//     県は手動のハードコード。subtitle に出典/根拠を添える。
//   - 可変（popular*）… 変化しうるもの。「人気の◯◯」と名付け、県は集計 or キュレーション。
//
//  設計: docs の計画（sharded-munching-snail）§アーキテクチャ。UI 非依存にしておくことで、
//  ホームの見せ方を後から差し替えても作り直しにならない。
//

import Foundation
import SwiftUI
import UIKit

enum PrefectureTheme: String, CaseIterable, Identifiable {
    // MARK: 固定指標（不変・そのまま）
    case japanThreeViews    // 日本三景
    case threeFamousOnsen   // 日本三名泉
    case threeGardens       // 日本三名園
    case threeNightViews    // 日本三大夜景

    // MARK: 可変（「人気の◯◯」/ キュレーション）
    case popularSouvenirs   // 人気のおみやげ
    case seaAndBeach        // 海・ビーチ

    var id: String { rawValue }

    /// ホームに並べる順（固定指標を先に、可変を後に）。CaseIterable の定義順をそのまま使う。
    static var displayOrder: [PrefectureTheme] { allCases }

    /// 見出しに使うローカライズキー（全 12 言語の Localizable.strings に対応キーがある）。
    var titleKey: String { "home.theme.\(rawValue).title" }

    /// 出典・根拠の一文（固定指標のみ）。可変テーマは nil。
    /// 「なぜこの県なのか」を一言で示し、恣意的でないことを伝える。
    var subtitleKey: String? {
        switch self {
        case .japanThreeViews, .threeFamousOnsen, .threeGardens, .threeNightViews:
            return "home.theme.\(rawValue).subtitle"
        case .popularSouvenirs, .seaAndBeach:
            return nil
        }
    }

    /// 見出しアイコン（SF Symbol）。
    var icon: String {
        switch self {
        case .japanThreeViews:    return "photo.on.rectangle.angled"
        case .threeFamousOnsen:   return "drop.fill"
        case .threeGardens:       return "leaf.fill"
        case .threeNightViews:    return "moon.stars.fill"
        case .popularSouvenirs:   return "gift.fill"
        case .seaAndBeach:        return "water.waves"
        }
    }

    /// このテーマ×県で「カードのビジュアルに使う代表スポット」の nameKey。
    /// 固定指標テーマは「その県で紹介しているまさにそのスポット」を返す
    /// （例: 日本三景×京都 = 天橋立）。nil のときは呼び出し側が
    /// 「県の写真つきスポットの先頭」にフォールバックする。
    ///
    /// 可変テーマ（人気の◯◯ / 海）は単一の代表スポットが定まらないので nil。
    /// 固定指標でも同県が複数テーマに出る（兵庫=三名泉[有馬]／三大夜景[摩耶山]）ため、
    /// 県だけでなくテーマも見て決める必要がある。
    func heroNameKey(for prefecture: Prefecture) -> String? {
        switch self {
        case .japanThreeViews:
            switch prefecture {
            case .miyagi:    return "attraction_matsushima"
            case .kyoto:     return "attraction_amanohashidate"
            case .hiroshima: return "attraction_itsukushima_shrine"
            default:         return nil
            }
        case .threeFamousOnsen:
            switch prefecture {
            case .gunma: return "attraction_kusatsu_onsen"
            case .gifu:  return "attraction_gero_onsen"
            case .hyogo: return "attraction_arima_onsen"
            default:     return nil
            }
        case .threeGardens:
            switch prefecture {
            case .ishikawa: return "attraction_kenrokuen"
            case .okayama:  return "attraction_korakuen"
            case .ibaraki:  return "attraction_kairakuen"
            default:        return nil
            }
        case .threeNightViews:
            switch prefecture {
            case .hokkaido: return "attraction_hakodate_mountain"
            case .hyogo:    return "attraction_mount_maya"
            case .nagasaki: return "attraction_inasayama"
            default:        return nil
            }
        case .popularSouvenirs, .seaAndBeach:
            return nil
        }
    }

    /// テーマの中身。テーマによって「県そのもの」か「もの（おみやげ品・海の名所）」かが違う。
    ///  - 固定指標（三景/三名泉/三名園/三大夜景）: その県を紹介する → .prefectures
    ///  - 人気のおみやげ / 海: 県ではなく「もの」を紹介する → .items
    enum Content {
        case prefectures([Prefecture])
        case items([ThemeItem])
    }

    var content: Content {
        switch self {
        // ── 固定指標（県を出す）──
        // 日本三景（江戸初期・林春斎）: 松島=宮城 / 天橋立=京都 / 宮島=広島
        case .japanThreeViews:
            return .prefectures([.miyagi, .kyoto, .hiroshima])
        // 日本三名泉（林羅山「天下の三名泉」）: 草津=群馬 / 下呂=岐阜 / 有馬=兵庫
        case .threeFamousOnsen:
            return .prefectures([.gunma, .gifu, .hyogo])
        // 日本三名園: 兼六園=石川 / 後楽園=岡山 / 偕楽園=茨城
        case .threeGardens:
            return .prefectures([.ishikawa, .okayama, .ibaraki])
        // 日本三大夜景: 函館山=北海道 / 摩耶山=兵庫 / 稲佐山=長崎
        case .threeNightViews:
            return .prefectures([.hokkaido, .hyogo, .nagasaki])

        // ── 可変（もの＝人気のものだけを出す。順位は付けない）──
        // 人気のおみやげ: 全県 souvenirItems のうち popularity==5（最上位＝全国区の定番）だけ。
        case .popularSouvenirs:
            return .items(PrefectureTheme.popularSouvenirItems)
        // 海: 自然名所(NatureSpot)の海カテゴリのうち popularity==5 だけ。
        case .seaAndBeach:
            return .items(PrefectureTheme.popularSeaItems)
        }
    }

    /// ホームの「おすすめ」セクションで出す定番エリア（固定・表示順）。
    /// これは根拠のあるランキングではなく、あくまで従来ホームの「おすすめ」導線用の
    /// 手動リスト（旧 HomeView.recommendedPrefectures を移設したもの）。
    /// テーマ機能（PrefectureTheme）の「人気の都道府県」は根拠が無いため廃止した。
    static let popularPrefectureList: [Prefecture] =
        [.okinawa, .fukuoka, .kyoto, .hokkaido, .osaka,
         .hiroshima, .hyogo, .aichi, .miyagi, .kanagawa]

    // MARK: - 「もの」テーマのデータ（人気=popularity 最上位だけに絞る）

    /// 人気のおみやげ: 全県の souvenirItems のうち popularity==5（＝最上位）だけ。
    /// これはアプリ内で人気度として定義済みの値を使うだけで、新たに順位は捏造しない。
    /// 並びは県の登場順（Prefecture.allCases）そのままで、順位付けはしない。
    static let popularSouvenirItems: [ThemeItem] = {
        var result: [ThemeItem] = []
        for pref in Prefecture.allCases {
            for souvenir in pref.souvenirItems where souvenir.popularity == 5 {
                result.append(ThemeItem(id: "souvenir_\(souvenir.id)",
                                        name: souvenir.name,
                                        icon: souvenir.imageSymbol,
                                        prefecture: pref,
                                        photoAssetName: SouvenirPhoto.assetName(for: souvenir.stableKey),
                                        detailTarget: .souvenir(stableKey: souvenir.stableKey)))
            }
        }
        return result
    }()

    /// 有名なビーチ（砂浜・海水浴場に限定）。全国の定番を北→南の地理順で。
    /// 既存 NatureSpot（岬・海岸・島など海全般が混在）は使わず、ビーチだけを独立定義した。
    /// 「人気」ランキングではなく「広く名の知れた定番」を順位を付けずに並べたもの。
    static let popularSeaItems: [ThemeItem] = {
        // (ローカライズキー, 所属県)。名前は Localizable.strings の beach.* を参照。
        // 高浜(五島)・水晶浜は Wikimedia に写真が無くアイコン表示になるため、
        // ホームのビーチ一覧からは外した（自然タブには sea カテゴリとして残している）。
        let beaches: [(nameKey: String, prefecture: Prefecture)] = [
            ("beach.jodogahama",   .iwate),      // 浄土ヶ浜
            ("beach.kujukurihama", .chiba),      // 九十九里浜
            ("beach.yuigahama",    .kanagawa),   // 由比ヶ浜
            ("beach.izu_shirahama", .shizuoka),  // 伊豆白浜
            ("beach.takeno",       .hyogo),      // 竹野浜
            ("beach.shirarahama",  .wakayama),   // 白良浜
            ("beach.emerald",      .okinawa),    // エメラルドビーチ
            ("beach.nishihama",    .okinawa)     // ニシ浜（波照間）
        ]
        // 自然タブに同 nameKey の海スポットがあるビーチだけ、タップ後に自然スポット詳細を開く。
        // 自然データに無いビーチ（伊豆白浜・九十九里浜など）は県詳細だけを開く（.none）。
        let natureBeachKeys = Set(
            NatureSpotDataRepository.shared.allFixedSpots
                .filter { $0.spotType == .sea }
                .map { $0.nameKey }
        )
        return beaches.map { entry in
            let target: ThemeItemDetailTarget = natureBeachKeys.contains(entry.nameKey)
                ? .natureSpot(nameKey: entry.nameKey)
                : .none
            return ThemeItem(id: entry.nameKey,
                             name: NSLocalizedString(entry.nameKey, comment: ""),
                             icon: "beach.umbrella.fill",
                             prefecture: entry.prefecture,
                             photoAssetName: BeachPhoto.assetName(for: entry.nameKey),
                             detailTarget: target)
        }
    }()
}

/// テーマが紹介する「もの」（おみやげ品・海の名所など）。
/// 県そのものではなく品や名所を出すテーマ（人気のおみやげ・海）で使う。
/// タップすると、そのものがある県の詳細（prefecture）へ遷移し、続けてその品／名所の
/// 詳細（detailTarget）まで自動で開く。
struct ThemeItem: Identifiable {
    let id: String
    let name: String            // もの名（ローカライズ済み）
    let icon: String            // 写真が無いときのフォールバック用 SF Symbol
    let prefecture: Prefecture  // タップ先の県詳細
    /// 同梱写真の Asset 名（例: "beach_nishihama"）。無ければ nil。
    /// 画像の解決は保持値ではなく計算プロパティ（photo）で表示時に行う。
    let photoAssetName: String?
    /// 県詳細を開いた直後に自動で開く、この「もの」自身の詳細。
    let detailTarget: ThemeItemDetailTarget

    /// 同梱写真（CC 表示素材）。表示時に Asset を解決する。無ければ nil → icon にフォールバック。
    var photo: Image? {
        guard let photoAssetName, UIImage(named: photoAssetName) != nil else { return nil }
        return Image(photoAssetName)
    }
}

/// テーマの「もの」カードのタップ先（県詳細を開いた後に続けて開く詳細）。
/// おみやげ品はお土産詳細、ビーチは自然スポット詳細を開く。ビーチの中には
/// アプリ内に詳細画面を持たないものもあるため .none（県詳細だけ）も用意する。
enum ThemeItemDetailTarget {
    /// お土産詳細（SouvenirItem.stableKey で県内から特定する。UUID は不安定なので使わない）。
    case souvenir(stableKey: String)
    /// 自然スポット詳細（FixedNatureSpotItem の nameKey。ビーチ = 海カテゴリ）。
    case natureSpot(nameKey: String)
    /// 詳細画面が無い（県詳細だけを開く）。
    case none
}

/// 有名なビーチの同梱写真を解決する（AttractionPhoto/SouvenirPhoto と同じ方式）。
/// beach.* キーの "." を "_" に置換したものが imageset 名。
/// 例: "beach.nishihama" → asset "beach_nishihama"（"beach_" を重ねない）。
enum BeachPhoto {
    static func assetName(for beachKey: String) -> String {
        beachKey.replacingOccurrences(of: ".", with: "_")
    }
    static func image(for beachKey: String) -> Image? {
        let asset = assetName(for: beachKey)
        guard UIImage(named: asset) != nil else { return nil }
        return Image(asset)
    }
}

extension Array {
    /// 要素を size 個ずつのまとまり（行）に分割する。テーマの 2 列グリッド化に使う。
    /// 例: [a,b,c,d,e].chunked(into: 2) == [[a,b],[c,d],[e]]
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
