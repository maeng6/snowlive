# 크루 · 라이브톡 변경 정리 (백엔드 + 플러터)

작성 시점 기준, **라이브톡 crew_id/secret 추가**와 **크루홈 신규 API**, **크루 게스트 정책**,
**크루 플러터 파일 재정리**를 한 곳에 정리한다. 프론트(뷰) 작업 시 이 문서를 참고.

- 백엔드: `snowlive-api` (Heroku 배포 완료)
- 앱 API 베이스: `https://snowlive-api-c617725e2b78.herokuapp.com/api`
- 플러터 브랜치: `maeng`

---

## 1. 라이브톡 — crew_id · secret 추가 (크루 라이브톡 판별)

### 백엔드
- `LiveTalk` 모델에 필드 추가(둘 다 nullable):
  - `crew_id` (Crew_info FK, `SET_NULL`) — 있으면 **크루 라이브톡**, 없으면 일반 라이브톡
  - `secret` (Boolean) — 크루톡 공개/비공개 (`true`=크루 비공개, `false`=전체공개)
- **정책**: `crew_id`가 있으면 `secret`은 **반드시 지정**돼야 한다(null 금지). 작성 API에서 검증.
- 마이그레이션: `livetalk_app/0002_livetalk_crew_id_livetalk_secret` (적용 완료)
- `LiveTalkSerializer` 응답에 `crew_id`, `secret` 포함.

**작성 API** — `POST /api/livetalk/create/` (raw JSON)
```jsonc
// 일반 라이브톡 (기존과 동일)
{ "user_id": 2715, "description": "오늘 설질 최고", "image_url": null }

// 크루 라이브톡 - 전체공개
{ "user_id": 2715, "description": "우리 크루 정모!", "crew_id": 12, "secret": false }

// 크루 라이브톡 - 비공개(크루만)
{ "user_id": 2715, "description": "내부 공지", "crew_id": 12, "secret": true }
```
- ❌ `crew_id`만 주고 `secret` 누락 → `400 {"error":"secret is required when crew_id is set"}`

### 플러터
- `lib/core/model/m_liveTalk.dart` — `LiveTalk`에 `int? crewId`, `bool? secret` + `bool get isCrewTalk`(=crewId!=null). fromJson/toJson 반영.
- `lib/core/viewmodel/liveTalk/vm_liveTalk.dart` — `create()`에 `int? crewId`, `bool? secret` 파라미터 추가.
  crewId가 있으면 body에 `crew_id`/`secret`을 싣고, `crewId != null이면 secret 필수`를 assert로 강제.
- `lib/core/api/api_liveTalk.dart` — `create(Map)`는 Map 그대로 전송이라 **변경 없음**(호출부에서 키 추가).

---

## 2. 크루홈 — 신규 집계 API

### 요청
```
GET /api/crew/home/     (파라미터 없음, 게스트(비로그인) 허용)
```

### 응답 구조
```
top:                       // 각 최대 10개, 크루 카드 리스트
  newest_crews             // 최근 생성 크루
  liveon_today             // 오늘 라이브온 인원 많은 크루  (+liveon_today_count)
  slope_occupied           // 점령 슬로프 많은 크루        (+occupied_slope_count)
  diverse_resort           // 이번시즌 탄 리조트 종류 많은 크루 (+resort_count)
  today_score              // 오늘 획득 랭킹점수 많은 크루   (+today_score)

middle:
  by_resort                // 스키장별(활성 리조트 12개) 각 { resort_id, resort_nickname,
                           //   resort_fullname, crews[≤30] }  (크루원 많은 순)
  most_members             // 크루원 많은 순 [≤30]
  liveon_season            // 이번시즌 라이브온 인원 많은 [≤30] (+liveon_season_count)
  ski_majority             // 10명↑ & 스키 비율>50% [≤30]   (+ratio, +count)
  board_majority           // 10명↑ & 보더 비율>50% [≤30]   (+ratio, +count)

bottom:
  crew_talks               // 공개 크루톡(crew_id 있음 & secret=false) 최신 20 (LiveTalk 객체)
```

