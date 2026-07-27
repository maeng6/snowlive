# 스노우라이브 — 폴리곤 기반 라이딩 판별 & 스코어링 전환 계획서

작성일: 2026-07-23 · 개정: 2026-07-26 (판별 로직 오프라인 시뮬 검증 반영 — bin기반 커버리지 + 시간포함 dedup + 연속/중간합류/공유하단) · **개정: 2026-07-27** (스코어링 **덧셈형(거리6:경사3:속도1) 확정**, **접합점 기반 연결감지**(포크/중간합류/꼬리물기), **세션 노브·원격설정·병행전환(dual-write) 확정** — §3-2·§3-5·§4)
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
  - **밴드Δ = 25 m 확정** (턴 역행보다 크고 리프트·걸어오름보다 작게). 어드민 원격설정
- **정체(평지·횡단)는 종료 아님**: 진행률이 안 늘어도 max에서 후퇴가 아니면 세션 유지
- **S자 턴 역행/작은 지터**: max_progress − Δ 밴드 안이면 무시 → 세션 안에 포함(궤적·점수 반영). 뚱뚱한 S자 모양도 궤적에 정직하게 그려짐
- **이탈 히스테리시스**: 폴리곤 밖 좌표 1개로 즉시 종료 ❌ → **연속 3점 밖**일 때만 이탈 확정(기본 3, 원격설정). 경계 오차·GPS 튐 1~2점은 무시(세션 유지)
- **재진입 유예**: 이탈 확정 전 **유예 3점 이내 같은 폴리곤 재진입**(기본 3, 원격설정) 시 새 세션 말고 **기존 세션 이어감** → 경계에서 잠깐 삐져나감으로 라이딩이 쪼개지거나 중복 카운트되는 것 방지
- **GPS 스파이크 제거**: 순간이동 수준 좌표는 상태머신 진입 전 `_validatePosition`/Mock 감지에서 걸러 이탈 오판 방지
- **폴리곤은 넉넉하게**: 어드민에서 슬로프보다 약간 크게 그려 경계 지터를 흡수
- 시작 2점 · 종료 밴드Δ(25m) · 이탈 3점 · 재진입 유예 3점은 **노이즈/턴/경계 흡수 노브** — **전부 어드민 원격설정**(§4-6), 실측 미세튜닝은 Phase 4

### 3-3. 커밋 (라이딩 인정)
- **전부 카운트**: 진짜 하강이면 무조건 `Ranking_record_2627` 생성 + 점수 부여. 짧은 라이딩은 거리·하강고도가 작아 점수가 낮게 매겨짐(스코어링이 크기 흡수). **커버리지 30% 게이트 폐기.**
- 리프트/걸어오름 배제는 3-2의 **진입=하강 조건**이 담당 (진입 자체가 하강일 때만 세션 열림)
- **노이즈 하한**: GPS 튐 2초짜리 헛것만 거르는 아주 작은 하강 하한만 유지
- **부분 라이딩(포크/중간합류)**: 정책 (A) **1회 카운트**. 점수는 **실제 탄 GPS 거리만큼** 자동 부분 반영(거리점수가 실측 궤적 기반이라 별도 fraction 로직 불필요) — §4-2
- 커밋 시 `commit-ride` API 호출 + 즉시 flush

