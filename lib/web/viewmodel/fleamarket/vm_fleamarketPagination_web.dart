import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:get/get.dart';

/// 웹 전용 페이지네이션. **번호식 페이지 이동(gotoPage)** + prev/next 지원.
/// core FleamarketListViewModel(모바일 무한스크롤)과 달리 매 조회마다 리스트를 통째로
/// 교체해서 한 번에 한 페이지만 보여준다. FleamarketAPI를 직접 호출한다.
///
/// [UI 연결 — 번호식]
///  - 관찰: `items`, `currentPage`, `totalPages`, `totalCount`, `isLoading`
///  - 하단 번호: `pageWindow()`로 번호 리스트 렌더 → 클릭 시 `gotoPage(n)`
///  - 이전/다음: `loadPrevious()` / `loadNext()` (hasPrevious/hasNext)
class FleamarketPaginationViewModelWeb extends GetxController {
  final FleamarketAPI _api = FleamarketAPI();

  final RxList<Fleamarket> _items = <Fleamarket>[].obs;
  final RxBool _isLoading = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCount = 0.obs;

  // 필터 상태 (번호 이동 시 유지)
  int? _userId;
  String? _categoryMain;
  String? _categorySub;
  String? _spot;
  String? _searchQuery;
  bool? _favoriteList;
  bool? _myflea;

  List<Fleamarket> get items => _items;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCount => _totalCount.value;
  bool get hasNext => _currentPage.value < _totalPages.value;
  bool get hasPrevious => _currentPage.value > 1;

  @override
  void onInit() {
    super.onInit();
    loadFirstPage(userId: Get.find<UserViewModel>().user.user_id);
  }

  /// 필터를 세팅하고 1페이지부터 로드
  Future<void> loadFirstPage({
    int? userId,
    String? categoryMain,
    String? categorySub,
    String? spot,
    bool? favoriteList,
    bool? myflea,
    String? searchQuery,
  }) async {
    _userId = userId;
    _categoryMain = categoryMain;
    _categorySub = categorySub;
    _spot = spot;
    _favoriteList = favoriteList;
    _myflea = myflea;
    _searchQuery = searchQuery;
    _totalPages.value = 1; // gotoPage 범위체크 초기화
    await gotoPage(1);
  }

  /// 번호식 페이지 이동 (하단 번호 클릭)
  Future<void> gotoPage(int page) async {
    if (page < 1) return;
    if (_totalPages.value >= 1 && page > _totalPages.value) return;
    _isLoading.value = true;
    try {
      isGlobalPageLoading.value = true;
      await _fetchWithRetry(page);
    } finally {
      _isLoading.value = false;
      isGlobalPageLoading.value = false;
    }
  }

  /// Heroku 무료/이코 dyno가 잠들어 있으면 첫 요청이 라우터 타임아웃(30초)에 걸려
  /// 실패로 돌아오는 경우가 있다(서버는 그 사이 백그라운드에서 깨어남). 실패 시
  /// 짧게 대기 후 한 번 더 시도해서, 사용자가 탭을 다시 누르지 않아도 되게 한다.
  Future<void> _fetchWithRetry(int page, {int attempt = 0}) async {
    try {
      final response = await _api.fetchFleamarketList(
        userId: _userId,
        categoryMain: _categoryMain,
        categorySub: _categorySub,
        spot: _spot,
        favorite_list: _favoriteList,
        myflea: _myflea,
        search_query: _searchQuery,
        page: page,
      );
      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        final parsed = FleamarketResponse.fromJson(data);
        _items.value = parsed.results ?? [];
        _totalCount.value = (data['count'] ?? 0) as int;
        _totalPages.value =
            (data['total_pages'] ?? ((_totalCount.value + 29) ~/ 30)) as int;
        _currentPage.value = (data['current_page'] ?? page) as int;
      } else if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        print('[Fleamarket] 목록 조회 실패: ${response.error}');
      }
    } catch (e) {
      if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        print('[Fleamarket] 목록 조회 예외: $e');
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
