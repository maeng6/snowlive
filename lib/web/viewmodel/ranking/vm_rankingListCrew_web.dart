import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew.dart';
import 'package:com.snowlive/web/util/ranking_season_web.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:get/get.dart';

/// 웹 전용 크루 랭킹 — **번호식 페이지네이션**(개인랭킹과 동일 패턴).
/// 크루 응답은 `{ my_crew_ranking_info, results:{ count, total_pages, current_page, results:[...] } }`
/// 구조라, 페이지 메타(total_pages/current_page/count)는 최상위가 아니라 `results` 안에 있다.
/// userId는 게스트도 조회 가능하도록 옵셔널.
///
/// [UI 연결] `NumberedPaginationBar`(currentPage/totalPages/hasPrevious/hasNext/pageWindow/gotoPage)와 함께 쓴다.
class RankingListCrewViewModelWeb extends GetxController {
  final RankingAPI _api = RankingAPI();
  final int pageSize;

  RankingListCrewViewModelWeb({this.pageSize = 30});

  final RxList<CrewRanking> _items = <CrewRanking>[].obs;
  final Rxn<MyCrewRankingInfo> _myCrewRankingInfo = Rxn<MyCrewRankingInfo>();
  final RxBool _isLoading = false.obs;
  final RxBool _hasLoadedOnce = false.obs;
  /// 서버에 **실제로 보낸** 검색어. 빈 상태 문구를 입력 중인 값이 아니라
  /// 조회에 쓰인 값으로 쓰기 위해 따로 들고 있다(커뮤니티와 같은 방식).
  final RxString _appliedQuery = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCount = 0.obs;

  // 필터 상태 (번호 이동 시 유지)
  int? _userId;
  int? _resortId;
  String? _federation;
  bool? _daily;
  String? _fetchedSeason;
  String? _searchQuery;   // 통합 검색어

  List<CrewRanking> get items => _items;
  MyCrewRankingInfo? get myCrewRankingInfo => _myCrewRankingInfo.value;
  bool get isLoading => _isLoading.value;

  /// 첫 조회가 한 번이라도 끝났는지. 시즌을 파이어스토어에서 먼저 받아오는 구간에는
  /// [isLoading]이 아직 false여서, 화면이 "데이터 없음"을 먼저 보여주는 문제가 있었다.
  /// 화면은 이 값이 false인 동안 빈 상태 대신 스켈레톤을 그려야 한다.
  bool get hasLoadedOnce => _hasLoadedOnce.value;

  String get appliedQuery => _appliedQuery.value;
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

  /// 시즌 조회 구간에도 진행바가 보이도록 감싼다(개인랭킹과 동일).
  Future<void> _init() => withPageLoading(() async {
        try {
          _fetchedSeason = await fetchCurrentRankingSeason();
        } catch (_) {
          // 시즌 조회가 실패해도 화면이 스켈레톤에 갇히지 않게 플래그는 세운다.
          _hasLoadedOnce.value = true;
          rethrow;
        }
      });

  /// 필터를 세팅하고 1페이지부터 로드. [userId]는 게스트면 null이어도 된다.
  Future<void> loadFirstPage({
    int? userId,
    int? resortId,
    String? federation,
    bool? daily,
    String? searchQuery,
  }) async {
    _userId = userId;
    _resortId = resortId;
    _federation = federation;
    _daily = daily;
    _searchQuery = searchQuery;
    _appliedQuery.value = searchQuery ?? '';
    _fetchedSeason ??= await fetchCurrentRankingSeason();
    // 탭(누적·일간)·필터·검색이 바뀌면 조회 조건이 통째로 달라진다 — 이전 목록을
    // 남겨두면 새 응답이 올 때까지 다른 조건의 값이 잠깐 보인다. 그래서 여기서
    // 비워 스켈레톤이 뜨게 하고, 같은 조건의 페이지 이동(gotoPage)에서는 유지한다.
    _items.clear();
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
      _hasLoadedOnce.value = true;
      endPageLoading();
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

  /// Heroku dyno가 잠들어 있으면 첫 요청이 라우터 타임아웃(30초)에 걸려 실패로
  /// 돌아오는 경우가 있어(서버는 그 사이 백그라운드에서 깨어남), 실패 시 짧게 대기 후 한 번 더 시도한다.
  Future<void> _fetchWithRetry(int page, {int attempt = 0}) async {
    try {
      final res = await _api.fetchRankingData_crew(
        userId: _userId,
        resortId: _resortId,
        federation: _federation,
        daily: _daily,
        season: _fetchedSeason,
        page: page,
        pageSize: pageSize,
        searchQuery: _searchQuery,
      );
      if (res.success) {
        final data = res.data as Map<String, dynamic>;
        final parsed = RankingListCrewModel.fromJson(data);
        // 크루 미소속이면 my_crew_ranking_info가 null이 아니라 "필드가 전부 null인
        // 빈 객체"로 오는 경우가 있어서, 그대로 두면 값 없는 내 크루 카드가 그려진다.
        // crewId가 없으면 소속 크루가 없는 것으로 보고 null로 정규화한다.
        final myCrew = parsed.myCrewRankingInfo;
        _myCrewRankingInfo.value = myCrew?.crewId == null ? null : myCrew;
        _items.value = parsed.rankingResults?.results ?? [];

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
        print('[Ranking] 크루랭킹 조회 실패: ${res.error}');
      }
    } catch (e) {
      if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        print('[Ranking] 크루랭킹 파싱 에러: $e');
      }
    }
  }
}
