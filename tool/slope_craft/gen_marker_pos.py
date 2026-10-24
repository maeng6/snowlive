#!/usr/bin/env python3
"""슬로프 하이라이트 이미지에서 PC·태블릿용 마커 좌표를 뽑는다.

왜 필요한가: 기존 좌표표는 앱(모바일) 화면에서 손으로 찍은 값이라, 지도가 큰
PC에서는 같은 비율 오차가 큰 픽셀 오차가 되어 마커가 코스를 벗어나 보인다.
하이라이트 오버레이는 전부 정확히 780x900이고 지도 틀도 780/900이라, 거기서
뽑은 비율을 보정 없이 그대로 쓸 수 있다.

기준점: alpha>=128 마스크의 알파가중 무게중심 → **마스크 위 최근접 픽셀로 스냅**.
스냅을 안 하면 ㄱ자로 휜 코스에서 무게중심이 꺾인 안쪽(코스 밖)으로 빠진다
(실측 146개 중 37개). 스냅 비용은 평균 0.0043(PC 2.6px)에 불과하다.

사용법:
    python3 tool/slope_craft/gen_marker_pos.py --report-only
    python3 tool/slope_craft/gen_marker_pos.py --out <경로>
    python3 tool/slope_craft/gen_marker_pos.py --report-only --overrides
"""

import argparse
import os
import sys
import statistics

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import dart_table
import overlap as overlap_mod
import pngio

ASSET_DIR = 'assets/imgs/imgs/slopeRush'

# 알파는 안티에일리어싱이라 이진이 아니다. 128을 쓰는 이유:
#  · `>0`은 알파 1~3의 잡색 후광까지 포함한다(파일마다 수백 px).
#  · `>=200`은 알파가 255까지 안 올라가는 24개 중 2개를 빈 마스크로 만든다
#    (yongpyong_redgoldbridge 최대 189, jisan_newOrange 204).
#  · 128이면 146개 전부 40px 이상 확보된다(실측).
ALPHA_THRESHOLD = 128

# 마스크가 이보다 작으면 무게중심을 믿을 수 없다 → 경고.
MIN_MASK_PIXELS = 40

# 알파가 이보다 낮으면 아트가 더 투명해진 것일 수 있다 → 경고(실패는 아님).
LOW_ALPHA_WARN = 200

SOURCE_W, SOURCE_H = 780, 900


def anchor(path):
    """하이라이트 PNG 하나에서 기준점을 뽑는다.

    반환: (dx, dy, 정보dict). 좌표는 **픽셀 중심**(+0.5) 기준이다 —
    안 그러면 모든 값이 소스 반 픽셀만큼 좌상단으로 치우친다.
    """
    w, h, bpp, px = pngio.decode(path)
    mask = []
    for y in range(h):
        row = y * w
        for x in range(w):
            a = px[(row + x) * bpp + 3]
            if a >= ALPHA_THRESHOLD:
                mask.append((x, y, a))
    if not mask:
        raise ValueError(f'alpha>={ALPHA_THRESHOLD} 픽셀이 없다: {path}')

    total = sum(a for _, _, a in mask)
    cx = sum(a * (x + 0.5) for x, _, a in mask) / total
    cy = sum(a * (y + 0.5) for _, y, a in mask) / total

    # 무게중심이 마스크 밖이면 코스 밖에 뜬다 → 마스크 위 최근접 픽셀로 당긴다.
    # 동률은 (거리, y, x) 오름차순으로 끊어 결정론을 지킨다.
    best = min(mask, key=lambda p: ((p[0] + 0.5 - cx) ** 2 + (p[1] + 0.5 - cy) ** 2,
                                    p[1], p[0]))
    sx, sy = best[0], best[1]
    inside = px[(int(cy) * w + int(cx)) * bpp + 3] >= ALPHA_THRESHOLD
    snapped = ((sx + 0.5 - cx) ** 2 + (sy + 0.5 - cy) ** 2) ** 0.5 / w

    return (sx + 0.5) / w, (sy + 0.5) / h, {
        'size': (w, h),
        # 겹침을 풀 때 "코스 밖으로 나가지 않게" 되돌릴 기준점(2px 간격 표본).
        'mask': [((x + 0.5) / w, (y + 0.5) / h)
                 for x, y, _a in mask if x % 2 == 0 and y % 2 == 0],
        'mask_px': len(mask),
        'max_alpha': max(a for _, _, a in mask),
        'centroid_inside': inside,
        'snap_dist': snapped,
    }


def _labels():
    """이미지 키 → 화면에 뜨는 슬로프명. 이름표 폭이 겹침 판정을 좌우한다."""
    import re
    src = open(dart_table.DATA_FILE, encoding='utf-8').read()
    body = dart_table._block(src, 'kSlopeCraftSlopeKeys')
    out, rid = {}, None
    for line in body.split('\n'):
        head = re.match(r'\s*(\d+)\s*:\s*\{', line)
        if head:
            rid = int(head.group(1))
            out[rid] = {}
            continue
        hit = re.search(r"'([^']*)'\s*:\s*'([^']+)'", line)
        if hit and rid is not None:
            out[rid][hit.group(2)] = hit.group(1)
    return out


