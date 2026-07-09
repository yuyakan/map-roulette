#!/usr/bin/env python3
"""
確定した1枚をアプリに取り込む。
  add_photo.py <nameKey> <commons_file_title>
Commons API からライセンス/作者/元URL/直リンクを取得し、
  - Assets.xcassets/Attractions/<nameKey>.imageset/ に長辺1600pxで配置
  - photo_credits.json に TASL レコードを追記（CC0でも記録。CC0は表示不要だが台帳には残す）
license が CC BY-SA/GFDL/NC/ND のものは弾く（取り込まない）。
"""
import json, os, re, subprocess, sys, urllib.parse, urllib.request

REPO = "/Users/uebetsunawayuuya/MapRoulette/MapRoulette"
ATTR = f"{REPO}/Assets.xcassets/Attractions"
LEDGER = f"{REPO}/photo_credits.json"
UA = "MapRoulette/1.0 (image import; kanbe1365@icloud.com)"
API = "https://commons.wikimedia.org/w/api.php"

def api_imageinfo(title):
    q = urllib.parse.urlencode({
        "action": "query", "titles": title, "prop": "imageinfo",
        "iiprop": "url|extmetadata|size|mime", "format": "json",
    })
    req = urllib.request.Request(API + "?" + q, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as r:
        d = json.load(r)
    p = list(d["query"]["pages"].values())[0]
    return p["title"], p["imageinfo"][0]

def strip(v):
    return re.sub(r"<[^>]+>", "", v or "").replace("&amp;", "&").strip()

def license_class(short):
    s = (short or "").lower()
    if "sa" in s or "share" in s or "gfdl" in s or "gnu" in s or "nc" in s or "nd" in s:
        return None
    if s.startswith("cc0") or "public domain" in s or s == "pd":
        return "CC0"
    if s.startswith("cc by") or s.startswith("cc-by"):
        return "CC BY"
    return None

def main():
    name_key, title = sys.argv[1], sys.argv[2]
    if not title.lower().startswith("file:"):
        title = "File:" + title
    full_title, ii = api_imageinfo(title)
    em = ii["extmetadata"]
    short = em.get("LicenseShortName", {}).get("value", "")
    lc = license_class(short)
    if lc is None:
        print(f"REJECT [{name_key}] license={short!r} → 取り込まない")
        sys.exit(2)

    # ダウンロード
    imgset = f"{ATTR}/{name_key}.imageset"
    os.makedirs(imgset, exist_ok=True)
    tmp = f"/tmp/{name_key}_src"
    req = urllib.request.Request(ii["url"], headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r, open(tmp, "wb") as f:
        f.write(r.read())
    # リサイズ＋JPEG化
    out = f"{imgset}/{name_key}.jpg"
    subprocess.run(["sips", "-Z", "1600", "-s", "format", "jpeg", tmp, "--out", out],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    os.remove(tmp)
    # Contents.json
    with open(f"{imgset}/Contents.json", "w") as f:
        json.dump({
            "images": [
                {"filename": f"{name_key}.jpg", "idiom": "universal", "scale": "1x"},
                {"idiom": "universal", "scale": "2x"},
                {"idiom": "universal", "scale": "3x"},
            ],
            "info": {"author": "xcode", "version": 1},
        }, f, indent=2)

    # 台帳へ追記
    ledger = []
    if os.path.exists(LEDGER):
        ledger = json.load(open(LEDGER))
    ledger = [x for x in ledger if x["nameKey"] != name_key]  # 上書き
    ledger.append({
        "nameKey": name_key,
        "licenseClass": lc,
        "license": short,
        "licenseUrl": em.get("LicenseUrl", {}).get("value", ""),
        "author": strip(em.get("Artist", {}).get("value", "")),
        "title": full_title.replace("File:", ""),
        "sourceUrl": ii.get("descriptionurl", ""),
        "modified": "resized",
    })
    ledger.sort(key=lambda x: x["nameKey"])
    json.dump(ledger, open(LEDGER, "w"), ensure_ascii=False, indent=1)
    sz = os.path.getsize(out) // 1024
    print(f"OK [{name_key}] {lc} ({short}) {sz}KB  by {strip(em.get('Artist',{}).get('value',''))[:30]}")

if __name__ == "__main__":
    main()
