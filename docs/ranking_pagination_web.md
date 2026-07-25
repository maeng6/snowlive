# 웹 개인 랭킹 번호식 페이지네이션 — UI 개발 안내 (팀원용)

브랜치: `maeng`
범위: **백엔드 + API + 뷰모델(번호식) 완료.** 랭킹 목록 + 하단 페이지번호 UI 연결만 팀원 작업.
> 중고거래(`fleamarket_pagination_web.md`)와 **완전히 동일한 패턴**입니다.

---

## 0. 먼저
`git pull origin maeng` 로 최신 받기. 랭킹 파일이 core/mobile/web으로 재배치됐으니 참고:
- 공용: `lib/core/api/api_ranking.dart`, `lib/core/model/m_rankingList*.dart`, `lib/core/viewmodel/ranking/`
- 모바일 전용(게임플레이/기록): `lib/mobile/viewmodel/ranking/`, 모바일 화면: `lib/mobile/view/ranking/`
- 웹: `lib/web/viewmodel/ranking/`  ← 여기에 페이지네이션 VM 있음

## 1. 무엇이 바뀌었나
- **백엔드**: 랭킹 리스트 응답 `results` 안에 `total_pages`·`current_page`·`page_size` 추가 (기존 필드 유지, non-breaking)
- **API**: `RankingAPI().fetchRankingData_indiv(... , page: N, pageSize: 30)` — `?page=N&page_size=` 지원
- **뷰모델**: `RankingListViewModelWeb` 신규 (번호식). 모바일 core `RankingListViewModel`(누적/무한스크롤)은 **건드리지 말 것.**

## 2. 뷰모델 API — `RankingListViewModelWeb`
```dart
final vm = Get.find<RankingListViewModelWeb>();

// 관찰 (Obx)
vm.items          // List<RankingUser> — 현재 페이지 랭킹 목록
vm.myRankingInfo  // MyRankingInfo? — 내 랭킹 요약(상단 배너용, nullable)
vm.currentPage    // int
vm.totalPages     // int
vm.totalCount     // int (전체 인원)
vm.isLoading      // bool

// 페이지 이동
vm.gotoPage(n);   // 번호 클릭 → n페이지 로드
vm.loadNext();    // 다음
vm.loadPrevious();// 이전
vm.hasNext / vm.hasPrevious

// 하단 번호 목록 (현재 주변 윈도우)
vm.pageWindow();          // 예: [3,4,5,6,7,8,9]
vm.pageWindow(span: 5);

// 필터 바꾸고 1페이지부터
vm.loadFirstPage(resortId: 13, season: '2025-11-01,2026-03-31', federation: null, daily: false);
```
- 바인딩: `WebRankingListBinding`(이미 `bindings_web.dart`에 등록됨). 라우트에 연결만 하면 됨.
- `pageSize`는 VM 생성 시 지정 가능(기본 30): `Get.lazyPut(() => RankingListViewModelWeb(pageSize: 50))`.

## 3. 만들 것 — 목록 + 하단 페이지 번호 UI
```dart
Obx(() {
  final vm = Get.find<RankingListViewModelWeb>();
  return Column(children: [
    // (선택) 내 랭킹 요약 배너
    if (vm.myRankingInfo != null) _myRankBanner(vm.myRankingInfo!),

    // 랭킹 목록
    ...vm.items.map((u) => _rankRow(
      rank: u.overallRank,
      name: u.displayName ?? '',
      score: u.overallTotalScore ?? 0,
      tier: u.tierNameKor,
    )),

    // 하단 페이지 번호
    Wrap(spacing: 4, children: [
      _pgBtn('‹', enabled: vm.hasPrevious, onTap: vm.loadPrevious),
      if (vm.pageWindow().first > 1) ...[
        _pgBtn('1', onTap: () => vm.gotoPage(1)),
        if (vm.pageWindow().first > 2) const Text('…'),
      ],
      ...vm.pageWindow().map((p) => _pgBtn('$p',
          active: p == vm.currentPage,
          onTap: () => vm.gotoPage(p))),
      if (vm.pageWindow().last < vm.totalPages) ...[
        if (vm.pageWindow().last < vm.totalPages - 1) const Text('…'),
        _pgBtn('${vm.totalPages}', onTap: () => vm.gotoPage(vm.totalPages)),
      ],
      _pgBtn('›', enabled: vm.hasNext, onTap: vm.loadNext),
    ]),
  ]);
});
```
- `active`면 강조, `enabled=false`면 비활성
- 로딩 중엔 `vm.isLoading`으로 스피너/디밍
- 페이지 이동 시 스크롤 맨 위로 올려주면 UX 좋음

## 4. 백엔드 응답 (참고 — 페이지 메타는 `results` 안에 중첩)
```
GET /api/ranking/list-indiv/?user_id=2715&resort_id=13&page=2&page_size=30
→ {
    "my_ranking_info": { ... },
    "results": {
      "count": 940,
      "total_pages": 32,
      "current_page": 2,
      "page_size": 30,
      "next": ..., "previous": ...,
      "results": [ { rankingUser }, ... ]
    }
  }
```
> ⚠️ 중고거래와 달리 페이지 메타(`count/total_pages/current_page`)가 최상위가 아니라 **`results` 안**에 있음. VM이 이미 처리하므로 UI에선 `vm.totalPages` 등만 쓰면 됨.

## 5. 파일 위치
```
lib/web/viewmodel/ranking/vm_rankingList_web.dart   # ✅ 번호식 VM (완료)
lib/core/api/api_ranking.dart                        # ✅ page/pageSize 파라미터 (완료)
lib/web/routes/bindings_web.dart                     # ✅ WebRankingListBinding (완료)
lib/web/view/ranking/…                               # ← 팀원: 목록 + 하단 번호 UI
```

## 하지 말 것
- ❌ core `RankingListViewModel`(모바일 누적/무한스크롤) 수정
- ❌ 게임플레이/기록 VM(`lib/mobile/viewmodel/ranking/`) 웹에서 사용
- ✅ `RankingListViewModelWeb`의 `gotoPage`/`pageWindow`/`items`/`myRankingInfo`만 쓰면 됨
