import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_fleamarket.dart';
import '../model/m_fleamarket.dart';

class FleamarketSearchViewModel extends GetxController {

  var isLoading = true.obs;
  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  RxList<String> _recentSearches = <String>[].obs;
  RxBool _isSearching = false.obs;
  var _fleamarketList_search = <Fleamarket>[].obs;
  var _nextPageUrl_total = ''.obs;
  var _previousPageUrl_total = ''.obs;
  RxBool _showAddButton = true.obs;
  RxBool _isVisible = false.obs;
  RxString _tapName = '전체'.obs;
  RxString _selectedCategory_sub_total = '전체 카테고리'.obs;
  RxString _selectedCategory_spot_total = '전체 거래장소'.obs;
  RxBool _showRecentSearch = true.obs;


  List<Fleamarket> get fleamarketListSearch => _fleamarketList_search;
  String get nextPageUrlTotal => _nextPageUrl_total.value;
  String get previousPageUrlTotal => _previousPageUrl_total.value;
  bool get showAddButton => _showAddButton.value;
  bool get isVisible => _isVisible.value;
  String get tapName => _tapName.value;
  String get selectedCategory_sub_total => _selectedCategory_sub_total.value;
  String get selectedCategory_spot_total => _selectedCategory_spot_total.value;
  ScrollController get scrollController => _scrollController;
  List<String> get recentSearches => _recentSearches;
  bool get isSearching => _isSearching.value;
  bool get showRecentSearch => _showRecentSearch.value;


  ScrollController _scrollController = ScrollController();

  final FleamarketAPI _fleamarketAPI = FleamarketAPI();

  @override
  void onInit() async {
    super.onInit();
    _loadRecentSearches();

    _scrollController = ScrollController()
      ..addListener(_scrollListener);

  }

  Future<void> _scrollListener() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_nextPageUrl_total.value.isNotEmpty) {
        await fetchFleamarketData_total(
            userId: _userViewModel.user.user_id,
            url: _nextPageUrl_total.value
        ); // 추가 데이터 로딩
      }
    }

    // 버튼 표시 여부 결정
    _showAddButton.value = _scrollController.offset <= 0;

    // 숨김/표시 여부 결정
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      _isVisible.value = true;
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward ||
        _scrollController.position.pixels <= _scrollController.position.maxScrollExtent) {
      _isVisible.value = false;
    }
  }

  Future<void> fetchFleamarketData_total({
    required int userId,
    String? categoryMain,
    String? categorySub,
    String? spot,
    bool? favorite_list,
    String? search_query,
    bool? myflea,
    String? url,
  }) async {
    isLoading(true);

    try {

      final response = await _fleamarketAPI.fetchFleamarketList(
          userId: userId,
          categoryMain: categoryMain,
          categorySub: categorySub,
          spot: spot,
          favorite_list: favorite_list,
          search_query: search_query,
          myflea: myflea,
          url: url
      );

      if (response.success) {
        final fleamarketResponse = FleamarketResponse.fromJson(response.data!);

        if (url == null) {
          // For initial fetch
          _fleamarketList_search.value = fleamarketResponse.results ?? [];
        } else {
          // For pagination
          _fleamarketList_search.addAll(fleamarketResponse.results ?? []);
        }

        _nextPageUrl_total.value = fleamarketResponse.next ?? '';
        _previousPageUrl_total.value = fleamarketResponse.previous ?? '';
      } else {
        // Handle error response
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
  }


  Future<void> fetchNextPage_total() async{
    if (_nextPageUrl_total.value.isNotEmpty) {
      await fetchFleamarketData_total(
        userId: _userViewModel.user.user_id,
          url: _nextPageUrl_total.value
      );
    }
  }


  Future<void> fetchPreviousPage_total() async{
    if (_previousPageUrl_total.value.isNotEmpty) {
      await fetchFleamarketData_total(
          userId: _userViewModel.user.user_id,
          url: _previousPageUrl_total.value
      );
    }
  }


  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches.value = prefs.getStringList('recentSearches') ?? [];
  }
  Future<void> saveRecentSearch(String searchQuery) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 기존 검색어 리스트 불러오기
    List<String> searches = prefs.getStringList('recentSearches') ?? [];

    // 중복 검색어 제거
    searches.remove(searchQuery);

    // 최신 검색어를 리스트의 맨 앞에 추가
    searches.insert(0, searchQuery);

    // 최대 10개의 검색어만 저장 (필요에 따라 조정)
    if (searches.length > 10) {
      searches = searches.sublist(0, 10);
    }

    // SharedPreferences에 저장
    await prefs.setStringList('recentSearches', searches);

    // 상태 반영
    _recentSearches.value = searches;
  }


  Future<void> deleteRecentSearch(String searchQuery) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    recentSearches.remove(searchQuery);
    await prefs.setStringList('recentSearches', recentSearches);
  }

  void search(String query) {
    if (query.isNotEmpty) {
      _isSearching.value = true;
      saveRecentSearch(query);
    }
  }

  Future<void> deleteAllRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    recentSearches.clear();
    await prefs.remove('recentSearches');
  }


  void changeShowRecentSearch() {
    _showRecentSearch.value = !_showRecentSearch.value;
  }


}