### 3-4. 특수 케이스
| 케이스 | 동작 |
|---|---|
| 걸어 올라가기 | 진행률 상향 → 세션 시작 안 함 / 중간이면 max−Δ 후퇴로 종료 → 카운트 X |
| 리프트로 슬로프 위 횡단 | 진입이 하강 아님 → 세션 시작 안 함 |
| 슬로프 중간까지 타고 리프트로 올라감 | max−Δ 후퇴 감지 시 종료, **최하단 지점까지를 궤적·점수로 커밋**. 이후 재하강 시 새 세션 |
| **뚱뚱한 S자 턴(순간 역행)** | max−Δ 밴드 안이면 **세션 유지**, 역행 좌표도 궤적·점수 포함 |
| **경계 오차·GPS 튐으로 잠깐 폴리곤 밖** | 연속 2~3점 밖 아니면 **세션 유지** / 재진입 유예 내 복귀 시 이어감 → 쪼개짐·중복 방지 |
| 평지·횡단 | 진행률 정체(후퇴 아님) → 세션 유지 |
| **연속(A→B, 상단연결)** | A 끝나고 B 시작(서로 시간상 안 감쌈) → **A·B 각 1회** |
| **중간합류(A하단→B중간)** | A 완주 후 B 중간부터 이어 하강. B가 **고유 하단 구간**을 가지면(A 밖으로 뻗음) → **A·B 각 1회** |
| **공유하단(도도/슬로프스타일)** | 두 폴리곤 겹침. 안 탄 슬로프 후보는 실제 탄 슬로프 세션에 **시간상 포함(nesting)** 돼 억제 → **실제 탄 하나만** |

### 3-5. 겹침·연속·공유하단 귀속 (dedup) — **현행 구현**
> 구현: `lib/test_polygon/polygon_session_machine.dart` · 검증: `docs/polygon_test_runbook.md` (6개 리조트 통과).
> ⚠️ 초기 설계의 "커버리지(미터) 큰 슬로프 우선" 규칙은 **부분주행(중간합류) 시 짧은 이웃에 뺏기는 문제**로 폐기 → 아래 **bin기반 진행률 + 시간포함(nesting)** 으로 대체됨.

**커버리지 = 실주행 축 구간 비율(bin 기반).** 축을 5m 단위 bin으로 나누고, 좌표가 **그 폴리곤 안일 때만** 해당 bin을 채운다. 커버리지 = 채운 bin 수 / 전체 bin 수. → 진행률 "스팬(최대−최소)"이 아니라 **실제 지나간 구간의 밀도**라, 띄엄띄엄 걸쳐 지나가도 부풀지 않음(투영 착시 방지).

- **각 점은 그 폴리곤 안에 있을 때만** 해당 슬로프 진행률에 합산 → A 단독 구간에선 B 진행률이 안 오르고, 공유 구간에선 둘 다 오른다.
- **후보는 폴리곤별 병렬 추적** (전부 클라 메모리, 서버 API는 커밋 때 1회). 후보 시작은 막지 않음(막으면 합류가 깨짐).
- **dedup = 시간포함(nesting) 기반** — 종료된 후보 그룹을 **확정 시점에 일괄 판정**:
  - 후보 B의 세션 구간이 다른 후보 A의 세션 구간 안에 **완전히 들어가면(늦게 시작 + 먼저·같이 끝남) B 억제** = B는 A에 올라탄 승객(공유하단의 안 탄 슬로프).
  - 보조: 두 세션이 실질적으로 겹치고(≥50%) A 진행률이 더 크면 억제 — **단 B가 A를 감싸면 예외**(감싸는 쪽 우선). 경계 1틱 스침은 겹침으로 안 봄.
- **연속(A→B)·중간합류**: A가 끝난 뒤 B 시작 → 서로 시간상 안 감쌈 → **둘 다 커밋**. B가 A 밖으로 뻗는 **고유 하단 구간**이 있으면 nesting에 안 걸린다.
- **공유하단**: B의 하단이 A 폴리곤에 대부분(>80%) 잠겨 **고유 하단이 없으면** → B 세션이 A에 포함 → **A만 커밋**. (연속/중간합류 검출도 이 경우를 "연속 아님"으로 제외)
- **왜 정확한가**: 실제 탄 슬로프는 자기 축을 완주해 세션이 그룹 전체를 감싼다 → 억제 안 됨. 겹친 이웃은 공유 구간만 잡혀 그 안에 포함 → 억제. **겹침이 균일할 필요 없고, 각 슬로프가 "고유 상단(진입부)"만 가지면 됨.** 한 폴리곤이 다른 걸 통째로 삼키는 **near-duplicate(겹침≈100%)만 피하면** 된다.
- **폐기 = 서버 레코드를 애초에 안 만듦**(commit-ride 호출 안 함, 정리 불필요).

