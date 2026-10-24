# 슬로프크래프트 마커 좌표 생성기

웹 **PC·태블릿**용 마커 좌표(`lib/web/data/slope_craft_marker_pos_generated_web.dart`)를
슬로프 하이라이트 이미지에서 뽑는다. 1회성 개발 도구이고 앱에는 포함되지 않는다.

## 왜 있나

원래 좌표표(`kSlopeCraftMarkerPos`)는 앱 화면에서 손으로 찍은 값이다. 지도가 작은
모바일에서는 그럴듯하지만, 지도가 커지는 PC에서는 **같은 비율 오차가 큰 픽셀 오차**가
된다 — 하이라이트가 실제로 칠해진 영역의 중심과 평균 0.09 어긋나 있고, 이는 PC에서
54px(마커 1.6개 크기)다. 마커가 코스 밖 빈 배경에 떠 있는 경우도 있었다.

모바일 표는 앱과 눈이 같아야 해서 **건드리지 않는다**. 이 생성기는 PC·태블릿 표만 만든다.

## 어떻게 뽑나

1. `{슬러그}_{키}.png`에서 `alpha >= 128`인 픽셀을 마스크로 잡는다.
   - `> 0`은 알파 1~3의 잡색 후광까지 포함한다.
   - `>= 200`은 알파가 255까지 안 올라가는 2개(`yongpyong_redgoldbridge` 최대 189,
     `jisan_newOrange` 204)를 빈 마스크로 만든다.
2. 알파 가중 **무게중심**을 구하고, **마스크 위 최근접 픽셀로 스냅**한다.
   스냅이 없으면 ㄱ자로 휜 코스에서 중심이 꺾인 안쪽(코스 밖)으로 빠진다 —
   146개 중 36개가 그랬고, 스냅이 전부 구제한다(추가 이동 평균 0.004).
3. **PC 기준 겹침을 푼다**(`overlap.py`). 가까운 슬로프끼리 원·이름표가 겹쳐
   30쌍이 나왔다. 각 마커를 자기 코스 위 후보점 중 "겹친 넓이 + 원래 자리에서
   멀어진 벌점"이 최소인 곳으로 옮긴다 → 1쌍(0.2px, 스치는 수준)만 남는다.

좌표는 **픽셀 중심**(+0.5) 기준이고 소수 3자리다(`1/780 = 0.0013`이라 3자리가 한 픽셀에 해당).

## 쓰는 법

```bash
# 리포트만 (생성 안 함) — 이동량·경고·안 풀린 겹침
python3 tool/slope_craft/gen_marker_pos.py --report-only

# 표 생성
python3 tool/slope_craft/gen_marker_pos.py \
  --out lib/web/data/slope_craft_marker_pos_generated_web.dart

# 손보정까지 반영해서 리포트
python3 tool/slope_craft/gen_marker_pos.py --report-only --overrides

# 겹침 해소를 끄고 순수 무게중심만 보기
python3 tool/slope_craft/gen_marker_pos.py --report-only --no-resolve

# 눈 확인용 합성 이미지 (스크래치에만, 커밋하지 않는다)
python3 tool/slope_craft/render_preview.py <출력경로> --overrides
python3 tool/slope_craft/render_preview.py <출력경로> --overview-only
```

미리보기 범례: **빨간 링 = 현재(모바일) 좌표**, **초록 점 = 생성 좌표**, 회색 선 = 이동,
자홍색 = 생성기가 본 마스크(확대 이미지만).

재실행하면 **바이트 동일한 파일**이 나온다(날짜·경로를 넣지 않고 순서를 기존 표에서
가져온다). 생성 후 `git diff --exit-code`로 확인할 수 있다.

## 손보정

생성 파일은 재실행하면 통째로 덮인다. 손으로 고칠 값은 반드시
`lib/web/data/slope_craft_maps_web.dart`의 `kSlopeCraftMarkerPosOverride`에
**사유와 함께** 적는다 — 그래야 재생성해도 살아남는다.

## 의존성

없다. PIL·numpy를 쓰지 않고 `zlib`·`struct`로 PNG을 직접 디코드/인코드한다
(`pngio.py`). 저장소에 둘 다 설치돼 있지 않고, 1회성 도구에 의존성을 더할 이유도 없다.

## 알려진 문제

`o2_default.png`가 780x909다(다른 리조트는 780x900). 지도 틀이 `780/900`이라
`BoxFit.cover`가 기본지도 위아래를 4.5px씩 잘라낸다. **하이라이트는 전부 780x900으로
정확하므로 좌표에는 영향이 없다.** 미리보기도 같은 잘림을 재현한다 — 안 그러면 o2에서
9px짜리 가짜 어긋남이 보여 엉뚱한 방향으로 보정하게 된다. 정렬을 수치로 찾아봤지만
최적 보정이 슬로프마다 +7/+14로 갈려(피크도 얕다) **숫자 보정은 하지 않는다.**
디자인에 780x900 재추출을 요청해야 한다.
