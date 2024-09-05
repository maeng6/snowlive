import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import '../api/api_fleamarket.dart';
import '../model/m_fleamarket.dart';

class FleamarketSearchViewModel extends GetxController {

  var isLoading = true.obs;
  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();



  var _fleamarketList_total = <Fleamarket>[].obs;
  var _nextPageUrl_total = ''.obs;
  var _previousPageUrl_total = ''.obs;
  RxBool _showAddButton = true.obs;
  RxBool _isVisible = false.obs;
  RxString _tapName = '전체'.obs;

  RxString _selectedCategory_sub_total = '전체 카테고리'.obs;
  RxString _selectedCategory_spot_total = '전체 거래장소'.obs;

  List<Fleamarket> get fleamarketListTotal => _fleamarketList_total;

  String get nextPageUrlTotal => _nextPageUrl_total.value;

  String get previousPageUrlTotal => _previousPageUrl_total.value;
  bool get showAddButton => _showAddButton.value;
  bool get isVisible => _isVisible.value;
  String get tapName => _tapName.value;

  String get selectedCategory_sub_total => _selectedCategory_sub_total.value;
  String get selectedCategory_spot_total => _selectedCategory_spot_total.value;

  ScrollController get scrollController => _scrollController;

  ScrollController _scrollController = ScrollController();

  final FleamarketAPI _fleamarketAPI = FleamarketAPI();

  @override
  void onInit() async {
    super.onInit();


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
          _fleamarketList_total.value = fleamarketResponse.results ?? [];
        } else {
          // For pagination
          _fleamarketList_total.addAll(fleamarketResponse.results ?? []);
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


}



