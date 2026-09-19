//
//  CategoryPhoto.swift
//  MapRoulette
//
//  グルメ・自然スポット・お祭りに紐づく「実写写真」を提供する。
//  観光スポットの AttractionPhoto と同じ方式を、そのまま横展開したもの。
//
//  規約:
//   - 写真は Assets.xcassets/<カテゴリ>/ 配下に imageset として同梱する。
//   - imageset 名は「安定キー」から機械的に決まる（下の assetName を参照）。
//   - ライセンスは CC0 / CC BY のみ。SA・GFDL・NC・ND は一切使わない。
//     CC BY の帰属は photo_credits.json → Settings.bundle/PhotoCredits.plist
//     （iOS 設定アプリの「写真クレジット」画面）で一括表示する。
//   - 写真が無いキーは自動的に「写真なし」になり、各詳細画面は従来の
//     カラーヘッダーにフォールバックする。埋まっていなくても破綻しない。
//
//  お土産（SouvenirPhoto）は商品パッケージの著作権に触れるため、この横展開の
//  対象から外している。
//

import SwiftUI
import UIKit

// MARK: - グルメ

/// グルメ品の同梱写真。キーは GourmetItem.nameKey（例: "gourmet_genghis_khan"）で、
/// そのまま imageset 名になる（AttractionPhoto と同じ「キー == imageset 名」の規約）。
///
/// 品そのもの（料理）の写真だけを使う。店舗の看板・ロゴ・メニュー表が主役の写真は、
/// 商標／著作物が写り込むため採用しない。
enum GourmetPhoto {
    static func assetName(for nameKey: String) -> String { nameKey }

    static func hasPhoto(for nameKey: String) -> Bool {
        UIImage(named: assetName(for: nameKey)) != nil
    }

    static func image(for nameKey: String) -> Image? {
        guard hasPhoto(for: nameKey) else { return nil }
        return Image(assetName(for: nameKey))
    }
}

// MARK: - 自然スポット

/// 自然スポットの同梱写真。キーは FixedNatureSpotItem.nameKey
/// （例: "nightview_hakodate_name"）。末尾の "_name" は imageset 名では落とす。
/// 例: "nightview_hakodate_name" → asset "nature_nightview_hakodate"。
///
/// "nature_" を前置するのは、自然の nameKey（nightview_* / starry_* / sea_* /
/// camping_*）が観光スポットの attraction_* と違って接頭辞が分散しており、
/// Assets 内での所属が名前から読み取れなくなるのを避けるため。
enum NaturePhoto {
    static func assetName(for nameKey: String) -> String {
        var base = nameKey
        if base.hasSuffix("_name") {
            base = String(base.dropLast("_name".count))
        }
        return "nature_" + base
    }

    static func hasPhoto(for nameKey: String) -> Bool {
        UIImage(named: assetName(for: nameKey)) != nil
    }

    static func image(for nameKey: String) -> Image? {
        guard hasPhoto(for: nameKey) else { return nil }
        return Image(assetName(for: nameKey))
    }
}

// MARK: - お祭り

/// お祭りの同梱写真。
///
/// お祭りのデータ（FestivalItem / OtherFestivalItem / IntegratedFestivalItem）は
/// 名前をローカライズ済みの `name: String` として持っており、安定キーを持たない。
/// 200 件超の定義を書き換えずに済ませるため、表示名からローカライズキーを
/// 逆引きして安定キーを得る（LocalizationMatcher と同じ仕組み）。
///
/// 例: name "郡上おどり" → key "gujo_odori_name" → asset "festival_gujo_odori"。
///
/// 祭りの写真は人物が大きく写り込むものが多い。肖像・被写体の権利に配慮し、
/// 特定個人が主役になっている写真は採用しない（群衆・山車・灯籠など、
/// 祭りの構造物や全景が主役のものを使う）。
enum FestivalPhoto {
    /// 祭り名（表示言語は問わない）から imageset 名を決める。
    /// 対応するローカライズキーが見つからない場合は nil。
    static func assetName(forFestivalName name: String) -> String? {
        guard let key = FestivalNameKeyIndex.key(forDisplayName: name) else { return nil }
        let base = key.hasSuffix("_name") ? String(key.dropLast("_name".count)) : key
        return "festival_" + base
    }

    static func hasPhoto(forFestivalName name: String) -> Bool {
        guard let asset = assetName(forFestivalName: name) else { return false }
        return UIImage(named: asset) != nil
    }

    static func image(forFestivalName name: String) -> Image? {
        guard let asset = assetName(forFestivalName: name),
              UIImage(named: asset) != nil else { return nil }
        return Image(asset)
    }
}

/// 「祭りの表示名 → その名前を生む `*_name` ローカライズキー」の逆引き索引。
///
/// LocalizationMatcher と同じく全対応言語の Localizable.strings を読むが、
/// こちらは「キーそのもの」が欲しいので別建てにしている。索引は祭り名のキー
/// （`*_name` で終わり、かつ `_description` 等ではないもの）だけに絞る。
private enum FestivalNameKeyIndex {
    /// アプリが対応する言語コード（*.lproj に対応）。
    /// 端末がどの言語でも、その言語の表示名からキーを引けるようにする。
    private static let languageCodes = [
        "ja", "en", "ko", "zh-Hans", "zh-Hant", "zh-HK",
        "de", "es", "fr", "id", "th", "vi"
    ]

    /// 表示名 → ローカライズキー。同名の祭りが複数県にある場合は先勝ちになるが、
    /// その場合どちらのキーを引いても「同名の祭り」なので実害はない。
    ///
    /// なお索引は `*_name` キー全体（祭り以外も含む）を舐めるため、祭り以外と
    /// 表示名が衝突する可能性は理屈の上ではある（現状の唯一の同名は
    /// starry_erimo / sea_erimo_cape = 「襟裳岬」で、どちらも祭りではない）。
    /// 衝突しても「祭りの写真が出ない」だけで、誤った写真は出ない
    /// ——引いたキーから作る asset 名は祭り用の imageset には存在しないため。
    private static let nameToKey: [String: String] = {
        var result: [String: String] = [:]
        for code in languageCodes {
            guard let url = Bundle.main.url(forResource: "Localizable",
                                            withExtension: "strings",
                                            subdirectory: nil,
                                            localization: code),
                  let dict = NSDictionary(contentsOf: url) as? [String: String] else {
                continue
            }
            for (key, value) in dict where key.hasSuffix("_name") {
                if result[value] == nil {
                    result[value] = key
                }
            }
        }
        return result
    }()

    static func key(forDisplayName name: String) -> String? {
        nameToKey[name]
    }
}
