import 'package:com.snowlive/core/api/api_liveTalk.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:get/get.dart';

/// 웹 전용 라이브톡 목록 뷰모델. **번호식 페이지 이동**(gotoPage) 방식으로,
/// 매 조회마다 리스트를 통째로 교체해 한 번에 한 페이지만 보여준다.
/// 커뮤니티/중고거래 웹 페이지네이션 뷰모델과 같은 구조.
///
/// core의 `LiveTalkViewModel`(모바일)은 쓰지 않는다 — 그쪽은 `dart:io`(File),
/// XFile(이미지피커), TextEditingController/ScrollController 등 UI·플랫폼 의존이 많아
/// 웹(dart2js) 빌드가 깨지고, next URL 누적(무한스크롤) 방식이라 번호식과도 안 맞는다.
/// 여기서는 core의 **API/모델만** 사용해 새로 구현한다.
class LiveTalkListPaginationViewModelWeb extends GetxController {
  final LiveTalkAPI _api = LiveTalkAPI();

  /// 서버 `LiveTalkPagination.page_size`(30)와 일치시켜야 total_pages 계산이 맞다.
  /// 응답에 total_pages가 없어 count로 직접 나눈다.
  static const int pageSize = 30;

  final RxList<LiveTalk> _items = <LiveTalk>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCount = 0.obs;

  // 번호 이동 시 유지되어야 하므로 Rx가 아닌 평범한 필드.
  int? _userId;

  List<LiveTalk> get items => _items;
  bool get isLoading => _isLoading.value;

  /// 조회 자체 실패(네트워크/4xx). 개별 글 파싱 실패는 포함되지 않는다.
  bool get hasError => _hasError.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCount => _totalCount.value;
  bool get hasNext => _currentPage.value < _totalPages.value;
  bool get hasPrevious => _currentPage.value > 1;

  /// 필터(userId)를 세팅하고 1페이지부터 로드.
  /// 게스트면 userId를 null로 넘기면 된다(비로그인 조회 허용).
  Future<void> loadFirstPage({int? userId}) async {
    _userId = userId;
    // gotoPage의 범위 가드에 막혀 1페이지 조회 자체가 안 나가는 것을 막는다.
    _totalPages.value = 1;
    await gotoPage(1);
  }

  /// 번호식 페이지 이동 (하단 번호 클릭).
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

  /// 에러 상태에서 "다시 시도"용.
  Future<void> retry() => gotoPage(_currentPage.value);

  /// Heroku eco dyno가 잠들어 있으면 첫 요청이 라우터 타임아웃으로 실패할 수 있어
  /// (서버는 그 사이 깨어남) 실패 시 한 번 더 시도한다.
  Future<void> _fetchWithRetry(int page, {int attempt = 0}) async {
    try {
      final response = await _api.fetchList(
        {
          // 게스트(userId == null)면 user_id를 아예 빼야 한다.
          if (_userId != null) 'user_id': _userId,
        },
        // 번호식: page는 쿼리로 전달. POST 엔드포인트여도 DRF PageNumberPagination은
        // query_params에서 page를 읽으므로 URL 뒤에 ?page=N 을 붙인다.
        url: '${LiveTalkAPI.baseUrl}/list/?page=$page',
      );

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        _items.value = _parseResults(data['results']);
        _totalCount.value = (data['count'] ?? 0) as int;
        _totalPages.value =
            ((_totalCount.value + pageSize - 1) ~/ pageSize).clamp(1, 1 << 31);
        _currentPage.value = page;
        _hasError.value = false;
      } else if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        print('[LiveTalk] 목록 조회 실패: ${response.error}');
        _hasError.value = true;
      }
    } catch (e) {
      if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        print('[LiveTalk] 목록 조회 예외: $e');
        _hasError.value = true;
      }
    }
  }

  /// **글 하나씩** 파싱한다. 한 건이 깨져도 나머지를 보여주기 위해서.
  List<LiveTalk> _parseResults(Object? rawResults) {
    if (rawResults is! List) return [];
    final parsed = <LiveTalk>[];
    var skipped = 0;
    for (final raw in rawResults) {
      try {
        parsed.add(LiveTalk.fromJson(raw as Map<String, dynamic>));
      } catch (e) {
        skipped++;
        print('[LiveTalk] 글 파싱 건너뜀: $e');
      }
    }
    if (skipped > 0) print('[LiveTalk] 파싱 실패로 건너뛴 글 $skipped건');
    return parsed;
  }

  /// 피드에서 하트를 눌렀을 때. 상세를 열지 않고 그 자리에서 토글한다.
  /// 게스트면 false를 리턴해 호출자가 로그인 안내를 띄우게 한다.
  Future<bool> toggleLike(LiveTalk item) async {
    final userId = _userId;
    if (userId == null || item.livetalkId == null) return false;
    try {
      final response = await _api.toggleLike({
        'livetalk_id': item.livetalkId,
        'user_id': userId,
      });
      if (!response.success) {
        print('[LiveTalk] 좋아요 실패: ${response.error}');
        return false;
      }
      final parsed =
          LiveTalkLikeResponse.fromJson(response.data as Map<String, dynamic>);
      item
        ..isLiked = parsed.liked ?? !(item.isLiked ?? false)
        ..likeCount = parsed.likeCount ?? item.likeCount;
      // 리스트 원소 내부만 바뀌었으므로 RxList가 스스로 알지 못한다 → 강제 통지.
      _items.refresh();
      return true;
    } catch (e) {
      print('[LiveTalk] 좋아요 예외: $e');
      return false;
    }
  }

  /// 상세 오버레이에서 좋아요·댓글이 바뀐 뒤 해당 글만 다시 받아 끼워넣는다.
  /// 페이지를 통째로 다시 불러오면 스크롤 위치가 날아간다.
  Future<void> reloadItem(int livetalkId) async {
    try {
      final response = await _api.fetchDetail({
        'livetalk_id': livetalkId,
        if (_userId != null) 'user_id': _userId,
      });
      if (!response.success) return;
      final fresh = LiveTalk.fromJson(response.data as Map<String, dynamic>);
      final index = _items.indexWhere((e) => e.livetalkId == livetalkId);
      if (index < 0) return;
      // 목록은 댓글을 들고 있지 않아도 되지만, 있어도 무해하다.
      _items[index] = fresh;
    } catch (e) {
      print('[LiveTalk] 글 갱신 예외: $e');
    }
  }

  Future<void> loadNext() =>
      hasNext ? gotoPage(_currentPage.value + 1) : Future.value();
  Future<void> loadPrevious() =>
      hasPrevious ? gotoPage(_currentPage.value - 1) : Future.value();

  /// 하단에 표시할 페이지 번호 목록 (현재 페이지 주변 span개 윈도우).
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
