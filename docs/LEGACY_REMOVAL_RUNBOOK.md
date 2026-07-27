# 레거시(원+반경) 제거 런북 — 폴리곤 방식 영구 전환

작성: 2026-07-27
목적: 폴리곤 방식이 실전 검증되면 **구버전(원+반경) 시스템을 안전하게 제거**하기 위한 단계별 절차.
연관: `docs/POLYGON_RIDING_PLAN.md` (전체 설계)

---

## 0. 현재 상태 (병행 dual-write)

| 구분 | 구(legacy) | 신(polygon) |
|---|---|---|
| 슬로프 | `Slope_info` (원+반경) | **`Slope_info_2627`** (폴리곤+축, **시즌별 테이블** — 이후 시즌 `_2728`…) |
| 라이딩 기록 | `Ranking_record` (고정점수) | `Ranking_record_2627` (per-ride score, **시즌별**) |
| 커밋 | `add-check-point/` → `respawn/` | `commit-ride/` |
| 실시간 위치 | `Slope_pass_temp` | `User_live_position` |
| 판별 | 클라 원+반경 | 클라 폴리곤 세션머신 |

- **쓰기**: `Riding_config.write_legacy` / `write_polygon` 플래그로 각각 on/off (현재 둘 다 on)
- **읽기(랭킹 집계)**: `Riding_config.read_source` = `'legacy'`(기본) 또는 `'polygon'`
- **read_source 스위칭은 이미 사전구축 완료** — 랭킹 집계 20곳이 `ranking_src()` 헬퍼를 통해 소스 선택

---

## 1. 전환 순서 (expand → contract)

```
① 신 쓰기 검증 (write_polygon=on, 겨울 실데이터 축적)
② read_source=polygon 전환 (랭킹이 신 소스로)  ← 무중단, 롤백 가능
③ 안정화 관찰 (며칠~몇 주)
④ write_legacy=off (구 기록 중단)               ← 여기까지 롤백 쉬움
⑤ 레거시 코드·테이블 영구 제거 (본 런북 §3)      ← 되돌리기 어려움
```

**②③④는 어드민 플래그만으로 무중단.** ⑤만 코드 배포 + 테이블 drop.

---

## 2. 전환 (플래그, 코드변경 없음)

### 2-1. read_source 전환
어드민 `snowlive-admin/config/` → 병행전환 → **read_source = polygon** 저장
- 다음 랭킹 조회부터 `Ranking_record_2627` 집계로 즉시 전환
- 문제 시 **read_source = legacy** 로 즉시 롤백 (구 데이터 그대로 있음)

### 2-2. 구 쓰기 중단
안정화 후 **write_legacy = off** 저장 → 클라가 `add-check-point/respawn` 호출 중단
(신 `commit-ride`만 기록)

---

## 3. 레거시 영구 제거 체크리스트 (⑤단계, 코드 배포)

> ⚠️ **여기부터는 되돌리기 어려움.** ②~④ 안정화 확인 후 진행. DB 백업 필수.

### 3-1. 백엔드 — `ranking_src()` 헬퍼 단순화
read_source 분기를 제거하고 폴리곤 고정으로. **두 곳** 동일:
- `ranking_app/api/views.py` 의 `ranking_src()`
- `crew_app/api/views.py` 의 `ranking_src()`
```python
def ranking_src():
    return Ranking_record_2627, 'score'   # legacy 분기 제거
```
→ 이 한 줄만 바꾸면 20개 집계 지점이 전부 폴리곤 고정 (헬퍼 덕에 지점별 수정 불필요)

### 3-2. 백엔드 — 구 엔드포인트/뷰 제거
`ranking_app/api/`:
- `urls.py`: `add-check-point/`, `respawn/`, `reset/` 라우트 제거
- `views.py`: `AddSlopePassTempView`, `AddRankingRecord`, `DeleteSlopePassTempView` 클래스 제거
- `CheckCoordinatesWithinRadiusView`(check-wb): 응답에서 `slope_info`(구 원+반경), `reset_point`, `respawn_point` 제거 → `slope_info_2627`/`riding_config`만 남김

### 3-3. 백엔드 — 친구위치 듀얼 READ → 단일
`friend_app/api/views.py` (FriendListView):
- `Slope_pass_temp`·`Ranking_record` fallback 제거 → `User_live_position`만 읽기
- import에서 `Slope_pass_temp, Ranking_record` 제거

