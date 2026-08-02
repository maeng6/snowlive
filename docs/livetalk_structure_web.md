# 라이브톡(livetalk) — core/mobile/web 구조 정리 (웹 확장 준비) (팀원용)

브랜치: `maeng`
> 라이브톡을 **웹으로 확장**하기 위해 다트 파일을 core(공유)/mobile(모바일 화면)로 재배치.
> 웹 화면은 `web/`에 신규로 붙이면 됨 (core 재사용, 랭킹 웹 패턴과 동일).

---

## 0. 먼저
`git pull origin maeng`. import 경로가 바뀌었으니 pull 후 전체 빌드/analyze 권장.

## 1. 파일 위치 (이동 결과)
```
[core — 공유: 웹도 그대로 재사용]
lib/core/api/api_liveTalk.dart                 # (이전 lib/api/)
lib/core/model/m_liveTalk.dart                 # (이전 lib/model/)
lib/core/viewmodel/liveTalk/vm_liveTalk.dart   # (이전 lib/viewmodel/liveTalk/) — 공유 데이터/로직

[mobile — 모바일 화면·위젯]
lib/mobile/view/liveTalk/v_liveTalk_main.dart       # (이전 lib/view/community/liveTalk/ → mobile/view/community/liveTalk/)
lib/mobile/view/liveTalk/v_liveTalk_feedItem.dart
lib/mobile/view/liveTalk/v_liveTalk_comment.dart
lib/mobile/view/liveTalk/v_liveTalk_inputArea.dart
lib/mobile/view/liveTalk/v_liveTalk_imageScreen.dart
```
> 라이브톡을 커뮤니티 하위(`view/community/liveTalk`)에서 **독립 피처(`mobile/view/liveTalk`)로 분리** — 웹은 `web/view/liveTalk`로 미러.
> 옛 경로(`lib/api/`, `lib/model/`, `lib/viewmodel/liveTalk/`, `lib/mobile/view/community/liveTalk/`)엔 라이브톡 파일 없음. import 전부 `package:com.snowlive/core|mobile/...` 로 갱신됨.

## 2. 웹 확장 방법 (랭킹 웹과 동일 패턴)
1. **core 재사용**: `core/api/api_liveTalk.dart`, `core/model/m_liveTalk.dart` (둘 다 웹 안전 — `dart:io` 없음).
2. **웹 VM: ✅ 작성 완료** — `lib/web/viewmodel/liveTalk/vm_liveTalk_web.dart`
   - core 모바일 VM(`LiveTalkViewModel`)은 `dart:io`/이미지피커/컨트롤러 의존이라 **재사용 안 함**. core API/모델만 사용해 신규 구현.
   - **번호식 페이지네이션**(커뮤니티/랭킹 웹과 동일). 서버 `LiveTalkPagination` page_size=30, `?page=N` 지원, 게스트 조회 허용.
3. **웹 화면(팀원 작업)**: `lib/web/view/liveTalk/…` — 아래 VM 인터페이스에 바인딩.
4. **바인딩/라우팅(팀원)**: 웹 바인딩에 `Get.put(LiveTalkListPaginationViewModelWeb())`, `lib/web/routes/`에 라우트 추가.

### 웹 VM 인터페이스 (`LiveTalkListPaginationViewModelWeb`)
```dart
final vm = Get.find<LiveTalkListPaginationViewModelWeb>();

// 관찰 (Obx)
vm.items          // List<LiveTalk> (한 페이지)
vm.isLoading / vm.hasError
vm.currentPage / vm.totalPages / vm.totalCount
vm.hasNext / vm.hasPrevious

// 최초 로드 (게스트면 userId 생략/null)
await vm.loadFirstPage(userId: uid);

// 페이지 이동
vm.gotoPage(n);  vm.loadNext();  vm.loadPrevious();
vm.pageWindow();          // 하단 번호 윈도우 [3,4,5,6,7,8,9]
vm.retry();               // hasError일 때 다시 시도
```
- 리스트는 `vm.items`(Obx), 로딩 중엔 `vm.isLoading`(글로벌 상단바 `beginPageLoading`도 내장).
- 하단 번호 바는 웹 공용 `NumberedPaginationBar`(`web/widget/w_numbered_pagination_web.dart`) 재사용 가능.
- 작성/상세/댓글 등 상호작용이 웹에도 필요하면, `core/api/api_liveTalk.dart`의 `create/fetchDetail/...`를 이 VM에 메서드로 추가.

## 3. 현재 결합 (참고)
- 모바일 커뮤니티 메인(`mobile/view/community/v_community_main.dart`)이 라이브톡 탭으로 `v_liveTalk_main`을 사용.
- `CommunityBulletinListViewModel`(core)·웹 커뮤니티 VM이 `LiveTalkViewModel`을 참조(라이브톡 목록 병렬 로딩).
- 즉 **데이터/VM은 core 공유**, 화면만 플랫폼별.

## 하지 말 것 / 주의
- ❌ 옛 경로로 새 import 금지 → `package:com.snowlive/core|mobile|web/...`
- ❌ 웹에서 모바일 라이브톡 화면(`mobile/view/liveTalk/`) 직접 사용 → 웹은 `web/view/liveTalk/` 신규
- ✅ api·model·(공유)VM = `core`, 화면 = 플랫폼별(`mobile`/`web`)
