//
//  Omiyage.swift
//  MapRoulette
//
//  Created by 上別縄祐也 on 2025/07/27.
//

import SwiftUI

struct SouvenirItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let category: SouvenirCategory
    let imageSymbol: String
    let price: String
    let bestSeason: String
    let popularity: Int // 1-5
}

enum SouvenirCategory: String, CaseIterable {
    case sweets = "souvenirCategory.sweets"
    case food = "souvenirCategory.food"
    case crafts = "souvenirCategory.crafts"
    case drinks = "souvenirCategory.drinks"
    case textiles = "souvenirCategory.textiles"
    case ceramics = "souvenirCategory.ceramics"
    case regional = "souvenirCategory.regional"
    
    /// カテゴリ色。白文字を載せても読めるよう明度・彩度を手調整した値に統一。
    var color: Color {
        switch self {
        case .sweets:   return Color(red: 0.86, green: 0.35, blue: 0.58) // ピンク
        case .food:     return Color(red: 0.93, green: 0.45, blue: 0.13) // オレンジ
        case .crafts:   return Color(red: 0.60, green: 0.42, blue: 0.28) // ブラウン
        case .drinks:   return Color(red: 0.55, green: 0.38, blue: 0.78) // パープル
        case .textiles: return Color(red: 0.16, green: 0.50, blue: 0.85) // ブルー
        case .ceramics: return Color(red: 0.45, green: 0.45, blue: 0.50) // グレー
        case .regional: return Color(red: 0.24, green: 0.62, blue: 0.40) // グリーン
        }
    }
    
    var icon: String {
        switch self {
        case .sweets: return "birthday.cake.fill"
        case .food: return "bag.fill"
        case .crafts: return "hammer.fill"
        case .drinks: return "wineglass.fill"
        case .textiles: return "tshirt.fill"
        case .ceramics: return "cup.and.saucer.fill"
        case .regional: return "star.fill"
        }
    }
}

