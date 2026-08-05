import 'package:com.snowlive/core/api/api_community.dart';
import 'package:com.snowlive/core/model/m_communityList.dart';
import 'package:com.snowlive/web/widget/w_top_loading_bar_web.dart';
import 'package:get/get.dart';

/// 커뮤니티 카테고리 탭.
///
/// core의 `Community_Category_sub_bulletin`을 재사용하지 않는 이유: 그 enum이 있는
/// vm_communityBulletinList.dart가 vm_liveTalk.dart를 import하고, 그 파일이 `dart:io`를
/// 끌고 와서 웹(dart2js) 빌드가 깨진다. 트리셰이킹으로 회피되지 않으므로 웹에 다시
/// 정의한다. **문자열 값은 core enum과 동일하게 유지해야 서버 필터가 맞는다.**
enum CommunityCategoryTab {
  total('전체', null),
  chat('잡담', '잡담'),
  room('시즌방', '시즌방'),
  crew('단톡방·동호회', '단톡방·동호회');

  const CommunityCategoryTab(this.label, this.categorySub);

  final String label;

  /// null이면 category_sub를 아예 보내지 않는다(= 전체).
  final String? categorySub;
}

/// 검색 범위. 백엔드가 지원하는 3종만 둔다.
/// (목업의 '제목만'/'작성일'/'답글'은 서버 파라미터가 없어 만들지 않았다)
enum CommunitySearchScope {
  titleContent('제목+내용'),
  author('작성자'),
  comment('댓글');

  const CommunitySearchScope(this.label);

  final String label;
}

/// 정렬. 서버의 `sort` 파라미터 값(`latest` / `views` / `comments`)과 1:1로 맞춘다.
/// (최신순은 서버 기본값이기도 하지만, 계약대로 명시해서 보낸다)
enum CommunitySortOption {
  latest('최신순', 'latest'),
  views('조회수순', 'views'),
  comments('댓글순', 'comments');

  const CommunitySortOption(this.label, this.sortParam);

  final String label;
  final String sortParam;
}

/// 웹 전용 커뮤니티 목록 뷰모델. **번호식 페이지 이동**(gotoPage) 방식으로,
/// 매 조회마다 리스트를 통째로 교체해 한 번에 한 페이지만 보여준다.
/// 중고거래 웹 페이지네이션 뷰모델과 같은 구조다.
///
/// core의 CommunityBulletinListViewModel(모바일 무한스크롤)은 쓰지 않는다 —
/// 그쪽은 next URL 누적 방식이고 onInit에서 LiveTalkViewModel을 Get.find 하는데
/// 웹에는 등록되어 있지 않다.
class CommunityListPaginationViewModelWeb extends GetxController {
  final CommunityAPI _api = CommunityAPI();

  /// 서버 응답 page_size. 응답에 total_pages가 없어서 직접 나눠야 한다.
  static const int pageSize = 30;

  /// 커뮤니티 게시판은 category_main이 '게시판' 고정이다.
  static const String _categoryMain = '게시판';

  final RxList<Community> _items = <Community>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _totalCount = 0.obs;
  final RxString _appliedQuery = ''.obs;

  // 필터 상태 (번호 이동 시 유지되어야 하므로 Rx가 아닌 평범한 필드)
  int? _userId;
  String? _categorySub;
  String? _searchQuery;
  String? _searchQueryUser;
  String? _searchQueryComment;
  String _sort = CommunitySortOption.latest.sortParam;

  List<Community> get items => _items;
  bool get isLoading => _isLoading.value;

  /// 조회 자체가 실패했는지(네트워크/4xx). 개별 글 파싱 실패는 여기에 포함되지 않는다.
  bool get hasError => _hasError.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalCount => _totalCount.value;
  bool get hasNext => _currentPage.value < _totalPages.value;
  bool get hasPrevious => _currentPage.value > 1;

  /// 현재 적용된 검색어(뷰의 입력창 값이 아니라 **서버에 실제로 보낸 값**).
  /// 검색어 강조와 "OO 검색 결과입니다." 문구가 이 값을 기준으로 그려진다.
  ///
  /// Rx로 둔다 — 검색 상태만 보고 안내 박스를 그리는 Obx가 있어서, 평범한 getter면
  /// 관찰 대상이 없는 Obx가 되어 GetX가 예외를 던진다.
  String get appliedQuery => _appliedQuery.value;

