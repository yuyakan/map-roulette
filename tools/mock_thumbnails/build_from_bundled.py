"""
App Store スクショ撮影用のモックサムネを、アプリ同梱写真から作る。

【なぜ同梱写真を使うか】
gen.py が描く抽象画は権利的には最も安全だが、実写のトレンド枠に並べると
明らかに浮く。アプリ同梱写真は `photo_credits.json` で出所が台帳管理されて
いるので、**CC0 / Public domain に限れば帰属表記なしで配布物に使える**。
App Store のスクショはアプリとは別の配布物で、アプリ内クレジット画面は
ストアページの閲覧者には届かない。だから CC BY（要帰属）は使わない。

【カテゴリ対応】
トレンドの棚は spot / gourmet / cafe の3種類。棚と無関係な絵が入ると
「沖縄県のグルメ」に花火が並ぶような不自然さが出る（iPad で顕著）。
そこで棚ごとに絵の母集団を分け、ScreenshotMode 側で棚に応じて引く。

使い方:
    python3 tools/mock_thumbnails/build_from_bundled.py
出力:
    MapRoulette/Assets.xcassets/MockThumbnails/mock_<cat>_<n>.imageset/
"""
import json, glob, os, shutil
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LEDGER = os.path.join(ROOT, "MapRoulette/photo_credits.json")
OUTDIR = os.path.join(ROOT, "MapRoulette/Assets.xcassets/MockThumbnails")
W, H = 720, 1280                      # 9:16（カードもプレイヤーも縦型）
FREE = ("CC0", "Public domain")       # 帰属表記が要らないものだけ
DIRS = {"attraction": "Attractions", "gourmet": "Gourmet",
        "nature": "Nature", "festival": "Festivals"}

# 棚ごとに使う母集団。cafe は「落ち着いた屋内・静かな風景」に寄せたいので
# 自然＋祭り以外の名所から引く（甘味・茶の写真は gourmet 側に置く）。
SHELVES = {
    "gourmet": {"cats": ("gourmet",), "count": 8},
    "spot":    {"cats": ("attraction",), "count": 8},
    "cafe":    {"cats": ("nature",), "count": 6},
}


def asset_path(entry):
    cat = entry.get("category", "attraction")
    key = entry["nameKey"].replace(".", "_")
    if cat == "nature" and not key.startswith("nature_"):
        key = "nature_" + key.replace("_name", "")
    if cat == "festival" and not key.startswith("festival_"):
        key = "festival_" + key
    hits = [p for p in glob.glob(f"{os.path.join(ROOT,'MapRoulette/Assets.xcassets',DIRS[cat],key)}.imageset/*")
            if p.lower().endswith((".jpg", ".jpeg", ".png"))]
    return hits[0] if hits else None


def crop_portrait(src, dst):
    """中央基準で 9:16 に切り出す。上寄せぎみにして被写体の頭を残す。"""
    im = Image.open(src).convert("RGB")
    tw, th = W / H, im.width / im.height
    if th > tw:                                   # 横長 → 左右を落とす
        nw = int(im.height * tw)
        x = (im.width - nw) // 2
        im = im.crop((x, 0, x + nw, im.height))
    else:                                         # 縦長 → 下を多めに落とす
        nh = int(im.width / tw)
        y = int((im.height - nh) * 0.35)
        im = im.crop((0, y, im.width, y + nh))
    im = im.resize((W, H), Image.LANCZOS)
    im.save(dst, "JPEG", quality=82, optimize=True)


CONTENTS = json.dumps({
    "images": [{"filename": "", "idiom": "universal", "scale": s} for s in ("1x", "2x", "3x")],
    "info": {"author": "xcode", "version": 1},
}, indent=2)


def write_imageset(name, jpg_src):
    d = os.path.join(OUTDIR, f"{name}.imageset")
    os.makedirs(d, exist_ok=True)
    crop_portrait(jpg_src, os.path.join(d, f"{name}.jpg"))
    c = json.loads(CONTENTS)
    c["images"][0]["filename"] = f"{name}.jpg"      # 単一画像（1x に入れる）
    json.dump(c, open(os.path.join(d, "Contents.json"), "w"), indent=2)


def main():
    led = json.load(open(LEDGER))
    free = [x for x in led if x.get("license") in FREE]
    pool = {}
    for x in free:
        p = asset_path(x)
        if p:
            pool.setdefault(x.get("category", "attraction"), []).append((x["nameKey"], p))
    for k in pool:
        pool[k].sort()                              # 実行ごとに同じ選択になるよう固定

    # 既存の mock_trend_* は作り直し対象。消してから書く。
    for old in glob.glob(os.path.join(OUTDIR, "mock_*.imageset")):
        shutil.rmtree(old)

    manifest = {}
    for shelf, spec in SHELVES.items():
        cands = [e for c in spec["cats"] for e in pool.get(c, [])]
        step = max(1, len(cands) // spec["count"])  # 母集団全体から散らして取る
        picked = cands[::step][:spec["count"]]
        names = []
        for i, (key, path) in enumerate(picked, 1):
            name = f"mock_{shelf}_{i}"
            write_imageset(name, path)
            names.append(name)
            print(f"  {name:16s} <- {key}")
        manifest[shelf] = names

    print("\nScreenshotMode.mockAssets に貼る内容:")
    for shelf, names in manifest.items():
        joined = ", ".join(f'"{n}"' for n in names)
        print(f'    "{shelf}": [{joined}],')


if __name__ == "__main__":
    main()