**크루 카드 공통필드**: `crew_id, crew_name, crew_logo_url, color, description, base_resort_id,
base_resort_nickname, member_count` + 리스트별 지표.

### 지표 정의
- **점령(occupied_slope_count)**: 슬로프별 통과수 1위 크루가 그 슬로프를 "점령" → 크루별 점령 슬로프 수.
- **다양성(resort_count)**: 이번 시즌 크루원 라이딩 기록의 서로 다른 리조트 수.
- **오늘 점수(today_score)**: 오늘(pass_time 날짜) 크루원 랭킹 점수 합.
- **라이브온 인원**: 해당 기간 Live_on_log의 distinct 유저수(오늘 / 이번시즌).
- **스키/보더 비율**: 크루원 중 skiorboard='스키'/'스노보드' 비율. (10명 이상 & 50% 초과)
- 소속·활동 기준: 멤버수/스키·보드 비율은 `Crew_member`, 활동(랭킹·라이브온)은 `User.crew_id`.
- 시즌 랭킹 소스는 앱 공통 `ranking_src()`(폴리곤=Ranking_record_2627/score, 레거시=Ranking_record/slope 점수).
- 노출 대상은 `reveal_in_search=True` 크루만.
- 효율: 크루 기본정보·멤버통계·랭킹·라이브온을 **각 1회씩만** 조회해 여러 리스트가 재사용
  (특히 점령·다양성은 랭킹 1회 스캔에서 동시 산출).

> 오프시즌엔 `today_score`·`liveon_today`가 비고, 크루톡이 없으면 `crew_talks`가 빈 배열(정상).

### 플러터 (core 신규)
- `lib/core/api/api_crewHome.dart` — `CrewHomeAPI.fetchCrewHome()`
- `lib/core/model/m_crewHome.dart` — `CrewCard`(공통+지표 nullable) / `CrewHomeResortGroup`(스키장별) /
  `CrewHomeModel`(top5 + middle5 + bottom `List<LiveTalk>` crewTalks)
- `lib/core/viewmodel/crew/vm_crewHome.dart` — `CrewHomeViewModel`(fetchCrewHome / home / isLoading / hasError / refresh)

---

## 3. 크루 API 게스트 정책 (현재 상태)

### ✅ 게스트 조회 가능 (user_id 없이 200)
| 엔드포인트 | 비고 |
|---|---|
| `GET /api/crew/home/` | 크루홈(신규) |
| `GET /api/crew/` | 크루 리스트 (crew_name·iskusbf·base_resort_id 필터) |
| `GET /api/crew/detail/?crew_id=` · `/detail/<crew_id>/` | 크루 상세 |
| `GET /api/crew/detail/recordroom/` | 상세 기록실 |
| `GET /api/crew/<crew_id>/members/` | 크루원 목록 |
| `GET /api/crew/check-crew-name/` | 크루명 중복확인 |

### 🔒 크루원/로그인 전용 (user_id 필수)
| 엔드포인트 | 이유 |
|---|---|
| `GET /api/crew/crew-daily-report/` (+`/recordroom/`) | **크루원만**(user_id 필수 + 소속 검증). 비크루원 403 |
| `GET /api/crew/crew-member-ranking/` (+`/recordroom/`) | user_id 필수(요청자 크루원 여부 판정) |
| `GET /api/crew/notice/list/` | 크루 내부 공지 → 크루원만 |
| 쓰기 전부 (create/apply/approve/leave/update-status/notice CUD/schedule/error-log) | 로그인 필요 |

---

## 4. 크루 플러터 파일 재정리 (core / mobile)

> 라이브톡은 이미 core/mobile/web으로 정리돼 있어 이동 없음. **크루만** 레거시→core/mobile로 이동.

