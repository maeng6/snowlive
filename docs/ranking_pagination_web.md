# 웹 랭킹 번호식 페이지네이션 — 현황 & 개발 안내 (팀원용)

브랜치: `maeng`
> **개인·크루 랭킹 = 번호식 페이지네이션 완성.** 기록실·beta는 API 준비 완료(웹 화면 대기).
> 중고거래(`fleamarket_pagination_web.md`)와 동일한 번호식 패턴.

---

## 0. 먼저
`git pull origin maeng` 로 최신 받기.

## 1. 현황 요약
| 랭킹 | API(page 지원) | 웹 VM | 웹 화면 | 상태 |
|---|---|---|---|---|
| 개인(indiv) | ✅ | `RankingListViewModelWeb` | ✅ | **번호식 완성** |
| 크루(crew) | ✅ | `RankingListCrewViewModelWeb` | ✅ | **번호식 완성** |
| 기록실 개인(recordroom-indiv) | ✅ | ❌ | 준비중 | API만 준비 |
| 기록실 크루(recordroom-crew) | ✅ | ❌ | 준비중 | API만 준비 |
| beta 개인(indiv-beta) | ✅ | ❌ | 미노출 | API만 준비 |
| beta 크루(crew-beta) | ✅ | ❌ | 미노출 | API만 준비 |

## 2. 무엇이 바뀌었나
- **백엔드**: 랭킹 리스트 6종 전부 `total_pages`/`current_page`/`page_size` 반환 (배포 완료)
- **API** (`lib/core/api/api_ranking.dart`): 리스트 메서드 6종 모두 `page`/`pageSize` 파라미터 지원
  - `fetchRankingData_indiv / _crew / _indiv_recordRoom / _crew_recordRoom / _indiv_beta / _crew_beta`
- **뷰모델**: 개인·크루 웹 VM을 **번호식**으로 완성 (`gotoPage`/`pageWindow`)
- **위젯**: `NumberedPaginationBar`(`lib/web/widget/w_numbered_pagination_web.dart`) — 재사용 번호 바

## 3. ⚠️ 응답 구조 — total_pages 위치가 종류별로 다름
```
개인·크루·기록실:  data['results']['total_pages']     ← results 안에 중첩
beta(개인·크루):   data['total_pages']                ← 최상위 (표준 DRF 모양)
```
- 개인/크루/기록실은 응답이 `{ my_ranking_info, results:{count,total_pages,current_page,results:[...]} }` 라서 **`results` 안**.
- beta는 `my_ranking_info` 래퍼가 없어서 **최상위**.
- (VM 안에서 이미 처리하므로 UI에선 `vm.totalPages`만 쓰면 됨)

## 4. 뷰모델 API (개인·크루 공통 인터페이스)
```dart
final vm = Get.find<RankingListViewModelWeb>();       // 개인
final crew = Get.find<RankingListCrewViewModelWeb>(); // 크루

// 관찰 (Obx)
vm.items          // 개인: List<RankingUser> / 크루: List<CrewRanking>
vm.myRankingInfo  // 개인: MyRankingInfo? (크루는 vm.myCrewRankingInfo)
vm.currentPage / vm.totalPages / vm.totalCount / vm.isLoading
vm.hasNext / vm.hasPrevious

// 페이지 이동
vm.gotoPage(n);   // 번호 클릭
vm.loadNext();  vm.loadPrevious();
vm.pageWindow();          // 하단 번호 윈도우 [3,4,5,6,7,8,9]
vm.pageWindow(span: 5);

// 필터 바꾸고 1페이지부터
vm.loadFirstPage(resortId: 13, federation: null, daily: false);   // 개인
crew.loadFirstPage(userId: uid, resortId: 13, federation: null, daily: false); // 크루(게스트면 userId null)
```
- 크루 VM은 시즌 자동 조회 + Heroku dyno 재시도 + 글로벌 로딩바(`isGlobalPageLoading`)를 내장.
- pageSize 기본 30, 생성 시 지정 가능: `RankingListViewModelWeb(pageSize: 50)`

## 5. UI — 하단 번호 바 (팀원 위젯 재사용)
```dart
Obx(() => NumberedPaginationBar(
  currentPage: vm.currentPage,
  totalPages:  vm.totalPages,
  hasPrevious: vm.hasPrevious,
  hasNext:     vm.hasNext,
  pageWindow:  vm.pageWindow(),
  onGotoPage:  (page) => vm.gotoPage(page),
));
```
목록은 `vm.items`(Obx), 로딩 중엔 `vm.isLoading`.
→ 개인/크루 둘 다 `v_rankingHome_web.dart`에 이미 이렇게 연결돼 있음.

## 6. 기록실 / beta 나중에 붙이는 법
API는 이미 `page`/`pageSize` 지원. 웹 화면 만들 때:
1. `vm_rankingList_web.dart`(개인) 또는 크루 VM을 복사해 VM 생성
2. 호출 메서드만 교체: `fetchRankingData_indiv_recordRoom(..., selected_season:, page:, pageSize:)` 등
   - 기록실은 **`selected_season` 필수** (예: 운영 시즌 코드)
3. total_pages 읽는 위치만 주의:
   - 기록실 → `data['results']['total_pages']`
   - **beta → `data['total_pages']` (최상위)**
4. UI는 동일하게 `NumberedPaginationBar` 사용

## 7. 파일 위치
```
lib/core/api/api_ranking.dart                          # ✅ 6종 page/pageSize
lib/web/viewmodel/ranking/vm_rankingList_web.dart      # ✅ 개인 번호식
lib/web/viewmodel/ranking/vm_rankingListCrew_web.dart  # ✅ 크루 번호식
lib/web/widget/w_numbered_pagination_web.dart          # 재사용 번호 바
lib/web/view/ranking/v_rankingHome_web.dart            # 개인+크루 연결됨
lib/web/view/ranking/…                                 # ← 기록실/beta 화면(예정)
```

## 하지 말 것
- ❌ core `RankingListViewModel`(모바일) 수정
- ❌ 게임플레이 VM(`lib/mobile/viewmodel/ranking/`) 웹에서 사용
- ✅ 개인/크루는 `RankingListViewModelWeb`/`RankingListCrewViewModelWeb`의 `gotoPage`/`pageWindow`/`items`만 쓰면 됨