#### 연결 판정 (접합점 junction 모델) — **3가지 유형**
> ⚠️ 초기 검출은 "B 상단점이 A 축에 붙는 포크"만 잡아 **중간합류(A하단→B중간)를 놓쳤음** → **두 축의 최단접근점(junction)** 을 접합점으로 잡는 일반 모델로 교체.

- **연결 게이트 = 폴리곤 맞닿음/겹침**(폴리곤 최소거리 <20m 또는 intersects). ⚠️ **축 끝점 거리로 판정 금지** — 병렬 겹침 슬로프(축은 100m+ 떨어져도 폴리곤은 겹침)를 비연결로 오판함.
- **접합점** = A 축과 B 축이 가장 가까워지는 지점. 그 지점의 **A 진행률 `fa` · B 진행률 `fb`** 로 유형·부분구간 결정:
  - **포크** (`fa<0.85, fb≈0`): B 상단이 A 중간에서 갈라짐 → **A는 0→fa 부분 + B 풀**. 예) 챔피온→디지 (A23%→B0%)
  - **중간합류** (`fb≥0.15`): A 하단이 B 중간으로 합침 → **A 풀 + B는 fb→하단 부분**. 예) 챔피온→스패로우 (A100%→B16%, 스패로우 84%만)
  - **꼬리물기** (`fa≈1, fb≈0`): A 끝→B 시작 → **둘 다 풀**. 예) 밸리→펭귄
- **비연결**: 폴리곤이 20m+ 떨어지면 한 번에 못 탐(리프트/이동) → 각각 별개 세션.
- **공유하단 예외**: `fb≥0.9` 이거나 B의 합류 후 구간이 A 폴리곤에 80%+ 잠기면 = 공유하단으로 보고 연결에서 제외(위 nesting 규칙으로 억제).
- **실서비스에선 이 판정이 자동**: 실 GPS가 폴리곤 진입/이탈 + 진행률로 어느 구간을 탔는지 그대로 알려줌. 접합점 모델은 **오프라인 시뮬 합성 궤적**용(축당 축 1개로 충분, 포크 축을 미리 그릴 필요 없음).

---

## 4. 스코어링 시스템 (**덧셈형 확정 · 2026-07-27**)

### 4-1. 신호 (세션 좌표에서 산출)
| 신호 | 계산 |
|---|---|
| 라이딩 거리 L | **실제 GPS 활강 경로 길이** (세션 궤적 점 사이 거리 합, 스무딩 후) — 축 길이 아님 |
| 경사도 G | 슬로프 **평균경사 `slope_avg`(도)** 고정값 사용 |
| 속도 V | 세션 **평균속도** (km/h) |
| 하강 고도 Δh | 실측 고도 진입−최저 (기록용, **점수엔 미사용** — 경사는 slope_avg로 대체) |

### 4-2. 공식 (**덧셈형** = 거리점수 + 경사점수 + 속도점수)
```
슬로프 점수 = 거리점수 + 경사점수 + 속도점수
  거리점수 = w1 × min( 실제 GPS 활강거리,  탄 구간 축길이 × 1.3 )
  경사점수 = w2 × slope_avg(도)
  속도점수 = w3 × min( 평균속도, 50 × 1.3 = 65 km/h )
```
- **가중 비율  거리 : 경사 : 속도 = 6 : 3 : 1** (기여 밸런스)
- 전체 최고 슬로프가 **≈ 20점**이 되도록 글로벌 스케일 k 보정 (예: 용평 레인보우파라다이스 20)
- **거리 상한 축×1.3**: S자 뻥튀기 어뷰징 방지 — 자연 카빙(1.1~1.3배)은 그대로 인정, 극단 지그재그는 여기서 컷
- **부분 주행**(포크/중간합류): 세션 거리 = 폴리곤 안에서 **실제 탄 GPS 거리** → 거리점수가 **자동으로 부분 반영**. 경사·속도는 그 구간 값. 실 GPS가 곧 실제 탄 구간이라 **별도 fraction 로직 불필요**
- 세 신호가 **독립 합산**이라 **중복계산 없음** (거리와 경사를 곱하지 않음)

