# 커뮤니티 — 파일 구조 정리(core/web/mobile) & 댓글·작성자 검색 (팀원용)

브랜치: `maeng`
> 커뮤니티 관련 다트 파일을 **core/mobile 로 재배치**(랭킹·중고거래와 동일 패턴)하고,
> 목록 API에 **댓글 검색·작성자 검색** 파라미터를 추가했습니다.

---

## 0. 먼저
`git pull origin maeng` 로 최신 받기. import 경로가 대거 바뀌었으니 **pull 후 전체 빌드/analyze 권장.**

## 1. 무엇이 바뀌었나
- **백엔드(배포 완료)**: `CommunityListView`(`community_app/api/views.py`)에 `search_query_comment`, `search_query_user` 추가
- **API/뷰모델**: `fetchCommunityList()`와 목록 VM 4종에 위 두 검색 파라미터 관통 연결
- **파일 재배치**: 커뮤니티 다트 파일을 `core`(공유 로직) / `mobile`(화면·위젯)로 이동 (`git mv`, 히스토리 보존)
  - 웹 커뮤니티 화면은 아직 없어서 `web/` 에는 추가 안 함(필요 시 나중에 web VM/view 생성)

## 2. 파일 위치 (이동 결과)
```
[core — 공유 비즈니스 로직]
lib/core/api/api_community.dart                 # (이전 lib/api/)
lib/core/model/m_communityList.dart             # (기존부터 core)
lib/core/model/m_comment_community.dart         # (이전 lib/model/)
lib/core/model/m_communityDetail.dart           # (이전 lib/model/)
lib/core/viewmodel/community/vm_community*.dart  # 6종 (이전 lib/viewmodel/community/)
   ├ vm_communityBulletinList.dart   (목록·검색·페이지네이션)
   ├ vm_communityDetail.dart
   ├ vm_communityCommentDetail.dart
   ├ vm_communityUpload.dart
   ├ vm_communityUpdate.dart
   └ vm_communityAlarm.dart

[mobile — 화면·위젯]
lib/mobile/view/community/v_community_main.dart
lib/mobile/view/community/free/v_community_*.dart      # 게시판/상세/업로드/수정/댓글 등
lib/mobile/view/banner/v_banner_community(.._detail).dart
lib/mobile/widget/w_community_Free_Quill_editor.dart
lib/mobile/widget/w_community_Free_Quill_toolbar.dart
```
> 옛 경로(`lib/api/`, `lib/model/`, `lib/viewmodel/community/`, `lib/view/community/`)에는 커뮤니티 파일이 남아 있지 않음. import는 전부 `package:com.snowlive/core|mobile/...` 로 갱신됨.

## 3. 댓글 검색 · 작성자 검색
### 요청 파라미터 (백엔드)
| 파라미터 | 검색 대상 |
|---|---|
| `search_query` | 글 제목·본문 (기존) |
| `search_query_comment` | **댓글 내용**(`Comment_community.content`)에 포함된 글 |
| `search_query_user` | **작성자**(`user_id`)의 `display_name`에 포함된 글 |
- 카테고리·차단유저 제외 등 기존 필터와 **조합** 가능.

### API (`lib/core/api/api_community.dart`)
```dart
CommunityAPI().fetchCommunityList(
  userId: uid,
  searchQueryComment: '검색어',   // 댓글 검색
  searchQueryUser:    '닉네임',   // 작성자 검색
  // categoryMain/Sub, searchQuery(제목·본문) 등과 함께 사용 가능
);
```
- 페이지네이션은 서버가 준 `next`/`previous` URL을 그대로 재호출(`url:`)하므로 **검색 조건이 URL에 유지됨** → 추가 처리 불필요.

### 뷰모델 (`vm_communityBulletinList.dart`)
`fetchCommunityList_total / _free / _room / _crew` 4종 모두 `searchQueryComment`, `searchQueryUser` 파라미터를 받아 API로 전달.
```dart
await vm.fetchCommunityList_free(
  userId: uid, categoryMain: '게시판',
  categorySub: Community_Category_sub_bulletin.chat.korean,
  searchQueryComment: keyword,   // 또는 searchQueryUser: keyword
);
```

## 3-1. 목록 정렬 (최신/조회/댓글순)
`sort` 파라미터 (기본 `latest`):
| sort | 정렬 |
|---|---|
| `latest` | 최신순 (`-upload_time`, 기본) |
| `views` | 조회순 (CommunityViewLog 수 desc) |
| `comments` | 댓글많은순 (댓글+답글 합계 desc) |
```dart
await vm.fetchCommunityList_free(
  userId: uid, categoryMain: '게시판',
  categorySub: Community_Category_sub_bulletin.chat.korean,
  sort: 'views',   // 'latest' | 'views' | 'comments'
);
```
- 검색·카테고리 필터와 조합 가능. 페이지네이션 URL에도 유지됨.

## 4. 남은 일 (검색 UI)
- 현재 커뮤니티엔 **검색 입력 화면이 없음** — `searchQuery`(제목·본문)도 아직 UI 미연결.
- **API·뷰모델 플러밍은 완료**되어 있으니, 검색 화면을 만들 때 입력값을 위 파라미터로 넘기면 바로 동작.
- 탭별(전체/잡담/시즌방/단톡방) 검색이면 해당 `fetchCommunityList_*` 호출에 검색어만 추가.

## 하지 말 것 / 주의
- ❌ 옛 경로로 새 import 작성 금지 → `package:com.snowlive/core|mobile/...` 사용
- ❌ 웹에서 커뮤니티 모바일 VM 직접 사용 (웹 필요 시 `web/viewmodel/community/` 로 별도 생성, 랭킹 웹 패턴 참고)
- ✅ 공유 로직(API·모델·목록 VM)은 `core`, 화면·위젯은 `mobile`
