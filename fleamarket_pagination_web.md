# 웹 중고거래 번호식 페이지네이션 — UI 개발 안내 (팀원용)

브랜치: `maeng`
범위: **백엔드 + API + 뷰모델(번호식) 완료.** 하단 페이지번호 UI 연결만 팀원 작업.

---

## 0. 먼저
`git pull origin maeng` 로 최신 받기 (아래 VM 확장분이 들어있음).

## 1. 무엇이 바뀌었나
- **백엔드**: `/api/fleamarket/` 응답에 `total_pages`·`current_page`·`page_size` 추가 (기존 `count/next/previous/results` 유지)
- **API**: `FleamarketAPI().fetchFleamarketList(... , page: N)` — `?page=N` 지원
- **뷰모델**: `FleamarketPaginationViewModelWeb`에 **번호식** 추가 (기존 prev/next 그대로)

> ⚠️ 모바일 코어 `FleamarketListViewModel`(무한스크롤)은 **건드리지 말 것.** 웹은 `FleamarketPaginationViewModelWeb`만 사용.

## 2. 뷰모델 API — `FleamarketPaginationViewModelWeb`
```dart
final vm = Get.find<FleamarketPaginationViewModelWeb>();

// 관찰 (Obx)
vm.items          // List<Fleamarket> — 현재 페이지 목록
vm.currentPage    // int
vm.totalPages     // int
vm.totalCount     // int (전체 건수)
vm.isLoading      // bool

// 페이지 이동
vm.gotoPage(n);   // 번호 클릭 → n페이지 로드
vm.loadNext();    // 다음
vm.loadPrevious();// 이전
vm.hasNext / vm.hasPrevious

// 하단 번호 목록 (현재 주변 윈도우)
vm.pageWindow();          // 예: [3,4,5,6,7,8,9]
vm.pageWindow(span: 5);   // 개수 조절

// 필터 바꾸고 1페이지부터
vm.loadFirstPage(userId: ..., categoryMain: '스노보드', searchQuery: '버튼', ...);
```

## 3. 만들 것 — 하단 페이지 번호 UI
```dart
Obx(() {
  final vm = Get.find<FleamarketPaginationViewModelWeb>();
  return Wrap(spacing: 4, children: [
    // 이전
    _pgBtn('‹', enabled: vm.hasPrevious, onTap: vm.loadPrevious),
    // 첫 페이지 + … (윈도우가 1보다 크게 시작하면)
    if (vm.pageWindow().first > 1) ...[
      _pgBtn('1', onTap: () => vm.gotoPage(1)),
      if (vm.pageWindow().first > 2) const Text('…'),
    ],
    // 번호 윈도우
    ...vm.pageWindow().map((p) => _pgBtn('$p',
        active: p == vm.currentPage,
        onTap: () => vm.gotoPage(p))),
    // … + 마지막 페이지
    if (vm.pageWindow().last < vm.totalPages) ...[
      if (vm.pageWindow().last < vm.totalPages - 1) const Text('…'),
      _pgBtn('${vm.totalPages}', onTap: () => vm.gotoPage(vm.totalPages)),
    ],
    // 다음
    _pgBtn('›', enabled: vm.hasNext, onTap: vm.loadNext),
  ]);
});
```
- `active`면 강조(볼드/배경), `enabled=false`면 비활성
- 목록은 `vm.items` (Obx), 로딩 중엔 `vm.isLoading`으로 스피너/디밍
- 페이지 이동 시 스크롤 맨 위로 올려주면 UX 좋음

## 4. 백엔드 응답 (참고)
```
GET /api/fleamarket/?page=2&page_size=30&category_main=스노보드
→ { count, total_pages, current_page, page_size, next, previous, results:[...] }
```
필터 파라미터: `category_main / category_sub / spot / search_query / favorite_list=true / myflea=true / user_id / find_user_id`

## 5. 파일 위치
```
lib/web/viewmodel/fleamarket/vm_fleamarketPagination_web.dart   # ✅ 번호식 VM (완료)
lib/core/api/api_fleamarket.dart                                # ✅ page 파라미터 (완료)
lib/web/view/fleamarket/…                                       # ← 팀원: 목록 + 하단 번호 UI
```

## 하지 말 것
- ❌ 모바일 코어 `FleamarketListViewModel` 수정
- ❌ 웹에서 무한스크롤 로직 재사용 (웹은 번호식)
- ✅ `FleamarketPaginationViewModelWeb`의 `gotoPage`/`pageWindow`/`items`만 쓰면 됨
