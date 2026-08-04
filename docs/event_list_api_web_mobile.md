# 각종소식(event) 목록 — API 사용법 & 뷰 신규 작성 가이드 (팀원용)

브랜치: `maeng`
> 각종소식(event)은 **인스타 크롤 피드**다. **목록 조회만** 하고, 아이템을 누르면 **원글(landing_url)로 바로 이동**한다. 상세·조회수·작성/수정/삭제는 **앱에 없음**(어드민 CRUD는 웹 각종소식 어드민에서).
> 기존 event 뷰(`v_eventPage`, `w_eventPageEmbedded` 등)는 **삭제**했고, **web·mobile 뷰를 팀원이 새로 만든다.** 데이터 계층(api/model/vm)은 아래처럼 core에 정리돼 있으니 그대로 재사용.

---

## 0. 파일 위치 (현재 정리 상태)
```
[core — 공유, 그대로 재사용]
lib/core/api/api_event.dart              # fetchEventList 하나만
lib/core/model/m_event.dart              # EventModel, EventListResponse
lib/core/viewmodel/event/vm_event.dart   # EventViewModel (모바일 무한스크롤용)

[mobile] 이벤트 뷰 없음 → 팀원이 lib/mobile/view/event/ 에 신규
[web]    이벤트 뷰 없음 → 팀원이 lib/web/view/event/ (+ 필요시 web/viewmodel/event/) 신규
```
> 참고: `viewmodel/vm_eventAlarm.dart`(각종소식 새글 알림 뱃지)는 event 목록과 별개 기능이라 그대로 뒀다(홈·더보기 등 여러 화면에서 사용 중). 목록 피처와 무관.

## 1. 백엔드 엔드포인트 (앱이 쓰는 것)
```
GET https://snowlive-api-c617725e2b78.herokuapp.com/api/event/
```
- 쿼리(전부 선택): `category=각종소식` · `search_query=키워드` · `page=1` · `page_size=50`(기본 50, max 100)
- 로그인 불필요(게스트 조회 가능). 최신순(`-upload_time`).
- 응답: `{ "count", "next", "previous", "results": [ {event...} ] }`

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
### 공통 — 아이템 탭 동작
상세 화면 없음. 아이템 누르면 원글로 보낸다:
```dart
onTap: () {
  final url = event.landingUrl;
  if (url != null && url.isNotEmpty) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
```
카드에는 `thumbImgUrl` 이미지 + `title` 정도. (조회수·좋아요·댓글 없음)

### 모바일 (`lib/mobile/view/event/`)
- **core `EventViewModel` 그대로 사용**(무한스크롤 적합). `Obx(() => ListView(vm.eventList...))`, 스크롤 끝에서 `vm.fetchMoreEvents()`, 당겨서 새로고침 `vm.refresh()`.

### 웹 (`lib/web/view/event/`)
- core `EventViewModel`은 **무한스크롤**이라 웹 번호식 UI와 안 맞을 수 있다. 웹에서 **번호식 페이지네이션**을 원하면:
  1. `lib/web/viewmodel/event/vm_event_web.dart` 신규 — **라이브톡/커뮤니티 웹 VM 패턴** 복사(`vm_liveTalk_web.dart` 참고).
  2. core `api_event.dart`의 `fetchEventList(url: '${EventAPI.baseUrl}/?page=N')` 로 페이지 요청, `count`/page_size(50)로 total_pages 계산.
  3. `EventModel`/`EventListResponse`(core)는 그대로 재사용.
- 무한스크롤/더보기로 갈 거면 core VM 재사용도 가능.

## 5. 하지 말 것 / 참고
- ❌ 상세/작성/수정/삭제/조회수 API 호출 (앱에서 제거됨). 어드민 CRUD는 웹 각종소식 어드민(news.html).
- ❌ 옛 경로 import — `package:com.snowlive/core/...` 사용.
- ✅ 데이터는 core(api/model/vm) 재사용, 화면만 mobile/web 각자.
