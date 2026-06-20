//
//  NatureSpotPrefecture.swift
//  MapRoulette
//
//  自然スポット（nameKey）→ 所属都道府県の対応表。
//  各スポットの実在地を名前から確定的に特定したもの。
//  座標推測（Prefecture.nearest）の県境誤判定を避けるために使う。
//

import Foundation

enum NatureSpotPrefecture {
    static let byNameKey: [String: Prefecture] = [
        "nightview_hakodate_name": .hokkaido,  // 函館山(函館市)
        "nightview_maya_name": .hyogo,  // 摩耶山(神戸市)
        "nightview_inasa_name": .nagasaki,  // 稲佐山(長崎市)
        "nightview_tokyo_towers_name": .tokyo,  // 東京スカイツリー周辺
        "nightview_shonan_name": .kanagawa,  // 湘南
        "nightview_rokko_name": .hyogo,  // 六甲山(神戸市)
        "nightview_sarakura_name": .fukuoka,  // 皿倉山(北九州市)
        "nightview_minatomirai_name": .kanagawa,  // みなとみらい(横浜市)
        "nightview_tempozan_name": .osaka,  // 天保山(大阪市)
        "nightview_wakakusa_name": .nara,  // 若草山(奈良市)
        "nightview_shiroyama_name": .kagoshima,  // 城山(鹿児島市)
        "nightview_moiwa_name": .hokkaido,  // 藻岩山(札幌市)
        "starry_achi_name": .nagano,  // 阿智村
        "starry_ishigaki_name": .okinawa,  // 石垣島
        "starry_nobeyama_name": .nagano,  // 野辺山(南牧村)
        "starry_utsukushigahara_name": .nagano,  // 美ヶ原
        "starry_odaigahara_name": .nara,  // 大台ヶ原(奈良/三重県境・主峰は奈良)
        "starry_yatsugatake_name": .nagano,  // 八ヶ岳
        "starry_iriomote_name": .okinawa,  // 西表島
        "starry_kuju_name": .oita,  // くじゅう連山
        "starry_kirigamine_name": .nagano,  // 霧ヶ峰(諏訪市)
        "starry_akagi_name": .gunma,  // 赤城山
        "starry_zao_name": .yamagata,  // 蔵王(山形側・座標は山形蔵王)
        "starry_daisetsu_name": .hokkaido,  // 大雪山
        "starry_tsubetsu_name": .hokkaido,  // 津別峠
        "starry_erimo_name": .hokkaido,  // 襟裳岬
        "camping_toya_name": .hokkaido,  // 洞爺湖
        "camping_shikotsu_name": .hokkaido,  // 支笏湖
        "camping_mashu_name": .hokkaido,  // 摩周湖
        "camping_furano_biei_name": .hokkaido,  // 富良野・美瑛
        "camping_niseko_name": .hokkaido,  // ニセコ
        "camping_towada_name": .aomori,  // 十和田湖(座標40.44,140.92は青森側)
        "camping_bandai_name": .fukushima,  // 磐梯
        "camping_goshikinuma_name": .fukushima,  // 五色沼
        "camping_zao_name": .yamagata,  // 蔵王(座標38.14,140.44は山形蔵王)
        "camping_okutama_name": .tokyo,  // 奥多摩
        "camping_tanzawa_name": .kanagawa,  // 丹沢
        "camping_nasu_name": .tochigi,  // 那須
        "camping_okunikko_name": .tochigi,  // 奥日光
        "camping_hakone_name": .kanagawa,  // 箱根
        "camping_fujigoko_name": .yamanashi,  // 富士五湖
        "camping_kamikochi_name": .nagano,  // 上高地
        "camping_hakuba_name": .nagano,  // 白馬
        "camping_karuizawa_name": .nagano,  // 軽井沢
        "camping_kiyosato_name": .yamanashi,  // 清里
        "camping_shiga_name": .nagano,  // 志賀高原
        "camping_biwa_name": .shiga,  // 琵琶湖
        "camping_hiruzen_name": .okayama,  // 蒜山(座標35.31,133.66は岡山側)
        "camping_odaigahara_name": .nara,  // 大台ヶ原
        "camping_tsurugi_name": .tokushima,  // 剣山
        "camping_shimanto_name": .kochi,  // 四万十川
        "camping_aso_name": .kumamoto,  // 阿蘇
        "camping_kuju_name": .oita,  // くじゅう
        "camping_kirishima_name": .kagoshima,  // 霧島(座標31.93,130.86は鹿児島側)
        "camping_yakushima_name": .kagoshima,  // 屋久島
        "camping_yanbaru_name": .okinawa,  // やんばる
        "sea_miyako_irabu_name": .okinawa,  // 宮古・伊良部
        "sea_ishigaki_kabira_name": .okinawa,  // 石垣島川平
        "sea_shirahama_name": .wakayama,  // 白浜
        "sea_tsunoshima_name": .yamaguchi,  // 角島
        "sea_takeno_name": .hyogo,  // 竹野(豊岡市)
        "sea_kujukurihama_name": .chiba,  // 九十九里浜
        "sea_shonan_name": .kanagawa,  // 湘南
        "sea_izu_shirahama_name": .shizuoka,  // 伊豆白浜
        "sea_chirihama_name": .ishikawa,  // 千里浜
        "sea_tottori_name": .tottori,  // 鳥取砂丘
        "sea_katsurahama_name": .kochi,  // 桂浜
        "sea_blue_cave_name": .okinawa,  // 青の洞窟(恩納村)
        "sea_zanpa_name": .okinawa,  // 残波岬
        "sea_manzamo_name": .okinawa,  // 万座毛
        "sea_hedo_name": .okinawa,  // 辺戸岬
        "sea_erimo_cape_name": .hokkaido,  // 襟裳岬
        "sea_shakotan_name": .hokkaido,  // 積丹
        "sea_shiretoko_name": .hokkaido,  // 知床
        "sea_sanriku_name": .iwate,  // 三陸(座標39.64,141.94は岩手側)
        "sea_matsushima_name": .miyagi,  // 松島
        "sea_tanesashi_name": .aomori,  // 種差海岸(八戸市)
        "sea_jogashima_name": .kanagawa,  // 城ヶ島
        "sea_enoshima_name": .kanagawa,  // 江の島
        "sea_atami_name": .shizuoka,  // 熱海
        "sea_iseshima_name": .mie,  // 伊勢志摩
        "sea_amanohashidate_name": .kyoto,  // 天橋立
        "sea_naruto_name": .tokushima,  // 鳴門
        "sea_muroto_name": .kochi,  // 室戸岬
        "sea_ashizuri_name": .kochi,  // 足摺岬
        "sea_munakata_name": .fukuoka,  // 宗像(座標34.24,130.10)
        "sea_iki_tsushima_name": .nagasaki,  // 壱岐・対馬
        "sea_amakusa_name": .kumamoto,  // 天草
        "sea_nichinan_name": .miyazaki,  // 日南海岸
    ]
}
