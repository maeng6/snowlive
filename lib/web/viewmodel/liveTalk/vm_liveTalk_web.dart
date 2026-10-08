import 'package:com.snowlive/core/api/api_liveTalk.dart';
import 'package:com.snowlive/core/model/m_liveTalk.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:get/get.dart';

/// 웹 전용 라이브톡 목록 뷰모델. 화면은 **무한 스크롤**([loadMore])로 쓰고,
/// 내부적으로는 서버의 번호식 페이지네이션(page=N)을 그대로 쓴다 — 다음 페이지를
/// 받아 리스트 뒤에 이어붙인다. [gotoPage]/[loadFirstPage]는 리스트를 통째로
/// 교체하므로 첫 로드·새로고침(글 등록 후 1페이지로 복귀)에 쓴다.
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
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasError = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCount = 0.obs;

  // 번호 이동 시 유지되어야 하므로 Rx가 아닌 평범한 필드.
  int? _userId;

  List<LiveTalk> get items => _items;
  bool get isLoading => _isLoading.value;

  /// 무한 스크롤로 **다음 페이지를 이어붙이는 중**(첫 로딩과 구분한다 —
  /// 첫 로딩은 스켈레톤, 이쪽은 목록 하단 스피너).
  bool get isLoadingMore => _isLoadingMore.value;

  /// 더 받아올 페이지가 남았는지.
  bool get hasMore => _currentPage.value < _totalPages.value;

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

  /// 무한 스크롤 — 다음 페이지를 받아 리스트 **뒤에 이어붙인다**.
  /// 이미 받는 중이거나 마지막 페이지면 아무것도 하지 않는다(중복 호출 가드).
  Future<void> loadMore() async {
    if (_isLoading.value || _isLoadingMore.value || !hasMore) return;
    _isLoadingMore.value = true;
    try {
      await _fetchWithRetry(_currentPage.value + 1, append: true);
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// 에러 상태에서 "다시 시도"용.
  Future<void> retry() => gotoPage(_currentPage.value);

  /// Heroku eco dyno가 잠들어 있으면 첫 요청이 라우터 타임아웃으로 실패할 수 있어
  /// (서버는 그 사이 깨어남) 실패 시 한 번 더 시도한다.
  ///
  /// [append]가 true면 기존 목록 뒤에 이어붙이고(무한 스크롤), false면 교체한다.
  Future<void> _fetchWithRetry(
    int page, {
    int attempt = 0,
    bool append = false,
  }) async {
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
        final parsed = _parseResults(data['results']);
        if (append) {
          _items.addAll(parsed);
        } else {
          _items.value = parsed;
        }
        _totalCount.value = (data['count'] ?? 0) as int;
        _totalPages.value =
            ((_totalCount.value + pageSize - 1) ~/ pageSize).clamp(1, 1 << 31);
        _currentPage.value = page;
        _hasError.value = false;
      } else if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1, append: append);
      } else {
        print('[LiveTalk] 목록 조회 실패: ${response.error}');
        // 이어붙이기 실패는 에러 화면으로 넘기지 않는다 — 이미 보고 있던 글이
        // 통째로 사라진다. 다음 스크롤에서 다시 시도된다.
        if (!append) _hasError.value = true;
      }
    } catch (e) {
      if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1, append: append);
      } else {
        print('[LiveTalk] 목록 조회 예외: $e');
        if (!append) _hasError.value = true;
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

  /// 내 글 본문 수정 → 성공하면 그 글만 다시 받아 목록에 반영한다.
  Future<bool> updateDescription({
    required int livetalkId,
    required String description,
  }) async {
    final userId = _userId;
    if (userId == null) return false;
    try {
      final response = await _api.update({
        'livetalk_id': livetalkId,
        'user_id': userId,
        'description': description,
      });
      if (!response.success) {
        print('[LiveTalk] 수정 실패: ${response.error}');
        return false;
      }
      await reloadItem(livetalkId);
      return true;
    } catch (e) {
      print('[LiveTalk] 수정 예외: $e');
      return false;
    }
  }

  /// 글이 삭제됐을 때 목록에서 즉시 뺀다. 지워진 글은 [reloadItem]으로는 못 지운다
  /// (상세 조회가 실패하면 그냥 두기 때문) → 삭제 성공 시 호출자가 이걸 부른다.
  void removeItem(int livetalkId) {
    final before = _items.length;
    _items.removeWhere((e) => e.livetalkId == livetalkId);
    if (_items.length < before && _totalCount.value > 0) {
      _totalCount.value = _totalCount.value - 1;
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