### 4-3. 왜 덧셈형인가 (곱셈형 폐기 사유)
- 초기 곱셈형(`Base(Δh√L)×난이도×스타일`)은 경사가 3곳에 곱으로 작용해 **완경사↔급경사가 ~9배**로 벌어짐 → 분포 **SD 4.2·CV 0.95, 최저 슬로프 0점대**로 바닥에 깔림
- 덧셈형은 **SD 2.85·CV 0.29, 최저 슬로프도 4점대**로 촘촘 + 길이 잘 반영(긴 완경사 슬로프도 대접)
- 검증: 6개 리조트 전 슬로프 + 휘닉스 조합(포크/중간합류/꼬리물기) 시뮬로 확인 (`docs/polygon_test_runbook.md`)

### 4-4. 계산 위치 = 서버
- 클라는 **원시 측정값(거리·평균속도·궤적)만 전송** → **서버가 slope_avg 조회 + 노브 적용 + score 산출**
- 이유: 앱 업데이트 없이 튜닝, 치팅 방지, 일관성

### 4-5. 확정된 정책
- 부분 라이딩: **(A) 1회 카운트**, 점수는 실제 탄 거리만큼
- **슬로프별 상대점수/티어 리그 도입 안 함**
- **slope_avg / length 참고값 유지** → **slope_avg는 이제 경사점수 입력으로도 사용**

### 4-6. 원격 설정 노브 (어드민 · 실시간 반영)
앱 업데이트 없이 조정. **앱 시작/liveOn 시 config fetch**, 실패 시 안전 기본값 fallback. 값(스칼라 몇 개)만 바뀌고 **코드 분기·로직은 고정** → 메모리 영향 미미.
| 노브 | 기본값 | 의미 |
|---|---|---|
| 점수 가중 w1:w2:w3 | **6:3:1** | 거리·경사·속도 밸런스 |
| 글로벌 스케일 k | (max≈20 보정) | 전체 점수 스케일 |
| 거리 상한 배수 | **1.3** | GPS/축 비율 상한(어뷰징 방지) |
| 속도 상한 | **65 km/h** | 속도점수 cap (50×1.3) |
| 이탈 허용 | **3점** | 연속 몇 GPS점 밖이면 이탈 확정 |
| 재진입 유예 | **3점** | 이탈 확정 전 재진입 시 세션 이어감 |
| 밴드 Δ | **25 m** | max_progress 후퇴 허용(턴 흡수) |

> ⚠️ 노브는 **값만** 원격 조정 — 새 신호·새 연결유형 같은 **로직 변경은 앱 배포 필요**.