def build(apply_overrides=False, resolve_overlaps=True):
    legacy = dart_table.read_offset_table()
    slug = dart_table.read_slug_table()
    slope_keys = dart_table.read_slope_keys()
    labels = _labels()
    override = (dart_table.read_offset_table('kSlopeCraftMarkerPosOverride')
                if apply_overrides else {})

    table, rows, warnings, nudged = {}, [], [], {}
    for rid, keys in legacy.items():
        s = slug[rid]
        table[rid] = {}
        masks, details = {}, {}
        on_disk = {f[len(s) + 1:-4] for f in os.listdir(f'{ASSET_DIR}/{s}')
                   if f.endswith('.png') and f != f'{s}_default.png'}
        for extra in sorted(on_disk - set(keys)):
            warnings.append(f'표에 없는 하이라이트 파일: {s}_{extra}.png')
        for key, old in keys.items():
            path = f'{ASSET_DIR}/{s}/{s}_{key}.png'
            if not os.path.exists(path):
                raise SystemExit(f'하이라이트 파일이 없다: {path}')
            if key not in slope_keys.get(rid, set()):
                raise SystemExit(f'kSlopeCraftSlopeKeys에 없는 키: {s}/{key}')

            dx, dy, info = anchor(path)
            if info['size'] != (SOURCE_W, SOURCE_H):
                warnings.append(f'{s}_{key}: 크기 {info["size"]} != '
                                f'({SOURCE_W}, {SOURCE_H}) — 좌표를 믿을 수 없다')
            if info['mask_px'] < MIN_MASK_PIXELS:
                warnings.append(f'{s}_{key}: 마스크 {info["mask_px"]}px (너무 작다)')
            if info['max_alpha'] < LOW_ALPHA_WARN:
                warnings.append(f'{s}_{key}: 최대 알파 {info["max_alpha"]} '
                                f'(< {LOW_ALPHA_WARN})')

            table[rid][key] = (dx, dy)
            masks[key] = info['mask']
            details[key] = info

        if resolve_overlaps:
            # 가까운 슬로프끼리 원·이름표가 겹친다 → 코스 위에 둔 채로 떼어 놓는다.
            table[rid], moved, left = overlap_mod.resolve(
                table[rid], labels[rid], masks)
            for key, (was, now) in moved.items():
                nudged[(s, key)] = (was, now)
            for a, b, ox, oy in left:
                warnings.append(
                    f'{s}: {labels[rid].get(a, a)}({a}) ↔ {labels[rid].get(b, b)}({b}) '
                    f'겹침이 안 풀린다 (가로 {ox:.0f} 세로 {oy:.0f}) — 두 코스가 너무 붙어 있다')

        for key, (dx, dy) in list(table[rid].items()):
            dx, dy = round(dx, 3), round(dy, 3)
            if rid in override and key in override[rid]:
                dx, dy = override[rid][key]
            table[rid][key] = (dx, dy)
            old = legacy[rid][key]
            rows.append((((dx - old[0]) ** 2 + (dy - old[1]) ** 2) ** 0.5,
                         s, key, old, (dx, dy), details[key]))

    return table, rows, warnings, slug, nudged


def report(rows, warnings, nudged=None):
    rows = sorted(rows, reverse=True)
    moves = [r[0] for r in rows]
    print(f'마커 {len(rows)}개', file=sys.stderr)
    print(f'이동량  평균 {statistics.mean(moves):.3f}  '
          f'중앙값 {statistics.median(moves):.3f}  최대 {max(moves):.3f}',
          file=sys.stderr)
    print(f'        0.15 초과 {sum(1 for m in moves if m > 0.15)}개 · '
          f'0.05 미만 {sum(1 for m in moves if m < 0.05)}개', file=sys.stderr)
    print(f'무게중심이 마스크 밖이었던 개수 {sum(1 for r in rows if not r[5]["centroid_inside"])}'
          f' → 스냅 후 0 (스냅이 전부 구제)', file=sys.stderr)
    if nudged:
        print(f'겹침 때문에 추가로 민 마커 {len(nudged)}개', file=sys.stderr)
    print(f'경고 {len(warnings)}건', file=sys.stderr)
    for w in warnings:
        print(f'  ! {w}', file=sys.stderr)
    print('\n이동량 큰 순:', file=sys.stderr)
    for move, s, key, old, new, info in rows:
        flag = '' if info['centroid_inside'] else '  [중심이 코스 밖이었음]'
        print(f'  {move:.3f}  {s}/{key:<18} ({old[0]:.3f},{old[1]:.3f})'
              f' -> ({new[0]:.3f},{new[1]:.3f})  mask={info["mask_px"]:>5}'
              f' maxA={info["max_alpha"]}{flag}', file=sys.stderr)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', help='생성 Dart 파일 경로 (생략하면 표준출력)')
    ap.add_argument('--report-only', action='store_true', help='리포트만, Dart 미출력')
    ap.add_argument('--overrides', action='store_true',
                    help='kSlopeCraftMarkerPosOverride를 적용해 리포트')
    ap.add_argument('--no-resolve', action='store_true',
                    help='PC 겹침 해소를 끄고 순수 무게중심만 본다')
    args = ap.parse_args()

    table, rows, warnings, slug, nudged = build(
        apply_overrides=args.overrides, resolve_overlaps=not args.no_resolve)
    report(rows, warnings, nudged)
    if args.report_only:
        return

    text = dart_table.render_table(table, slug)
    if args.out:
        with open(args.out, 'w', encoding='utf-8') as f:
            f.write(text)
        print(f'\n{args.out} 작성', file=sys.stderr)
    else:
        sys.stdout.write(text)


if __name__ == '__main__':
    main()
