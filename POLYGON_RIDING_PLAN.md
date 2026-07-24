# 스노우라이브 — 폴리곤 기반 라이딩 판별 & 스코어링 전환 계획서

작성일: 2026-07-23 (최종 결정 반영)
대상 시즌: **26/27 (2627)** — 기존 시스템과 병행 구축 후 검증하여 전환
관련 프로젝트: 프론트 `project/snowlive` (Flutter) · 백엔드 `project/python/snowlive_api/snowlive` (Django/PostGIS)

---

## 1. 목표

1. 슬로프 판별을 **원(점+반경) → 폴리곤(면적) 방식**으로 전환 → 정확도 향상, 리프트/곤돌라/걸어오름 오판 제거
2. 라이딩 점수를 **슬로프 고정점수 합산 → 실측 기반(거리·경사·속도) per-ride 점수**로 전환
3. 라이딩 궤적을 **영구 저장**(유료 전용)하여 궤적 이미지·공개 프로필 등 신규 BM 기반 확보
4. **판별·궤적·점수를 하나의 세션 데이터로 통합** (동일 좌표 집합에서 산출)

### 핵심 원칙: 안전한 병행 전환
- 기존 `Slope_info` / `Ranking_record` / 원 판별 로직 **그대로 유지**
- 신규 시스템은 **26/27 시즌 테이블(`Slope_info_2627` 등)로 별도 구축** → dual-run 검증 후 전환
- 과거 시즌 데이터·FK 무손상

---

## 2. 판별 방식 전환

### 2-1. 원 → 폴리곤
- 슬로프를 **면적 폴리곤** + **방향축(axis, 상단→하단 중심선 LineString)** 으로 정의
- 판별은 현재처럼 **클라이언트 수행** (서버는 폴리곤 저장·전송만). 클라에 **점-in-폴리곤 ray-casting** 구현
- **진행률(progress)**: 좌표를 축에 투영한 값. 0=상단, 1=하단. 수평 위치 기반이라 GPS 고도보다 정확 → **판별의 유일 신호**

### 2-2. 판별 함수 분리
현재 `checkPositionInAreas`(슬로프+눈송이+reset+respawn 통합)를 분리:
- `checkRidingInSlopes()` — **폴리곤 ray-casting** (신규, 라이딩 판별)
- `checkSnowballHits()` — **점+반경 로직 그대로 유지** (눈송이/트레저헌트, 변경 없음)
- reset/respawn 판별은 **폐기** (세션 상태머신이 대체)

> ⚠️ 눈송이 검출은 반드시 기존 점+반경 유지 — 폴리곤 전환으로 회귀 없어야 함

---

## 3. 세션 상태머신 (라이딩 판별 핵심)

**세션 하나 = 하강 하나 = 궤적 1개 = 점수 1개 (1:1).** 궤적과 점수는 **동일 좌표 집합**으로 계산.
판별 신호는 **진행률(축 투영)만** 사용 — 고도는 판별에 쓰지 않음.

### 3-1. 상태 전이
```
[IDLE]
  └─(폴리곤 안 + 진행률 하단방향 증가, 연속 2점)──▶ [IN_RUN]
        · 클라 메모리에 기록: entry_progress, started_at, 세션 궤적 리스트, max_progress
        · 세션 시작점을 첫 하강 좌표로 소급(backdate) → 확정 지연분 데이터 손실 없음
        · 즉시 flush (진입 이벤트, User_live_position 갱신)
  [IN_RUN]
        · 매 좌표: 궤적·max_progress·거리 메모리 누적 (DB엔 60초 배치 로그)
  └─(진행률이 max_progress − 밴드Δ 후퇴  또는  폴리곤 이탈(연속 2~3점 밖 + 재진입 유예 통과))──▶ 세션 종료 → 커밋
        · 후퇴로 종료 시(리프트/걸어오름): 종료점 = max_progress(최하단) 지점으로 소급 (후퇴 좌표는 세션 제외)
        · 폴리곤 이탈로 종료 시: 종료점 = 마지막으로 폴리곤 안이었던 좌표로 소급 (밖으로 튄 좌표는 제외)
```