### 4-7. 병행 전환 (Dual-write) & 플래그
겨울에만 오픈 → 필드 테스트 불가 → 사실상 **도박성 프로덕션 배포**. 위험 완화를 위해 **구/신 병렬 기록**:
- **쓰기**: 세션마다 **구 방식(원+반경 → `Ranking_record`) + 신 방식(폴리곤 → `Ranking_record_2627`) 둘 다 기록**. 엔진별 **write 플래그**로 개별 on/off.
- **읽기**: 랭킹·홈·크루가 어느 세트를 집계·표시할지 **단일 read 플래그**로 결정. write와 **decouple**.
- **어드민 토글**: 신버전/구버전 체크 + 신버전 on/off. 문제 시 **read만 즉시 구버전 롤백**(양쪽 데이터 다 있음).
- **확장/축소(expand→contract)**: ① 신 쓰기 추가(dark launch) → ② 검증 → ③ read 전환 → ④ 구 쓰기 제거.
- 병렬 기록이라 백엔드 엔드포인트 **구/신 2세트** 필요(commit-ride, check-wb, live position, ranking-read).

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
    distance = models.FloatField(null=True, blank=True)        # m — 실제 GPS 활강거리(원본) ✅거리점수 입력
    entry_progress = models.FloatField(null=True, blank=True)  # 탄 구간 시작 진행률 0~1 (포크/중간합류 부분계산)
    exit_progress = models.FloatField(null=True, blank=True)   # 탄 구간 끝 진행률 0~1
    avg_speed = models.FloatField(null=True, blank=True)       # km/h ✅속도점수 입력(65 cap)
    max_speed = models.FloatField(null=True, blank=True)       # km/h (원본, 기록용)
    vertical_drop = models.FloatField(null=True, blank=True)   # m 실측 고도 (기록용, 점수 미사용)
    gradient = models.FloatField(null=True, blank=True)        # % Δh/L (기록용) — 점수는 slope.slope_avg(도) 사용
    coverage = models.FloatField(null=True, blank=True)        # 진행률 span 0~1 (기록용, 카운트 게이트 아님)
    score = models.FloatField(default=0)                       # 서버 계산 (덧셈형 §4-2)
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
    """유저당 1행 upsert. 친구 위치 신 소스 (구 Slope_pass_temp와 병행 → 친구위치는 듀얼 READ). 무료·유료 전원."""
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

### 5-6. `Riding_config` (resort_app/models.py, 신규 · 원격 노브 + 병행전환 플래그)
싱글턴(1행). 어드민에서 수정 → 앱이 **시작/liveOn 시 fetch**(check-wb 응답에 실어보내거나 별도 `riding-config/` 엔드포인트). 값(스칼라)만 바뀌고 **코드 분기·로직 고정** → 메모리 영향 미미.
```python
class Riding_config(models.Model):
    # ── 점수 노브 (§4-2) ──
    w_distance     = models.FloatField(default=6.0)    # 거리 가중
    w_gradient     = models.FloatField(default=3.0)    # 경사 가중
    w_speed        = models.FloatField(default=1.0)    # 속도 가중
    global_k       = models.FloatField(default=1.0)    # 전체 스케일 (max≈20 보정)
    dist_cap_ratio = models.FloatField(default=1.3)    # GPS/축 상한 배수 (S자 어뷰징)
    speed_cap      = models.FloatField(default=65.0)   # 속도점수 cap km/h (50×1.3)
    # ── 세션 노브 (§3-2) ──
    exit_tolerance = models.IntegerField(default=3)    # 이탈 확정 연속 점수
    reentry_grace  = models.IntegerField(default=3)    # 재진입 유예 점수
    band_meters    = models.FloatField(default=25.0)   # max_progress 후퇴 밴드 Δ (m)
    # ── 병행전환 플래그 (§4-7) ──
    write_legacy   = models.BooleanField(default=True) # 구 방식(원+반경) 기록 on/off
    write_polygon  = models.BooleanField(default=True) # 신 방식(폴리곤) 기록 on/off
    read_source    = models.CharField(max_length=10, default='legacy')  # 집계·표시 소스 'legacy'|'polygon'
    updated_at     = models.DateTimeField(auto_now=True)
```
- **점수 노브(w·k·cap)** 는 서버에서만 쓰면 됨(서버 스코어링) → 클라 fetch 불필요. **세션 노브(이탈·재진입·밴드)** 만 클라가 fetch.
- Firebase Remote Config 대안 가능하나, 이미 서버가 점수를 계산하므로 **Django 단일 config 테이블**이 단순·일관적. `read_source`는 백엔드 집계에서만 참조.

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

