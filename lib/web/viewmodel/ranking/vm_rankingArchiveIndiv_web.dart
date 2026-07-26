import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/core/model/m_rankingListIndiv_recordRoom.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart' show RankingFilter_season;
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:get/get.dart';

/// 웹 전용 "랭킹 기록실" 개인랭킹. 지난 시즌 기록을 번호식 페이지네이션으로 보여준다.
/// 라이브 랭킹(RankingListViewModelWeb)과 동일한 패턴이지만, 현재 시즌 대신
/// 사용자가 고른 과거 시즌(selected_season)을 조회하는 recordRoom API를 쓴다.
///
/// [응답 구조 주의]
///  `{ my_ranking_info, results:{ count, next, previous, results:[...] } }` 형태라
///  페이지 메타(count 등)는 최상위가 아니라 `results` 안에 있다.
class RankingArchiveIndivViewModelWeb extends GetxController {
  final RankingAPI _api = RankingAPI();

  final RxList<RankingUser_recordRoom> _items = <RankingUser_recordRoom>[].obs;
  final Rxn<MyRankingInfo_recordRoom> _myRankingInfo = Rxn<MyRankingInfo_recordRoom>();
  final RxBool _isLoading = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCount = 0.obs;
  final int pageSize;

  // 필터 상태 (번호 이동 시 유지)
  String _season = RankingFilter_season.season2526.dbSeason;
  int? _resortId;
  String? _federation;
  bool? _daily;
  String? _searchQuery;   // 통합 검색어

  RankingArchiveIndivViewModelWeb({this.pageSize = 30});

  List<RankingUser_recordRoom> get items => _items;
  MyRankingInfo_recordRoom? get myRankingInfo => _myRankingInfo.value;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCount => _totalCount.value;
  bool get hasNext => _currentPage.value < _totalPages.value;
  bool get hasPrevious => _currentPage.value > 1;

  /// 필터를 세팅하고 1페이지부터 로드.
  Future<void> loadFirstPage({
    required String season,
    int? resortId,
    String? federation,
    bool? daily,
    String? searchQuery,
  }) async {
    _season = season;
    _resortId = resortId;
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

  /// Heroku dyno가 잠들어 있으면 첫 요청이 실패로 돌아오는 경우가 있어 1회 재시도한다.
  Future<void> _fetchWithRetry(int page, {int attempt = 0}) async {
    try {
      final res = await _api.fetchRankingData_indiv_recordRoom(
        // 게스트면 null 그대로 넘긴다(0 같은 더미값을 보내면 서버가 에러를 준다).
        userId: Get.find<UserViewModel>().user.user_id,
        resortId: _resortId,
        daily: _daily,
        selected_season: _season,
        federation: _federation,
        page: page,
        pageSize: pageSize,
        searchQuery: _searchQuery,
      );
      if (res.success) {
        final data = res.data as Map<String, dynamic>;
        final resultsMap = (data['results'] as Map<String, dynamic>?) ?? {};

        // 게스트/미참여 시즌이면 my_ranking_info가 null로 오는데, 모델의 fromJson은
        // null을 그대로 넘기면 터져서 여기서 먼저 걸러낸다.
        final myJson = data['my_ranking_info'];
        _myRankingInfo.value = myJson is Map<String, dynamic>
            ? MyRankingInfo_recordRoom.fromJson(myJson)
            : null;

        _items.value = Results_recordRoom.fromJson(resultsMap).rankingUsers;
        _totalCount.value = (resultsMap['count'] ?? 0) as int;
        _totalPages.value =
            (resultsMap['total_pages'] ?? ((_totalCount.value + pageSize - 1) ~/ pageSize)) as int;
        _currentPage.value = (resultsMap['current_page'] ?? page) as int;
      } else if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      }
    } catch (e) {
      if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
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