### 3-2. 판별 규칙 (진행률 only)
- **시작**: 폴리곤 안 + 진행률이 하단 방향으로 **증가**(연속 2점)
- **종료**: **현재 진행률이 max_progress(가장 깊이 내려간 지점)보다 밴드Δ만큼 후퇴** 또는 폴리곤 이탈
  - "진행률 감소 몇 점"이 아니라 **"최하단에서 Δ만큼 물러났나"** 로 판정 → S자 턴의 순간 역행에 안 끊김
  - 밴드Δ = 턴의 역행보다 크고 진짜 턴어라운드(리프트·걸어오름)보다 작게 (예: 축 20~30m, Phase 4 튜닝)
- **정체(평지·횡단)는 종료 아님**: 진행률이 안 늘어도 max에서 후퇴가 아니면 세션 유지
- **S자 턴 역행/작은 지터**: max_progress − Δ 밴드 안이면 무시 → 세션 안에 포함(궤적·점수 반영). 뚱뚱한 S자 모양도 궤적에 정직하게 그려짐
- **이탈 히스테리시스**: 폴리곤 밖 좌표 1개로 즉시 종료 ❌ → **연속 2~3점 밖**일 때만 이탈 확정. 경계 오차·GPS 튐 1점은 무시(세션 유지)
- **재진입 유예**: 이탈 확정 전 **짧은 시간·거리 내 같은 폴리곤 재진입** 시 새 세션 말고 **기존 세션 이어감** → 경계에서 잠깐 삐져나감으로 라이딩이 쪼개지거나 중복 카운트되는 것 방지
- **GPS 스파이크 제거**: 순간이동 수준 좌표는 상태머신 진입 전 `_validatePosition`/Mock 감지에서 걸러 이탈 오판 방지
- **폴리곤은 넉넉하게**: 어드민에서 슬로프보다 약간 크게 그려 경계 지터를 흡수
- 시작 2점 · 종료 밴드Δ · 이탈 2~3점 · 재진입 유예는 **노이즈/턴/경계 흡수 노브** (Phase 4 튜닝)

### 3-3. 커밋 (라이딩 인정)
- **전부 카운트**: 진짜 하강이면 무조건 `Ranking_record_2627` 생성 + 점수 부여. 짧은 라이딩은 거리·하강고도가 작아 점수가 낮게 매겨짐(스코어링이 크기 흡수). **커버리지 30% 게이트 폐기.**
- 리프트/걸어오름 배제는 3-2의 **진입=하강 조건**이 담당 (진입 자체가 하강일 때만 세션 열림)
- **노이즈 하한**: GPS 튐 2초짜리 헛것만 거르는 아주 작은 하강 하한만 유지
- **부분 라이딩(합류)**: 정책 (A) **1회 카운트**
- 커밋 시 `commit-ride` API 호출 + 즉시 flush

### 3-4. 특수 케이스
| 케이스 | 동작 |
|---|---|
| 걸어 올라가기 | 진행률 상향 → 세션 시작 안 함 / 중간이면 max−Δ 후퇴로 종료 → 카운트 X |
| 리프트로 슬로프 위 횡단 | 진입이 하강 아님 → 세션 시작 안 함 |
| 슬로프 중간까지 타고 리프트로 올라감 | max−Δ 후퇴 감지 시 종료, **최하단 지점까지를 궤적·점수로 커밋**. 이후 재하강 시 새 세션 |
| **뚱뚱한 S자 턴(순간 역행)** | max−Δ 밴드 안이면 **세션 유지**, 역행 좌표도 궤적·점수 포함 |
| **경계 오차·GPS 튐으로 잠깐 폴리곤 밖** | 연속 2~3점 밖 아니면 **세션 유지** / 재진입 유예 내 복귀 시 이어감 → 쪼개짐·중복 방지 |
| 합류(중간 진입) | 하강이면 정상 세션 → 1회 카운트 |
| 평지·횡단 | 진행률 정체(후퇴 아님) → 세션 유지 |
| 연속 슬로프(A→B) | 폴리곤별 후보 병렬 추적 → A·B 각 1회 |
| **공유하단(도도/슬로프스타일)** | 두 폴리곤 겹침 → 커버리지 큰 슬로프에만 귀속(dedup), 나머지 억제 |

