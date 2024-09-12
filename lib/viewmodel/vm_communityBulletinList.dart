import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import '../api/api_community.dart';
import '../api/api_fleamarket.dart';
import '../model/m_communityList.dart';
import '../model/m_fleamarket.dart';

class CommunityBulletinListViewModel extends GetxController {

  var isLoading = true.obs;
  RxString _tapName = '게시판'.obs;
  RxString _chipName = '전체'.obs;
  var _communityList_total = <Community>[].obs;
  var _communityList_free = <Community>[].obs;
  var _communityList_room = <Community>[].obs;
  var _communityList_crew = <Community>[].obs;

  List<Community> get communityList_total => _communityList_total;
  List<Community> get communityList_free => _communityList_free;
  List<Community> get communityList_room => _communityList_room;
  List<Community> get communityList_crew => _communityList_crew;

  var _nextPageUrl_total = ''.obs;
  var _nextPageUrl_free = ''.obs;
  var _nextPageUrl_room = ''.obs;
  var _nextPageUrl_crew = ''.obs;

  var _previousPageUrl_total = ''.obs;
  var _previousPageUrl_free = ''.obs;
  var _previousPageUrl_room = ''.obs;
  var _previousPageUrl_crew = ''.obs;

  RxBool _showAddButton_total = true.obs;
  RxBool _showAddButton_free = true.obs;
  RxBool _showAddButton_room = true.obs;
  RxBool _showAddButton_crew = true.obs;

  RxBool _isVisible_total = false.obs;
  RxBool _isVisible_free = false.obs;
  RxBool _isVisible_room = false.obs;
  RxBool _isVisible_crew = false.obs;

  String get nextPageUrlTotal => _nextPageUrl_total.value;
  String get nextPageUrlFree => _nextPageUrl_free.value;
  String get nextPageUrlRoom => _nextPageUrl_room.value;
  String get nextPageUrlCrew => _nextPageUrl_crew.value;

  String get previousPageUrlTotal => _previousPageUrl_total.value;
  String get previousPageUrlFree => _previousPageUrl_free.value;
  String get previousPageUrlRoom => _previousPageUrl_room.value;
  String get previousPageUrlCrew => _previousPageUrl_crew.value;

  bool get showAddButton_total => _showAddButton_total.value;
  bool get showAddButton_free => _showAddButton_free.value;
  bool get showAddButton_room => _showAddButton_room.value;
  bool get showAddButton_crew => _showAddButton_crew.value;

  bool get isVisible_total  => _isVisible_total .value;
  bool get isVisible_free  => _isVisible_free .value;
  bool get isVisible_room  => _isVisible_room .value;
  bool get isVisible_crew  => _isVisible_crew .value;

  String get tapName => _tapName.value;
  String get chipName => _chipName.value;

  ScrollController scrollController_total = ScrollController();
  ScrollController scrollController_free = ScrollController();
  ScrollController scrollController_room = ScrollController();
  ScrollController scrollController_crew = ScrollController();

  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void onInit() async {
    super.onInit();
    await fetchCommunityList_total(userId: _userViewModel.user.user_id,categoryMain: '게시판');
    await fetchCommunityList_free(userId: _userViewModel.user.user_id, categoryMain:'게시판', categorySub: Community_Category_sub_bulletin.free.korean);
    await fetchCommunityList_room(userId: _userViewModel.user.user_id, categoryMain:'게시판',categorySub: Community_Category_sub_bulletin.room.korean);
    await fetchCommunityList_crew(userId: _userViewModel.user.user_id, categoryMain:'게시판',categorySub: Community_Category_sub_bulletin.crew.korean);

    scrollController_total = ScrollController()
      ..addListener(_scrollListener_total);
    scrollController_free = ScrollController()
      ..addListener(_scrollListener_free);
    scrollController_room = ScrollController()
      ..addListener(_scrollListener_room);
    scrollController_crew = ScrollController()
      ..addListener(_scrollListener_crew);

  }

