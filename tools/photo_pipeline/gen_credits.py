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
    names = {}
    import re
    for line in open(JA, encoding="utf-8"):
        m = re.match(r'"(attraction_\w+)"\s*=\s*"(.+?)";', line.strip())
        if m:
            names[m.group(1)] = m.group(2)
    return names

def main():
    ledger = json.load(open(LEDGER))
    names = load_ja_names()
    ledger.sort(key=lambda x: (x["licenseClass"] != "CC BY", x["nameKey"]))

    ccby = [x for x in ledger if x["licenseClass"] == "CC BY"]
    cc0  = [x for x in ledger if x["licenseClass"] == "CC0"]

    lines = []
    lines.append("本アプリの観光スポット写真の一部は、Wikimedia Commons 上の")
    lines.append("クリエイティブ・コモンズ表示（CC BY）ライセンスで提供されている")
    lines.append("作品を、アプリ内表示に合わせてリサイズして使用しています。")
    lines.append("各作品の帰属情報は以下の通りです。")
    lines.append("")
    lines.append("──────────────")
    lines.append("CC BY（表示ライセンス）")
    lines.append("──────────────")
    for x in ccby:
        spot = names.get(x["nameKey"], x["nameKey"])
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
            spot = names.get(x["nameKey"], x["nameKey"])
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
