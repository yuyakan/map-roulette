#!/usr/bin/env python3
"""
複数スポットの候補をまとめて検索し、カード(260x180 ≒ 1.44)に適した
横構図・高解像度のものだけを絞って一覧する。

使い方:
  batch_find.py <<'EOF'
  attraction_key<TAB>検索語
  ...
  EOF

採用基準（README準拠）で足切りする:
  - アスペクト比 1.15〜2.2（極端なパノラマ・縦構図を除外）
  - 長辺 1200px 以上（低解像度を除外）
出力は各キーにつき最大3件。目視は呼び出し側で行う。
"""
import json, subprocess, sys, time, os

HERE = os.path.dirname(os.path.abspath(__file__))

def find(query, n=6):
    out = subprocess.run(["python3", f"{HERE}/find_cc.py", query, str(n)],
                         capture_output=True, text=True).stdout
    try:
        return json.loads(out)
    except Exception:
        return []

def ok(x):
    w, h = x["width"], x["height"]
    if h == 0:
        return False
    r = w / h
    return 1.15 <= r <= 2.2 and max(w, h) >= 1200

def main():
    rows = [l.rstrip("\n").split("\t") for l in sys.stdin if l.strip()]
    for i, row in enumerate(rows):
        key, query = row[0], row[1]
        cands = [x for x in find(query) if ok(x)]
        print(f"### {key}\t{query}")
        for x in cands[:3]:
            r = x["width"] / x["height"]
            print(f"  {x['license_class']:6} r={r:.2f} {x['width']}x{x['height']:<5} "
                  f"{x['author'][:16]:16} | {x['title'][5:]}")
        if not cands:
            print("  (none)")
        sys.stdout.flush()
        if i < len(rows) - 1:
            time.sleep(6)

if __name__ == "__main__":
    main()
