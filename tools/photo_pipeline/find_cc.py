#!/usr/bin/env python3
"""
Commons のカテゴリ or 検索語から、CC0 / CC BY(バージョン不問) の画像だけを抽出する。
CC BY-SA / GFDL / その他制限つきは除外。
使い方: find_cc.py "search term" [max]
出力: 各候補の JSON（license, author, descurl, fileurl, title, width）
"""
import json, sys, urllib.parse, urllib.request

UA = "MapRoulette/1.0 (CC0/CCBY image finder; contact kanbe1365@icloud.com)"
API = "https://commons.wikimedia.org/w/api.php"

def api(params):
    params["format"] = "json"
    url = API + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)

def search_files(term, limit=40):
    # ファイル名前空間(6)を全文検索
    d = api({
        "action": "query", "list": "search",
        "srsearch": f"{term}", "srnamespace": "6",
        "srlimit": str(limit),
    })
    return [x["title"] for x in d.get("query", {}).get("search", [])]

def imageinfo(titles):
    # 最大50件まとめて取得
    d = api({
        "action": "query", "titles": "|".join(titles),
        "prop": "imageinfo",
        "iiprop": "url|extmetadata|size|mime",
    })
    return list(d.get("query", {}).get("pages", {}).values())

# 許容ライセンス判定: CC0 / PD / CC BY(x.x) は許可。SA・GFDL・NC・ND は不可。
def license_ok(short):
    s = (short or "").lower()
    if not s:
        return None
    if "sa" in s or "share" in s:      # CC BY-SA
        return None
    if "gfdl" in s or "gnu" in s:
        return None
    if "nc" in s or "nd" in s:
        return None
    if s.startswith("cc0") or "public domain" in s or s == "pd":
        return "CC0"
    if s.startswith("cc by") or s.startswith("cc-by"):
        return "CC BY"
    return None

def strip_html(v):
    import re
    v = re.sub(r"<[^>]+>", "", v or "")
    return v.replace("&amp;", "&").strip()

def main():
    term = sys.argv[1]
    maxn = int(sys.argv[2]) if len(sys.argv) > 2 else 8
    titles = search_files(term, 50)
    results = []
    # 50件ずつ imageinfo
    for i in range(0, len(titles), 50):
        for p in imageinfo(titles[i:i+50]):
            ii = (p.get("imageinfo") or [{}])[0]
            if not ii:
                continue
            em = ii.get("extmetadata", {})
            short = em.get("LicenseShortName", {}).get("value", "")
            ok = license_ok(short)
            if not ok:
                continue
            mime = ii.get("mime", "")
            if not mime.startswith("image/"):
                continue
            results.append({
                "license_class": ok,
                "license": short,
                "license_url": em.get("LicenseUrl", {}).get("value", ""),
                "author": strip_html(em.get("Artist", {}).get("value", ""))[:80],
                "title": p.get("title", ""),
                "descurl": ii.get("descriptionurl", ""),
                "fileurl": ii.get("url", ""),
                "width": ii.get("width", 0),
                "height": ii.get("height", 0),
            })
    # CC0優先、次に幅の大きい順
    results.sort(key=lambda r: (r["license_class"] != "CC0", -r["width"]))
    print(json.dumps(results[:maxn], ensure_ascii=False, indent=1))

if __name__ == "__main__":
    main()
