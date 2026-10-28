"""`slope_craft_maps_web.dart`의 표를 읽고, 같은 서식으로 새 표를 쓴다.

새 표의 리조트·키 **순서를 기존 표와 똑같이** 맞추기 위해 기존 파일을 파싱한다.
그래야 diff가 줄 단위로 대응되고, 재실행해도 순서가 흔들리지 않는다.
"""

import re

DATA_FILE = 'lib/web/data/slope_craft_maps_web.dart'

__all__ = ['read_offset_table', 'read_slug_table', 'read_slope_keys', 'render_table']


def _block(src, decl):
    """`... decl = {` 다음의 중괄호 블록 본문을 돌려준다.

    이름만 찾으면 문서 주석의 `[kSlopeCraftMarkerPos]` 같은 **언급**에 먼저 걸린다
    → 반드시 `= {`가 뒤따르는 **선언**만 잡는다.
    """
    hit = re.search(re.escape(decl) + r'\s*=\s*\{', src)
    if hit is None:
        raise ValueError(f'{decl} 선언을 찾지 못했다')
    start = src.index('{', hit.start())
    depth = 0
    for i in range(start, len(src)):
        if src[i] == '{':
            depth += 1
        elif src[i] == '}':
            depth -= 1
            if depth == 0:
                return src[start + 1:i]
    raise ValueError(f'{decl} 블록이 닫히지 않았다')


def _read(path=DATA_FILE):
    return open(path, encoding='utf-8').read()


def read_offset_table(name='kSlopeCraftMarkerPos', path=DATA_FILE):
    """`{리조트id: {키: (dx, dy)}}`. dict는 삽입 순서를 지키므로 원본 순서가 보존된다."""
    body = _block(_read(path), name)
    table, rid = {}, None
    for line in body.split('\n'):
        head = re.match(r'\s*(\d+)\s*:\s*\{', line)
        if head:
            rid = int(head.group(1))
            table[rid] = {}
            continue
        hit = re.search(
            r"'([^']+)'\s*:\s*(?:const\s+)?Offset\(\s*([\d.]+)\s*,\s*([\d.]+)\s*\)", line)
        if hit and rid is not None:
            table[rid][hit.group(1)] = (float(hit.group(2)), float(hit.group(3)))
    return table


def read_slug_table(path=DATA_FILE):
    body = _block(_read(path), 'kSlopeCraftResortSlug')
    return {int(r): s for r, s in re.findall(r"(\d+)\s*:\s*'([a-z0-9]+)'", body)}


def read_slope_keys(path=DATA_FILE):
    """`{리조트id: {이미지키, ...}}` — 라벨 역조회가 가능한지 확인하는 데 쓴다."""
    body = _block(_read(path), 'kSlopeCraftSlopeKeys')
    table, rid = {}, None
    for line in body.split('\n'):
        head = re.match(r'\s*(\d+)\s*:\s*\{', line)
        if head:
            rid = int(head.group(1))
            table[rid] = set()
            continue
        hit = re.search(r"'[^']*'\s*:\s*'([^']+)'", line)
        if hit and rid is not None:
            table[rid].add(hit.group(1))
    return table


def render_table(table, slug):
    """생성 파일 전체를 문자열로 만든다. 날짜·경로·장비명을 넣지 않아 재실행해도 동일하다."""
    out = [
        '// GENERATED — 손으로 고치지 마세요.',
        '// 재생성: python3 tool/slope_craft/gen_marker_pos.py \\',
        '//           --out lib/web/data/slope_craft_marker_pos_generated_web.dart',
        '//',
        '// 각 값 = {슬러그}_{키}.png 의 alpha>=128 마스크 알파가중 무게중심을',
        '// 가장 가까운 마스크 픽셀로 당긴 좌표(780x900 기준 0~1 비율).',
        '// 손보정은 이 파일이 아니라 slope_craft_maps_web.dart 의',
        '// kSlopeCraftMarkerPosOverride 에 적는다 — 재생성해도 살아남는다.',
        "import 'package:flutter/painting.dart';",
        '',
        '/// 하이라이트 이미지에서 뽑은 PC·태블릿용 마커 좌표(생성값).',
        'const Map<int, Map<String, Offset>> kSlopeCraftMarkerPosGenerated = {',
    ]
    for rid, keys in table.items():
        out.append(f'  {rid}: {{ // {slug[rid]}')
        for key, (dx, dy) in keys.items():
            out.append(f"    '{key}': Offset({dx:.3f}, {dy:.3f}),")
        out.append('  },')
    out += ['};', '']
    return '\n'.join(out)