### 3-5. 겹침·공유하단 슬로프 귀속 (dedup)
휘닉스파크 도도/슬로프스타일처럼 **하단부를 공유**하는 슬로프는 폴리곤이 겹침 → 공유 구간 좌표가 두 폴리곤에 동시 포함됨.

- **폴리곤은 겹쳐 그려도 됨**: 공유하단을 양쪽 슬로프 폴리곤에 모두 포함. 각 슬로프 축(axis)은 "자기 상단 → 공유하단"으로 그림.
- **후보 추적은 전부 클라 메모리**: 세션 시작/후보 추적은 **서버 API 없이 폰 안에서만**. API(`commit-ride`)는 **커밋 때 1회**만. 공유하단에선 메모리에 후보 2개가 동시 존재하지만 **서버 레코드는 없음**.
- **후보는 둘 다 열림**: 공유하단 진입 시 안 탄 슬로프 후보도 (중간 진입으로) 시작됨. **시작을 막지 않음** — 막으면 합류(Case 4)가 깨지므로.
- **종료 시 "지배(domination) 판정"으로 dedup**: 한 후보가 종료될 때, **동시에 활성이던(시간상 겹친) 다른 후보가 이미 커버리지 ≥ 이면 → 폐기(commit-ride 호출 안 함)**. 아니면 커밋. 폐기 = 서버 레코드를 애초에 안 만듦(정리 불필요).
- **누가 먼저 끝나도 타이밍 무관(블로킹 대기 아님)**: 경계 오차로 한 폴리곤이 더 짧아 **먼저 끝나도**, 종료되는 그 순간 상대 후보의 **현재 커버리지로 즉시 지배 판정** → 진 후보 폐기. 공유하단 도달 = 상대 상단 통과 이후라 그 순간 상대 커버리지가 항상 우위 → 기하학적으로 항상 실제 탄 슬로프가 이김. **도도가 끝날 때까지 기다리는 게 아니라 그 자리에서 폐기.**
- **(옵션) 짧은 커밋 보류**: 기하가 애매해 종료 순간 지배가 불분명하면, 겹친 후보가 활성인 동안 커밋을 **짧게 보류(bounded hold)** 했다가 그룹이 다 끝나면 커버리지 최대로 확정. 무한 대기 아님. (Phase 4에서 필요 슬로프만 적용)
- **항상 정확한 이유**: 실제 탄 슬로프 = 고유상단 + 공유하단 = 전체 커버 / 안 탄 슬로프 = 공유하단만. "전체 ≥ 공유부분"이라 지배 판정이 언제나 실제 탄 슬로프를 남김.
- **합류(Case 4)와 구분**: 합류는 이전 폴리곤을 **벗어나 종료**(순차)하고 각자 고유 구간을 타서 서로 지배하지 않음 → 둘 다 카운트. 공유하단은 이전 폴리곤을 **안 벗어나 동시 진행**(concurrent) → 지배 판정으로 하나만.

---

## 4. 스코어링 시스템

### 4-1. 신호 (세션 좌표에서 산출)
| 신호 | 계산 |
|---|---|
| 라이딩 거리 L | 세션 궤적 점 사이 거리 합 (스무딩 후) |
| 하강 고도 Δh | **실측 고도** 진입−최저 (판별엔 미사용, **점수 입력으로만** 사용 — 결정 A) |
| 경사도 G | Δh / L |
| 속도 V | 평균 또는 퍼센타일 (**추후 결정**) · **50km/h 초과분 cap** |

### 4-2. 공식 (곱셈형: 물리량 × 난이도 × 스타일)
```
점수 = Base(Δh × √L) × 난이도계수(경사 G) × 스타일계수(속도 V)
```
- **가중치는 일단 동일 적용** (Base·난이도·스타일 지수 추후 튜닝)
- √·log 완충으로 한 축 폭주·GPS 튐값 지배 방지
- **속도 캡: V = min(실측속도, 50 km/h)**