### 유료 판별 (`_is_paid_user`)
- **서버에서 판별** (클라 플래그 아님, 치팅 방지). commit-ride가 이 헬퍼로 `Riding_track` 저장 여부 결정
- **현재(결제 도입 전)**: 전원 유료로 취급 → `return True` (디버깅/궤적 데이터 수집)
- **향후(인앱 결제 도입 시)**: `payment_app` 구독정보로 판별. 예)
  ```python
  UserSubscription.objects.filter(user_id=user, is_active=True,
      expires_at__gt=timezone.now()).exists()
  ```
  (구독 모델은 결제 시스템 설계 시 확정 → 헬퍼 한 곳만 교체하면 전체 반영)

---

## 7. 로그/전송 메커니즘 (용어)

- **버퍼(buffer)**: 좌표(5m/1초)를 폰 메모리에 쌓는 리스트 (`_logBuffer`)
- **flush**: 버퍼에 쌓인 좌표를 서버로 **일괄 전송**하는 동작
  - 주기: **60초마다** 또는 **500개** 도달 시 (`_logFlushIntervalSeconds=60`, `_maxBufferSize=500`)
  - **세션 상태 전환 시 즉시 flush → `User_live_position` 즉시 upsert** (60초 주기와 별개, 친구 위치 지연 방지):
    - **새 세션 시작**: `is_riding=true`, `slope_id=시작 슬로프`
    - **세션 종료(커밋)**: `is_riding=false`, `slope_id=null`
    - **활성 슬로프 변경**(연속 A→B 등): `slope_id=새 슬로프`
- **coverage(커버리지)**: **실주행 축 구간 비율(5m bin 기반)** — dedup 판정·`coverage` 컬럼 기록용. (초기 설계의 "진행률 스팬(최대−최소)"에서 변경 — §3-5)
- 세션 상태(entry_progress, 궤적, max_progress)는 **클라 메모리 변수** — DB 아님. DB 쓰기는 flush(로그)와 commit(세션 종료) 뿐

---

## 8. API 변경

| API | 변경 |
|---|---|
| `check-wb/` | 응답 `slope_info`를 **폴리곤 좌표열 + 축**으로 (2627 슬로프). **세션 노브(이탈·재진입·밴드) 동봉** → 클라가 fetch |
| `commit-ride/` (신규) | 세션 커밋: 원시지표+궤적 수신 → 서버 점수 계산 → `Ranking_record_2627`(+유료 `Riding_track`) 생성. **응답 계약 `inserted_count`, `latest_slope_fullname` 유지** (세션 카운트·Live Activity·홈 dailyTotalCount 구동) |
| `riding-config/` (신규, 선택) | 세션 노브만 반환(check-wb에 못 실을 때). 어드민 `Riding_config` 소스 |
| `error-log-bulk/` | `slope_id` 수용 + **배치 마지막 좌표로 `User_live_position` upsert** |
| `add-check-point/` · `respawn/` · `reset/` | **폐기** |
| 친구 위치 (friend_app) | **듀얼 READ**: `User_live_position`(신) 우선 + `Slope_pass_temp`(구) fallback. ⚠️ **교체 아님** — 병행전환 중 구/신 유저가 공존하므로 둘 다 읽어야 함. 구버전 쓰기 경로(add-check-point)는 **안 건드림**(도박 배포 중 legacy 위험 회피). 완전 전환 후 fallback 제거 |

### 8-1. `commit-ride/` 계약 (상세)
**요청** (세션 1건, 연속 A→B면 세션 배열):
```jsonc
{ "sessions": [ {
    "slope_id": 123,
    "started_at": "...", "ended_at": "...",
    "distance": 1080.5,            // 실제 GPS 활강거리 m (원본)
    "entry_progress": 0.0, "exit_progress": 0.24,  // 탄 구간(포크/중간합류 부분계산)
    "avg_speed": 41.2, "max_speed": 55.0,
    "vertical_drop": 210.0,        // 기록용
    "coverage": 0.24,              // 기록용
    "save_track": true,            // 유료 여부는 클라가 판단(구독모델 미정) → 플래그로 전달
    "track": [[lng,lat],...]       // save_track=true일 때만 저장, 아니면 서버가 버림
} ] }
```
> ⚠️ 클라는 **score를 보내지 않음.** 서버가 slope_avg·가중치·상한을 쥐고 계산(치팅 방지).

