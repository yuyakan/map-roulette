#!/usr/bin/env python3
"""
目視用プレビュー: Commons の直リンクURLを受け取り、scratchpad に取得して
長辺600pxに縮小した JPEG を出力する。curl を使わず urllib で取得（権限回避）。
使い方: preview.py <fileurl> <out_name_without_ext>
"""
import os, subprocess, sys, tempfile, urllib.request

# 出力先はセッションごとに変わるため固定パスにしない。
# 環境変数 PREVIEW_DIR があればそれを使い、無ければ一時ディレクトリ。
SCRATCH = os.environ.get("PREVIEW_DIR") or tempfile.gettempdir()
os.makedirs(SCRATCH, exist_ok=True)
UA = "MapRoulette/1.0 (image preview; kanbe1365@icloud.com)"

def main():
    url, name = sys.argv[1], sys.argv[2]
    tmp = f"{SCRATCH}/{name}_src"
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r, open(tmp, "wb") as f:
        f.write(r.read())
    out = f"{SCRATCH}/{name}.jpg"
    subprocess.run(["sips", "-Z", "600", "-s", "format", "jpeg", tmp, "--out", out],
                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(out)

if __name__ == "__main__":
    main()
