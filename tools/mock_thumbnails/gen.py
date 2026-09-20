"""
App Store スクショ撮影用のモックサムネを生成する。

方針:
- 実在の YouTube 動画のサムネに似せない。人物・ロゴ・文字を入れない。
- 「旅の風景」と分かる抽象的なシーンだけを、9:16 の縦型で描く。
- 特定の実在スポットの写真ではなく、幾何形状のみで構成する。
"""
from PIL import Image, ImageDraw, ImageFilter
import math, random

W, H = 720, 1280   # 9:16

def lerp(a, b, t): return tuple(int(a[i] + (b[i]-a[i])*t) for i in range(3))

def vgrad(img, top, bottom, y0=0, y1=None):
    y1 = y1 if y1 is not None else H
    d = ImageDraw.Draw(img)
    for y in range(y0, y1):
        t = (y-y0)/max(1,(y1-y0-1))
        d.line([(0,y),(W,y)], fill=lerp(top,bottom,t))

def sun(img, cx, cy, r, color, glow=True):
    ov = Image.new("RGB", (W,H), (0,0,0))
    d = ImageDraw.Draw(ov)
    d.ellipse([cx-r,cy-r,cx+r,cy+r], fill=color)
    if glow:
        ov = ov.filter(ImageFilter.GaussianBlur(40))
    img_px, ov_px = img.load(), ov.load()
    for y in range(H):
        for x in range(W):
            a,b = img_px[x,y], ov_px[x,y]
            img_px[x,y] = tuple(min(255, a[i]+b[i]) for i in range(3))
    d2 = ImageDraw.Draw(img)
    d2.ellipse([cx-r,cy-r,cx+r,cy+r], fill=color)

def ridge(d, base_y, amp, color, seed, steps=90):
    rnd = random.Random(seed)
    pts, phase = [], rnd.random()*6.28
    for i in range(steps+1):
        x = W*i/steps
        y = base_y - (math.sin(phase + i*0.16)*amp*0.5
                      + math.sin(phase*2 + i*0.07)*amp*0.5)
        pts.append((x,y))
    d.polygon(pts + [(W,H),(0,H)], fill=color)

def water(img, y0, color):
    """水面: 下半分を色で塗り、横方向の淡いハイライトを重ねる"""
    d = ImageDraw.Draw(img)
    d.rectangle([0,y0,W,H], fill=color)
    rnd = random.Random(7)
    for _ in range(70):
        y = rnd.randint(y0+8, H-8)
        x = rnd.randint(0, W-1)
        w = rnd.randint(40, 200)
        c = tuple(min(255,int(color[i]*1.35)) for i in range(3))
        d.line([(x,y),(x+w,y)], fill=c, width=2)

def grain(img, amount=5):
    px = img.load(); rnd = random.Random(99)
    for y in range(0,H,2):
        for x in range(0,W,2):
            n = rnd.randint(-amount, amount)
            r,g,b = px[x,y]
            px[x,y] = (max(0,min(255,r+n)), max(0,min(255,g+n)), max(0,min(255,b+n)))
    return img.filter(ImageFilter.GaussianBlur(0.4))

# ---------------- シーン定義 ----------------