### 4-3. 계산 위치 = 서버
- 클라는 **원시 측정값(거리·하강고도·경사·속도·궤적)만 전송** → **서버가 score 산출**
- 이유: 앱 업데이트 없이 튜닝, 치팅 방지, 일관성

### 4-4. 확정된 정책
- 부분 라이딩: **(A) 1회 카운트**
- **슬로프별 상대점수/티어 리그 도입 안 함**
- **slope_avg / length 참고값 유지**

---

## 5. DB 스키마 (26/27 신규 · 기존 테이블 미변경)

### 5-1. `Slope_info_2627` (resort_app/models.py, 신규)
```python
class Slope_info_2627(models.Model):
    slope_id = models.AutoField(primary_key=True)
    fullname = models.CharField(max_length=100)
    nickname = models.CharField(max_length=100)
    resort_id = models.ForeignKey('resort_app.Resort_info', on_delete=models.SET_NULL,
                                  null=True, blank=True, db_column='resort_id')
    area = gis_models.PolygonField(geography=True, srid=4326, null=True, blank=True)      # 판별 폴리곤
    axis = gis_models.LineStringField(geography=True, srid=4326, null=True, blank=True)   # 첫 점=상단, 끝 점=하단
    slope_avg = models.FloatField(null=True, blank=True)   # 참고값 유지 (난이도)
    length = models.FloatField(null=True, blank=True)      # 참고값 유지 (m)
    active = models.BooleanField(default=True)
    # radius / score(고정점수) 없음
```

### 5-2. `Ranking_record_2627` (ranking_app/models.py, 신규)
```python
class Ranking_record_2627(models.Model):
    ranking_id = models.AutoField(primary_key=True)
    user_id = models.ForeignKey(User, on_delete=models.CASCADE, db_column='user_id')
    slope_id = models.ForeignKey(Slope_info_2627, on_delete=models.CASCADE, db_column='slope_id')
    started_at = models.DateTimeField(null=True, blank=True)   # 세션 시작(소급된 첫 하강점)
    pass_time = models.DateTimeField(db_index=True)            # 세션 종료(커밋) 시각, 기존 쿼리 호환
    distance = models.FloatField(null=True, blank=True)        # m
    vertical_drop = models.FloatField(null=True, blank=True)   # m (실측 고도)
    gradient = models.FloatField(null=True, blank=True)        # %
    avg_speed = models.FloatField(null=True, blank=True)       # km/h
    max_speed = models.FloatField(null=True, blank=True)       # km/h (원본, 점수엔 50 cap)
    coverage = models.FloatField(null=True, blank=True)        # 진행률 span 0~1 (기록용, 카운트 게이트 아님)
    score = models.FloatField(default=0)                       # 서버 계산
    active = models.BooleanField(default=True)
```

### 5-3. `Riding_track` (ranking_app/models.py, 신규 · 영구 · 유료 전용)
```python
class Riding_track(models.Model):
    """세션 1개 = 궤적 1개. 3일 삭제 없음. 유료 전용 자동저장. 궤적 이미지/공개프로필 소스."""
    riding_track_id = models.AutoField(primary_key=True)
    user_id = models.ForeignKey(User, on_delete=models.CASCADE, db_column='user_id')
    slope_id = models.ForeignKey(Slope_info_2627, null=True, on_delete=models.SET_NULL, db_column='slope_id')
    ranking_id = models.OneToOneField(Ranking_record_2627, on_delete=models.CASCADE, db_column='ranking_id')  # 1:1
    track = gis_models.LineStringField(geography=True, srid=4326)   # 세션 시작~종료 전 좌표
    created_at = models.DateTimeField(default=timezone.now)
    # saved_by 없음 — 유료 자동저장만 (무료 셀프저장 폐기)
```

### 5-4. `User_live_position` (ranking_app/models.py, 신규 · 친구 실시간 위치)
```python
class User_live_position(models.Model):
    """유저당 1행 upsert. Slope_pass_temp의 친구 위치 역할 대체. 무료·유료 전원."""
    user_id = models.OneToOneField(User, primary_key=True, on_delete=models.CASCADE, db_column='user_id')
    coordinates = gis_models.PointField(geography=True, srid=4326)
    slope_id = models.ForeignKey(Slope_info_2627, null=True, on_delete=models.SET_NULL, db_column='slope_id')
    is_riding = models.BooleanField(default=False)
    updated_at = models.DateTimeField(auto_now=True)
```

