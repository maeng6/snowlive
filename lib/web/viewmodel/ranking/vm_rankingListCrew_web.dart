import 'package:com.snowlive/core/api/api_ranking.dart';
import 'package:com.snowlive/core/model/m_rankingListCrew.dart';
import 'package:com.snowlive/web/util/ranking_season_web.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:get/get.dart';

/// 웹 전용 크루 랭킹. `fetchRankingData_crew`가 아직 번호식 페이지네이션(page/page_size)을
/// 지원하지 않아서, 지금은 next/previous 커서 방식으로만 구현한다(중고거래 페이지네이션이
/// 번호식으로 업그레이드되기 전 초기 형태와 동일 패턴). 번호식으로 바꾸려면 백엔드에
/// page/page_size + total_pages/current_page 지원이 먼저 필요.
/// userId는 게스트도 조회 가능하도록 옵셔널(개인랭킹과 동일하게 게스트 우선 설계).
class RankingListCrewViewModelWeb extends GetxController {
  final RankingAPI _api = RankingAPI();

  final RxList<CrewRanking> _items = <CrewRanking>[].obs;
  final Rxn<MyCrewRankingInfo> _myCrewRankingInfo = Rxn<MyCrewRankingInfo>();
  final RxBool _isLoading = false.obs;

  String? _nextUrl;
  final List<String?> _urlStack = [null];

  int? _resortId;
  String? _federation;
  bool? _daily;
  String? _fetchedSeason;

  List<CrewRanking> get items => _items;
  MyCrewRankingInfo? get myCrewRankingInfo => _myCrewRankingInfo.value;
  bool get isLoading => _isLoading.value;
  bool get hasNext => _nextUrl != null && _nextUrl!.isNotEmpty;
  bool get hasPrevious => _urlStack.length > 1;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    _fetchedSeason = await fetchCurrentRankingSeason();
  }

  /// 필터를 세팅하고 1페이지부터 로드. [userId]는 게스트면 null이어도 된다.
  Future<void> loadFirstPage({
    int? userId,
    int? resortId,
    String? federation,
    bool? daily,
  }) async {
    _resortId = resortId;
    _federation = federation;
    _daily = daily;
    _urlStack
      ..clear()
      ..add(null);
    await _fetch(userId: userId, url: null);
  }

  Future<void> loadNext(int? userId) async {
    if (!hasNext) return;
    final url = _nextUrl!;
    await _fetch(userId: userId, url: url);
    _urlStack.add(url);
  }

  Future<void> loadPrevious(int? userId) async {
    if (!hasPrevious) return;
    _urlStack.removeLast();
    await _fetch(userId: userId, url: _urlStack.last);
  }

  Future<void> _fetch({int? userId, String? url}) async {
    _isLoading.value = true;
    try {
      isGlobalPageLoading.value = true;
      await _fetchWithRetry(userId: userId, url: url);
    } finally {
      _isLoading.value = false;
      isGlobalPageLoading.value = false;
    }
  }

  /// Heroku 무료/이코 dyno가 잠들어 있으면 첫 요청이 라우터 타임아웃(30초)에 걸려
  /// 실패로 돌아오는 경우가 있다(서버는 그 사이 백그라운드에서 깨어남). 실패 시
  /// 짧게 대기 후 한 번 더 시도해서, 사용자가 탭을 다시 누르지 않아도 되게 한다.
  Future<void> _fetchWithRetry({int? userId, String? url, int attempt = 0}) async {
    try {
      final res = await _api.fetchRankingData_crew(
        userId: userId,
        resortId: _resortId,
        federation: _federation,
        daily: _daily,
        season: _fetchedSeason,
        url: url,
      );
      if (res.success) {
        final data = res.data as Map<String, dynamic>;
        final parsed = RankingListCrewModel.fromJson(data);
        _myCrewRankingInfo.value = parsed.myCrewRankingInfo;
        _items.value = parsed.rankingResults?.results ?? [];
        _nextUrl = parsed.rankingResults?.next;
      } else if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(userId: userId, url: url, attempt: attempt + 1);
      } else {
        print('[Ranking] 크루랭킹 조회 실패: ${res.error}');
      }
    } catch (e) {
      if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(userId: userId, url: url, attempt: attempt + 1);
      } else {
        print('[Ranking] 크루랭킹 파싱 에러: $e');
      }
    }
  }
}