  Future<void> _scrollListener_total() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_total.position.pixels == scrollController_total.position.maxScrollExtent) {
          if (_nextPageUrl_total.value.isNotEmpty) {
            await fetchNextPage_total();
      }
    }

    // 버튼 표시 여부 결정
    _showAddButton_total.value = scrollController_total.offset <= 0;

    // 숨김/표시 여부 결정
    if (scrollController_total.position.userScrollDirection == ScrollDirection.reverse) {
      _isVisible_total.value = true;
    } else if (scrollController_total.position.userScrollDirection == ScrollDirection.forward ||
        scrollController_total.position.pixels <= scrollController_total.position.maxScrollExtent) {
      _isVisible_total.value = false;
    }
  }
  Future<void> _scrollListener_free() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_free.position.pixels == scrollController_free.position.maxScrollExtent) {
      if (_nextPageUrl_free.value.isNotEmpty) {
        await fetchNextPage_free();
      }
    }

    // 버튼 표시 여부 결정
    _showAddButton_free.value = scrollController_free.offset <= 0;

    // 숨김/표시 여부 결정
    if (scrollController_free.position.userScrollDirection == ScrollDirection.reverse) {
      _isVisible_free.value = true;
    } else if (scrollController_free.position.userScrollDirection == ScrollDirection.forward ||
        scrollController_free.position.pixels <= scrollController_free.position.maxScrollExtent) {
      _isVisible_free.value = false;
    }
  }
  Future<void> _scrollListener_room() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_room.position.pixels == scrollController_room.position.maxScrollExtent) {
      if (_nextPageUrl_room.value.isNotEmpty) {
        await fetchNextPage_room();
      }
    }

    // 버튼 표시 여부 결정
    _showAddButton_room.value = scrollController_room.offset <= 0;

    // 숨김/표시 여부 결정
    if (scrollController_room.position.userScrollDirection == ScrollDirection.reverse) {
      _isVisible_room.value = true;
    } else if (scrollController_room.position.userScrollDirection == ScrollDirection.forward ||
        scrollController_room.position.pixels <= scrollController_room.position.maxScrollExtent) {
      _isVisible_room.value = false;
    }
  }
  Future<void> _scrollListener_crew() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_crew.position.pixels == scrollController_crew.position.maxScrollExtent) {
      if (_nextPageUrl_crew.value.isNotEmpty) {
        await fetchNextPage_crew();
      }
    }

    // 버튼 표시 여부 결정
    _showAddButton_crew.value = scrollController_crew.offset <= 0;

    // 숨김/표시 여부 결정
    if (scrollController_crew.position.userScrollDirection == ScrollDirection.reverse) {
      _isVisible_crew.value = true;
    } else if (scrollController_crew.position.userScrollDirection == ScrollDirection.forward ||
        scrollController_crew.position.pixels <= scrollController_crew.position.maxScrollExtent) {
      _isVisible_crew.value = false;
    }
  }

  // 커뮤니티 목록 불러오기
  Future<void> fetchCommunityList_total({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    int? userId,
    String? url,  // URL을 추가
  }) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().fetchCommunityList(
        categoryMain: categoryMain,
        categorySub: categorySub,
        categorySub2: categorySub2,
        findUserId: findUserId,
        searchQuery: searchQuery,
        userId: userId.toString(),
        url: url,  // URL을 전달
      );

      if (response.success) {
        final communityResponse = CommunityListResponse.fromJson(response.data!);

        if (url == null) {
          // 초기 호출일 경우
          _communityList_total.value = communityResponse.results ?? [];
        } else {
          // 페이지네이션일 경우
          _communityList_total.addAll(communityResponse.results ?? []);
        }

        _nextPageUrl_total.value = communityResponse.next ?? '';
        _previousPageUrl_total.value = communityResponse.previous ?? '';
      } else {
        print('Failed to load community list: ${response.error}');
      }
    } catch (e) {
      print('Error fetching community list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCommunityList_free({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    int? userId,
    String? url,  // URL을 추가
  }) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().fetchCommunityList(
        categoryMain: categoryMain,
        categorySub: categorySub,
        categorySub2: categorySub2,
        findUserId: findUserId,
        searchQuery: searchQuery,
        userId: userId.toString(),
        url: url,  // URL을 전달
      );

      if (response.success) {
        final communityResponse = CommunityListResponse.fromJson(response.data!);

        if (url == null) {
          // 초기 호출일 경우
          _communityList_free.value = communityResponse.results ?? [];
        } else {
          // 페이지네이션일 경우
          _communityList_free.addAll(communityResponse.results ?? []);
        }

        _nextPageUrl_free.value = communityResponse.next ?? '';
        _previousPageUrl_free.value = communityResponse.previous ?? '';
      } else {
        print('Failed to load community list: ${response.error}');
      }
    } catch (e) {
      print('Error fetching community list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCommunityList_room({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    int? userId,
    String? url,  // URL을 추가
  }) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().fetchCommunityList(
        categoryMain: categoryMain,
        categorySub: categorySub,
        categorySub2: categorySub2,
        findUserId: findUserId,
        searchQuery: searchQuery,
        userId: userId.toString(),
        url: url,  // URL을 전달
      );

      if (response.success) {
        final communityResponse = CommunityListResponse.fromJson(response.data!);

        if (url == null) {
          // 초기 호출일 경우
          _communityList_room.value = communityResponse.results ?? [];
        } else {
          // 페이지네이션일 경우
          _communityList_room.addAll(communityResponse.results ?? []);
        }

        _nextPageUrl_room.value = communityResponse.next ?? '';
        _previousPageUrl_room.value = communityResponse.previous ?? '';
      } else {
        print('Failed to load community list: ${response.error}');
      }
    } catch (e) {
      print('Error fetching community list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCommunityList_crew({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    int? userId,
    String? url,  // URL을 추가
  }) async {
    isLoading.value = true;
    try {
      final response = await CommunityAPI().fetchCommunityList(
        categoryMain: categoryMain,
        categorySub: categorySub,
        categorySub2: categorySub2,
        findUserId: findUserId,
        searchQuery: searchQuery,
        userId: userId.toString(),
        url: url,  // URL을 전달
      );

      if (response.success) {
        final communityResponse = CommunityListResponse.fromJson(response.data!);

        if (url == null) {
          // 초기 호출일 경우
          _communityList_crew.value = communityResponse.results ?? [];
        } else {
          // 페이지네이션일 경우
          _communityList_crew.addAll(communityResponse.results ?? []);
        }

        _nextPageUrl_crew.value = communityResponse.next ?? '';
        _previousPageUrl_crew.value = communityResponse.previous ?? '';
      } else {
        print('Failed to load community list: ${response.error}');
      }
    } catch (e) {
      print('Error fetching community list: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchNextPage_total() async{
    if (_nextPageUrl_total.value.isNotEmpty) {
      await fetchCommunityList_total(
        userId: _userViewModel.user.user_id,
          url: _nextPageUrl_total.value
      );
    }
  }

  Future<void> fetchNextPage_free() async{
    if (_nextPageUrl_free.value.isNotEmpty) {
      await fetchCommunityList_free(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_free.value
      );
    }
  }

  Future<void> fetchNextPage_room() async{
    if (_nextPageUrl_room.value.isNotEmpty) {
      await fetchCommunityList_room(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_room.value
      );
    }
  }

  Future<void> fetchNextPage_crew() async{
    if (_nextPageUrl_crew.value.isNotEmpty) {
      await fetchCommunityList_crew(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew.value
      );
    }
  }

  void changeTap(value) {
    _tapName.value = value;
  }

  void changeChip(value) {
    _chipName.value = value;
    print('칩네임 $_chipName로 변경');
  }

  Future<void> onRefresh_bulletin_total() async {
    await fetchCommunityList_total(userId:  _userViewModel.user.user_id);
  }
  Future<void> onRefresh_bulletin_free() async {
    await fetchCommunityList_free(userId:  _userViewModel.user.user_id);
  }
  Future<void> onRefresh_bulletin_room() async {
    await fetchCommunityList_room(userId:  _userViewModel.user.user_id);
  }
  Future<void> onRefresh_bulletin_crew() async {
    await fetchCommunityList_crew(userId:  _userViewModel.user.user_id);
  }
}


enum Community_Category_sub_bulletin {
  total("전체", "free"),
  free("자유", "free"),
  room("시즌방", "deck"),
  crew("단톡방·동호회", "binding");

  final String korean;
  final String english;
  const Community_Category_sub_bulletin(this.korean, this.english);
}

enum Community_Category_sub2_bulletin {
  search("방 구해요", "free"),
  rent("방 임대", "deck"),
  invest("주주모집", "binding");

  final String korean;
  final String english;
  const Community_Category_sub2_bulletin(this.korean, this.english);
}