### 5-5. `Error_log` (수정 · slope_id 추가, nullable)
```python
    slope_id = models.ForeignKey(Slope_info_2627, null=True, blank=True,
                                 on_delete=models.SET_NULL, db_column='slope_id')  # 검증·디버그 보조
```

### 데이터 역할
- **Error_log** = 궤적 원천(연속 좌표, 3일 삭제) · **Riding_track** = 영구 궤적(유료)
- **Ranking_record_2627** = 커밋된 라이딩+점수(영구) · **User_live_position** = 지금 위치(유저당 1행)

---

## 6. 무료 / 유료 정책

| | 무료 | 유료 |
|---|---|---|
| 라이딩 카운트·점수 (`Ranking_record_2627`) | ✅ | ✅ |
| 실시간 위치 (`User_live_position`) | ✅ | ✅ |
| 궤적 영구저장 (`Riding_track`) | ❌ **저장 불가** | ✅ **커밋 시 자동저장** |

- 무료 셀프저장·저장 버튼·Live Activity 저장 버튼 **모두 없음**

---

## 7. 로그/전송 메커니즘 (용어)

- **버퍼(buffer)**: 좌표(5m/1초)를 폰 메모리에 쌓는 리스트 (`_logBuffer`)
- **flush**: 버퍼에 쌓인 좌표를 서버로 **일괄 전송**하는 동작
  - 주기: **60초마다** 또는 **500개** 도달 시 (`_logFlushIntervalSeconds=60`, `_maxBufferSize=500`)
  - **세션 상태 전환 시 즉시 flush → `User_live_position` 즉시 upsert** (60초 주기와 별개, 친구 위치 지연 방지):
    - **새 세션 시작**: `is_riding=true`, `slope_id=시작 슬로프`
    - **세션 종료(커밋)**: `is_riding=false`, `slope_id=null`
    - **활성 슬로프 변경**(연속 A→B 등): `slope_id=새 슬로프`
- **span**: 진행률의 최대−최소 폭 (얼마나 내려갔나). `coverage` 컬럼에 기록(참고용)
- 세션 상태(entry_progress, 궤적, max_progress)는 **클라 메모리 변수** — DB 아님. DB 쓰기는 flush(로그)와 commit(세션 종료) 뿐

---

## 8. API 변경

| API | 변경 |
|---|---|
| `check-wb/` | 응답 `slope_info`를 **폴리곤 좌표열 + 축**으로 (2627 슬로프) |
| `commit-ride/` (신규) | 세션 커밋: 원시지표+궤적 수신 → 서버 점수 계산 → `Ranking_record_2627`(+유료 `Riding_track`) 생성. **응답 계약 `inserted_count`, `latest_slope_fullname` 유지** (세션 카운트·Live Activity·홈 dailyTotalCount 구동) |
| `error-log-bulk/` | `slope_id` 수용 + **배치 마지막 좌표로 `User_live_position` upsert** |
| `add-check-point/` · `respawn/` · `reset/` | **폐기** |
| 친구 위치 (friend_app) | 소스 `Slope_pass_temp` → **`User_live_position`** |

---

## 9. 프론트 변경 (거의 `vm_resortHome.dart` 국소)

- `_isWithinRadius` → **ray-casting 점-in-폴리곤**
- `checkPositionInAreas` → `checkRidingInSlopes()`(폴리곤) + `checkSnowballHits()`(점+반경 유지) **분리**
- 원 판별·6개 호출부(addCheckPoint/respawn/reset @1203/1289/1367/1751/1837/1920) → **세션 상태머신 + commit-ride**
- 세션 궤적 누적(메모리), 진입/커밋 시 즉시 flush
- `check_wb` 응답 파싱을 폴리곤+축으로
- **새 UI 없음** (라이딩 시작 인디케이터 등 신규 화면 만들지 않음)

---

## 10. 영향 범위 매트릭스 (전환 시)

