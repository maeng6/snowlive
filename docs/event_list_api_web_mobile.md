# 각종소식(event) 목록 — API 사용법 & 뷰 신규 작성 가이드 (팀원용)

브랜치: `maeng`
> 각종소식(event)은 **인스타 크롤 피드**다. **목록 조회 + 조회수 증가**만 하고, 아이템을 누르면 **조회수를 올린 뒤 원글(landing_url)로 이동**한다. 상세·작성/수정/삭제는 **앱에 없음**(어드민 CRUD는 웹 각종소식 어드민에서).
> **웹 뷰는 완성**됐다(좌측 GNB `각종소식` → `/event`, `EventHomeViewWeb`). **모바일 뷰만 팀원이 새로 만든다.** 데이터 계층(api/model/vm)은 아래처럼 정리돼 있으니 그대로 재사용.

---

## 0. 파일 위치 (현재 정리 상태)
```
[core — 공유, 그대로 재사용]
lib/core/api/api_event.dart              # fetchEventList + incrementViewCount
lib/core/model/m_event.dart              # EventModel, EventListResponse
lib/core/viewmodel/event/vm_event.dart   # EventViewModel (모바일 무한스크롤용)

[web — 완성]
lib/web/view/event/v_eventHome_web.dart               # 독립 화면(/event)
lib/web/view/community/w_event_list_web.dart          # 목록 본문
lib/web/view/community/w_event_row_web.dart           # 표/카드 행
lib/web/viewmodel/event/vm_eventListPagination_web.dart # 번호식 페이지네이션 + openEvent(조회수+이동)

[mobile] 이벤트 뷰 없음 → 팀원이 lib/mobile/view/event/ 에 신규
```
> 참고: `viewmodel/vm_eventAlarm.dart`(각종소식 새글 알림 뱃지)는 event 목록과 별개 기능이라 그대로 뒀다(홈·더보기 등 여러 화면에서 사용 중). 목록 피처와 무관.

## 1. 백엔드 엔드포인트 (앱이 쓰는 것)
```
GET https://snowlive-api-c617725e2b78.herokuapp.com/api/event/
PUT https://snowlive-api-c617725e2b78.herokuapp.com/api/event/view/{event_id}/
```
- **목록** `GET /api/event/` — 쿼리(전부 선택): `category=각종소식` · `search_query=키워드` · `page=1`(page_size 50, max 100)
  - 로그인 불필요(게스트 조회 가능). 최신순(`-upload_time`).
  - 응답: `{ "count", "next", "previous", "results": [ {event..., "views_count": int} ] }`
- **조회수 증가** `PUT /api/event/view/{event_id}/` — raw JSON 바디 `{ "user_id": 1234 }`
  - 제목/아이템 클릭 → landing_url 이동 **직전에** 호출. `user_id` 필수(게스트면 400 → 호출하지 말 것).
  - **유저당 5분에 1회만** 카운트되지만 총합은 **무한 증가**(로그 누적).
  - 응답: `{ "detail": "ok", "counted": bool, "views_count": int }` — `views_count`가 최신 총합이니 화면 숫자를 이 값으로 갱신.

## 2. 모델 (`m_event.dart`)
`EventModel` 주요 필드:
| 필드 | 설명 |
|---|---|
| `eventId` | 이벤트 ID |
| `title` | 제목(캡션 첫 줄 등) |
| `description` | 본문 |
| `thumbImgUrl` | 썸네일 이미지 URL (리스트 카드 이미지) |
| `landingUrl` | **원글 URL(인스타)** — 아이템 탭 시 여기로 이동 |
| `category` | 표시 카테고리 |

`EventListResponse`: `count`, `next`, `previous`, `events`(List<EventModel>).

## 3. 뷰모델 (`EventViewModel`, core)
GetX. **모바일 무한스크롤** 기준으로 만들어져 있다(next URL 누적).
```dart
final vm = Get.find<EventViewModel>();   // bindings.dart에서 등록됨

// 관찰 (Obx)
vm.eventList        // List<EventModel>
vm.isLoading        // 초기 로딩
vm.isLoadingMore    // 추가 로딩
vm.hasNextPage      // 다음 페이지 존재
vm.selectedCategory / vm.searchQuery

// 동작
await vm.fetchEventList();               // 목록 로드(첫 페이지)
await vm.fetchMoreEvents();              // 무한스크롤 다음 페이지
await vm.refresh();                      // 당겨서 새로고침(리스트 유지)
vm.setCategory('각종소식');               // 카테고리 필터 후 재조회
vm.setSearchQuery('휘팍');                // 검색 후 재조회
vm.clearFilters();                       // 필터 초기화
```

## 4. 뷰 만드는 법
### 공통 — 아이템 탭 동작 (조회수 올리고 원글 이동)
상세 화면 없음. 아이템(제목)을 누르면 **조회수 증가 → 원글 이동** 순서로 처리한다.
조회수 증가는 이동을 막지 않게 `await` 하지 않는다(실패해도 이동은 한다). 로그인 유저만 카운트된다:
```dart
onTap: () async {
  final userId = 현재_로그인_user_id; // 게스트(null/<=0)면 아래 호출 생략
  if (event.eventId != null && userId != null) {
    // 결과를 기다리지 않는다. 응답 views_count로 화면 숫자 갱신하면 더 좋다.
    EventAPI().incrementViewCount(eventId: event.eventId!, userId: userId);
  }
  final url = event.landingUrl;
  if (url != null && url.isNotEmpty) {
    final uri = Uri.tryParse(url);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
```
> 웹은 이 로직을 `EventListPaginationViewModelWeb.openEvent(event)` 한 곳에 넣어 뒀다. 모바일도 VM에 동일한 메서드를 두는 걸 권장(조회수 증가+URL 검증+게스트 처리를 뷰에 흩뿌리지 말 것).
카드에는 `thumbImgUrl` 이미지 + `title` + `viewCount`(조회수) 정도.

### 모바일 (`lib/mobile/view/event/`)
- **core `EventViewModel` 그대로 사용**(무한스크롤 적합). `Obx(() => ListView(vm.eventList...))`, 스크롤 끝에서 `vm.fetchMoreEvents()`, 당겨서 새로고침 `vm.refresh()`.
- 탭 동작은 위 "공통" 스니펫대로 조회수 증가 + landing 이동.

### 웹 (완성 — 참고용)
- `EventHomeViewWeb`(`/event`) → `EventListWeb` → `EventTableRow`/`EventCardRow`.
- 번호식 페이지네이션 + 조회수/이동은 `EventListPaginationViewModelWeb`이 담당. 새로 만들 필요 없음.

## 5. 하지 말 것 / 참고
- ❌ 상세/작성/수정/삭제 API 호출 (앱에서 제거됨). 어드민 CRUD는 웹 각종소식 어드민(news.html).
- ⚠️ 조회수 증가는 **로그인 유저만**. 게스트면 `incrementViewCount` 호출하지 말 것(서버 400).
- ❌ 옛 경로 import — `package:com.snowlive/core/...` 사용.
- ✅ 데이터는 core(api/model/vm) 재사용, 화면만 mobile/web 각자.
