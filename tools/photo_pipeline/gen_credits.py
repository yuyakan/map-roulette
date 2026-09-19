#!/usr/bin/env python3
"""
photo_credits.json から Settings.bundle/PhotoCredits.plist を生成する。
- CC BY: TASL（作品名・作者・出典URL・ライセンス）＋改変(resized)を必須明記
- CC0 : 法的には不要だが、透明性のため出典を併記
plist の FooterText に全文を入れる（Google SDK ライセンスと同じ方式）。
"""
import json, plistlib

REPO = "/Users/uebetsunawayuuya/MapRoulette/MapRoulette"
LEDGER = f"{REPO}/photo_credits.json"
JA = f"{REPO}/Base/ja.lproj/Localizable.strings"
OUT = f"{REPO}/Settings.bundle/PhotoCredits.plist"

def load_ja_names():
    """ja.lproj の全キー→日本語名。観光・グルメ・自然・祭りのどのキーも引ける。"""
    names = {}
    import re
    for line in open(JA, encoding="utf-8"):
        m = re.match(r'"([^"]+)"\s*=\s*"(.+?)";', line.strip())
        if m:
            names[m.group(1)] = m.group(2)
    return names

# 台帳の category → クレジット画面に出す見出し。
# category を持たない既存レコードは観光スポット。
CATEGORY_LABEL = {
    "attraction": "観光スポット",
    "gourmet": "グルメ",
    "nature": "自然スポット",
    "festival": "祭り・行事",
}

def display_name(rec, names):
    """台帳1件の表示名（日本語）。祭りは "<キー>_name" 側に名前がある。"""
    key = rec["nameKey"]
    for candidate in (key, key + "_name"):
        if candidate in names:
            return names[candidate]
    return key

def category_of(rec):
    return rec.get("category", "attraction")

def main():
    ledger = json.load(open(LEDGER))
    names = load_ja_names()
    ledger.sort(key=lambda x: (x["licenseClass"] != "CC BY", x["nameKey"]))

    ccby = [x for x in ledger if x["licenseClass"] == "CC BY"]
    cc0  = [x for x in ledger if x["licenseClass"] == "CC0"]

    lines = []
    lines.append("本アプリの写真（観光スポット・グルメ・自然スポット・祭り）の一部は、")
    lines.append("Wikimedia Commons 上のクリエイティブ・コモンズ表示（CC BY）")
    lines.append("ライセンスで提供されている作品を、アプリ内表示に合わせて")
    lines.append("リサイズして使用しています。")
    lines.append("各作品の帰属情報は以下の通りです。")
    lines.append("")
    lines.append("──────────────")
    lines.append("CC BY（表示ライセンス）")
    lines.append("──────────────")
    for x in ccby:
        spot = f"{display_name(x, names)}（{CATEGORY_LABEL[category_of(x)]}）"
        lines.append(f"● {spot}")
        lines.append(f'  「{x["title"]}」')
        lines.append(f'  Author: {x["author"]}')
        lines.append(f'  License: {x["license"]} ({x["licenseUrl"]})')
        lines.append(f'  Source: {x["sourceUrl"]}')
        lines.append(f'  ※アプリ表示用にリサイズ (resized)')
        lines.append("")

    if cc0:
        lines.append("──────────────")
        lines.append("パブリックドメイン / CC0（帰属義務なし・参考出典）")
        lines.append("──────────────")
        for x in cc0:
            spot = f"{display_name(x, names)}（{CATEGORY_LABEL[category_of(x)]}）"
            lines.append(f"● {spot} — {x['author'] or 'Unknown'}")
            lines.append(f'  {x["sourceUrl"]}')
        lines.append("")

    footer = "\n".join(lines)

    plist = {
        "PreferenceSpecifiers": [
            {
                "Type": "PSGroupSpecifier",
                "Title": "Photo Credits",
                "FooterText": footer,
            }
        ]
    }
    with open(OUT, "wb") as f:
        plistlib.dump(plist, f)
    print(f"生成: {OUT}")
    print(f"CC BY {len(ccby)}件 / CC0 {len(cc0)}件")

if __name__ == "__main__":
    main()