| 이동 전 | 이동 후 |
|---|---|
| `lib/api/api_crew.dart` | `lib/core/api/api_crew.dart` |
| `lib/model/m_crew{ApplyList,Detail,Detail_recordRoom,List,LogoModel,MemberList,Notice,RecordRoom}.dart` | `lib/core/model/` |
| `lib/viewmodel/crew/*` (vm_crewApply, vm_crewDetail(+_recordRoom), vm_crewMemberList, vm_crewNotice, vm_crewRecordRoom, vm_searchCrew, vm_setCrew, vm_dailyRecord) | `lib/core/viewmodel/crew/` |
| `lib/view/crew/*` (크루 화면 전체) | `lib/mobile/view/crew/` |

- 전 프로젝트 import 경로 일괄 수정, `flutter analyze` 에러 0 확인.
- 이미 core에 있던 크루 관련 파일(`m_crewHome`, `m_crewMemberRankingList*`, `m_rankingListCrew*`,
  `vm_crewHome`, `vm_crewMemberRankingList*`, `vm_rankingCrewHistory`)은 그대로 둠.
- 웹 크루 관련(`web/viewmodel/ranking/vm_rankingListCrew_web.dart`, `vm_rankingArchiveCrew_web.dart`)도 그대로.

---

## 5. 크루홈 방문자 집계 (게스트 포함, 5분 스로틀)

**목적**: 크루홈 헤더의 `방문자 Today / Total`을 실제 집계로 표시. 비로그인(게스트) 방문도 포함.

### 백엔드 (snowlive-api / crew_app)
- 모델 `Crew_visit_log(crew_id, user_id[nullable], ip, visited_at)` + 인덱스. 마이그레이션 `0017`.
- `POST /api/crew/visit/<crew_id>/`
  - 바디: `{"user_id": 123}` (게스트는 생략)
  - **5분 스로틀**: 로그인=`(크루,유저)`, 게스트=`(크루,IP)` 기준. 프록시(Heroku) 뒤에선 `X-Forwarded-For` 첫 IP.
  - 응답: `{counted, today, total}`
- `GET /api/crew/detail/?crew_id=`(크루상세) 응답 `crew_detail_info`에 `visitor_today`/`visitor_total` 추가(초기 렌더용).

### 프런트 (Flutter)
- `core/api/api_crew.dart` → `visitCrew(crewId, {userId})`.
- `core/model/m_crewDetail.dart` → `CrewDetailInfo.visitorToday/visitorTotal` (`visitor_today`/`visitor_total`).
- **웹**: `web/viewmodel/crew/vm_crewDetail_web.dart`
  - `load()`에서 상세 응답의 방문자수로 먼저 seed → `_logVisit()`가 진입당 1회 `visitCrew` POST 후 응답 `today/total`로 최신화.
  - `_visitLoggedCrewId`로 자동로그인 확정 재로딩 시 중복 POST 방지.
  - 헤더 `w_crewhome_header_web.dart`에 `visitorToday/visitorTotal` 전달, 값 없으면 `-`.
- **모바일**: `core/viewmodel/crew/vm_crewDetail.dart` `fetchCrewDetail()` 성공 시 `_logCrewVisit()`(비차단) 호출.
  모바일엔 방문자 표시 UI가 없지만 **앱 방문도 같은 집계에 포함**시키기 위함. `fetchCrewDetail`은 사실상 모든 크루홈 진입 직전에 불리므로 커버리지 넓음(권한 토글 등 소수 재조회는 5분 스로틀로 흡수).

---

## 6. TODO (프론트 후속)
- 크루 메뉴 → **크루홈**(위 `CrewHomeViewModel`) → 크루 누르면 **크루상세**로 이동하는 라우팅/뷰.
- 크루 라이브톡 작성 UI에서 `crewId`/`secret`(공개/비공개 토글) 전달.