### 🔴 반드시 함께 고침
- 랭킹 점수 집계 **19곳**: `Sum('slope_id__score')` (ranking_app 9 + crew_app 10) → **per-ride `score` 합산**
- `add-check-point/respawn/reset` 폐기·재설계 + `Slope_pass_temp` 정리
- **친구 실시간 위치**: `Slope_pass_temp` → `User_live_position`
- 라이딩카드 재계산 + `Ranking_record` 소비처(resorthome/themeStore/friendDetailPage) → 2627 모델 교체
- **커밋 API 응답 계약**(`inserted_count`/`latest_slope_fullname`) 유지

### 🟡 함께 검토
- 홈 점수·횟수 / 크루 점수 — 서버 필드명 유지 시 UI 무손상
- 티어(`Ranking_tier`) — 집계 소스 교체 시 자동 반영, 검증만
- 기록실 passcount 그래프 — 횟수 유지 시 무변경

### 🟢 무관
- **beta(`Ranking_indiv/crew_beta`)** — 과거 데이터 집계 그대로, **손대지 않음**
- **눈송이** — 점+반경 유지, 함수만 분리
- point/payment/event/community/fcm/user/forestPark/livetalk — 참조 전무
- 라이딩카드 — 이미 거리/경사/속도 기반, 새 스키마와 정합
- 슬로프러시·지도 렌더링 — slope_info 미사용

---

## 11. 단계별 로드맵

- **Phase 0 — 스키마**: `Slope_info_2627`/`Ranking_record_2627`/`Riding_track`/`User_live_position` 신규 + `Error_log.slope_id`. makemigrations (migrate 적용은 별도 확인). 순수 추가라 안전
- **Phase 1 — 어드민 폴리곤 도구**(병목 선행): 폴리곤+방향축 그리기, `Slope_info_2627` CRUD, 파일럿 리조트 1곳 폴리곤화 (`ST_Buffer` 중심선 반자동 검토)
- **Phase 2 — 백엔드 API**: `commit-ride/`(서버 스코어링, 응답 계약 준수), `check-wb/` 폴리곤 응답, `error-log-bulk/` live position upsert, 친구 위치 소스 교체
- **Phase 3 — 프론트 상태머신**: ray-casting, 함수 분리, 진행률 상태머신, commit 호출, 궤적 누적, 즉시 flush
- **Phase 4 — 검증(Dual-run)**: 파일럿 리조트에서 원 방식 vs 폴리곤 방식 동시 실행 비교. 노이즈 임계값(진입 2점/종료 2~3점/하강 하한) 튜닝. 눈송이·친구위치·세션카운트·Live Activity 회귀 테스트
- **Phase 5 — 전환**: 26/27 시즌부터 신규 시스템 적용, 랭킹 집계 19곳 교체, 구 엔드포인트/`Slope_pass_temp` 폐기

---

## 12. 추후 결정 (미확정)
- 스코어링 세부 가중치(Base·난이도·스타일 지수) — 일단 동일
- 속도 신호: 평균 vs 퍼센타일
- 노이즈/턴/경계 흡수 임계값(진입 2점 / 종료 밴드Δ / 이탈 2~3점 / 재진입 유예 시간·거리 / 하강 하한) — Phase 4 실측 튜닝

---

## 부록 — 핵심 코드 터치포인트
- 프론트 판별/전송: `lib/viewmodel/resortHome/vm_resortHome.dart` (판별 2078, 반경 2124, 호출 1203/1289/1367/1751/1837/1920, 로그버퍼 490~608, flush 상수 189~190)
- 프론트 API: `lib/api/api_ranking.dart` (check_wb 8, addCheckPoint 56, respawn 76, reset 94)
- 백엔드 점수 집계: `ranking_app/api/views.py`(9곳) · `crew_app/api/views.py`(10곳) `Sum('slope_id__score')`
- 백엔드 모델: `resort_app/models.py`(Slope_info 23) · `ranking_app/models.py`(Ranking_record 15, Error_log 139)
- 친구 위치: `friend_app/api/views.py:252-267` (Slope_pass_temp 의존)
- 3일 삭제: `reset_within_boundary.py:22-23`
