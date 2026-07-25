import 'package:com.snowlive/core/api/api_fleamarket.dart';
import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:get/get.dart';

/// 웹 전용 페이지네이션 상태. core의 FleamarketListViewModel은 모바일 무한스크롤을 위해
/// 항상 리스트를 append하지만, 이 컨트롤러는 매 조회마다 리스트를 통째로 교체해서
/// 한 번에 한 페이지만 보여주는 웹 UX를 구현한다. FleamarketAPI를 직접 호출한다.
class FleamarketPaginationViewModelWeb extends GetxController {
  final FleamarketAPI _api = FleamarketAPI();

  final RxList<Fleamarket> _items = <Fleamarket>[].obs;
  final RxBool _isLoading = false.obs;
  String? _nextUrl;

  /// 지금까지 방문한 페이지의 조회 URL 스택(첫 페이지는 null). '‹'를 누르면 pop해서
  /// 바로 이전 페이지의 URL로 다시 조회한다.
  final List<String?> _urlStack = [null];

  List<Fleamarket> get items => _items;
  bool get isLoading => _isLoading.value;
  bool get hasNext => _nextUrl != null && _nextUrl!.isNotEmpty;
  bool get hasPrevious => _urlStack.length > 1;
  int get currentPage => _urlStack.length;

  @override
  void onInit() {
    super.onInit();
    loadFirstPage(userId: Get.find<UserViewModel>().user.user_id);
  }

  Future<void> loadFirstPage({
    int? userId,
    String? categoryMain,
    String? categorySub,
    String? spot,
    bool? favoriteList,
    bool? myflea,
    String? searchQuery,
  }) async {
    _urlStack
      ..clear()
      ..add(null);
    await _fetch(
      userId: userId,
      categoryMain: categoryMain,
      categorySub: categorySub,
      spot: spot,
      favoriteList: favoriteList,
      myflea: myflea,
      searchQuery: searchQuery,
      url: null,
    );
  }

  Future<void> loadNext() async {
    if (!hasNext) return;
    final url = _nextUrl!;
    await _fetch(url: url);
    _urlStack.add(url);
  }

  Future<void> loadPrevious() async {
    if (!hasPrevious) return;
    _urlStack.removeLast();
    await _fetch(url: _urlStack.last);
  }

  Future<void> _fetch({
    int? userId,
    String? categoryMain,
    String? categorySub,
    String? spot,
    bool? favoriteList,
    bool? myflea,
    String? searchQuery,
    String? url,
  }) async {
    _isLoading.value = true;
    try {
      final response = await _api.fetchFleamarketList(
        userId: userId,
        categoryMain: categoryMain,
        categorySub: categorySub,
        spot: spot,
        favorite_list: favoriteList,
        myflea: myflea,
        search_query: searchQuery,
        url: url,
      );
      if (response.success) {
        final parsed = FleamarketResponse.fromJson(response.data!);
        _items.value = parsed.results ?? [];
        _nextUrl = parsed.next;
      }
    } finally {
      _isLoading.value = false;
    }
  }
}
