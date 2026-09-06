import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/util/ranking_season_web.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
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
  String? _searchQuery;   // 통합 검색어

  // 파이어스토어에서 1회 조회해 캐싱하는 현재 시즌 값. 모바일의 모든 랭킹 호출부가
  // 항상 season을 넘기는 것과 동일하게 맞추기 위해 필요(누락 시 백엔드가 빈 결과를
  // 돌려주는 것으로 보임 — 실사용 중 리스트가 안 뜨던 원인).
  String? _fetchedSeason;

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
    _init();
  }

  /// 파이어스토어에서 시즌을 먼저 받아온 뒤에야 목록 조회가 시작되는데, 그 구간에도
  /// 진행바가 보이도록 전체를 감싼다. 안쪽 gotoPage가 한 번 더 begin/end 하지만
  /// 참조 카운트라 중첩돼도 안전하다.
  Future<void> _init() => withPageLoading(() async {
        _fetchedSeason = await fetchCurrentRankingSeason();
        await loadFirstPage();
      });

  /// 필터를 세팅하고 1페이지부터 로드. season을 명시적으로 안 넘기면
  /// 파이어스토어에서 1회 조회해둔 현재 시즌 값을 그대로 쓴다.
  Future<void> loadFirstPage({
    int? resortId,
    String? season,
    String? federation,
    bool? daily,
    String? searchQuery,
  }) async {
    _resortId = resortId;
    _season = season ?? _fetchedSeason;
    _federation = federation;
    _daily = daily;
    _searchQuery = searchQuery;
    _totalPages.value = 1; // gotoPage 범위체크 초기화
    await gotoPage(1);
  }

  /// 번호식 페이지 이동 (하단 번호 클릭)
  Future<void> gotoPage(int page) async {
    if (page < 1) return;
    if (_totalPages.value >= 1 && page > _totalPages.value) return;
    _isLoading.value = true;
    beginPageLoading();
    try {
      await _fetchWithRetry(page);
    } finally {
      _isLoading.value = false;
      endPageLoading();
    }
  }

  /// Heroku 무료/이코 dyno가 잠들어 있으면 첫 요청이 라우터 타임아웃(30초)에 걸려
  /// 실패로 돌아오는 경우가 있다(서버는 그 사이 백그라운드에서 깨어남). 실패 시
  /// 짧게 대기 후 한 번 더 시도해서, 사용자가 탭을 다시 누르지 않아도 되게 한다.
  Future<void> _fetchWithRetry(int page, {int attempt = 0}) async {
    try {
      final res = await _api.fetchRankingData_indiv(
        userId: Get.find<UserViewModel>().user.user_id,
        resortId: _resortId,
        season: _season,
        federation: _federation,
        daily: _daily,
        page: page,
        pageSize: pageSize,
        searchQuery: _searchQuery,
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
      } else if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        print('[Ranking] 개인랭킹 조회 실패: ${res.error}');
      }
    } catch (e) {
      if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        print('[Ranking] 개인랭킹 파싱 에러: $e');
      }
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
