"""PC 기준으로 겹치는 마커를 조금씩 밀어 떼어 놓는다.

지도에 마커를 좌표 그대로 찍으면 가까운 슬로프끼리 원·이름표가 겹친다(실측 30쌍).
사람이 하나씩 옮기면 다시 생성할 때마다 사라지므로 생성 단계에서 푼다.

푸는 방식은 **마스크 위 국소 탐색**이다. 밀어낸 뒤 코스로 되돌리는 방식은 되돌림이
밀어냄을 상쇄해 제자리걸음을 하고 새 겹침까지 만들었다 → 대신 자기 코스 위 후보점만
놓고 "겹친 넓이 + 원래 자리에서 멀어진 벌점"이 가장 작은 곳을 고른다. 코스를
벗어나는 선택지는 애초에 후보에 없으므로 제약이 저절로 지켜진다.

좁은 두 코스가 바짝 붙어 있으면 어디에 둬도 겹친다 — 그런 쌍은 호출 쪽에 돌려준다.

치수는 **PC 지도(600x692)** 기준이다. 태블릿은 더 넓어 같은 좌표에서 덜 겹치고,
모바일은 이 표를 쓰지 않는다.
"""

__all__ = ['MAP_W', 'MAP_H', 'marker_box', 'find_overlaps', 'resolve']

# PC 실측: 콘텐츠 1160 안에서 4:3 → 카드 640, 카드 여백 20씩 빼서 지도 600.
MAP_W = 600.0
MAP_H = 600.0 * 900 / 780          # 692.3
_SCALE = MAP_W / 640               # w_slopecraft_map_web.dart 의 slopeCraftMapScale

_CIRCLE = 36 * _SCALE              # 원 지름 33.75
_SLOT = _CIRCLE + 6 * _SCALE       # hover로 커질 자리까지 포함한 칸 39.375
_FONT = 10 * _SCALE                # 이름표 글자 9.375
_LABEL_H = _FONT * 1.25 + 2 * _SCALE
_CIRCLE_TO_LABEL = 2 * _SCALE
_LABEL_PAD_X = 3 * _SCALE

COLUMN_H = _SLOT + _CIRCLE_TO_LABEL + _LABEL_H

# 떼어 놓느라 원래 자리에서 이만큼 넘게 벗어나지는 않는다(지도 폭 비율).
MAX_DRIFT = 0.10

# 떼어 놓은 뒤 남길 최소 간격(px). 0이면 딱 붙는다.
CLEARANCE = 2.0


def _text_width(label):
    """Pretendard Bold 근사 — 한글·전각 1.0em, 나머지 0.55em."""
    return sum(1.0 if ord(c) > 0x2000 else 0.55 for c in label) * _FONT


def marker_box(offset, label):
    """마커 묶음이 차지하는 사각형 (left, top, right, bottom), PC 픽셀.

    가로는 `FractionalTranslation(-0.5, 0)`으로 가운데 정렬이고 폭은 원이 아니라
    **이름표**가 정한다. 세로는 `top = dy*h - 칸/2`에서 시작해 이름표까지 내려간다.
    """
    width = max(_CIRCLE, _text_width(label) + 2 * _LABEL_PAD_X)
    cx = offset[0] * MAP_W
    top = offset[1] * MAP_H - _SLOT / 2
    return (cx - width / 2, top, cx + width / 2, top + COLUMN_H)


def find_overlaps(table, labels):
    """겹친 쌍 목록 `[(키A, 키B, 가로겹침, 세로겹침), ...]`."""
    boxes = {k: marker_box(o, labels[k]) for k, o in table.items()}
    keys = list(table)
    hits = []
    for i in range(len(keys)):
        for j in range(i + 1, len(keys)):
            a, b = boxes[keys[i]], boxes[keys[j]]
            ox = min(a[2], b[2]) - max(a[0], b[0]) + CLEARANCE
            oy = min(a[3], b[3]) - max(a[1], b[1]) + CLEARANCE
            if ox > 0 and oy > 0:
                hits.append((keys[i], keys[j], ox, oy))
    return hits


def _area(a, b):
    """두 사각형이 겹친 넓이(px²). 안 겹치면 0."""
    ox = min(a[2], b[2]) - max(a[0], b[0]) + CLEARANCE
    oy = min(a[3], b[3]) - max(a[1], b[1]) + CLEARANCE
    return ox * oy if ox > 0 and oy > 0 else 0.0


# 원래 자리에서 멀어지는 데 매기는 벌점(겹친 px² 당 지도폭 비율 1.0 기준).
# 크게 두면 안 움직이고, 작게 두면 코스 위를 멀리 돌아다닌다.
_DRIFT_PENALTY = 4000.0

# 후보로 쓸 마스크 표본 간격(원본 픽셀). 촘촘할수록 느리다.
_CANDIDATE_STEP = 4


def resolve(table, labels, masks, rounds=8):
    """겹침을 푼 좌표표를 돌려준다.

    `masks[키]`는 그 슬로프의 마스크 점 `[(dx, dy), ...]`(0~1 비율).
    반환: (새 표, 움직인 키→(이전, 이후), 끝내 남은 겹침).
    """
    pos = dict(table)
    origin = dict(table)
    keys = list(table)

    # 후보점: 자기 코스 위이면서 원래 자리에서 MAX_DRIFT 안. 가까운 순으로 본다.
    candidates = {}
    for k in keys:
        ox, oy = origin[k]
        pts = [p for i, p in enumerate(masks[k]) if i % _CANDIDATE_STEP == 0]
        near = [p for p in pts
                if (p[0] - ox) ** 2 + (p[1] - oy) ** 2 <= MAX_DRIFT ** 2]
        near.sort(key=lambda p: ((p[0] - ox) ** 2 + (p[1] - oy) ** 2, p[1], p[0]))
        candidates[k] = near or [origin[k]]

    # 멀리 떨어진 마커끼리는 절대 안 겹치므로 이웃만 본다.
    neighbours = {k: [o for o in keys if o != k
                      and abs(origin[o][0] - origin[k][0]) < 0.3
                      and abs(origin[o][1] - origin[k][1]) < 0.3]
                  for k in keys}

    for _ in range(rounds):
        boxes = {k: marker_box(pos[k], labels[k]) for k in keys}
        conflict = {k: sum(_area(boxes[k], boxes[o]) for o in neighbours[k])
                    for k in keys}
        if not any(conflict.values()):
            break

        moved_any = False
        # 가장 심하게 겹친 것부터 자리를 양보받는다.
        for key in sorted(keys, key=lambda k: -conflict[k]):
            if conflict[key] <= 0:
                continue
            ox, oy = origin[key]
            others = [boxes[o] for o in neighbours[key]]
            best, best_pt = None, None
            for cand in candidates[key]:
                box = marker_box(cand, labels[key])
                drift = ((cand[0] - ox) ** 2 + (cand[1] - oy) ** 2) ** 0.5
                cost = sum(_area(box, o) for o in others) + _DRIFT_PENALTY * drift
                if best is None or cost < best:
                    best, best_pt = cost, cand
            if best_pt is not None and best_pt != pos[key]:
                pos[key] = best_pt
                boxes[key] = marker_box(best_pt, labels[key])
                conflict = {k: sum(_area(boxes[k], boxes[o]) for o in neighbours[k])
                            for k in keys}
                moved_any = True
        if not moved_any:
            break

    moved = {k: (origin[k], pos[k]) for k in keys if pos[k] != origin[k]}
    return pos, moved, find_overlaps(pos, labels)
