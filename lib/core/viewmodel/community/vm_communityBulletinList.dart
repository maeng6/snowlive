import 'package:com.snowlive/core/api/api_community.dart';
import 'package:com.snowlive/core/model/m_communityList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/core/viewmodel/liveTalk/vm_liveTalk.dart';
// [이벤트·소식 탭 비활성화] import 'package:com.snowlive/viewmodel/vm_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class CommunityBulletinListViewModel extends GetxController {

  var isLoading = true.obs;
  RxString _tapName = '라이브톡'.obs;
  RxString _chipName = '전체'.obs;
  var _communityList_total = <Community>[].obs;
  var _communityList_free = <Community>[].obs;
  var _communityList_room = <Community>[].obs;
  var _communityList_crew = <Community>[].obs;
  // [이벤트·소식 탭 비활성화] var _communityList_event = <Community>[].obs;

  List<Community> get communityList_total => _communityList_total;
  List<Community> get communityList_free => _communityList_free;
  List<Community> get communityList_room => _communityList_room;
  List<Community> get communityList_crew => _communityList_crew;
  // [이벤트·소식 탭 비활성화] List<Community> get communityList_event => _communityList_event;

  var _nextPageUrl_total = ''.obs;
  var _nextPageUrl_free = ''.obs;
  var _nextPageUrl_room = ''.obs;
  var _nextPageUrl_crew = ''.obs;
  // [이벤트·소식 탭 비활성화] var _nextPageUrl_event = ''.obs;

  var _previousPageUrl_total = ''.obs;
  var _previousPageUrl_free = ''.obs;
  var _previousPageUrl_room = ''.obs;
  var _previousPageUrl_crew = ''.obs;
  // [이벤트·소식 탭 비활성화] var _previousPageUrl_event = ''.obs;

  RxBool _showAddButton_total = true.obs;
  RxBool _showAddButton_free = true.obs;
  RxBool _showAddButton_room = true.obs;
  RxBool _showAddButton_crew = true.obs;
  // [이벤트·소식 탭 비활성화] RxBool _showAddButton_event = true.obs;

  RxBool _isVisible_total = false.obs;
  RxBool _isVisible_free = false.obs;
  RxBool _isVisible_room = false.obs;
  RxBool _isVisible_crew = false.obs;
  // [이벤트·소식 탭 비활성화] RxBool _isVisible_event = false.obs;

  // 카테고리 칩 영역 표시/숨김 상태
  RxBool _showCategoryChips = true.obs;

  RxBool _isLoadingList_total = false.obs;
  RxBool _isLoadingList_free = false.obs;
  RxBool _isLoadingList_room = false.obs;
  RxBool _isLoadingList_crew = false.obs;
  // [이벤트·소식 탭 비활성화] RxBool _isLoadingList_event = false.obs;

  RxBool _isLoadingNextList_total = false.obs;
  RxBool _isLoadingNextList_free = false.obs;
  RxBool _isLoadingNextList_room = false.obs;
  RxBool _isLoadingNextList_crew = false.obs;
  // [이벤트·소식 탭 비활성화] RxBool _isLoadingNextList_event = false.obs;

  String get nextPageUrlTotal => _nextPageUrl_total.value;
  String get nextPageUrlFree => _nextPageUrl_free.value;
  String get nextPageUrlRoom => _nextPageUrl_room.value;
  String get nextPageUrlCrew => _nextPageUrl_crew.value;
  // [이벤트·소식 탭 비활성화] String get nextPageUrlEvent => _nextPageUrl_event.value;

  String get previousPageUrlTotal => _previousPageUrl_total.value;
  String get previousPageUrlFree => _previousPageUrl_free.value;
  String get previousPageUrlRoom => _previousPageUrl_room.value;
  String get previousPageUrlCrew => _previousPageUrl_crew.value;
  // [이벤트·소식 탭 비활성화] String get previousPageUrlEvent => _previousPageUrl_event.value;

  bool get showAddButton_total => _showAddButton_total.value;
  bool get showAddButton_free => _showAddButton_free.value;
  bool get showAddButton_room => _showAddButton_room.value;
  bool get showAddButton_crew => _showAddButton_crew.value;
  // [이벤트·소식 탭 비활성화] bool get showAddButton_event => _showAddButton_event.value;

  bool get isVisible_total  => _isVisible_total .value;
  bool get isVisible_free  => _isVisible_free .value;
  bool get isVisible_room  => _isVisible_room .value;
  bool get isVisible_crew  => _isVisible_crew .value;
  // [이벤트·소식 탭 비활성화] bool get isVisible_event  => _isVisible_event .value;

  bool get showCategoryChips => _showCategoryChips.value;

  bool get isLoadingList_total => _isLoadingList_total .value;
  bool get isLoadingList_free  => _isLoadingList_free .value;
  bool get isLoadingList_room  => _isLoadingList_room .value;
  bool get isLoadingList_crew  => _isLoadingList_crew .value;
  // [이벤트·소식 탭 비활성화] bool get isLoadingList_event  => _isLoadingList_event .value;

  bool get isLoadingNextList_total => _isLoadingNextList_total .value;
  bool get isLoadingNextList_free  => _isLoadingNextList_free .value;
  bool get isLoadingNextList_room  => _isLoadingNextList_room .value;
  bool get isLoadingNextList_crew  => _isLoadingNextList_crew .value;
  // [이벤트·소식 탭 비활성화] bool get isLoadingNextList_event  => _isLoadingNextList_event .value;

  String get tapName => _tapName.value;
  String get chipName => _chipName.value;

  ScrollController scrollController_total = ScrollController();
  ScrollController scrollController_free = ScrollController();
  ScrollController scrollController_room = ScrollController();
  ScrollController scrollController_crew = ScrollController();
  // [이벤트·소식 탭 비활성화] ScrollController scrollController_event = ScrollController();

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  // bindings.dart에서 먼저 등록되므로 직접 find 사용
  LiveTalkViewModel get _liveTalkViewModel => Get.find<LiveTalkViewModel>();
  // [이벤트·소식 탭 비활성화] EventViewModel get _eventViewModel => Get.find<EventViewModel>();

  @override
  void onInit() async {
    super.onInit();
    // 스크롤 리스너를 먼저 추가 (기존 컨트롤러에)
    scrollController_total.addListener(_scrollListener_total);
    scrollController_free.addListener(_scrollListener_free);
    scrollController_room.addListener(_scrollListener_room);
    scrollController_crew.addListener(_scrollListener_crew);
    // [이벤트·소식 탭 비활성화] scrollController_event.addListener(_scrollListener_event);

    await fetchAllCommunity();
  }

  Future<void> fetchAllCommunity() async{
    _isLoadingList_total.value = true;
    _isLoadingList_free.value = true;
    _isLoadingList_room.value = true;
    _isLoadingList_crew.value = true;
    // [이벤트·소식 탭 비활성화] _isLoadingList_event.value = true;

    // 라이브톡 데이터 먼저 로딩 (게시판과 병렬로)
    final liveTalkFuture = _liveTalkViewModel.fetchLiveTalkList(refresh: true);
    // [이벤트·소식 탭 비활성화] final eventFuture = _eventViewModel.fetchEventList();

    // 게시판 데이터 로딩
    await fetchCommunityList_total(userId: _userViewModel.user.user_id,categoryMain: '게시판');
    _isLoadingList_total.value = false;
    await fetchCommunityList_free(userId: _userViewModel.user.user_id, categoryMain:'게시판', categorySub: Community_Category_sub_bulletin.chat.korean);
    _isLoadingList_free.value = false;
    await fetchCommunityList_room(userId: _userViewModel.user.user_id, categoryMain:'게시판',categorySub: Community_Category_sub_bulletin.room.korean);
    _isLoadingList_room.value = false;
    await fetchCommunityList_crew(userId: _userViewModel.user.user_id, categoryMain:'게시판',categorySub: Community_Category_sub_bulletin.crew.korean);
    _isLoadingList_crew.value = false;
    // [이벤트·소식 탭 비활성화] await fetchCommunityList_event(userId: _userViewModel.user.user_id, categoryMain:'이벤트');
    // [이벤트·소식 탭 비활성화] _isLoadingList_event.value = false;

    // 라이브톡 로딩 완료 대기
    await liveTalkFuture;
    // [이벤트·소식 탭 비활성화] await eventFuture;
  }


  // [이벤트·소식 탭 비활성화]
  // Future<void> fetchEventCommunity() async{
  //   _isLoadingList_event.value = true;
  //   await fetchCommunityList_event(userId: _userViewModel.user.user_id, categoryMain:'이벤트');
  //   _isLoadingList_event.value = false;
  // }

  Future<void> _scrollListener_total() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_total.position.pixels == scrollController_total.position.maxScrollExtent) {
      if (!_isLoadingNextList_total.value && _nextPageUrl_total.value.isNotEmpty) {
        _isLoadingNextList_total.value = true;
        await fetchNextPage_total();
        _isLoadingNextList_total.value = false;
      }
    }

    // 버튼 표시 여부 결정
    _showAddButton_total.value = scrollController_total.offset <= 0;

    // 스크롤이 최상단에 가까우면 항상 칩 표시
    if (scrollController_total.offset <= 10) {
      _isVisible_total.value = false;
      _showCategoryChips.value = true;
      return;
    }

    // 숨김/표시 여부 결정
    if (scrollController_total.position.userScrollDirection == ScrollDirection.reverse) {
      _isVisible_total.value = true;
      _showCategoryChips.value = false; // 스크롤 올릴 때 (컨텐츠 아래로) 숨김
    } else if (scrollController_total.position.userScrollDirection == ScrollDirection.forward) {
      _isVisible_total.value = false;
      _showCategoryChips.value = true; // 스크롤 내릴 때 (컨텐츠 위로) 표시
    }
  }

  Future<void> _scrollListener_free() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_free.position.pixels == scrollController_free.position.maxScrollExtent) {
      if (!_isLoadingNextList_free.value && _nextPageUrl_free.value.isNotEmpty) {
        _isLoadingNextList_free.value = true;
        await fetchNextPage_free();
        _isLoadingNextList_free.value = false;
      }
    }

    // 버튼 표시 여부 결정
    _showAddButton_free.value = scrollController_free.offset <= 0;

    // 스크롤이 최상단에 가까우면 항상 칩 표시
    if (scrollController_free.offset <= 10) {
      _isVisible_free.value = false;
      _showCategoryChips.value = true;
      return;
    }

    // 숨김/표시 여부 결정
    if (scrollController_free.position.userScrollDirection == ScrollDirection.reverse) {
      _isVisible_free.value = true;
      _showCategoryChips.value = false;
    } else if (scrollController_free.position.userScrollDirection == ScrollDirection.forward) {
      _isVisible_free.value = false;
      _showCategoryChips.value = true;
    }
  }

  Future<void> _scrollListener_room() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_room.position.pixels == scrollController_room.position.maxScrollExtent) {
      if (!_isLoadingNextList_room.value && _nextPageUrl_room.value.isNotEmpty) {
        _isLoadingNextList_room.value = true;
        await fetchNextPage_room();
        _isLoadingNextList_room.value = false;
      }
    }

    // 버튼 표시 여부 결정
    _showAddButton_room.value = scrollController_room.offset <= 0;

    // 스크롤이 최상단에 가까우면 항상 칩 표시
    if (scrollController_room.offset <= 10) {
      _isVisible_room.value = false;
      _showCategoryChips.value = true;
      return;
    }

    // 숨김/표시 여부 결정
    if (scrollController_room.position.userScrollDirection == ScrollDirection.reverse) {
      _isVisible_room.value = true;
      _showCategoryChips.value = false;
    } else if (scrollController_room.position.userScrollDirection == ScrollDirection.forward) {
      _isVisible_room.value = false;
      _showCategoryChips.value = true;
    }
  }

  Future<void> _scrollListener_crew() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_crew.position.pixels == scrollController_crew.position.maxScrollExtent) {
      if (!_isLoadingNextList_crew.value && _nextPageUrl_crew.value.isNotEmpty) {
        _isLoadingNextList_crew.value = true;
        await fetchNextPage_crew();
        _isLoadingNextList_crew.value = false;
      }
    }

    // 버튼 표시 여부 결정
    _showAddButton_crew.value = scrollController_crew.offset <= 0;

    // 스크롤이 최상단에 가까우면 항상 칩 표시
    if (scrollController_crew.offset <= 10) {
      _isVisible_crew.value = false;
      _showCategoryChips.value = true;
      return;
    }

    // 숨김/표시 여부 결정
    if (scrollController_crew.position.userScrollDirection == ScrollDirection.reverse) {
      _isVisible_crew.value = true;
      _showCategoryChips.value = false;
    } else if (scrollController_crew.position.userScrollDirection == ScrollDirection.forward) {
      _isVisible_crew.value = false;
      _showCategoryChips.value = true;
    }
  }

  // [이벤트·소식 탭 비활성화]
  // Future<void> _scrollListener_event() async {
  //   // 스크롤이 리스트의 끝에 도달했을 때
  //   if (scrollController_event.position.pixels == scrollController_event.position.maxScrollExtent) {
  //     if (!_isLoadingNextList_event.value && _nextPageUrl_event.value.isNotEmpty) {
  //       _isLoadingNextList_event.value = true;
  //       await fetchNextPage_event();
  //       _isLoadingNextList_event.value = true;
  //     }
  //   }
  //
  //   // 버튼 표시 여부 결정
  //   _showAddButton_event.value = scrollController_event.offset <= 0;
  //
  //   // 숨김/표시 여부 결정
  //   if (scrollController_event.position.userScrollDirection == ScrollDirection.reverse) {
  //     _isVisible_event.value = true;
  //   } else if (scrollController_event.position.userScrollDirection == ScrollDirection.forward ||
  //       scrollController_event.position.pixels <= scrollController_event.position.maxScrollExtent) {
  //     _isVisible_event.value = false;
  //   }
  // }

  // 커뮤니티 목록 불러오기
  Future<void> fetchCommunityList_total({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    String? searchQueryComment,
    String? searchQueryUser,
    String? sort,
    int? userId,
    String? url,  // URL을 추가
  }) async {
    try {
      final response = await CommunityAPI().fetchCommunityList(
        categoryMain: categoryMain,
        categorySub: categorySub,
        categorySub2: categorySub2,
        findUserId: findUserId,
        searchQuery: searchQuery,
        searchQueryComment: searchQueryComment,
        searchQueryUser: searchQueryUser,
        sort: sort,
        userId: userId?.toString(),  // 게스트(null)면 user_id 미전송
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
    }
  }

  Future<void> fetchCommunityList_free({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    String? searchQueryComment,
    String? searchQueryUser,
    String? sort,
    int? userId,
    String? url,  // URL을 추가
  }) async {
    try {
      final response = await CommunityAPI().fetchCommunityList(
        categoryMain: categoryMain,
        categorySub: categorySub,
        categorySub2: categorySub2,
        findUserId: findUserId,
        searchQuery: searchQuery,
        searchQueryComment: searchQueryComment,
        searchQueryUser: searchQueryUser,
        sort: sort,
        userId: userId?.toString(),  // 게스트(null)면 user_id 미전송
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
    }
  }

  Future<void> fetchCommunityList_room({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    String? searchQueryComment,
    String? searchQueryUser,
    String? sort,
    int? userId,
    String? url,  // URL을 추가
  }) async {
    try {
      final response = await CommunityAPI().fetchCommunityList(
        categoryMain: categoryMain,
        categorySub: categorySub,
        categorySub2: categorySub2,
        findUserId: findUserId,
        searchQuery: searchQuery,
        searchQueryComment: searchQueryComment,
        searchQueryUser: searchQueryUser,
        sort: sort,
        userId: userId?.toString(),  // 게스트(null)면 user_id 미전송
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
    }
  }

  Future<void> fetchCommunityList_crew({
    String? categoryMain,
    String? categorySub,
    String? categorySub2,
    String? findUserId,
    String? searchQuery,
    String? searchQueryComment,
    String? searchQueryUser,
    String? sort,
    int? userId,
    String? url,  // URL을 추가
  }) async {
    try {
      final response = await CommunityAPI().fetchCommunityList(
        categoryMain: categoryMain,
        categorySub: categorySub,
        categorySub2: categorySub2,
        findUserId: findUserId,
        searchQuery: searchQuery,
        searchQueryComment: searchQueryComment,
        searchQueryUser: searchQueryUser,
        sort: sort,
        userId: userId?.toString(),  // 게스트(null)면 user_id 미전송
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
    }
  }

  // [이벤트·소식 탭 비활성화]
  // Future<void> fetchCommunityList_event({
  //   String? categoryMain,
  //   String? categorySub,
  //   String? categorySub2,
  //   String? findUserId,
  //   String? searchQuery,
  //   int? userId,
  //   String? url,
  // }) async {
  //   try {
  //     final response = await CommunityAPI().fetchCommunityList(
  //       categoryMain: categoryMain,
  //       categorySub: categorySub,
  //       categorySub2: categorySub2,
  //       findUserId: findUserId,
  //       searchQuery: searchQuery,
  //       userId: userId.toString(),
  //       url: url,
  //     );
  //
  //     if (response.success) {
  //       final communityResponse = CommunityListResponse.fromJson(response.data!);
  //       print('이벤트완료');
  //
  //       if (url == null) {
  //         _communityList_event.value = communityResponse.results ?? [];
  //       } else {
  //         _communityList_event.addAll(communityResponse.results ?? []);
  //       }
  //
  //       _nextPageUrl_event.value = communityResponse.next ?? '';
  //       _previousPageUrl_event.value = communityResponse.previous ?? '';
  //     } else {
  //       print('Failed to load community list: ${response.error}');
  //     }
  //   } catch (e) {
  //     print('Error fetching community list: $e');
  //   } finally {
  //   }
  // }


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

  // [이벤트·소식 탭 비활성화]
  // Future<void> fetchNextPage_event() async{
  //   if (_nextPageUrl_event.value.isNotEmpty) {
  //     await fetchCommunityList_event(
  //         userId: _userViewModel.user.user_id,
  //         url: _nextPageUrl_event.value
  //     );
  //   }
  // }

  void changeTap(value) {
    _tapName.value = value;
    _showCategoryChips.value = true; // 탭 변경 시 카테고리 칩 표시
  }

  void changeChip(value) {
    _chipName.value = value;
    _showCategoryChips.value = true; // 칩 변경 시 카테고리 칩 표시
    print('칩네임 $_chipName로 변경');
  }

  /// 커뮤니티 탭으로 돌아왔을 때 스크롤 위치에 따라 칩 표시 상태 업데이트
  void updateChipsVisibility() {
    try {
      double currentOffset = 0;

      if (_tapName.value == '게시판') {
        switch (_chipName.value) {
          case '전체':
            if (scrollController_total.hasClients) {
              currentOffset = scrollController_total.offset;
            }
            break;
          case '잡담':
            if (scrollController_free.hasClients) {
              currentOffset = scrollController_free.offset;
            }
            break;
          case '시즌방':
            if (scrollController_room.hasClients) {
              currentOffset = scrollController_room.offset;
            }
            break;
          case '단톡방·동호회':
            if (scrollController_crew.hasClients) {
              currentOffset = scrollController_crew.offset;
            }
            break;
        }
      }
      // [이벤트·소식 탭 비활성화]
      // else if (_tapName.value == '이벤트·소식') {
      //   if (scrollController_event.hasClients) {
      //     currentOffset = scrollController_event.offset;
      //   }
      // }

      // 스크롤이 최상단에 가까우면 칩 표시
      if (currentOffset <= 10) {
        _showCategoryChips.value = true;
      }
    } catch (e) {
      print('updateChipsVisibility error: $e');
    }
  }

  /// 현재 탭의 스크롤을 최상단으로 이동
  void scrollToTop() {
    try {
      if (_tapName.value == '게시판') {
        switch (_chipName.value) {
          case '전체':
            if (scrollController_total.hasClients) {
              scrollController_total.animateTo(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
            break;
          case '잡담':
            if (scrollController_free.hasClients) {
              scrollController_free.animateTo(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
            break;
          case '시즌방':
            if (scrollController_room.hasClients) {
              scrollController_room.animateTo(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
            break;
          case '단톡방·동호회':
            if (scrollController_crew.hasClients) {
              scrollController_crew.animateTo(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
            break;
        }
      }
      // [이벤트·소식 탭 비활성화]
      // else if (_tapName.value == '이벤트·소식') {
      //   if (scrollController_event.hasClients) {
      //     scrollController_event.animateTo(
      //       0,
      //       duration: Duration(milliseconds: 300),
      //       curve: Curves.easeOut,
      //     );
      //   }
      // }
      _showCategoryChips.value = true; // 스크롤 최상단 이동 시 카테고리 칩 표시
    } catch (e) {
      print('scrollToTop error: $e');
    }
  }

  // 카테고리 칩 표시/숨김 설정 (외부 호출용)
  void setCategoryChipsVisible(bool visible) {
    _showCategoryChips.value = visible;
  }

  Future<void> onRefresh_bulletin_total() async {
    await fetchCommunityList_total(userId:  _userViewModel.user.user_id,categoryMain: '게시판');
    fetchCommunityList_free(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.chat.korean);
    fetchCommunityList_room(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.room.korean);
    fetchCommunityList_crew(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.crew.korean);
    // [이벤트·소식 탭 비활성화] fetchCommunityList_event(userId:  _userViewModel.user.user_id,categoryMain: '이벤트');
  }
  Future<void> onRefresh_bulletin_free() async {
    await fetchCommunityList_free(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.chat.korean);
    fetchCommunityList_total(userId:  _userViewModel.user.user_id,categoryMain: '게시판');
    fetchCommunityList_room(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.room.korean);
    fetchCommunityList_crew(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.crew.korean);
    // [이벤트·소식 탭 비활성화] fetchCommunityList_event(userId:  _userViewModel.user.user_id,categoryMain: '이벤트');
  }
  Future<void> onRefresh_bulletin_room() async {
    await fetchCommunityList_room(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.room.korean);
    fetchCommunityList_total(userId:  _userViewModel.user.user_id,categoryMain: '게시판');
    fetchCommunityList_free(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.chat.korean);
    fetchCommunityList_crew(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.crew.korean);
    // [이벤트·소식 탭 비활성화] fetchCommunityList_event(userId:  _userViewModel.user.user_id,categoryMain: '이벤트');
  }
  Future<void> onRefresh_bulletin_crew() async {
    await fetchCommunityList_crew(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.crew.korean);
    fetchCommunityList_total(userId:  _userViewModel.user.user_id,categoryMain: '게시판');
    fetchCommunityList_free(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.chat.korean);
    fetchCommunityList_room(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.room.korean);
    // [이벤트·소식 탭 비활성화] fetchCommunityList_event(userId:  _userViewModel.user.user_id,categoryMain: '이벤트');
  }
  // [이벤트·소식 탭 비활성화]
  // Future<void> onRefresh_bulletin_event() async {
  //   await fetchCommunityList_event(userId:  _userViewModel.user.user_id,categoryMain: '이벤트');
  //   fetchCommunityList_total(userId:  _userViewModel.user.user_id,categoryMain: '게시판');
  //   fetchCommunityList_free(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.chat.korean);
  //   fetchCommunityList_room(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.room.korean);
  //   fetchCommunityList_crew(userId:  _userViewModel.user.user_id,categoryMain: '게시판',categorySub: Community_Category_sub_bulletin.crew.korean);
  // }

  @override
  void onClose() {
    // 메모리 누수 방지: ScrollController dispose
    scrollController_total.dispose();
    scrollController_free.dispose();
    scrollController_room.dispose();
    scrollController_crew.dispose();
    // [이벤트·소식 탭 비활성화] scrollController_event.dispose();
    super.onClose();
  }
}

enum Community_Category_sub_bulletin {
  total("전체", "free"),
  chat("잡담", "chat"),
  room("시즌방", "deck"),
  crew("단톡방·동호회", "binding");

  final String korean;
  final String english;
  const Community_Category_sub_bulletin(this.korean, this.english);
}

// [이벤트·소식 탭 비활성화]
// enum Community_Category_sub_event {
//   total("전체", "free"),
//   clinic_free("클리닉(무료)", "clinic_free"),
//   clinic_pay("클리닉(유료)", "clinic_pay"),
//   test("시승회", "test"),
//   match("대회", "match"),
//   etc("기타", "etc");
//
//   final String korean;
//   final String english;
//   const Community_Category_sub_event(this.korean, this.english);
// }

enum Community_Category_sub2_bulletin {
  search("방 구해요", "free"),
  rent("방 임대", "deck"),
  invest("멤버모집", "binding");

  final String korean;
  final String english;
  const Community_Category_sub2_bulletin(this.korean, this.english);
}