def scene_cafe():
    """カフェの窓辺。外の緑・窓枠・テーブルのカップを横から見た構図。"""
    img = Image.new("RGB",(W,H))
    vgrad(img,(92,62,46),(44,30,24))
    d = ImageDraw.Draw(img)
    # 窓の外（空と緑）
    d.rectangle([60,120,660,760], fill=(198,224,232))
    d.rectangle([60,520,660,760], fill=(150,186,140))
    rnd = random.Random(21)
    for _ in range(16):                                   # 外の木
        x = rnd.randint(70,640); r = rnd.randint(40,90)
        d.ellipse([x-r,470-r//2,x+r,470+r], fill=(108,152,104))
    # 窓枠
    d.rectangle([60,120,660,760], outline=(72,50,38), width=16)
    d.rectangle([352,120,368,760], fill=(72,50,38))
    d.rectangle([60,432,660,448], fill=(72,50,38))
    # テーブル
    d.rectangle([0,880,W,H], fill=(112,76,52))
    d.rectangle([0,880,W,920], fill=(140,98,68))
    # カップとソーサー
    d.ellipse([214,946,506,1074], fill=(232,226,216))     # ソーサー
    d.ellipse([250,930,470,1050], fill=(250,248,244))     # カップ本体
    d.ellipse([276,946,444,1032], fill=(112,70,44))       # コーヒー
    d.ellipse([292,956,428,1020], fill=(146,96,60))
    d.arc([440,952,516,1028], -70, 70, fill=(250,248,244), width=16)  # 取っ手
    # 湯気
    steam = Image.new("RGB",(W,H),(0,0,0))
    sd = ImageDraw.Draw(steam)
    for i in range(3):
        cx = 300 + i*60
        for k in range(5):
            rr = 16 + k*4
            sd.ellipse([cx-rr, 840-k*46, cx+rr, 880-k*46], fill=(40,40,40))
    steam = steam.filter(ImageFilter.GaussianBlur(22))
    sp, ip = steam.load(), img.load()
    for y in range(H):
        for x in range(W):
            a,b = ip[x,y], sp[x,y]
            ip[x,y] = tuple(min(255,a[i]+b[i]) for i in range(3))
    return grain(img)

def scene_ramen():
    """丼の俯瞰。具材は左右非対称に散らし、顔に見えないようにする。"""
    img = Image.new("RGB",(W,H))
    vgrad(img,(60,42,34),(30,22,18))
    d = ImageDraw.Draw(img)
    d.ellipse([60,330,660,930], fill=(232,226,214))    # 丼のふち
    d.ellipse([92,362,628,898], fill=(214,206,192))
    d.ellipse([112,382,608,878], fill=(198,140,74))    # スープ
    # 麺（スープ上の細い帯を弧状に）
    for i in range(11):
        y = 470 + i*34
        x0 = 170 + (i%3)*18
        x1 = 560 - (i%4)*22
        d.line([(x0,y),(x1,y)], fill=(226,186,118), width=9)
    # 具（非対称配置）
    d.ellipse([190,430,330,556], fill=(246,240,220))   # 卵
    d.ellipse([214,452,306,534], fill=(242,198,96))    # 黄身
    d.ellipse([398,690,528,806], fill=(150,102,64))    # チャーシュー
    d.ellipse([418,708,508,788], fill=(178,126,84))
    d.rounded_rectangle([196,650,330,690], 16, fill=(58,118,58))   # ねぎ
    d.rounded_rectangle([250,720,360,752], 14, fill=(46,102,50))
    d.rectangle([430,420,470,560], fill=(40,44,52))    # 海苔
    d.ellipse([520,560,580,620], fill=(206,86,70))     # 唐辛子
    return grain(img)

def scene_mountain():
    """朝焼けの山並み。"""
    img = Image.new("RGB",(W,H))
    vgrad(img,(250,168,110),(120,72,120))
    sun(img, 360, 600, 88, (255,232,170))
    d = ImageDraw.Draw(img)
    ridge(d, 820, 190, (92,72,116), 3)
    ridge(d, 950, 150, (58,48,84), 11)
    ridge(d, 1090, 120, (32,28,52), 23)
    return grain(img)

def scene_sea():
    """海と水平線。"""
    img = Image.new("RGB",(W,H))
    vgrad(img,(120,198,238),(214,240,248))
    sun(img, 520, 250, 66, (255,250,220))
    water(img, 700, (36,128,176))
    d = ImageDraw.Draw(img)
    d.polygon([(0,700),(W,700),(W,740),(0,740)], fill=(160,214,232))
    d.ellipse([-120,1120,860,1500], fill=(238,226,196))  # 砂浜
    return grain(img)

def scene_night():
    """夜景。ビル群と灯り。"""
    img = Image.new("RGB",(W,H))
    vgrad(img,(16,20,48),(58,40,78))
    d = ImageDraw.Draw(img)
    rnd = random.Random(5)
    for _ in range(90):   # 星
        x,y = rnd.randint(0,W), rnd.randint(0,540)
        d.point((x,y), fill=(220,220,240))
    xs = 0
    while xs < W:         # ビル
        bw = rnd.randint(52,104); bh = rnd.randint(200,470)
        top = 900-bh
        d.rectangle([xs,top,xs+bw,900], fill=(22,24,44))
        for wy in range(top+16, 890, 28):
            for wx in range(xs+10, xs+bw-10, 22):
                if rnd.random()<0.55:
                    d.rectangle([wx,wy,wx+9,wy+13], fill=(255,214,128))
        xs += bw + rnd.randint(6,18)
    d.rectangle([0,900,W,H], fill=(12,14,30))
    for _ in range(60):   # 水面の映り込み
        x = rnd.randint(0,W); y = rnd.randint(910,H)
        d.line([(x,y),(x+rnd.randint(8,26),y)], fill=(90,70,40), width=2)
    return grain(img)

def scene_festival():
    """祭りの提灯。"""
    img = Image.new("RGB",(W,H))
    vgrad(img,(40,16,28),(96,28,36))
    d = ImageDraw.Draw(img)
    rnd = random.Random(31)
    for row,(y,r) in enumerate([(300,58),(560,66),(830,58)]):
        for i in range(4):
            cx = 100 + i*170 + (30 if row==1 else 0)
            d.line([(cx,y-160),(cx,y-r)], fill=(60,40,30), width=4)
            d.ellipse([cx-r,y-r*1.25,cx+r,y+r*1.25], fill=(232,88,64))
            d.ellipse([cx-r*0.62,y-r*0.95,cx+r*0.62,y+r*0.95], fill=(248,150,110))
            d.rectangle([cx-r*0.34,y-r*1.30,cx+r*0.34,y-r*1.12], fill=(50,34,28))
            d.rectangle([cx-r*0.34,y+r*1.12,cx+r*0.34,y+r*1.30], fill=(50,34,28))
    return grain(img)

def scene_onsen():
    """露天風呂。奥に岩、手前に湯、立ちのぼる湯気。"""
    img = Image.new("RGB",(W,H))
    vgrad(img,(58,74,62),(26,36,32))
    d = ImageDraw.Draw(img)
    rnd = random.Random(41)
    # 奥の木立
    for i in range(9):
        x = -20 + i*92
        h = rnd.randint(150,260)
        d.ellipse([x, 300-h//2, x+150, 300+h//2], fill=(44,68,52))
    # 岩（大きさ・高さをばらして並べる）
    for i in range(8):
        x = -30 + i*100
        w = rnd.randint(110,170)
        hh = rnd.randint(70,120)
        top = 560 + rnd.randint(-26,18)
        d.ellipse([x, top, x+w, top+hh], fill=(70,68,62))
        d.ellipse([x+12, top+8, x+w-20, top+hh-24], fill=(88,86,78))
    # 湯船
    d.rectangle([0,660,W,H], fill=(58,116,120))
    d.ellipse([-120,620,840,860], fill=(74,140,142))
    # 湯面のゆらぎ
    for _ in range(90):
        y = rnd.randint(700,H-10); x = rnd.randint(0,W)
        w = rnd.randint(40,170)
        d.line([(x,y),(x+w,y)], fill=(104,176,176), width=3)
    # 湯気
    steam = Image.new("RGB",(W,H),(0,0,0))
    sd = ImageDraw.Draw(steam)
    for _ in range(30):
        cx,cy = rnd.randint(60,660), rnd.randint(560,900)
        rr = rnd.randint(70,160)
        sd.ellipse([cx-rr,cy-rr//2,cx+rr,cy+rr//2], fill=(52,52,52))
    steam = steam.filter(ImageFilter.GaussianBlur(50))
    sp, ip = steam.load(), img.load()
    for y in range(H):
        for x in range(W):
            a,b = ip[x,y], sp[x,y]
            ip[x,y] = tuple(min(255,a[i]+b[i]) for i in range(3))
    return grain(img)

def scene_torii():
    """鳥居のシルエット。"""
    img = Image.new("RGB",(W,H))
    vgrad(img,(246,186,132),(150,96,122))
    sun(img, 360, 700, 76, (255,238,196))
    d = ImageDraw.Draw(img)
    ridge(d, 980, 90, (72,56,80), 9)
    c=(178,48,44)                                        # 鳥居
    d.rectangle([150,470,196,1080], fill=c)
    d.rectangle([524,470,570,1080], fill=c)
    d.polygon([(96,470),(624,470),(600,418),(120,418)], fill=c)
    d.rectangle([112,500,608,536], fill=c)
    d.rectangle([336,536,384,610], fill=c)
    d.rectangle([0,1080,W,H], fill=(44,34,52))
    return grain(img)

def scene_sakura():
    """桜並木と天守。花は天守にかからないよう左右と上に配置する。"""
    img = Image.new("RGB",(W,H))
    vgrad(img,(250,220,232),(206,226,244))
    d = ImageDraw.Draw(img)
    rnd = random.Random(17)

    # 地面
    d.rectangle([0,1000,W,H], fill=(118,146,112))
    d.rectangle([0,1000,W,1030], fill=(138,166,128))

    # 天守（各層に屋根のひさしを付けて城らしくする）
    cx = 360
    layers = [ (250, 980, 900), (205, 900, 830), (160, 830, 762), (118, 762, 700) ]
    for hw, ybot, ytop in layers:
        d.polygon([(cx-hw,ybot),(cx+hw,ybot),(cx+hw-14,ytop),(cx-hw+14,ytop)],
                  fill=(78,80,104))
        # ひさし（下端で外に張り出す）
        d.polygon([(cx-hw-30,ytop+16),(cx+hw+30,ytop+16),(cx+hw-20,ytop-8),(cx-hw+20,ytop-8)],
                  fill=(54,56,78))
        # 窓
        for wx in range(cx-hw+34, cx+hw-34, 56):
            d.rectangle([wx, ytop+30, wx+18, ytop+58], fill=(226,214,180))
    # 最上層の屋根
    d.polygon([(cx-140,706),(cx+140,706),(cx,628)], fill=(54,56,78))
    d.rectangle([cx-6,600,cx+6,634], fill=(206,178,96))   # 鯱鉾がわりの棟飾り

    # 桜（天守の領域を避けて散らす）
    def on_castle(x,y):
        return (cx-300 < x < cx+300) and (600 < y < 1000)
    for _ in range(190):
        x,y = rnd.randint(0,W), rnd.randint(60,1180)
        if on_castle(x,y):
            continue
        r = rnd.randint(8,22)
        t = rnd.random()
        col = lerp((248,186,208),(252,232,240), t)
        d.ellipse([x-r,y-r,x+r,y+r], fill=col)

    # 手前の枝（上部から垂れる）
    for bx in (60, 300, 580):
        d.line([(bx-40,60),(bx+70,190)], fill=(104,74,66), width=9)
        for k in range(9):
            px = bx-40 + k*12
            py = 60 + k*14
            rr = rnd.randint(12,26)
            d.ellipse([px-rr,py-rr,px+rr,py+rr], fill=(250,200,216))
    return grain(img)

SCENES = {
    "mock_trend_cafe":     scene_cafe,
    "mock_trend_gourmet":  scene_ramen,
    "mock_trend_mountain": scene_mountain,
    "mock_trend_sea":      scene_sea,
    "mock_trend_night":    scene_night,
    "mock_trend_festival": scene_festival,
    "mock_trend_onsen":    scene_onsen,
    "mock_trend_torii":    scene_torii,
    "mock_trend_sakura":   scene_sakura,
}

for name, fn in SCENES.items():
    fn().save(f"{name}.jpg", quality=88, optimize=True)
    print("generated", name)