**서버 처리**:
1. `Slope_info_2627`에서 `slope_avg`(도)·축길이 조회, `Riding_config` 노브 로드
2. 탄 구간 축길이 = `(exit−entry) × 전체 축길이`
3. 거리 상한: `min(distance, 탄구간축길이 × dist_cap_ratio)`
4. `frac = exit_progress − entry_progress` (미지정 1.0). `score = global_k × ( w_distance×상한거리 + frac × (w_gradient×slope_avg + w_speed×min(avg_speed, speed_cap)) )`
   - ⚠️ **경사·속도도 `frac`로 스케일** — 거리는 실 GPS라 이미 부분값이지만 경사·속도는 per-ride 평균이라 풀로 들어가면 급경사 조금씩 파밍 가능 → 탄 비율만큼 반영 (combo 시뮬과 일치)
5. `write_polygon` on → `Ranking_record_2627` 생성 (+`save_track` 플래그시 유료 `Riding_track`), `User_live_position` upsert(`is_riding=false`)
6. **구 방식 dual-write는 클라 주도**: 두 엔진(원+반경 / 폴리곤)은 입력이 달라 서버가 합칠 수 없음 → 클라가 `write_legacy` on이면 기존 `add-check-point/respawn`을 병행 호출. commit-ride는 폴리곤 기록만 담당

**응답**: `{ "inserted_count": N, "latest_slope_fullname": "챔피온" }` (기존 계약 유지)

### 8-2. 병행 전환용 2세트 엔드포인트
| 목적 | 구(legacy) | 신(polygon) |
|---|---|---|
| 세션 커밋 | `add-check-point/`(유지) | `commit-ride/` |
| 슬로프 정보 | 기존 `check-wb`(원+반경) | `check-wb` 폴리곤 응답 |
| 실시간 위치 | `Slope_pass_temp` | `User_live_position` |
| 랭킹 읽기(집계) | `Ranking_record` 집계 | `Ranking_record_2627` 집계 |
- **읽기 분기는 `Riding_config.read_source` 하나로** 스위칭 (write는 플래그별 독립).

---

## 9. 프론트 변경 (거의 `vm_resortHome.dart` 국소)

- `_isWithinRadius` → **ray-casting 점-in-폴리곤**
- `checkPositionInAreas` → `checkRidingInSlopes()`(폴리곤) + `checkSnowballHits()`(점+반경 유지) **분리**
- 원 판별·6개 호출부(addCheckPoint/respawn/reset @1203/1289/1367/1751/1837/1920) → **세션 상태머신 + commit-ride**
- **`poly=true` 분기**: 기존 진입 흐름 그대로 두고, 폴리곤 로드·판별·commit-ride만 새 경로로. **별도 진입점 X** (`main_test.dart`는 시뮬 검증 실행용). 프로덕션 배포 시 `poly=true`로 폴리곤 모드 전체 작동
- 세션 궤적 누적(메모리), 진입/커밋 시 즉시 flush. **세션 노브(이탈·재진입·밴드)는 check-wb에서 fetch**
- `check_wb` 응답 파싱을 폴리곤+축으로
- **새 UI 없음** (라이딩 시작 인디케이터 등 신규 화면 만들지 않음)

---

## 10. 영향 범위 매트릭스 (전환 시)

### 🔴 반드시 함께 고침
- 랭킹 점수 집계 **19곳**: `Sum('slope_id__score')` (ranking_app 9 + crew_app 10) → **per-ride `score` 합산**. **`read_source` 플래그로 구/신 소스 스위칭**(병행전환) — 전환은 플래그 한 번, 롤백도 플래그 한 번
- `add-check-point/respawn/reset` 폐기·재설계 + `Slope_pass_temp` 정리
- **친구 실시간 위치**: **듀얼 READ** (`User_live_position` 우선 + `Slope_pass_temp` fallback) — 교체 아님, 병행전환 중 구/신 공존. 구버전 쓰기 경로 미변경
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