extension Prefecture {
    var souvenirItems: [SouvenirItem] {
        switch self {
        case .oita:
            return [
                SouvenirItem(
                    name: NSLocalizedString("oita.zabieru.name", comment: ""),
                    description: NSLocalizedString("oita.zabieru.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("oita.zabieru.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("oita.kojono_tsuki.name", comment: ""),
                    description: NSLocalizedString("oita.kojono_tsuki.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "moon.fill",
                    price: NSLocalizedString("oita.kojono_tsuki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("oita.yaseuma.name", comment: ""),
                    description: NSLocalizedString("oita.yaseuma.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "minus.rectangle.fill",
                    price: NSLocalizedString("oita.yaseuma.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("oita.gomadashi_udon.name", comment: ""),
                    description: NSLocalizedString("oita.gomadashi_udon.description", comment: ""),
                    category: .food,
                    imageSymbol: "bowl.fill",
                    price: NSLocalizedString("oita.gomadashi_udon.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("oita.onsen_goods.name", comment: ""),
                    description: NSLocalizedString("oita.onsen_goods.description", comment: ""),
                    category: .regional,
                    imageSymbol: "drop.fill",
                    price: NSLocalizedString("oita.onsen_goods.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .yamanashi:
            return [
                SouvenirItem(
                    name: NSLocalizedString("yamanashi.kikyo_shingen_mochi.name", comment: ""),
                    description: NSLocalizedString("yamanashi.kikyo_shingen_mochi.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("yamanashi.kikyo_shingen_mochi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamanashi.kikyo_shingen_soft.name", comment: ""),
                    description: NSLocalizedString("yamanashi.kikyo_shingen_soft.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "snowflake",
                    price: NSLocalizedString("yamanashi.kikyo_shingen_soft.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamanashi.budo_no_sato.name", comment: ""),
                    description: NSLocalizedString("yamanashi.budo_no_sato.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("yamanashi.budo_no_sato.price", comment: ""),
                    bestSeason: NSLocalizedString("common.autumn", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamanashi.fuji_no_shirayuki.name", comment: ""),
                    description: NSLocalizedString("yamanashi.fuji_no_shirayuki.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "mountain.2.fill",
                    price: NSLocalizedString("yamanashi.fuji_no_shirayuki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamanashi.koshu_wine.name", comment: ""),
                    description: NSLocalizedString("yamanashi.koshu_wine.description", comment: ""),
                    category: .drinks,
                    imageSymbol: "wineglass.fill",
                    price: NSLocalizedString("yamanashi.koshu_wine.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .okayama:
            return [
                SouvenirItem(
                    name: NSLocalizedString("okayama.ote_manju.name", comment: ""),
                    description: NSLocalizedString("okayama.ote_manju.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("okayama.ote_manju.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("okayama.kibi_dango.name", comment: ""),
                    description: NSLocalizedString("okayama.kibi_dango.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("okayama.kibi_dango.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("okayama.chofu.name", comment: ""),
                    description: NSLocalizedString("okayama.chofu.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("okayama.chofu.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("okayama.hakujuji_waffle.name", comment: ""),
                    description: NSLocalizedString("okayama.hakujuji_waffle.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "square.grid.3x3.fill",
                    price: NSLocalizedString("okayama.hakujuji_waffle.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("okayama.bizen_yaki.name", comment: ""),
                    description: NSLocalizedString("okayama.bizen_yaki.description", comment: ""),
                    category: .ceramics,
                    imageSymbol: "cup.and.saucer.fill",
                    price: NSLocalizedString("okayama.bizen_yaki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
        case .hiroshima:
            return [
                SouvenirItem(
                    name: NSLocalizedString("hiroshima.momiji_manju.name", comment: ""),
                    description: NSLocalizedString("hiroshima.momiji_manju.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("hiroshima.momiji_manju.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("hiroshima.nama_momiji.name", comment: ""),
                    description: NSLocalizedString("hiroshima.nama_momiji.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("hiroshima.nama_momiji.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("hiroshima.nishikido_momiji.name", comment: ""),
                    description: NSLocalizedString("hiroshima.nishikido_momiji.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("hiroshima.nishikido_momiji.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("hiroshima.kawadori_mochi.name", comment: ""),
                    description: NSLocalizedString("hiroshima.kawadori_mochi.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("hiroshima.kawadori_mochi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("hiroshima.hiroshima_na.name", comment: ""),
                    description: NSLocalizedString("hiroshima.hiroshima_na.description", comment: ""),
                    category: .food,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("hiroshima.hiroshima_na.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .yamaguchi:
            return [
                SouvenirItem(
                    name: NSLocalizedString("yamaguchi.mameshiro.name", comment: ""),
                    description: NSLocalizedString("yamaguchi.mameshiro.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("yamaguchi.mameshiro.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamaguchi.uiro.name", comment: ""),
                    description: NSLocalizedString("yamaguchi.uiro.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("yamaguchi.uiro.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamaguchi.tsuki_de_hirotta_tamago.name", comment: ""),
                    description: NSLocalizedString("yamaguchi.tsuki_de_hirotta_tamago.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("yamaguchi.tsuki_de_hirotta_tamago.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamaguchi.hagi_yaki.name", comment: ""),
                    description: NSLocalizedString("yamaguchi.hagi_yaki.description", comment: ""),
                    category: .ceramics,
                    imageSymbol: "cup.and.saucer.fill",
                    price: NSLocalizedString("yamaguchi.hagi_yaki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamaguchi.natsu_mikan_goods.name", comment: ""),
                    description: NSLocalizedString("yamaguchi.natsu_mikan_goods.description", comment: ""),
                    category: .food,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("yamaguchi.natsu_mikan_goods.price", comment: ""),
                    bestSeason: NSLocalizedString("common.summer", comment: ""),
                    popularity: 3
                )
            ]
            
        case .tokushima:
            return [
                SouvenirItem(
                    name: NSLocalizedString("tokushima.kincho_manju.name", comment: ""),
                    description: NSLocalizedString("tokushima.kincho_manju.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("tokushima.kincho_manju.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tokushima.potelet.name", comment: ""),
                    description: NSLocalizedString("tokushima.potelet.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("tokushima.potelet.price", comment: ""),
                    bestSeason: NSLocalizedString("common.autumn", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tokushima.wasanbon.name", comment: ""),
                    description: NSLocalizedString("tokushima.wasanbon.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "square.fill",
                    price: NSLocalizedString("tokushima.wasanbon.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tokushima.ai_no_sato.name", comment: ""),
                    description: NSLocalizedString("tokushima.ai_no_sato.description", comment: ""),
                    category: .textiles,
                    imageSymbol: "tshirt.fill",
                    price: NSLocalizedString("tokushima.ai_no_sato.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tokushima.awa_odori_goods.name", comment: ""),
                    description: NSLocalizedString("tokushima.awa_odori_goods.description", comment: ""),
                    category: .regional,
                    imageSymbol: "figure.dance",
                    price: NSLocalizedString("tokushima.awa_odori_goods.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .kagawa:
            return [
                SouvenirItem(
                    name: NSLocalizedString("kagawa.meibutsu_kamado.name", comment: ""),
                    description: NSLocalizedString("kagawa.meibutsu_kamado.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("kagawa.meibutsu_kamado.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("kagawa.oiri.name", comment: ""),
                    description: NSLocalizedString("kagawa.oiri.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("kagawa.oiri.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("kagawa.kyu_man.name", comment: ""),
                    description: NSLocalizedString("kagawa.kyu_man.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("kagawa.kyu_man.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("kagawa.honetsuki_tori_senbei.name", comment: ""),
                    description: NSLocalizedString("kagawa.honetsuki_tori_senbei.description", comment: ""),
                    category: .food,
                    imageSymbol: "bird.fill",
                    price: NSLocalizedString("kagawa.honetsuki_tori_senbei.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("kagawa.olive_goods.name", comment: ""),
                    description: NSLocalizedString("kagawa.olive_goods.description", comment: ""),
                    category: .food,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("kagawa.olive_goods.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .ehime:
            return [
                SouvenirItem(
                    name: NSLocalizedString("ehime.botchan_dango.name", comment: ""),
                    description: NSLocalizedString("ehime.botchan_dango.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("ehime.botchan_dango.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("ehime.tart.name", comment: ""),
                    description: NSLocalizedString("ehime.tart.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("ehime.tart.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("ehime.botemu.name", comment: ""),
                    description: NSLocalizedString("ehime.botemu.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "heart.fill",
                    price: NSLocalizedString("ehime.botemu.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("ehime.imabari_towel.name", comment: ""),
                    description: NSLocalizedString("ehime.imabari_towel.description", comment: ""),
                    category: .textiles,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("ehime.imabari_towel.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("ehime.tobe_yaki.name", comment: ""),
                    description: NSLocalizedString("ehime.tobe_yaki.description", comment: ""),
                    category: .ceramics,
                    imageSymbol: "cup.and.saucer.fill",
                    price: NSLocalizedString("ehime.tobe_yaki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .kochi:
            return [
                SouvenirItem(
                    name: NSLocalizedString("kochi.mille_biscuit.name", comment: ""),
                    description: NSLocalizedString("kochi.mille_biscuit.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.grid.3x3.fill",
                    price: NSLocalizedString("kochi.mille_biscuit.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("kochi.imo_kenpi.name", comment: ""),
                    description: NSLocalizedString("kochi.imo_kenpi.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "minus.rectangle.fill",
                    price: NSLocalizedString("kochi.imo_kenpi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("kochi.tosa_nikki.name", comment: ""),
                    description: NSLocalizedString("kochi.tosa_nikki.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "book.fill",
                    price: NSLocalizedString("kochi.tosa_nikki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("kochi.kanzashi.name", comment: ""),
                    description: NSLocalizedString("kochi.kanzashi.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "sparkles",
                    price: NSLocalizedString("kochi.kanzashi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("kochi.tosa_washi.name", comment: ""),
                    description: NSLocalizedString("kochi.tosa_washi.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "doc.fill",
                    price: NSLocalizedString("kochi.tosa_washi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .fukuoka:
            return [
                SouvenirItem(
                    name: NSLocalizedString("fukuoka.hakata_torimon.name", comment: ""),
                    description: NSLocalizedString("fukuoka.hakata_torimon.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("fukuoka.hakata_torimon.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukuoka.hiyoko.name", comment: ""),
                    description: NSLocalizedString("fukuoka.hiyoko.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "bird.fill",
                    price: NSLocalizedString("fukuoka.hiyoko.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukuoka.tirolian.name", comment: ""),
                    description: NSLocalizedString("fukuoka.tirolian.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "minus.rectangle.fill",
                    price: NSLocalizedString("fukuoka.tirolian.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukuoka.hakata_no_onna.name", comment: ""),
                    description: NSLocalizedString("fukuoka.hakata_no_onna.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "heart.fill",
                    price: NSLocalizedString("fukuoka.hakata_no_onna.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukuoka.mentaiko.name", comment: ""),
                    description: NSLocalizedString("fukuoka.mentaiko.description", comment: ""),
                    category: .food,
                    imageSymbol: "fish.fill",
                    price: NSLocalizedString("fukuoka.mentaiko.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukuoka.hakata_ori.name", comment: ""),
                    description: NSLocalizedString("fukuoka.hakata_ori.description", comment: ""),
                    category: .textiles,
                    imageSymbol: "tshirt.fill",
                    price: NSLocalizedString("fukuoka.hakata_ori.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .saga:
            return [
                SouvenirItem(
                    name: NSLocalizedString("saga.maru_boro.name", comment: ""),
                    description: NSLocalizedString("saga.maru_boro.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("saga.maru_boro.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("saga.ikkoko.name", comment: ""),
                    description: NSLocalizedString("saga.ikkoko.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("saga.ikkoko.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("saga.shoro_manju.name", comment: ""),
                    description: NSLocalizedString("saga.shoro_manju.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("saga.shoro_manju.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("saga.ogi_yokan.name", comment: ""),
                    description: NSLocalizedString("saga.ogi_yokan.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("saga.ogi_yokan.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("saga.arita_yaki.name", comment: ""),
                    description: NSLocalizedString("saga.arita_yaki.description", comment: ""),
                    category: .ceramics,
                    imageSymbol: "cup.and.saucer.fill",
                    price: NSLocalizedString("saga.arita_yaki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .nagasaki:
            return [
                SouvenirItem(
                    name: NSLocalizedString("nagasaki.fukusaya_castella.name", comment: ""),
                    description: NSLocalizedString("nagasaki.fukusaya_castella.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("nagasaki.fukusaya_castella.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("nagasaki.kurusu.name", comment: ""),
                    description: NSLocalizedString("nagasaki.kurusu.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "plus",
                    price: NSLocalizedString("nagasaki.kurusu.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("nagasaki.yoriyori.name", comment: ""),
                    description: NSLocalizedString("nagasaki.yoriyori.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "tornado",
                    price: NSLocalizedString("nagasaki.yoriyori.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("nagasaki.momo_castella.name", comment: ""),
                    description: NSLocalizedString("nagasaki.momo_castella.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "heart.fill",
                    price: NSLocalizedString("nagasaki.momo_castella.price", comment: ""),
                    bestSeason: NSLocalizedString("common.spring", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("nagasaki.kakuni_manju.name", comment: ""),
                    description: NSLocalizedString("nagasaki.kakuni_manju.description", comment: ""),
                    category: .food,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("nagasaki.kakuni_manju.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .kumamoto:
            return [
                SouvenirItem(
                    name: NSLocalizedString("kumamoto.homare_no_jindaiko.name", comment: ""),
                    description: NSLocalizedString("kumamoto.homare_no_jindaiko.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("kumamoto.homare_no_jindaiko.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("kumamoto.ikinari_dango.name", comment: ""),
                    description: NSLocalizedString("kumamoto.ikinari_dango.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("kumamoto.ikinari_dango.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("kumamoto.musha_gaeshi.name", comment: ""),
                    description: NSLocalizedString("kumamoto.musha_gaeshi.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "triangle.fill",
                    price: NSLocalizedString("kumamoto.musha_gaeshi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("kumamoto.chosen_ame.name", comment: ""),
                    description: NSLocalizedString("kumamoto.chosen_ame.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("kumamoto.chosen_ame.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("kumamoto.kumamon_goods.name", comment: ""),
                    description: NSLocalizedString("kumamoto.kumamon_goods.description", comment: ""),
                    category: .regional,
                    imageSymbol: "bear.fill",
                    price: NSLocalizedString("kumamoto.kumamon_goods.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
        case .hokkaido:
            return [
                SouvenirItem(
                    name: NSLocalizedString("hokkaido.shiroi_koibito.name", comment: ""),
                    description: NSLocalizedString("hokkaido.shiroi_koibito.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "heart.fill",
                    price: NSLocalizedString("hokkaido.shiroi_koibito.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("hokkaido.marsei_butter_sand.name", comment: ""),
                    description: NSLocalizedString("hokkaido.marsei_butter_sand.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "square.fill",
                    price: NSLocalizedString("hokkaido.marsei_butter_sand.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("hokkaido.jaga_pokkuru.name", comment: ""),
                    description: NSLocalizedString("hokkaido.jaga_pokkuru.description", comment: ""),
                    category: .food,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("hokkaido.jaga_pokkuru.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("hokkaido.royce_nama_chocolate.name", comment: ""),
                    description: NSLocalizedString("hokkaido.royce_nama_chocolate.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("hokkaido.royce_nama_chocolate.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("hokkaido.yubari_melon_jelly.name", comment: ""),
                    description: NSLocalizedString("hokkaido.yubari_melon_jelly.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("hokkaido.yubari_melon_jelly.price", comment: ""),
                    bestSeason: NSLocalizedString("common.summer", comment: ""),
                    popularity: 4
                )
            ]
            
        case .aomori:
            return [
                SouvenirItem(
                    name: NSLocalizedString("aomori.kininaruringo.name", comment: ""),
                    description: NSLocalizedString("aomori.kininaruringo.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("aomori.kininaruringo.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("aomori.asa_no_hakkoda.name", comment: ""),
                    description: NSLocalizedString("aomori.asa_no_hakkoda.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "mountain.2.fill",
                    price: NSLocalizedString("aomori.asa_no_hakkoda.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("aomori.ringo_stick.name", comment: ""),
                    description: NSLocalizedString("aomori.ringo_stick.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "minus.rectangle.fill",
                    price: NSLocalizedString("aomori.ringo_stick.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("aomori.tsugaru_vidro.name", comment: ""),
                    description: NSLocalizedString("aomori.tsugaru_vidro.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("aomori.tsugaru_vidro.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("aomori.nebuta_goods.name", comment: ""),
                    description: NSLocalizedString("aomori.nebuta_goods.description", comment: ""),
                    category: .regional,
                    imageSymbol: "star.fill",
                    price: NSLocalizedString("aomori.nebuta_goods.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .iwate:
            return [
                SouvenirItem(
                    name: NSLocalizedString("iwate.kamome_no_tamago.name", comment: ""),
                    description: NSLocalizedString("iwate.kamome_no_tamago.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("iwate.kamome_no_tamago.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("iwate.nanbu_senbei.name", comment: ""),
                    description: NSLocalizedString("iwate.nanbu_senbei.description", comment: ""),
                    category: .food,
                    imageSymbol: "circle.grid.3x3.fill",
                    price: NSLocalizedString("iwate.nanbu_senbei.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("iwate.nanbu_tekki.name", comment: ""),
                    description: NSLocalizedString("iwate.nanbu_tekki.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "cup.and.saucer.fill",
                    price: NSLocalizedString("iwate.nanbu_tekki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("iwate.gangetsu.name", comment: ""),
                    description: NSLocalizedString("iwate.gangetsu.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "moon.fill",
                    price: NSLocalizedString("iwate.gangetsu.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("iwate.fukuda_pan.name", comment: ""),
                    description: NSLocalizedString("iwate.fukuda_pan.description", comment: ""),
                    category: .food,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("iwate.fukuda_pan.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .miyagi:
            return [
                SouvenirItem(
                    name: NSLocalizedString("miyagi.hagi_no_tsuki.name", comment: ""),
                    description: NSLocalizedString("miyagi.hagi_no_tsuki.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "moon.fill",
                    price: NSLocalizedString("miyagi.hagi_no_tsuki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("miyagi.sasa_kamaboko.name", comment: ""),
                    description: NSLocalizedString("miyagi.sasa_kamaboko.description", comment: ""),
                    category: .food,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("miyagi.sasa_kamaboko.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("miyagi.zunda_saryo.name", comment: ""),
                    description: NSLocalizedString("miyagi.zunda_saryo.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("miyagi.zunda_saryo.price", comment: ""),
                    bestSeason: NSLocalizedString("common.summer", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("miyagi.hakumatsuga_monaka.name", comment: ""),
                    description: NSLocalizedString("miyagi.hakumatsuga_monaka.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "hexagon.fill",
                    price: NSLocalizedString("miyagi.hakumatsuga_monaka.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("miyagi.kokeshi.name", comment: ""),
                    description: NSLocalizedString("miyagi.kokeshi.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "person.fill",
                    price: NSLocalizedString("miyagi.kokeshi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .akita:
            return [
                SouvenirItem(
                    name: NSLocalizedString("akita.kinman.name", comment: ""),
                    description: NSLocalizedString("akita.kinman.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("akita.kinman.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("akita.butter_mochi.name", comment: ""),
                    description: NSLocalizedString("akita.butter_mochi.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("akita.butter_mochi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("akita.namahage_goods.name", comment: ""),
                    description: NSLocalizedString("akita.namahage_goods.description", comment: ""),
                    category: .regional,
                    imageSymbol: "face.smiling.fill",
                    price: NSLocalizedString("akita.namahage_goods.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("akita.morokoshi.name", comment: ""),
                    description: NSLocalizedString("akita.morokoshi.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "square.fill",
                    price: NSLocalizedString("akita.morokoshi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("akita.inaniwa_udon.name", comment: ""),
                    description: NSLocalizedString("akita.inaniwa_udon.description", comment: ""),
                    category: .food,
                    imageSymbol: "minus.rectangle.fill",
                    price: NSLocalizedString("akita.inaniwa_udon.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .yamagata:
            return [
                SouvenirItem(
                    name: NSLocalizedString("yamagata.oshidori_milk_cake.name", comment: ""),
                    description: NSLocalizedString("yamagata.oshidori_milk_cake.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("yamagata.oshidori_milk_cake.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamagata.noshi_ume.name", comment: ""),
                    description: NSLocalizedString("yamagata.noshi_ume.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("yamagata.noshi_ume.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamagata.sakuranbo_kirara.name", comment: ""),
                    description: NSLocalizedString("yamagata.sakuranbo_kirara.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "heart.fill",
                    price: NSLocalizedString("yamagata.sakuranbo_kirara.price", comment: ""),
                    bestSeason: NSLocalizedString("common.summer", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamagata.shogi_koma.name", comment: ""),
                    description: NSLocalizedString("yamagata.shogi_koma.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "triangle.fill",
                    price: NSLocalizedString("yamagata.shogi_koma.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("yamagata.dadacha_mame.name", comment: ""),
                    description: NSLocalizedString("yamagata.dadacha_mame.description", comment: ""),
                    category: .food,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("yamagata.dadacha_mame.price", comment: ""),
                    bestSeason: NSLocalizedString("common.summer", comment: ""),
                    popularity: 3
                )
            ]
            
        case .fukushima:
            return [
                SouvenirItem(
                    name: NSLocalizedString("fukushima.mamadoru.name", comment: ""),
                    description: NSLocalizedString("fukushima.mamadoru.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "heart.fill",
                    price: NSLocalizedString("fukushima.mamadoru.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukushima.usukawa_manju.name", comment: ""),
                    description: NSLocalizedString("fukushima.usukawa_manju.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("fukushima.usukawa_manju.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukushima.exson_pie.name", comment: ""),
                    description: NSLocalizedString("fukushima.exson_pie.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "triangle.fill",
                    price: NSLocalizedString("fukushima.exson_pie.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukushima.aizu_nuri.name", comment: ""),
                    description: NSLocalizedString("fukushima.aizu_nuri.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "bowl.fill",
                    price: NSLocalizedString("fukushima.aizu_nuri.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukushima.kitakata_ramen.name", comment: ""),
                    description: NSLocalizedString("fukushima.kitakata_ramen.description", comment: ""),
                    category: .food,
                    imageSymbol: "bowl.fill",
                    price: NSLocalizedString("fukushima.kitakata_ramen.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .ibaraki:
            return [
                SouvenirItem(
                    name: NSLocalizedString("ibaraki.yoshiwara_denchu.name", comment: ""),
                    description: NSLocalizedString("ibaraki.yoshiwara_denchu.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "minus.rectangle.fill",
                    price: NSLocalizedString("ibaraki.yoshiwara_denchu.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("ibaraki.noshi_ume.name", comment: ""),
                    description: NSLocalizedString("ibaraki.noshi_ume.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("ibaraki.noshi_ume.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("ibaraki.natto.name", comment: ""),
                    description: NSLocalizedString("ibaraki.natto.description", comment: ""),
                    category: .food,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("ibaraki.natto.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("ibaraki.hoshi_imo.name", comment: ""),
                    description: NSLocalizedString("ibaraki.hoshi_imo.description", comment: ""),
                    category: .food,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("ibaraki.hoshi_imo.price", comment: ""),
                    bestSeason: NSLocalizedString("common.autumn_winter", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("ibaraki.hitachi_fudoki.name", comment: ""),
                    description: NSLocalizedString("ibaraki.hitachi_fudoki.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "mountain.2.fill",
                    price: NSLocalizedString("ibaraki.hitachi_fudoki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                )
            ]
            
        case .tochigi:
            return [
                SouvenirItem(
                    name: NSLocalizedString("tochigi.goyotei_no_tsuki.name", comment: ""),
                    description: NSLocalizedString("tochigi.goyotei_no_tsuki.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "moon.fill",
                    price: NSLocalizedString("tochigi.goyotei_no_tsuki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tochigi.lemon_milk_cookie.name", comment: ""),
                    description: NSLocalizedString("tochigi.lemon_milk_cookie.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "drop.fill",
                    price: NSLocalizedString("tochigi.lemon_milk_cookie.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tochigi.yuba_senbei.name", comment: ""),
                    description: NSLocalizedString("tochigi.yuba_senbei.description", comment: ""),
                    category: .food,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("tochigi.yuba_senbei.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tochigi.mashiko_yaki.name", comment: ""),
                    description: NSLocalizedString("tochigi.mashiko_yaki.description", comment: ""),
                    category: .ceramics,
                    imageSymbol: "cup.and.saucer.fill",
                    price: NSLocalizedString("tochigi.mashiko_yaki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tochigi.tochiotome_goods.name", comment: ""),
                    description: NSLocalizedString("tochigi.tochiotome_goods.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "heart.fill",
                    price: NSLocalizedString("tochigi.tochiotome_goods.price", comment: ""),
                    bestSeason: NSLocalizedString("common.winter_spring", comment: ""),
                    popularity: 4
                )
            ]
            
        case .gunma:
            return [
                SouvenirItem(
                    name: NSLocalizedString("gunma.tabi_garasu.name", comment: ""),
                    description: NSLocalizedString("gunma.tabi_garasu.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "bird.fill",
                    price: NSLocalizedString("gunma.tabi_garasu.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("gunma.isobe_senbei.name", comment: ""),
                    description: NSLocalizedString("gunma.isobe_senbei.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.grid.3x3.fill",
                    price: NSLocalizedString("gunma.isobe_senbei.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("gunma.konnyaku_park.name", comment: ""),
                    description: NSLocalizedString("gunma.konnyaku_park.description", comment: ""),
                    category: .food,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("gunma.konnyaku_park.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("gunma.daruma_bento.name", comment: ""),
                    description: NSLocalizedString("gunma.daruma_bento.description", comment: ""),
                    category: .food,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("gunma.daruma_bento.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("gunma.yaki_manju.name", comment: ""),
                    description: NSLocalizedString("gunma.yaki_manju.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("gunma.yaki_manju.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .saitama:
            return [
                SouvenirItem(
                    name: NSLocalizedString("saitama.jumangoku_manju.name", comment: ""),
                    description: NSLocalizedString("saitama.jumangoku_manju.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("saitama.jumangoku_manju.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("saitama.gokaho.name", comment: ""),
                    description: NSLocalizedString("saitama.gokaho.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("saitama.gokaho.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("saitama.soka_senbei.name", comment: ""),
                    description: NSLocalizedString("saitama.soka_senbei.description", comment: ""),
                    category: .food,
                    imageSymbol: "circle.grid.3x3.fill",
                    price: NSLocalizedString("saitama.soka_senbei.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("saitama.kawagoe_imo_cookie.name", comment: ""),
                    description: NSLocalizedString("saitama.kawagoe_imo_cookie.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("saitama.kawagoe_imo_cookie.price", comment: ""),
                    bestSeason: NSLocalizedString("common.autumn", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("saitama.sayama_cha.name", comment: ""),
                    description: NSLocalizedString("saitama.sayama_cha.description", comment: ""),
                    category: .drinks,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("saitama.sayama_cha.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .chiba:
            return [
                SouvenirItem(
                    name: NSLocalizedString("chiba.peanut_monaka.name", comment: ""),
                    description: NSLocalizedString("chiba.peanut_monaka.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("chiba.peanut_monaka.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("chiba.boso_biwa_jelly.name", comment: ""),
                    description: NSLocalizedString("chiba.boso_biwa_jelly.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("chiba.boso_biwa_jelly.price", comment: ""),
                    bestSeason: NSLocalizedString("common.summer", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("chiba.nagomi_komeya.name", comment: ""),
                    description: NSLocalizedString("chiba.nagomi_komeya.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("chiba.nagomi_komeya.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("chiba.oranda_sable.name", comment: ""),
                    description: NSLocalizedString("chiba.oranda_sable.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("chiba.oranda_sable.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("chiba.rakkasei.name", comment: ""),
                    description: NSLocalizedString("chiba.rakkasei.description", comment: ""),
                    category: .food,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("chiba.rakkasei.price", comment: ""),
                    bestSeason: NSLocalizedString("common.autumn", comment: ""),
                    popularity: 4
                )
            ]
            
        case .tokyo:
            return [
                SouvenirItem(
                    name: NSLocalizedString("tokyo.hiyoko.name", comment: ""),
                    description: NSLocalizedString("tokyo.hiyoko.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "bird.fill",
                    price: NSLocalizedString("tokyo.hiyoko.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("tokyo.tokyo_banana.name", comment: ""),
                    description: NSLocalizedString("tokyo.tokyo_banana.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("tokyo.tokyo_banana.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("tokyo.funawa_imo_yokan.name", comment: ""),
                    description: NSLocalizedString("tokyo.funawa_imo_yokan.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("tokyo.funawa_imo_yokan.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("tokyo.kaminari_okoshi.name", comment: ""),
                    description: NSLocalizedString("tokyo.kaminari_okoshi.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "bolt.fill",
                    price: NSLocalizedString("tokyo.kaminari_okoshi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tokyo.ningyo_yaki.name", comment: ""),
                    description: NSLocalizedString("tokyo.ningyo_yaki.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "person.fill",
                    price: NSLocalizedString("tokyo.ningyo_yaki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("tokyo.edo_kiriko.name", comment: ""),
                    description: NSLocalizedString("tokyo.edo_kiriko.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("tokyo.edo_kiriko.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .kanagawa:
            return [
                SouvenirItem(
                    name: NSLocalizedString("kanagawa.hato_sable.name", comment: ""),
                    description: NSLocalizedString("kanagawa.hato_sable.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "bird.fill",
                    price: NSLocalizedString("kanagawa.hato_sable.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                ),
                SouvenirItem(
                    name: NSLocalizedString("kanagawa.yokohama_renga.name", comment: ""),
                    description: NSLocalizedString("kanagawa.yokohama_renga.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("kanagawa.yokohama_renga.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("kanagawa.ariake_harbor.name", comment: ""),
                    description: NSLocalizedString("kanagawa.ariake_harbor.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "ship.fill",
                    price: NSLocalizedString("kanagawa.ariake_harbor.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("kanagawa.kiyoken_hyochan.name", comment: ""),
                    description: NSLocalizedString("kanagawa.kiyoken_hyochan.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "face.smiling.fill",
                    price: NSLocalizedString("kanagawa.kiyoken_hyochan.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("kanagawa.hakone_yosegi.name", comment: ""),
                    description: NSLocalizedString("kanagawa.hakone_yosegi.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "square.grid.3x3.fill",
                    price: NSLocalizedString("kanagawa.hakone_yosegi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .niigata:
            return [
                SouvenirItem(
                    name: NSLocalizedString("niigata.sasa_dango.name", comment: ""),
                    description: NSLocalizedString("niigata.sasa_dango.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("niigata.sasa_dango.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("niigata.kasen_kaki_no_tane.name", comment: ""),
                    description: NSLocalizedString("niigata.kasen_kaki_no_tane.description", comment: ""),
                    category: .food,
                    imageSymbol: "oval.fill",
                    price: NSLocalizedString("niigata.kasen_kaki_no_tane.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("niigata.yukiguni_arare.name", comment: ""),
                    description: NSLocalizedString("niigata.yukiguni_arare.description", comment: ""),
                    category: .food,
                    imageSymbol: "snowflake",
                    price: NSLocalizedString("niigata.yukiguni_arare.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("niigata.echigo_hime_sandwich.name", comment: ""),
                    description: NSLocalizedString("niigata.echigo_hime_sandwich.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "heart.fill",
                    price: NSLocalizedString("niigata.echigo_hime_sandwich.price", comment: ""),
                    bestSeason: NSLocalizedString("common.winter_spring", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("niigata.nihonshu.name", comment: ""),
                    description: NSLocalizedString("niigata.nihonshu.description", comment: ""),
                    category: .drinks,
                    imageSymbol: "wineglass.fill",
                    price: NSLocalizedString("niigata.nihonshu.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 5
                )
            ]
            
        case .toyama:
            return [
                SouvenirItem(
                    name: NSLocalizedString("toyama.masu_sushi.name", comment: ""),
                    description: NSLocalizedString("toyama.masu_sushi.description", comment: ""),
                    category: .food,
                    imageSymbol: "fish.fill",
                    price: NSLocalizedString("toyama.masu_sushi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("toyama.shiro_ebi_kiko.name", comment: ""),
                    description: NSLocalizedString("toyama.shiro_ebi_kiko.description", comment: ""),
                    category: .food,
                    imageSymbol: "fish.fill",
                    price: NSLocalizedString("toyama.shiro_ebi_kiko.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("toyama.getsusekai.name", comment: ""),
                    description: NSLocalizedString("toyama.getsusekai.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "moon.fill",
                    price: NSLocalizedString("toyama.getsusekai.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("toyama.kankintan.name", comment: ""),
                    description: NSLocalizedString("toyama.kankintan.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("toyama.kankintan.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("toyama.kombu.name", comment: ""),
                    description: NSLocalizedString("toyama.kombu.description", comment: ""),
                    category: .food,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("toyama.kombu.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
            
        case .ishikawa:
            return [
                SouvenirItem(
                    name: NSLocalizedString("ishikawa.ukokukei_castella.name", comment: ""),
                    description: NSLocalizedString("ishikawa.ukokukei_castella.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "rectangle.fill",
                    price: NSLocalizedString("ishikawa.ukokukei_castella.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("ishikawa.kinpaku_castella.name", comment: ""),
                    description: NSLocalizedString("ishikawa.kinpaku_castella.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "sparkles",
                    price: NSLocalizedString("ishikawa.kinpaku_castella.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("ishikawa.jiroame.name", comment: ""),
                    description: NSLocalizedString("ishikawa.jiroame.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "drop.fill",
                    price: NSLocalizedString("ishikawa.jiroame.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("ishikawa.kutani_yaki.name", comment: ""),
                    description: NSLocalizedString("ishikawa.kutani_yaki.description", comment: ""),
                    category: .ceramics,
                    imageSymbol: "cup.and.saucer.fill",
                    price: NSLocalizedString("ishikawa.kutani_yaki.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                ),
                SouvenirItem(
                    name: NSLocalizedString("ishikawa.wajima_nuri.name", comment: ""),
                    description: NSLocalizedString("ishikawa.wajima_nuri.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "bowl.fill",
                    price: NSLocalizedString("ishikawa.wajima_nuri.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 4
                )
            ]
            
        case .fukui:
            return [
                SouvenirItem(
                    name: NSLocalizedString("fukui.habutae_mochi.name", comment: ""),
                    description: NSLocalizedString("fukui.habutae_mochi.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "circle.fill",
                    price: NSLocalizedString("fukui.habutae_mochi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukui.satsukigase_senbei.name", comment: ""),
                    description: NSLocalizedString("fukui.satsukigase_senbei.description", comment: ""),
                    category: .food,
                    imageSymbol: "circle.grid.3x3.fill",
                    price: NSLocalizedString("fukui.satsukigase_senbei.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukui.gyuhi_kombu.name", comment: ""),
                    description: NSLocalizedString("fukui.gyuhi_kombu.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "leaf.fill",
                    price: NSLocalizedString("fukui.gyuhi_kombu.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 2
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukui.mizu_yokan.name", comment: ""),
                    description: NSLocalizedString("fukui.mizu_yokan.description", comment: ""),
                    category: .sweets,
                    imageSymbol: "drop.fill",
                    price: NSLocalizedString("fukui.mizu_yokan.price", comment: ""),
                    bestSeason: NSLocalizedString("common.summer", comment: ""),
                    popularity: 3
                ),
                SouvenirItem(
                    name: NSLocalizedString("fukui.echizen_washi.name", comment: ""),
                    description: NSLocalizedString("fukui.echizen_washi.description", comment: ""),
                    category: .crafts,
                    imageSymbol: "doc.fill",
                    price: NSLocalizedString("fukui.echizen_washi.price", comment: ""),
                    bestSeason: NSLocalizedString("common.year_round", comment: ""),
                    popularity: 3
                )
            ]
        
                    
                case .nara:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("nara.shika_sable.name", comment: ""),
                            description: NSLocalizedString("nara.shika_sable.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "bird.fill",
                            price: NSLocalizedString("nara.shika_sable.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("nara.mikasa.name", comment: ""),
                            description: NSLocalizedString("nara.mikasa.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("nara.mikasa.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("nara.kaki_senmon_ishii.name", comment: ""),
                            description: NSLocalizedString("nara.kaki_senmon_ishii.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("nara.kaki_senmon_ishii.price", comment: ""),
                            bestSeason: NSLocalizedString("common.autumn", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("nara.nakagawa_masashichi_goods.name", comment: ""),
                            description: NSLocalizedString("nara.nakagawa_masashichi_goods.description", comment: ""),
                            category: .crafts,
                            imageSymbol: "bag.fill",
                            price: NSLocalizedString("nara.nakagawa_masashichi_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("nara.shika_goods.name", comment: ""),
                            description: NSLocalizedString("nara.shika_goods.description", comment: ""),
                            category: .regional,
                            imageSymbol: "bird.fill",
                            price: NSLocalizedString("nara.shika_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        )
                    ]
                    
                case .wakayama:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("wakayama.kagero.name", comment: ""),
                            description: NSLocalizedString("wakayama.kagero.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "rectangle.fill",
                            price: NSLocalizedString("wakayama.kagero.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("wakayama.nachi_guro.name", comment: ""),
                            description: NSLocalizedString("wakayama.nachi_guro.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("wakayama.nachi_guro.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 2
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("wakayama.kinokawa_kaki.name", comment: ""),
                            description: NSLocalizedString("wakayama.kinokawa_kaki.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("wakayama.kinokawa_kaki.price", comment: ""),
                            bestSeason: NSLocalizedString("common.autumn", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("wakayama.arita_mikan_daifuku.name", comment: ""),
                            description: NSLocalizedString("wakayama.arita_mikan_daifuku.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("wakayama.arita_mikan_daifuku.price", comment: ""),
                            bestSeason: NSLocalizedString("common.winter", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("wakayama.umeboshi.name", comment: ""),
                            description: NSLocalizedString("wakayama.umeboshi.description", comment: ""),
                            category: .food,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("wakayama.umeboshi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 5
                        )
                    ]
                    
                case .tottori:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("tottori.inaba_no_shiro_usagi.name", comment: ""),
                            description: NSLocalizedString("tottori.inaba_no_shiro_usagi.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "rabbit.fill",
                            price: NSLocalizedString("tottori.inaba_no_shiro_usagi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("tottori.ofuroboshi.name", comment: ""),
                            description: NSLocalizedString("tottori.ofuroboshi.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "rectangle.fill",
                            price: NSLocalizedString("tottori.ofuroboshi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("tottori.nijusseiki_nashi_jelly.name", comment: ""),
                            description: NSLocalizedString("tottori.nijusseiki_nashi_jelly.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("tottori.nijusseiki_nashi_jelly.price", comment: ""),
                            bestSeason: NSLocalizedString("common.autumn", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("tottori.hakubaranyu_goods.name", comment: ""),
                            description: NSLocalizedString("tottori.hakubaranyu_goods.description", comment: ""),
                            category: .drinks,
                            imageSymbol: "drop.fill",
                            price: NSLocalizedString("tottori.hakubaranyu_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("tottori.sakyu_goods.name", comment: ""),
                            description: NSLocalizedString("tottori.sakyu_goods.description", comment: ""),
                            category: .regional,
                            imageSymbol: "mountain.2.fill",
                            price: NSLocalizedString("tottori.sakyu_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        )
                    ]
                    
                case .shimane:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("shimane.dojo_sukui_manju.name", comment: ""),
                            description: NSLocalizedString("shimane.dojo_sukui_manju.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "fish.fill",
                            price: NSLocalizedString("shimane.dojo_sukui_manju.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shimane.genji_maki.name", comment: ""),
                            description: NSLocalizedString("shimane.genji_maki.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "rectangle.fill",
                            price: NSLocalizedString("shimane.genji_maki.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shimane.wakakusa.name", comment: ""),
                            description: NSLocalizedString("shimane.wakakusa.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "leaf.fill",
                            price: NSLocalizedString("shimane.wakakusa.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 2
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shimane.shimane_wine.name", comment: ""),
                            description: NSLocalizedString("shimane.shimane_wine.description", comment: ""),
                            category: .drinks,
                            imageSymbol: "wineglass.fill",
                            price: NSLocalizedString("shimane.shimane_wine.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shimane.iwami_ginzan_goods.name", comment: ""),
                            description: NSLocalizedString("shimane.iwami_ginzan_goods.description", comment: ""),
                            category: .regional,
                            imageSymbol: "star.fill",
                            price: NSLocalizedString("shimane.iwami_ginzan_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        )
                    ]
                    
                case .nagano:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("nagano.raicho_no_sato.name", comment: ""),
                            description: NSLocalizedString("nagano.raicho_no_sato.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "bird.fill",
                            price: NSLocalizedString("nagano.raicho_no_sato.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("nagano.misuzu_ame.name", comment: ""),
                            description: NSLocalizedString("nagano.misuzu_ame.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("nagano.misuzu_ame.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("nagano.yawataya_isogoro_shichimi.name", comment: ""),
                            description: NSLocalizedString("nagano.yawataya_isogoro_shichimi.description", comment: ""),
                            category: .food,
                            imageSymbol: "flame.fill",
                            price: NSLocalizedString("nagano.yawataya_isogoro_shichimi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("nagano.kuri_kanoko.name", comment: ""),
                            description: NSLocalizedString("nagano.kuri_kanoko.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("nagano.kuri_kanoko.price", comment: ""),
                            bestSeason: NSLocalizedString("common.autumn", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("nagano.nozawana.name", comment: ""),
                            description: NSLocalizedString("nagano.nozawana.description", comment: ""),
                            category: .food,
                            imageSymbol: "leaf.fill",
                            price: NSLocalizedString("nagano.nozawana.price", comment: ""),
                            bestSeason: NSLocalizedString("common.winter", comment: ""),
                            popularity: 3
                        )
                    ]
                    
                case .gifu:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("gifu.hida_no_sato.name", comment: ""),
                            description: NSLocalizedString("gifu.hida_no_sato.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "mountain.2.fill",
                            price: NSLocalizedString("gifu.hida_no_sato.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("gifu.kuri_kinton.name", comment: ""),
                            description: NSLocalizedString("gifu.kuri_kinton.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("gifu.kuri_kinton.price", comment: ""),
                            bestSeason: NSLocalizedString("common.autumn", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("gifu.ayu_gashi.name", comment: ""),
                            description: NSLocalizedString("gifu.ayu_gashi.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "fish.fill",
                            price: NSLocalizedString("gifu.ayu_gashi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.summer", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("gifu.hoba_miso_senbei.name", comment: ""),
                            description: NSLocalizedString("gifu.hoba_miso_senbei.description", comment: ""),
                            category: .food,
                            imageSymbol: "leaf.fill",
                            price: NSLocalizedString("gifu.hoba_miso_senbei.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 2
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("gifu.mino_washi.name", comment: ""),
                            description: NSLocalizedString("gifu.mino_washi.description", comment: ""),
                            category: .crafts,
                            imageSymbol: "doc.fill",
                            price: NSLocalizedString("gifu.mino_washi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        )
                    ]
                    
                case .shizuoka:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("shizuoka.unagi_pie.name", comment: ""),
                            description: NSLocalizedString("shizuoka.unagi_pie.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "fish.fill",
                            price: NSLocalizedString("shizuoka.unagi_pie.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 5
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shizuoka.kokko.name", comment: ""),
                            description: NSLocalizedString("shizuoka.kokko.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "bird.fill",
                            price: NSLocalizedString("shizuoka.kokko.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shizuoka.jiichiro_baumkuchen.name", comment: ""),
                            description: NSLocalizedString("shizuoka.jiichiro_baumkuchen.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("shizuoka.jiichiro_baumkuchen.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shizuoka.fujisan_cho.name", comment: ""),
                            description: NSLocalizedString("shizuoka.fujisan_cho.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "mountain.2.fill",
                            price: NSLocalizedString("shizuoka.fujisan_cho.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shizuoka.shizuoka_cha.name", comment: ""),
                            description: NSLocalizedString("shizuoka.shizuoka_cha.description", comment: ""),
                            category: .drinks,
                            imageSymbol: "leaf.fill",
                            price: NSLocalizedString("shizuoka.shizuoka_cha.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 5
                        )
                    ]
                    
                case .aichi:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("aichi.uiro.name", comment: ""),
                            description: NSLocalizedString("aichi.uiro.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "rectangle.fill",
                            price: NSLocalizedString("aichi.uiro.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("aichi.yukari.name", comment: ""),
                            description: NSLocalizedString("aichi.yukari.description", comment: ""),
                            category: .food,
                            imageSymbol: "fish.fill",
                            price: NSLocalizedString("aichi.yukari.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("aichi.sakakaku_ebi_senbei.name", comment: ""),
                            description: NSLocalizedString("aichi.sakakaku_ebi_senbei.description", comment: ""),
                            category: .food,
                            imageSymbol: "fish.fill",
                            price: NSLocalizedString("aichi.sakakaku_ebi_senbei.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("aichi.nagoyan.name", comment: ""),
                            description: NSLocalizedString("aichi.nagoyan.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "heart.fill",
                            price: NSLocalizedString("aichi.nagoyan.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("aichi.arimatsu_shibori.name", comment: ""),
                            description: NSLocalizedString("aichi.arimatsu_shibori.description", comment: ""),
                            category: .textiles,
                            imageSymbol: "tshirt.fill",
                            price: NSLocalizedString("aichi.arimatsu_shibori.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        )
                    ]
                    
                case .mie:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("mie.akafuku.name", comment: ""),
                            description: NSLocalizedString("mie.akafuku.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "heart.fill",
                            price: NSLocalizedString("mie.akafuku.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 5
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("mie.henba_mochi.name", comment: ""),
                            description: NSLocalizedString("mie.henba_mochi.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("mie.henba_mochi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("mie.yasunaga_mochi.name", comment: ""),
                            description: NSLocalizedString("mie.yasunaga_mochi.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "oval.fill",
                            price: NSLocalizedString("mie.yasunaga_mochi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("mie.toraya_uiro.name", comment: ""),
                            description: NSLocalizedString("mie.toraya_uiro.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "rectangle.fill",
                            price: NSLocalizedString("mie.toraya_uiro.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("mie.shinju.name", comment: ""),
                            description: NSLocalizedString("mie.shinju.description", comment: ""),
                            category: .crafts,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("mie.shinju.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        )
                    ]
                    
                case .shiga:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("shiga.kisho_juian_kinogumo.name", comment: ""),
                            description: NSLocalizedString("shiga.kisho_juian_kinogumo.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "cloud.fill",
                            price: NSLocalizedString("shiga.kisho_juian_kinogumo.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shiga.itokiri_mochi.name", comment: ""),
                            description: NSLocalizedString("shiga.itokiri_mochi.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "minus.rectangle.fill",
                            price: NSLocalizedString("shiga.itokiri_mochi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 2
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shiga.chojifu.name", comment: ""),
                            description: NSLocalizedString("shiga.chojifu.description", comment: ""),
                            category: .food,
                            imageSymbol: "rectangle.fill",
                            price: NSLocalizedString("shiga.chojifu.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 2
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shiga.shigaraki_yaki.name", comment: ""),
                            description: NSLocalizedString("shiga.shigaraki_yaki.description", comment: ""),
                            category: .ceramics,
                            imageSymbol: "cup.and.saucer.fill",
                            price: NSLocalizedString("shiga.shigaraki_yaki.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("shiga.biwa_ko_goods.name", comment: ""),
                            description: NSLocalizedString("shiga.biwa_ko_goods.description", comment: ""),
                            category: .regional,
                            imageSymbol: "drop.fill",
                            price: NSLocalizedString("shiga.biwa_ko_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 2
                        )
                    ]
                    
                case .kyoto:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("kyoto.yatsuhashi.name", comment: ""),
                            description: NSLocalizedString("kyoto.yatsuhashi.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "triangle.fill",
                            price: NSLocalizedString("kyoto.yatsuhashi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 5
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("kyoto.ajari_mochi.name", comment: ""),
                            description: NSLocalizedString("kyoto.ajari_mochi.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("kyoto.ajari_mochi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("kyoto.cha_no_ka.name", comment: ""),
                            description: NSLocalizedString("kyoto.cha_no_ka.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "leaf.fill",
                            price: NSLocalizedString("kyoto.cha_no_ka.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("kyoto.marl_bransh_okoicha.name", comment: ""),
                            description: NSLocalizedString("kyoto.marl_bransh_okoicha.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "leaf.fill",
                            price: NSLocalizedString("kyoto.marl_bransh_okoicha.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("kyoto.yojiya_aburatorigami.name", comment: ""),
                            description: NSLocalizedString("kyoto.yojiya_aburatorigami.description", comment: ""),
                            category: .regional,
                            imageSymbol: "doc.fill",
                            price: NSLocalizedString("kyoto.yojiya_aburatorigami.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("kyoto.kiyomizu_yaki.name", comment: ""),
                            description: NSLocalizedString("kyoto.kiyomizu_yaki.description", comment: ""),
                            category: .ceramics,
                            imageSymbol: "cup.and.saucer.fill",
                            price: NSLocalizedString("kyoto.kiyomizu_yaki.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        )
                    ]
                    
                case .osaka:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("osaka.butaman_551.name", comment: ""),
                            description: NSLocalizedString("osaka.butaman_551.description", comment: ""),
                            category: .food,
                            imageSymbol: "circle.hexagonpath.fill",
                            price: NSLocalizedString("osaka.butaman_551.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 5
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("osaka.rikuro_cheesecake.name", comment: ""),
                            description: NSLocalizedString("osaka.rikuro_cheesecake.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("osaka.rikuro_cheesecake.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("osaka.omoshiroi_koibito.name", comment: ""),
                            description: NSLocalizedString("osaka.omoshiroi_koibito.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "face.smiling.fill",
                            price: NSLocalizedString("osaka.omoshiroi_koibito.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("osaka.mitarashi_dango.name", comment: ""),
                            description: NSLocalizedString("osaka.mitarashi_dango.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("osaka.mitarashi_dango.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("osaka.takoyaki_goods.name", comment: ""),
                            description: NSLocalizedString("osaka.takoyaki_goods.description", comment: ""),
                            category: .regional,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("osaka.takoyaki_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        )
                    ]
                    
                case .hyogo:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("hyogo.kobe_fugetsudo_gofer.name", comment: ""),
                            description: NSLocalizedString("hyogo.kobe_fugetsudo_gofer.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("hyogo.kobe_fugetsudo_gofer.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("hyogo.mon_loire_chocolate.name", comment: ""),
                            description: NSLocalizedString("hyogo.mon_loire_chocolate.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "rectangle.fill",
                            price: NSLocalizedString("hyogo.mon_loire_chocolate.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("hyogo.kannonya_denmark_cheesecake.name", comment: ""),
                            description: NSLocalizedString("hyogo.kannonya_denmark_cheesecake.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("hyogo.kannonya_denmark_cheesecake.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("hyogo.kobe_beef_goods.name", comment: ""),
                            description: NSLocalizedString("hyogo.kobe_beef_goods.description", comment: ""),
                            category: .food,
                            imageSymbol: "flame.fill",
                            price: NSLocalizedString("hyogo.kobe_beef_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("hyogo.arima_onsen_goods.name", comment: ""),
                            description: NSLocalizedString("hyogo.arima_onsen_goods.description", comment: ""),
                            category: .regional,
                            imageSymbol: "drop.fill",
                            price: NSLocalizedString("hyogo.arima_onsen_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        )
                    ]
        case .miyazaki:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("miyazaki.nanjako_daifuku.name", comment: ""),
                            description: NSLocalizedString("miyazaki.nanjako_daifuku.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("miyazaki.nanjako_daifuku.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("miyazaki.cheese_manju.name", comment: ""),
                            description: NSLocalizedString("miyazaki.cheese_manju.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("miyazaki.cheese_manju.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("miyazaki.aoshima_senbei.name", comment: ""),
                            description: NSLocalizedString("miyazaki.aoshima_senbei.description", comment: ""),
                            category: .food,
                            imageSymbol: "circle.grid.3x3.fill",
                            price: NSLocalizedString("miyazaki.aoshima_senbei.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 2
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("miyazaki.hyuganatsu_sable.name", comment: ""),
                            description: NSLocalizedString("miyazaki.hyuganatsu_sable.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("miyazaki.hyuganatsu_sable.price", comment: ""),
                            bestSeason: NSLocalizedString("common.spring_summer", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("miyazaki.mango_goods.name", comment: ""),
                            description: NSLocalizedString("miyazaki.mango_goods.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "oval.fill",
                            price: NSLocalizedString("miyazaki.mango_goods.price", comment: ""),
                            bestSeason: NSLocalizedString("common.summer", comment: ""),
                            popularity: 4
                        )
                    ]
                    
                case .kagoshima:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("kagoshima.karukan.name", comment: ""),
                            description: NSLocalizedString("kagoshima.karukan.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("kagoshima.karukan.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("kagoshima.satsuma_imo_tart.name", comment: ""),
                            description: NSLocalizedString("kagoshima.satsuma_imo_tart.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("kagoshima.satsuma_imo_tart.price", comment: ""),
                            bestSeason: NSLocalizedString("common.autumn", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("kagoshima.karukan_manju.name", comment: ""),
                            description: NSLocalizedString("kagoshima.karukan_manju.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("kagoshima.karukan_manju.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("kagoshima.satsuma_kiriko.name", comment: ""),
                            description: NSLocalizedString("kagoshima.satsuma_kiriko.description", comment: ""),
                            category: .crafts,
                            imageSymbol: "diamond.fill",
                            price: NSLocalizedString("kagoshima.satsuma_kiriko.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("kagoshima.imo_shochu.name", comment: ""),
                            description: NSLocalizedString("kagoshima.imo_shochu.description", comment: ""),
                            category: .drinks,
                            imageSymbol: "wineglass.fill",
                            price: NSLocalizedString("kagoshima.imo_shochu.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 5
                        )
                    ]
                    
                case .okinawa:
                    return [
                        SouvenirItem(
                            name: NSLocalizedString("okinawa.chinsuko.name", comment: ""),
                            description: NSLocalizedString("okinawa.chinsuko.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "square.fill",
                            price: NSLocalizedString("okinawa.chinsuko.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 5
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("okinawa.beni_imo_tart.name", comment: ""),
                            description: NSLocalizedString("okinawa.beni_imo_tart.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("okinawa.beni_imo_tart.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("okinawa.yukishio_chinsuko.name", comment: ""),
                            description: NSLocalizedString("okinawa.yukishio_chinsuko.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "snowflake",
                            price: NSLocalizedString("okinawa.yukishio_chinsuko.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("okinawa.sata_andagi.name", comment: ""),
                            description: NSLocalizedString("okinawa.sata_andagi.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("okinawa.sata_andagi.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("okinawa.awamori_cookie.name", comment: ""),
                            description: NSLocalizedString("okinawa.awamori_cookie.description", comment: ""),
                            category: .sweets,
                            imageSymbol: "wineglass.fill",
                            price: NSLocalizedString("okinawa.awamori_cookie.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 3
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("okinawa.ryukyu_glass.name", comment: ""),
                            description: NSLocalizedString("okinawa.ryukyu_glass.description", comment: ""),
                            category: .crafts,
                            imageSymbol: "circle.fill",
                            price: NSLocalizedString("okinawa.ryukyu_glass.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        ),
                        SouvenirItem(
                            name: NSLocalizedString("okinawa.shisa.name", comment: ""),
                            description: NSLocalizedString("okinawa.shisa.description", comment: ""),
                            category: .crafts,
                            imageSymbol: "dog.fill",
                            price: NSLocalizedString("okinawa.shisa.price", comment: ""),
                            bestSeason: NSLocalizedString("common.year_round", comment: ""),
                            popularity: 4
                        )
                    ]
        }
    }
}
