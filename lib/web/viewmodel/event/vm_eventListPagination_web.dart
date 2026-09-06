import 'dart:async';

import 'package:com.snowlive/core/api/api_event.dart';
import 'package:com.snowlive/core/model/m_event.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// 각종소식 크롤 계정 필터 항목. [id]가 null이면 '전체 계정'(필터 해제).
class EventAccountFilter {
  final int? id;
  final String label;

  const EventAccountFilter(this.id, this.label);

  /// 전체 보기(필터 없음) 기본 항목.
  static const EventAccountFilter all = EventAccountFilter(null, '전체 계정');

  bool get isAll => id == null;
}

/// 웹 커뮤니티의 `이벤트` 탭 목록 뷰모델. **번호식 페이지 이동** 방식으로,
/// 매 조회마다 리스트를 통째로 교체해 한 번에 한 페이지만 보여준다.
/// 커뮤니티/중고거래/라이브톡 웹 페이지네이션 뷰모델과 같은 구조.
///
/// core의 [EventViewModel]은 쓰지 않는다 — 그쪽은 ScrollController를 소유한
/// **무한스크롤 전용**(next URL 누적)이라 번호식과 맞지 않는다.
/// 여기서는 core의 **API/모델만** 사용한다.
class EventListPaginationViewModelWeb extends GetxController {
  final EventAPI _api = EventAPI();

  /// 서버 page_size(50)와 일치시켜야 total_pages 계산이 맞다.
  /// 응답에 total_pages가 없어 count로 직접 나눈다.
  static const int pageSize = 50;

  final RxList<EventModel> _items = <EventModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCount = 0.obs;

  /// 서버에 실제로 보낸 검색어. 빈 상태 문구에 쓴다.
  /// 평범한 getter로 두면 Obx가 감지하지 못해 화면이 갱신되지 않는다(커뮤니티에서 겪은 함정).
  final RxString _appliedQuery = ''.obs;

  // 번호 이동 시 유지되어야 하므로 Rx가 아닌 평범한 필드.
  String? _searchQuery;

  /// 선택된 크롤 계정 필터(null=전체). 검색과 독립적으로 유지·결합된다.
  int? _crawlAccountId;

  /// 필터 드롭다운에 채울 크롤 계정 목록(맨 앞은 '전체 계정'). 이름 가나다 순.
  final RxList<EventAccountFilter> _accountFilters =
      <EventAccountFilter>[EventAccountFilter.all].obs;
  List<EventAccountFilter> get accountFilters => _accountFilters;

  List<EventModel> get items => _items;
  bool get isLoading => _isLoading.value;

  /// 조회 자체 실패(네트워크/4xx). 개별 항목 파싱 실패는 포함되지 않는다.
  bool get hasError => _hasError.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCount => _totalCount.value;
  String get appliedQuery => _appliedQuery.value;
  bool get hasNext => _currentPage.value < _totalPages.value;
  bool get hasPrevious => _currentPage.value > 1;

  /// 검색어를 세팅하고 1페이지부터 로드.
  ///
  /// 이벤트 API는 정렬 파라미터가 없고 검색은 `search_query`(제목+내용)뿐이라
  /// 커뮤니티처럼 범위·정렬을 받지 않는다.
  Future<void> loadFirstPage({String? query}) async {
    final trimmed = query?.trim();
    _searchQuery = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    _appliedQuery.value = _searchQuery ?? '';

    // gotoPage의 범위 가드에 막혀 1페이지 조회 자체가 안 나가는 것을 막는다.
    _totalPages.value = 1;
    await gotoPage(1);
  }

  /// 크롤 계정 필터 선택(null=전체). 검색어는 유지한 채 1페이지부터 다시 조회한다.
  Future<void> setCrawlAccount(int? crawlAccountId) async {
    _crawlAccountId = crawlAccountId;
    _totalPages.value = 1;
    await gotoPage(1);
  }

