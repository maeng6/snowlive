import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:get/get.dart';

/// 웹 전용 개인 랭킹 페이지네이션. **번호식 페이지 이동(gotoPage)** + prev/next 지원.
/// core RankingListViewModel(모바일 무한스크롤/누적)과 달리 매 조회마다 리스트를 통째로
/// 교체해서 한 번에 한 페이지만 보여준다. 중고거래(FleamarketPaginationViewModelWeb)와 동일한 패턴.
///
/// [UI 연결 — 번호식]
///  - 관찰: `items`, `myRankingInfo`, `currentPage`, `totalPages`, `totalCount`, `isLoading`
///  - 하단 번호: `pageWindow()`로 번호 리스트 렌더 → 클릭 시 `gotoPage(n)`
///  - 이전/다음: `loadPrevious()` / `loadNext()` (hasPrevious/hasNext)
///
/// [응답 구조 주의]
///  개인 랭킹 응답은 `{ my_ranking_info, results:{ count, total_pages, current_page, results:[...] } }`
///  형태라, 페이지 메타(count/total_pages/current_page)는 최상위가 아니라 `results` 안에 있다.
class RankingListViewModelWeb extends GetxController {
  final RankingAPI _api = RankingAPI();

  final RxList<RankingUser> _items = <RankingUser>[].obs;
  final Rxn<MyRankingInfo> _myRankingInfo = Rxn<MyRankingInfo>();
  final RxBool _isLoading = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCount = 0.obs;
  final int pageSize;

  // 필터 상태 (번호 이동 시 유지)
  int? _resortId;
  String? _season;
  String? _federation;
  bool? _daily;

  RankingListViewModelWeb({this.pageSize = 30});

  List<RankingUser> get items => _items;
  MyRankingInfo? get myRankingInfo => _myRankingInfo.value;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCount => _totalCount.value;
  bool get hasNext => _currentPage.value < _totalPages.value;
  bool get hasPrevious => _currentPage.value > 1;

  @override
  void onInit() {
    super.onInit();
    loadFirstPage();
  }

  /// 필터를 세팅하고 1페이지부터 로드
  Future<void> loadFirstPage({
    int? resortId,
    String? season,
    String? federation,
    bool? daily,
  }) async {
    _resortId = resortId;
    _season = season;
    _federation = federation;
    _daily = daily;
    _totalPages.value = 1; // gotoPage 범위체크 초기화
    await gotoPage(1);
  }

  /// 번호식 페이지 이동 (하단 번호 클릭)
  Future<void> gotoPage(int page) async {
    if (page < 1) return;
    if (_totalPages.value >= 1 && page > _totalPages.value) return;
    _isLoading.value = true;
    try {
      final res = await _api.fetchRankingData_indiv(
        userId: Get.find<UserViewModel>().user.user_id,
        resortId: _resortId,
        season: _season,
        federation: _federation,
        daily: _daily,
        page: page,
        pageSize: pageSize,
      );
      if (res.success) {
        final data = res.data as Map<String, dynamic>;
        final parsed = RankingListIndivResponse.fromJson(data);
        _myRankingInfo.value = parsed.myRankingInfo;
        _items.value = parsed.results?.rankingUsers ?? [];

        // 페이지 메타는 results 내부에 있음
        final resultsMap = (data['results'] as Map<String, dynamic>?) ?? {};
        _totalCount.value = (resultsMap['count'] ?? 0) as int;
        _totalPages.value =
            (resultsMap['total_pages'] ?? ((_totalCount.value + pageSize - 1) ~/ pageSize)) as int;
        _currentPage.value = (resultsMap['current_page'] ?? page) as int;
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadNext() => hasNext ? gotoPage(_currentPage.value + 1) : Future.value();
  Future<void> loadPrevious() => hasPrevious ? gotoPage(_currentPage.value - 1) : Future.value();

  /// 하단에 표시할 페이지 번호 목록 (현재 페이지 주변 span개 윈도우)
  List<int> pageWindow({int span = 7}) {
    final tp = _totalPages.value;
    if (tp <= 1) return [1];
    int start = _currentPage.value - (span ~/ 2);
    if (start < 1) start = 1;
    int end = start + span - 1;
    if (end > tp) {
      end = tp;
      start = (end - span + 1) < 1 ? 1 : (end - span + 1);
    }
    return [for (int i = start; i <= end; i++) i];
  }
}
