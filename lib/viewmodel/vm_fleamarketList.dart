import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import '../api/api_fleamarket.dart';
import '../model/m_fleamarket.dart';

class FleamarketListViewModel extends GetxController {

  var isLoading = true.obs;
  var _fleamarketList_total = <Fleamarket>[].obs;
  var _fleamarketList_ski = <Fleamarket>[].obs;
  var _fleamarketList_board = <Fleamarket>[].obs;
  var _fleamarketList_my = <Fleamarket>[].obs;
  var _fleamarketList_favorite = <Fleamarket>[].obs;
  var _nextPageUrl_total = ''.obs;
  var _nextPageUrl_ski = ''.obs;
  var _nextPageUrl_board = ''.obs;
  var _nextPageUrl_my = ''.obs;
  var _nextPageUrl_favorite = ''.obs;
  var _previousPageUrl_total = ''.obs;
  var _previousPageUrl_ski = ''.obs;
  var _previousPageUrl_board = ''.obs;
  var _previousPageUrl_my = ''.obs;
  var _previousPageUrl_favorite = ''.obs;
  RxBool _showAddButton = true.obs;
  RxBool _isVisible = false.obs;
  RxString _tapName = '전체'.obs;

  RxString _selectedCategory_sub_total = '전체 카테고리'.obs;
  RxString _selectedCategory_spot_total = '전체 거래장소'.obs;
  RxString _selectedCategory_sub_ski = '전체 카테고리'.obs;
  RxString _selectedCategory_spot_ski = '전체 거래장소'.obs;
  RxString _selectedCategory_sub_board = '전체 카테고리'.obs;
  RxString _selectedCategory_spot_board = '전체 거래장소'.obs;

  List<Fleamarket> get fleamarketListTotal => _fleamarketList_total;
  List<Fleamarket> get fleamarketListSki => _fleamarketList_ski;
  List<Fleamarket> get fleamarketListBoard => _fleamarketList_board;
  List<Fleamarket> get fleamarketListMy => _fleamarketList_my;
  List<Fleamarket> get fleamarketListFavorite => _fleamarketList_favorite;

  String get nextPageUrlTotal => _nextPageUrl_total.value;
  String get nextPageUrlSki => _nextPageUrl_ski.value;
  String get nextPageUrlBoard => _nextPageUrl_board.value;
  String get nextPageUrlMy => _nextPageUrl_my.value;
  String get nextPageUrlFavorite => _nextPageUrl_favorite.value;

  String get previousPageUrlTotal => _previousPageUrl_total.value;
  String get previousPageUrlSki => _previousPageUrl_ski.value;
  String get previousPageUrlBoard => _previousPageUrl_board.value;
  String get previousPageUrlMy => _previousPageUrl_my.value;
  String get previousPageUrlFavorite => _previousPageUrl_favorite.value;
  bool get showAddButton => _showAddButton.value;
  bool get isVisible => _isVisible.value;
  String get tapName => _tapName.value;

  String get selectedCategory_sub_total => _selectedCategory_sub_total.value;
  String get selectedCategory_spot_total => _selectedCategory_spot_total.value;
  String get selectedCategory_sub_ski => _selectedCategory_sub_ski.value;
  String get selectedCategory_spot_ski => _selectedCategory_spot_ski.value;
  String get selectedCategory_sub_board => _selectedCategory_sub_board.value;
  String get selectedCategory_spot_board => _selectedCategory_spot_board.value;

  ScrollController get scrollController => _scrollController;

  ScrollController _scrollController = ScrollController();

  final FleamarketAPI _fleamarketAPI = FleamarketAPI();

  UserViewModel _userViewModel = Get.find<UserViewModel>();


  @override
  void onInit() async {
    super.onInit();
    await fetchFleamarketData_total(userId: _userViewModel.user.user_id);
    await fetchFleamarketData_ski(userId: _userViewModel.user.user_id, categoryMain:'스키');
    await fetchFleamarketData_board(userId: _userViewModel.user.user_id, categoryMain:'스노보드');
    await fetchFleamarketData_my(userId: _userViewModel.user.user_id, myflea: true);
    await fetchFleamarketData_favorite(userId: _userViewModel.user.user_id, favorite_list: true);

    _scrollController = ScrollController()
      ..addListener(_scrollListener);

  }