  /// 필터 드롭다운용 크롤 계정 목록을 채운다(최초 진입 시 1회). 이름 가나다 순.
  Future<void> fetchAccountFilters() async {
    final accounts = await _api.fetchCrawlAccounts();
    final filters = <EventAccountFilter>[];
    for (final a in accounts) {
      final id = a['crawl_account_id'];
      if (id is! int) continue;
      final name = (a['name'] as String?)?.trim() ?? '';
      final username = (a['username'] as String?)?.trim() ?? '';
      // 표시용 이름 우선, 없으면 인스타 아이디(username)로 대체.
      final label = name.isNotEmpty ? name : username;
      if (label.isEmpty) continue;
      filters.add(EventAccountFilter(id, label));
    }
    filters.sort((a, b) => a.label.compareTo(b.label)); // 가나다 순
    _accountFilters.value = [EventAccountFilter.all, ...filters];
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
      final response = await _api.fetchEventList(
        searchQuery: _searchQuery,
        crawlAccountId: _crawlAccountId,
        page: page,
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
        debugPrint('[Event] 목록 조회 실패: ${response.error}');
        _hasError.value = true;
      }
    } catch (e) {
      if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        debugPrint('[Event] 목록 조회 예외: $e');
        _hasError.value = true;
      }
    }
  }

  /// **항목 하나씩** 파싱한다. 한 건이 깨져도 나머지를 보여주기 위해서.
  /// 크롤링 데이터라 필드가 들쭉날쭉할 수 있어 특히 중요하다.
  List<EventModel> _parseResults(Object? rawResults) {
    if (rawResults is! List) return [];
    final parsed = <EventModel>[];
    var skipped = 0;
    for (final raw in rawResults) {
      try {
        parsed.add(EventModel.fromJson(raw as Map<String, dynamic>));
      } catch (e) {
        skipped++;
        debugPrint('[Event] 항목 파싱 건너뜀: $e');
      }
    }
    if (skipped > 0) debugPrint('[Event] 파싱 실패로 건너뛴 항목 $skipped건');
    return parsed;
  }

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

  /// 제목/행 클릭 시: 조회수를 올리고 `landing_url`로 외부 이동한다.
  /// 조회수 증가는 이동을 막지 않도록 기다리지 않는다(실패해도 이동은 한다).
  /// 로그인 유저만 서버가 카운트하므로(user_id 필수) 게스트는 이동만 한다.
  Future<void> openEvent(EventModel event) async {
    // 비로그인(게스트)도 조회수는 올라간다 → userId가 null이어도 호출한다.
    if (event.eventId != null) {
      unawaited(_incrementViewCount(event.eventId!, _currentUserId()));
    }
    await _launchLanding(event.landingUrl);
  }

  /// 현재 로그인 유저 id. 게스트(미로그인)면 null.
  int? _currentUserId() {
    try {
      final id = Get.find<UserViewModel>().user.user_id;
      if (id == null || id <= 0) return null;
      return id as int;
    } catch (_) {
      return null;
    }
  }

  /// 조회수 증가 호출. 성공하면 서버가 준 총합으로 목록의 해당 항목 숫자를 갱신한다.
  /// [userId]가 null이면 게스트(익명) 조회로 기록된다.
  Future<void> _incrementViewCount(int eventId, int? userId) async {
    try {
      final resp = await _api.incrementViewCount(eventId: eventId, userId: userId);
      if (!resp.success) return;
      final data = resp.data as Map<String, dynamic>;
      final newCount = data['views_count'];
      if (newCount is! int) return;
      final idx = _items.indexWhere((e) => e.eventId == eventId);
      if (idx < 0) return;
      _items[idx].viewCount = newCount;
      _items.refresh(); // 항목 내부 필드만 바꿔서 Obx가 감지하도록 강제 갱신.
    } catch (e) {
      debugPrint('[Event] 조회수 증가 실패: $e');
    }
  }

  /// `landing_url`을 외부 브라우저로 연다. **http/https만** 연다(`javascript:` 등 차단).
  Future<void> _launchLanding(String? raw) async {
    if (raw == null || raw.isEmpty) return;
    final uri = Uri.tryParse(raw);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
