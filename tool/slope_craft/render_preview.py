#!/usr/bin/env python3
"""생성 좌표를 눈으로 검증할 합성 이미지를 만든다 (스크래치 전용, 커밋하지 않는다).

  00_overview_{슬러그}.png   리조트 한 장에 전체 마커. 빨간 링=현재, 초록 점=생성값.
  move_{이동량}_{슬러그}_{키}.png
                             슬로프 하나 확대. 그 슬로프 하이라이트를 올리고
                             alpha>=128 마스크를 자홍색으로 덧칠해 **생성기가 본 것**을
                             그대로 보여준다 → 임계값 문제가 추측이 아니라 눈에 보인다.
                             파일명이 이동량 내림차순이라 `ls`로 최악부터 본다.

⚠️ o2 주의: o2_default.png는 780x909인데 하이라이트는 780x900이다. 화면에서는
`BoxFit.cover`가 기본지도 위아래를 4.5행씩 잘라낸다. 이 스크립트도 **같은 잘림을
재현**한다 — 원본을 그냥 그리면 o2 10장에서 9px짜리 가짜 어긋남이 보이고, 그걸 보고
손보정하면 틀린 방향으로 고치게 된다.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import dart_table
import gen_marker_pos as gen
import pngio

CARD_BG = (0xD2, 0xE4, 0xEE)   # kSlopeCraftMapBackground — 앱 카드색
OLD_COLOR = (0xE0, 0x00, 0x00)
NEW_COLOR = (0x00, 0xA0, 0x00)
LINK_COLOR = (0x70, 0x70, 0x70)
MASK_TINT = (0xFF, 0x00, 0xC0)
MASK_ALPHA = 0.35

W, H = gen.SOURCE_W, gen.SOURCE_H

# 색인 숫자용 5x7 비트맵. 글자는 넣지 않는다 — 색 범례는 stdout과 README에 있다.
DIGITS = {
    '0': ('01110', '10001', '10011', '10101', '11001', '10001', '01110'),
    '1': ('00100', '01100', '00100', '00100', '00100', '00100', '01110'),
    '2': ('01110', '10001', '00001', '00010', '00100', '01000', '11111'),
    '3': ('11110', '00001', '00001', '01110', '00001', '00001', '11110'),
    '4': ('00010', '00110', '01010', '10010', '11111', '00010', '00010'),
    '5': ('11111', '10000', '11110', '00001', '00001', '10001', '01110'),
    '6': ('00110', '01000', '10000', '11110', '10001', '10001', '01110'),
    '7': ('11111', '00001', '00010', '00100', '01000', '01000', '01000'),
    '8': ('01110', '10001', '10001', '01110', '10001', '10001', '01110'),
    '9': ('01110', '10001', '10001', '01111', '00001', '00010', '01100'),
}


class Canvas:
    def __init__(self, bg):
        self.px = bytearray(bg * (W * H))

    def blend(self, x, y, color, alpha=1.0):
        if not (0 <= x < W and 0 <= y < H):
            return
        i = (y * W + x) * 3
        for c in range(3):
            self.px[i + c] = int(self.px[i + c] * (1 - alpha) + color[c] * alpha)

    def disc(self, cx, cy, r, color, alpha=1.0):
        for y in range(cy - r, cy + r + 1):
            for x in range(cx - r, cx + r + 1):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                    self.blend(x, y, color, alpha)

    def ring(self, cx, cy, r, color, thickness=2):
        inner = (r - thickness) ** 2
        for y in range(cy - r, cy + r + 1):
            for x in range(cx - r, cx + r + 1):
                d = (x - cx) ** 2 + (y - cy) ** 2
                if inner <= d <= r * r:
                    self.blend(x, y, color)

    def line(self, x0, y0, x1, y1, color):
        dx, dy = abs(x1 - x0), abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        err = dx - dy
        while True:
            self.blend(x0, y0, color)
            if x0 == x1 and y0 == y1:
                return
            e2 = err * 2
            if e2 > -dy:
                err -= dy
                x0 += sx
            if e2 < dx:
                err += dx
                y0 += sy

    def number(self, x, y, text, color, scale=2):
        for ch in text:
            glyph = DIGITS.get(ch)
            if glyph:
                for ry, row in enumerate(glyph):
                    for rx, bit in enumerate(row):
                        if bit == '1':
                            for sy in range(scale):
                                for sx in range(scale):
                                    self.blend(x + rx * scale + sx,
                                               y + ry * scale + sy, color)
            x += 6 * scale


def composite_cover(canvas, path):
    """PNG을 780x900 틀에 `BoxFit.cover`와 **같은 방식**으로 올린다.

    780x900이 아닌 기본지도(o2 780x909, gangchon/muju 781x901)도 화면과 똑같이
    확대·중앙 잘림된다 → 미리보기가 실제 화면과 어긋나지 않는다.
    """
    sw, sh, bpp, px = pngio.decode(path)
    scale = max(W / sw, H / sh)
    # 틀 중앙과 이미지 중앙을 맞춘 뒤 역변환으로 소스 픽셀을 찍는다(최근접).
    ox = (sw * scale - W) / 2
    oy = (sh * scale - H) / 2
    for y in range(H):
        syf = int((y + oy) / scale)
        if not (0 <= syf < sh):
            continue
        for x in range(W):
            sxf = int((x + ox) / scale)
            if not (0 <= sxf < sw):
                continue
            i = (syf * sw + sxf) * bpp
            a = px[i + 3] / 255 if bpp == 4 else 1.0
            if a > 0:
                canvas.blend(x, y, (px[i], px[i + 1], px[i + 2]), a)


def mark(canvas, old, new, index=None):
    ox, oy = int(old[0] * W), int(old[1] * H)
    nx, ny = int(new[0] * W), int(new[1] * H)
    canvas.line(ox, oy, nx, ny, LINK_COLOR)
    canvas.ring(ox, oy, 7, OLD_COLOR, 2)
    canvas.disc(nx, ny, 6, (255, 255, 255))     # 흰 테두리 — 눈·지형 양쪽에서 보이게
    canvas.disc(nx, ny, 5, NEW_COLOR)
    if index is not None:
        canvas.number(nx + 9, ny - 7, f'{index:02d}', NEW_COLOR)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('out_dir')
    ap.add_argument('--overrides', action='store_true')
    ap.add_argument('--overview-only', action='store_true')
    args = ap.parse_args()
    os.makedirs(args.out_dir, exist_ok=True)

    legacy = dart_table.read_offset_table()
    slug = dart_table.read_slug_table()
    table, rows, _warn, _slug, _nudged = gen.build(apply_overrides=args.overrides)
    move_of = {(s, k): m for m, s, k, _o, _n, _i in rows}

    print('범례:  빨간 링 = 현재 좌표   초록 점 = 생성 좌표   회색 선 = 이동')
    print('       자홍색 = 생성기가 본 마스크(alpha>=128)  [확대 이미지만]')
    print()

    for rid, keys in legacy.items():
        s = slug[rid]
        default = f'{gen.ASSET_DIR}/{s}/{s}_default.png'

        base = Canvas(CARD_BG)
        composite_cover(base, default)
        note = ''
        dw, dh, _b, _p = pngio.decode(default)
        if (dw, dh) != (W, H):
            note = (f'  ⚠️ 기본지도 {dw}x{dh} — 화면처럼 중앙 잘림을 재현했다. '
                    f'하이라이트는 {W}x{H}로 정확하니 좌표는 믿을 수 있다.')

        overview = Canvas(CARD_BG)
        overview.px[:] = base.px
        print(f'{s} ({len(keys)}개){note}')
        for i, (key, old) in enumerate(keys.items(), 1):
            mark(overview, old, table[rid][key], index=i)
            print(f'   {i:02d} {key}  이동 {move_of[(s, key)]:.3f}')
        pngio.encode_rgb(f'{args.out_dir}/00_overview_{s}.png', W, H, overview.px)

        if args.overview_only:
            continue

        for key, old in keys.items():
            c = Canvas(CARD_BG)
            c.px[:] = base.px
            path = f'{gen.ASSET_DIR}/{s}/{s}_{key}.png'
            composite_cover(c, path)
            # 생성기가 쓴 마스크를 그대로 덧칠한다.
            hw, hh, hbpp, hpx = pngio.decode(path)
            if (hw, hh) == (W, H):
                for y in range(H):
                    for x in range(W):
                        if hpx[(y * W + x) * hbpp + 3] >= gen.ALPHA_THRESHOLD:
                            c.blend(x, y, MASK_TINT, MASK_ALPHA)
            mark(c, old, table[rid][key])
            name = f'move_{move_of[(s, key)]:.3f}_{s}_{key}.png'
            pngio.encode_rgb(f'{args.out_dir}/{name}', W, H, c.px)

    print(f'\n{args.out_dir} 에 생성 완료')


if __name__ == '__main__':
    main()