### 3-4. 백엔드 — recordRoom 시즌 로직 정리 (선택)
`ranking_app/api/views.py` recordRoom들의 `slope_model_name` 분기에서 레거시 시즌(2425/2526) 제거 가능. 단, **과거 시즌 기록 조회를 유지하려면 그대로 둠** (Slope_info_2425/2526 테이블 남겨둘 경우).

### 3-5. 테이블/모델 drop (마이그레이션)
**드롭 대상** (레거시 전용):
- `Ranking_record` (구 라이딩 기록) — user 요청: 레거시 폐기 시 함께 폐기
- `Slope_pass_temp` (구 실시간 위치)
- `Slope_info` (구 원+반경 슬로프) — ⚠️ `Snowball_info.slope_id`, `Ranking_record`가 FK. Snowball도 폴리곤 슬로프로 옮기거나 FK 정리 후 drop
- (선택) `Slope_info_2425`, `Slope_info_2526`, `Ranking_record_2425/2526` — 과거 시즌 조회 불필요 시

**유지**:
- `Slope_info_2627` 및 향후 시즌별 `Slope_info_XXXX` (폴리곤)
- `Ranking_record_2627` 및 향후 시즌별 `Ranking_record_XXXX`
- `Riding_track`, `User_live_position`, `Riding_config`

**주의 — FK 의존성 순서**: `Ranking_record`·`Snowball_info` 등이 `Slope_info`를 참조하므로, 참조하는 쪽 먼저 정리(또는 함께 drop). `Snowball_info`는 눈송이 기능이 계속 쓰므로 **폴리곤 슬로프(`Slope_info_2627`)로 FK 이전**하거나 눈송이 좌표를 유지하는 방식 검토 필요.

### 3-6. 3일 삭제 스크립트
`reset_within_boundary.py`: `Slope_pass_temp` 정리 로직 제거 (테이블 drop 시 무의미)

### 3-7. 프론트 (Flutter) 정리
- `vm_resortHome.dart`: 구 판별(`_isWithinRadius`, `checkPositionInAreas`의 원+반경 부분), `addCheckPoint`/`respawn`/`reset` 호출 제거. **폴리곤 컨트롤러(`PolygonRidingController`)만 남김**
- `api_ranking.dart`: `addCheckPoint`, `respawn`, `reset` 메서드 제거
- ⚠️ **눈송이(`checkSnowballHits`)는 점+반경 유지** — 이건 레거시 아님, 절대 제거 금지

---

## 4. 제거 전 확인 체크리스트

- [ ] read_source=polygon 상태로 **한 시즌(또는 충분 기간) 안정 운영**
- [ ] 랭킹/크루/티어/데일리리포트 신 소스로 정상 표시 확인
- [ ] 친구위치 신 소스만으로 정상
- [ ] DB 전체 백업
- [ ] `Snowball_info.slope_id` FK 처리 방안 결정 (Slope_info drop 전제)
- [ ] 과거 시즌 기록 조회(recordRoom) 폐기 여부 결정

---

## 5. 핵심 파일 인덱스 (제거 대상 빠른 참조)

| 파일 | 제거/변경 |
|---|---|
| `ranking_app/api/views.py` | `ranking_src()` 단순화 · AddSlopePassTempView/AddRankingRecord/DeleteSlopePassTempView 제거 · check-wb 구 필드 제거 |
| `crew_app/api/views.py` | `ranking_src()` 단순화 |
| `friend_app/api/views.py` | 듀얼 READ → User_live_position 단일 |
| `ranking_app/api/urls.py` | add-check-point/respawn/reset 라우트 제거 |
| `ranking_app/models.py` | (drop 시) Ranking_record, Slope_pass_temp |
| `resort_app/models.py` | (drop 시) Slope_info |
| `lib/viewmodel/resortHome/vm_resortHome.dart` | 구 판별·호출 제거, 폴리곤만 |
| `lib/core/api/api_ranking.dart` | addCheckPoint/respawn/reset 제거 |

> 참고: read_source 스위칭이 `ranking_src()` 헬퍼로 중앙화돼 있어, **집계 20곳을 개별 수정할 필요 없이 헬퍼 한 줄만 바꾸면** 폴리곤 고정으로 전환됨.