- **Phase 0 — 스키마**: `Slope_info_2627`/`Ranking_record_2627`/`Riding_track`/`User_live_position`/**`Riding_config`** 신규 + `Error_log.slope_id`. makemigrations (migrate 적용은 별도 확인). 순수 추가라 안전
- **Phase 1 — 어드민 폴리곤 도구**(병목 선행): 폴리곤+방향축 그리기, `Slope_info_2627` CRUD, 파일럿 리조트 폴리곤화. **어드민에 `Riding_config` 노브·병행전환 토글 UI**. (slope-admin 에디터 이미 구축)
- **Phase 2 — 백엔드 API**: `commit-ride/`(**덧셈형 서버 스코어링 §4-2**, 응답 계약 준수), `check-wb/` 폴리곤+세션노브 응답, `error-log-bulk/` live position upsert, 친구 위치 소스 교체. **`write_legacy`/`write_polygon`/`read_source` 플래그 분기**
- **Phase 3 — 프론트 상태머신**: ray-casting, 함수 분리, 진행률 상태머신(이탈3/재진입3/밴드25m 노브), commit 호출, 궤적 누적, 즉시 flush. **기존 `vm_resortHome`에 `poly=true` 분기 추가**(별도 진입점 대신), 시뮬 검증은 `main_test.dart`
- **Phase 4 — 검증(Dual-write)**: 파일럿에서 **구·신 병렬 기록** 후 read_source 비교. 노브 실측 미세튜닝. 눈송이·친구위치·세션카운트·Live Activity 회귀 테스트. **겨울 실데이터로 global_k 재보정**
- **Phase 5 — 전환**: `read_source=polygon` 스위칭 → 랭킹 집계 19곳 신 소스, 안정화 후 `write_legacy=false` + 구 엔드포인트/`Slope_pass_temp` 폐기 (expand→contract)

---

## 12. 확정 / 추후 결정

**확정 (2026-07-27)**
- 스코어링: **덧셈형, 거리:경사:속도 = 6:3:1, 거리상한 축×1.3, 속도상한 65km/h, max≈20 스케일** (§4)
- 속도 신호: **평균속도** 사용
- 세션 노브: **이탈 3점 / 재진입 3점 / 밴드 25m** (전부 원격설정, §4-6)
- 연결 감지: **접합점 기반 포크/중간합류/꼬리물기** (§3-5)
- 전환: **병행 기록(dual-write) + write/read 플래그 + 어드민 신·구 토글** (§4-7)

**추후 결정 (미확정)**
- 노브 기본값의 **실측 미세튜닝**(진입 2점 / 밴드 25m / 이탈·재진입 3점 / 하강 하한) — Phase 4 겨울 실측
- 글로벌 스케일 k 최종 보정값 (시즌 초 실데이터로 재보정)

---

## 부록 — 핵심 코드 터치포인트
- 프론트 판별/전송: `lib/viewmodel/resortHome/vm_resortHome.dart` (판별 2078, 반경 2124, 호출 1203/1289/1367/1751/1837/1920, 로그버퍼 490~608, flush 상수 189~190)
- 프론트 API: `lib/api/api_ranking.dart` (check_wb 8, addCheckPoint 56, respawn 76, reset 94)
- 백엔드 점수 집계: `ranking_app/api/views.py`(9곳) · `crew_app/api/views.py`(10곳) `Sum('slope_id__score')`
- 백엔드 모델: `resort_app/models.py`(Slope_info 23) · `ranking_app/models.py`(Ranking_record 15, Error_log 139)
- 친구 위치: `friend_app/api/views.py:252-267` (Slope_pass_temp 의존)
- 3일 삭제: `reset_within_boundary.py:22-23`