  Future<void> _scrollListener() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      switch (_tapName.value) {
        case '전체':
          if (_nextPageUrl_total.value.isNotEmpty) {
            await fetchNextPage_total();
          }
          break;
        case '스키':
          if (_nextPageUrl_ski.value.isNotEmpty) {
            await fetchNextPage_ski();
          }
          break;
        case '스노보드':
          if (_nextPageUrl_board.value.isNotEmpty) {
            await fetchNextPage_board();
          }
          break;
        case '내 게시글':
          if (_nextPageUrl_my.value.isNotEmpty) {
            await fetchNextPage_my();
          }
          break;
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

  Future<void> fetchFleamarketData_ski({
    required int userId,
    String? categoryMain = '스키',
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
          _fleamarketList_ski.value = fleamarketResponse.results ?? [];
        } else {
          // For pagination
          _fleamarketList_ski.addAll(fleamarketResponse.results ?? []);
        }

        _nextPageUrl_ski.value = fleamarketResponse.next ?? '';
        _previousPageUrl_ski.value = fleamarketResponse.previous ?? '';
      } else {
        // Handle error response
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
    //_scrollController.jumpTo(0);
  }

  Future<void> fetchFleamarketData_board({
    required int userId,
    String? categoryMain = '스노보드',
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
          _fleamarketList_board.value = fleamarketResponse.results ?? [];
        } else {
          // For pagination
          _fleamarketList_board.addAll(fleamarketResponse.results ?? []);
        }

        _nextPageUrl_board.value = fleamarketResponse.next ?? '';
        _previousPageUrl_board.value = fleamarketResponse.previous ?? '';
      } else {
        // Handle error response
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
    //_scrollController.jumpTo(0);
  }

  Future<void> fetchFleamarketData_favorite({
    required int userId,
    String? categoryMain,
    String? categorySub,
    String? spot,
    bool? favorite_list = true,
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
          _fleamarketList_favorite.value = fleamarketResponse.results ?? [];
        } else {
          // For pagination
          _fleamarketList_favorite.addAll(fleamarketResponse.results ?? []);
        }

        _nextPageUrl_favorite.value = fleamarketResponse.next ?? '';
        _previousPageUrl_favorite.value = fleamarketResponse.previous ?? '';
      } else {
        // Handle error response
        print('Failed to load data: ${response.error}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading(false);
    }
    //_scrollController.jumpTo(0);
  }

  Future<void> fetchFleamarketData_my({
    required int userId,
    String? categoryMain,
    String? categorySub,
    String? spot,
    bool? favorite_list,
    String? search_query,
    bool? myflea = true,
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
          _fleamarketList_my.value = fleamarketResponse.results ?? [];
        } else {
          // For pagination
          _fleamarketList_my.addAll(fleamarketResponse.results ?? []);
        }

        _nextPageUrl_my.value = fleamarketResponse.next ?? '';
        _previousPageUrl_my.value = fleamarketResponse.previous ?? '';
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

  Future<void> fetchNextPage_ski() async{
    if (_nextPageUrl_ski.value.isNotEmpty) {
      await fetchFleamarketData_ski(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_ski.value
      );
    }
  }

  Future<void> fetchNextPage_board() async{
    if (_nextPageUrl_board.value.isNotEmpty) {
      await fetchFleamarketData_board(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_board.value
      );
    }
  }

  Future<void> fetchNextPage_my() async{
    if (_nextPageUrl_my.value.isNotEmpty) {
      await fetchFleamarketData_my(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_my.value
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

  Future<void> fetchPreviousPage_ski() async{
    if (_previousPageUrl_ski.value.isNotEmpty) {
      await fetchFleamarketData_ski(
          userId: _userViewModel.user.user_id,
          url: _previousPageUrl_ski.value
      );
    }
  }

  Future<void> fetchPreviousPage_board() async{
    if (_previousPageUrl_board.value.isNotEmpty) {
      await fetchFleamarketData_board(
          userId: _userViewModel.user.user_id,
          url: _previousPageUrl_board.value
      );
    }
  }

  Future<void> fetchPreviousPage_my() async{
    if (_previousPageUrl_my.value.isNotEmpty) {
      await fetchFleamarketData_my(
          userId: _userViewModel.user.user_id,
          url: _previousPageUrl_my.value
      );
    }
  }

  void changeTap(value) {
    _tapName.value = value;
  }

  void changeCategory_sub_total(value) {
    _selectedCategory_sub_total.value = value;
  }

  void changeCategory_sub_ski(value) {
    _selectedCategory_sub_ski.value = value;
  }

  void changeCategory_sub_board(value) {
    _selectedCategory_sub_board.value = value;
  }

  void changeCategory_spot_total(value) {
    _selectedCategory_spot_total.value = value;
  }

  void changeCategory_spot_ski(value) {
    _selectedCategory_spot_ski.value = value;
  }

  void changeCategory_spot_board(value) {
    _selectedCategory_spot_board.value = value;
  }

  Future<void> onRefresh_flea_total() async {
    await fetchFleamarketData_total(userId:  _userViewModel.user.user_id);
  }
  Future<void> onRefresh_flea_ski() async {
    await fetchFleamarketData_ski(userId:  _userViewModel.user.user_id);
  }
  Future<void> onRefresh_flea_board() async {
    await fetchFleamarketData_board(userId:  _userViewModel.user.user_id);
  }
  Future<void> onRefresh_flea_favorite() async {
    await fetchFleamarketData_favorite(userId:  _userViewModel.user.user_id);
  }
  Future<void> onRefresh_flea_my() async {
    await fetchFleamarketData_my(userId:  _userViewModel.user.user_id);
  }
}


enum FleamarketCategory_sub {
  total("전체 카테고리", "total"),
  deck("데크", "deck"),
  binding("바인딩", "binding"),
  boots("부츠","boots"),
  cloth("의류","cloth"),
  plate("플레이트","plate"),
  etc("기타","etc");

  final String korean;
  final String english;
  const FleamarketCategory_sub(this.korean, this.english);
}

enum FleamarketCategory_spot {
  total("전체 거래장소", "total"),
  konjiam("곤지암리조트", ""),
  muju("무주덕유산리조트", ""),
  vivaldi("비발디파크",""),
  alphen("알펜시아",""),
  gangchon("엘리시안강촌",""),
  oak("오크밸리리조트",""),
  o2("오투리조트",""),
  yongpyong("용평리조트",""),
  welli("웰리힐리파크",""),
  jisan("지산리조트",""),
  high1("하이원리조트",""),
  phoenix("휘닉스파크",""),
  etc("기타","");

  final String korean;
  final String english;
  const FleamarketCategory_spot(this.korean, this.english);
}

enum FleamarketStatus {
  soldOut("거래완료", ""),
  forSale("거래가능", ""),
  onBooking("예약중", "");

  final String korean;
  final String english;
  const FleamarketStatus(this.korean, this.english);
}

