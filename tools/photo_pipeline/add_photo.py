#!/usr/bin/env python3
"""
確定した1枚をアプリに取り込む。
  add_photo.py <nameKey> <commons_file_title>            # 観光スポット（従来どおり）
  add_photo.py --gourmet  <nameKey>  <commons_file_title>
  add_photo.py --nature   <nameKey>  <commons_file_title>
  add_photo.py --festival <キー接頭辞> <commons_file_title>

Commons API からライセンス/作者/元URL/直リンクを取得し、
  - Assets.xcassets/<カテゴリ>/<asset名>.imageset/ に長辺1600pxで配置
  - photo_credits.json に TASL レコードを追記（CC0でも記録。CC0は表示不要だが台帳には残す）
license が CC BY-SA/GFDL/NC/ND のものは弾く（取り込まない）。

キーと asset 名の対応（アプリ側 Model/CategoryPhoto.swift と一致させること）:
  観光  attraction_kegon_falls        → Attractions/attraction_kegon_falls
  グルメ gourmet_genghis_khan          → Gourmet/gourmet_genghis_khan
  自然  nightview_hakodate_name       → Nature/nature_nightview_hakodate
  祭り  aomori_nebuta_festival        → Festivals/festival_aomori_nebuta_festival
        （祭りは "<キー>_name" が ja.lproj に在ることを検査する）
"""
import json, os, re, subprocess, sys, urllib.parse, urllib.request

REPO = "/Users/uebetsunawayuuya/MapRoulette/MapRoulette"
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

# ─────────────────────────────────────────────────────────────
# キーの実在検査。
# タイポは「imageset は出来るが画面には一生出ない」無言の失敗になるため、
# 取り込み前に必ず元データ側にそのキーが在ることを確かめる。
# ─────────────────────────────────────────────────────────────

def _src(path):
    return open(f"{REPO}/{path}", encoding="utf-8").read()

def known_name_keys():
    """TourismInfo.swift に実在する観光スポットの nameKey。"""
    return set(re.findall(r'nameKey:\s*"(\w+)"', _src("Model/TourismInfo.swift")))

def known_gourmet_keys():
    """Gourmet.swift に実在するグルメの nameKey。"""
    return set(re.findall(r'nameKey:\s*"(\w+)"', _src("Model/Gourmet.swift")))

def known_nature_keys():
    """NatureSpotMapView.swift の自然スポット定義に実在する nameKey。"""
    src = _src("Views/Nature/NatureSpotMapView.swift")
    return set(re.findall(r'\("(\w+_name)",\s*"\w+_description"', src))

def known_ja_keys():
    """ja.lproj/Localizable.strings に定義されている全キー。"""
    src = _src("Base/ja.lproj/Localizable.strings")
    return set(re.findall(r'^"([^"]+)"\s*=', src, re.M))

# カテゴリ定義: (Assets サブフォルダ, asset 名の作り方, キー検査)
def attraction_asset(key):
    return key

def gourmet_asset(key):
    return key

def nature_asset(key):
    base = key[:-len("_name")] if key.endswith("_name") else key
    return "nature_" + base

def festival_asset(key):
    base = key[:-len("_name")] if key.endswith("_name") else key
    return "festival_" + base

CATEGORIES = {
    "attraction": {
        "dir": "Attractions",
        "asset": attraction_asset,
        # beach_* は別データ源（PrefectureTheme.swift）なので従来どおり検査を免除。
        "check": lambda k: k.startswith("beach_") or k in known_name_keys(),
        "where": "Model/TourismInfo.swift",
    },
    "gourmet": {
        "dir": "Gourmet",
        "asset": gourmet_asset,
        "check": lambda k: k in known_gourmet_keys(),
        "where": "Model/Gourmet.swift",
    },
    "nature": {
        "dir": "Nature",
        "asset": nature_asset,
        "check": lambda k: k in known_nature_keys(),
        "where": "Views/Nature/NatureSpotMapView.swift",
    },
    "festival": {
        "dir": "Festivals",
        "asset": festival_asset,
        # 祭りは安定キーを持たず、アプリ側は「表示名 → "<キー>_name"」の逆引きで
        # asset を決める。よって検査対象は "<キー>_name" が ja に在るかどうか。
        "check": lambda k: (k if k.endswith("_name") else k + "_name") in known_ja_keys(),
        "where": "Base/ja.lproj/Localizable.strings の *_name",
    },
}

def main():
    args = sys.argv[1:]
    category = "attraction"
    if args and args[0].startswith("--"):
        category = args[0][2:]
        args = args[1:]
        if category not in CATEGORIES:
            print(f"不明なカテゴリ: --{category}（{'/'.join(CATEGORIES)}）")
            sys.exit(4)
    if len(args) < 2:
        print(__doc__)
        sys.exit(4)

    name_key, title = args[0], args[1]
    cat = CATEGORIES[category]

    if not cat["check"](name_key):
        print(f"REJECT [{name_key}] {cat['where']} に該当キーが無い → 取り込まない")
        sys.exit(3)

    asset = cat["asset"](name_key)
    outdir = f"{REPO}/Assets.xcassets/{cat['dir']}"

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
    imgset = f"{outdir}/{asset}.imageset"
    os.makedirs(imgset, exist_ok=True)
    tmp = f"/tmp/{asset}_src"
    req = urllib.request.Request(ii["url"], headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r, open(tmp, "wb") as f:
        f.write(r.read())
    # リサイズ＋JPEG化
    out = f"{imgset}/{asset}.jpg"
    subprocess.run(["sips", "-Z", "1600", "-s", "format", "jpeg", tmp, "--out", out],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    os.remove(tmp)
    # Contents.json
    with open(f"{imgset}/Contents.json", "w") as f:
        json.dump({
            "images": [
                {"filename": f"{asset}.jpg", "idiom": "universal", "scale": "1x"},
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
        # クレジット画面で「どのカテゴリの何か」を出すために記録する。
        # 既存レコード（category 無し）は観光スポットとして扱う。
        "category": category,
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
    print(f"OK [{category}/{asset}] {lc} ({short}) {sz}KB  by {strip(em.get('Artist',{}).get('value',''))[:30]}")

if __name__ == "__main__":
    main()
