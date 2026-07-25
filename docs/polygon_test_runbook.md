# 폴리곤 라이딩 모의테스트 런북 (Runbook)

> **트리거**: 사용자가 "폴리곤 테스트 진행해줘 (리조트명)" 이라고 하면 이 문서대로 진행한다.
> 실제 라이딩 없이, slope-admin에 그려둔 폴리곤(area)+중심선(axis)만으로 오류건을 점검한다.

---

## 0. 전제 조건
- 대상 리조트의 슬로프가 **slope-admin**(`/slope-admin/`)에서 `Slope_info_2627`에 **area(폴리곤) + axis(중심선)** 둘 다 그려져 있어야 함.
- 테스트는 **Heroku 라이브 DB**에 대해 실행(로컬 DB 아님).
- 판별 로직: `resort_app/management/commands/sim_slopes.py` (= `lib/test_polygon/polygon_session_machine.dart`를 파이썬으로 포팅한 것).

## 1. 리조트 ID 찾기
알려진 것: **용평=9, 휘닉스파크=13**(삼송 테스트용). 모르면:
```bash
cd /Users/maeng_6/project/python/snowlive_api/snowlive
heroku run --app snowlive-api "python manage.py shell -c \"
from resort_app.models import Resort_info
for r in Resort_info.objects.all():
    if '리조트명' in (r.fullname or '') or '리조트명' in (r.nickname or ''):
        print(r.resort_id, r.fullname, r.nickname)\""
```

## 2. 시뮬 실행 (핵심 1줄)
```bash
cd /Users/maeng_6/project/python/snowlive_api/snowlive
heroku run --app snowlive-api "python manage.py sim_slopes --resort <ID>"
```
출력에서 `SELECT|Running|connecting|Warning:` 라인은 노이즈라 필터해서 본다.

## 3. 결과 해석

### ① 정적 기하 검사
| 항목 | 정상 | 조치 필요 |
|---|---|---|
| **axis-폴리곤 정합** | "모두 정상 ✓" | 내부점이 2m 넘게 폴리곤 밖 → **폴리곤을 axis 포함하게 재드로잉** (끝점은 경계에 닿는 게 정상이라 검사 제외됨) |
| **폴리곤 면적 겹침** | 소규모(작은쪽 대비 <30%) | **작은쪽 대비 40%+ 겹침 → 재드로잉 1순위** (오기록 위험) |
| **하단 공유(합류)** | 하단점 30m 이내 표시(정상 가능) | 겹침 큰 것과 겹치면 위험 |

### ② 합성 라이딩 시뮬 (슬로프별)
각 슬로프 axis를 따라 상단→하단 하강시켜서:
- **PASS ✓** = 정확히 자기 슬로프만 1회 커밋
- **FAIL ✗** 플래그:
  - `미검출` — 자기 슬로프가 커밋 안 됨
  - `교차오검출→[X]` — 다른 슬로프 X도 잘못 커밋 (→ **폴리곤 겹침 과다**)
  - `리프트횡단오검출` — 수평 횡단인데 커밋 (→ 폴리곤 형상 확인, 좁고 짧은 슬로프에서 발생하는 엣지케이스)
- `상단25%커버` = 부분 라이딩(상단 25%) 시 잡히는 커버리지(m) 참고값

## 4. 체크리스트 (리조트별 판정)
- [ ] 모든 슬로프 **area+axis 둘 다** 있는가 (없으면 그 슬로프는 테스트 불가)
- [ ] **axis-폴리곤 정합** 경고 0건인가
- [ ] **겹침 쌍** 중 작은쪽 대비 40%+ 있는가 → 있으면 재드로잉 후보 목록화
- [ ] **정상하강 전부 PASS**인가 (요약의 `N/N PASS`)
- [ ] **교차오검출** 있는가 → 어느 슬로프끼리인지 → 폴리곤 상단 진입부 구분되게 재드로잉
- [ ] **리프트횡단 오검출** 있는가 → 해당 슬로프 폴리곤 형상 점검

## 5. 판정 로직 핵심 (참고)
- **진입**: 폴리곤 안 + 진행률 하단방향 증가(연속 2점)
- **종료**: max 진행률에서 밴드(25m) 후퇴 또는 폴리곤 이탈(연속 2점 밖)
- **커버리지 = 실제 지나간 축 구간(5m bin) 비율** (스팬 max-entry 아님 → 투영 착시 방지)
- **dedup(지배)**: 시간상 겹친 후보 그룹을 **종료 시 최종 진행률(비율)로 확정**, 가장 완주에 가까운(비율 최대) 슬로프만 남김. 절대 거리(m) 아님 → 길이 편향 없음.
- 각 점은 **그 폴리곤 안에 있을 때만** 해당 슬로프 진행률에 합산됨(단독 구간은 안 오르고, 공유 구간은 둘 다 오름).

## 6. 산출물
1. 결과를 `docs/<리조트>_sim_report.md`로 정리 (요약 + ① + ② + 진단 + 권장 조치).
2. cokacdir로 사용자에게 전송.
3. 재드로잉 후 다시 2번 실행 → 개선 숫자 비교.

## 7. 기록 (테스트 이력)
| 날짜 | 리조트 | 슬로프수 | 정상하강 PASS | 주요 이슈 |
|---|---|---|---|---|
| 2026-07-26 | 용평(#9) | 21 | 19/21 | 리프트횡단 2건(골드파라다이스·레드파라다이스). 겹침 오기록은 dedup 개선으로 해결 |

---
*판별 로직 원본: `lib/test_polygon/polygon_session_machine.dart` · 설계서: `docs/POLYGON_RIDING_PLAN.md`*