  // onInit에서 조회하지 않는다. 중고거래/랭킹은 onInit 조회 결과가 최초 진입에
  // 반영되지 않는 사례가 있어 화면에서 post-frame으로 한 번 더 조회하고 있고,
  // 그래서 진입마다 요청이 2번 나간다. 커뮤니티는 목록 페이로드에 댓글까지 들어와
  // 무겁기 때문에 화면이 단독으로 트리거하게 두어 중복 요청을 만들지 않는다.

  /// 필터를 세팅하고 1페이지부터 로드.
  ///
  /// [scope]에 따라 세 검색 파라미터 중 하나만 채운다. 뷰가 직접 조립하면
  /// "작성자 검색으로 바꿨는데 search_query가 남아 두 조건이 AND로 걸리는" 버그가
  /// 생기므로 매핑을 여기 한 곳에 둔다.
  Future<void> loadFirstPage({
    int? userId,
    CommunityCategoryTab tab = CommunityCategoryTab.total,
    CommunitySearchScope scope = CommunitySearchScope.titleContent,
    CommunitySortOption sort = CommunitySortOption.latest,
    String? query,
  }) async {
    _userId = userId;
    _categorySub = tab.categorySub;
    _sort = sort.sortParam;

    final trimmed = query?.trim();
    final keyword = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    _searchQuery = scope == CommunitySearchScope.titleContent ? keyword : null;
    _searchQueryUser = scope == CommunitySearchScope.author ? keyword : null;
    _searchQueryComment = scope == CommunitySearchScope.comment ? keyword : null;
    _appliedQuery.value = keyword ?? '';

    // gotoPage의 범위 가드에 막혀 1페이지 조회 자체가 안 나가는 것을 막는다.
    // (검색/필터로 결과 수가 줄어든 상태에서 특히 중요)
    _totalPages.value = 1;
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

  /// 에러 상태에서 "다시 시도"용.
  Future<void> retry() => gotoPage(_currentPage.value);

  /// Heroku 이코 dyno가 잠들어 있으면 첫 요청이 라우터 타임아웃에 걸려 실패로
  /// 돌아오는 경우가 있다(서버는 그 사이 깨어남). 실패 시 짧게 대기 후 한 번 더
  /// 시도해서 사용자가 다시 누르지 않아도 되게 한다.
  Future<void> _fetchWithRetry(int page, {int attempt = 0}) async {
    try {
      final response = await _api.fetchCommunityList(
        categoryMain: _categoryMain,
        categorySub: _categorySub,
        // 게스트(userId == null)면 파라미터를 아예 빼야 한다. int?에 .toString()을
        // 하면 문자열 "null"이 전송되어 서버가 파싱에 실패한다(모바일 VM의 기존 버그).
        userId: _userId?.toString(),
        searchQuery: _searchQuery,
        searchQueryUser: _searchQueryUser,
        searchQueryComment: _searchQueryComment,
        page: page,
        sort: _sort,
      );

      if (response.success) {
        final data = response.data as Map<String, dynamic>;
        _items.value = _parseResults(data['results']);
        _totalCount.value = (data['count'] ?? 0) as int;
        // 응답에 total_pages/current_page가 없어서 직접 계산한다.
        _totalPages.value = ((_totalCount.value + pageSize - 1) ~/ pageSize).clamp(1, 1 << 31);
        _currentPage.value = page;
        _hasError.value = false;
      } else if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        print('[Community] 목록 조회 실패: ${response.error}');
        _hasError.value = true;
      }
    } catch (e) {
      if (attempt < 1) {
        await Future.delayed(const Duration(seconds: 2));
        await _fetchWithRetry(page, attempt: attempt + 1);
      } else {
        print('[Community] 목록 조회 예외: $e');
        _hasError.value = true;
      }
    }
  }

  /// **글 하나씩** 파싱한다. CommunityListResponse.fromJson으로 한 번에 파싱하면
  /// description(Quill delta)이 깨진 글이 한 건만 있어도 페이지 전체가 실패한다.
  /// Community.fromJson은 delta가 빈 배열/빈 문자열/비JSON/JSON 객체일 때 각각
  /// ArgumentError·FormatException·TypeError를 던지고 방어 코드가 없다.
  /// 깨진 글은 건너뛰고 나머지를 보여준다.
  List<Community> _parseResults(Object? rawResults) {
    if (rawResults is! List) return [];
    final parsed = <Community>[];
    var skipped = 0;
    for (final raw in rawResults) {
      try {
        parsed.add(Community.fromJson(raw as Map<String, dynamic>));
      } catch (e) {
        skipped++;
        print('[Community] 글 파싱 건너뜀: $e');
      }
    }
    if (skipped > 0) print('[Community] 파싱 실패로 건너뛴 글 $skipped건');
    return parsed;
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
