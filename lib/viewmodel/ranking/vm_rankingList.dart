import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/model/m_rankingListCrew.dart';
import 'package:com.snowlive/model/m_rankingListIndiv.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class RankingListViewModel extends GetxController {
  var isLoading = false.obs;

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  //뷰에서 사용하는 변수 4개
  var _rankingListIndivList_view = <RankingUser>[].obs;
  var _rankingListIndivMy_view = RankingListIndivResponse().myRankingInfo.obs;
  var _rankingListCrewList_view = <CrewRanking>[].obs;
  var _rankingListCrewMy_view = RankingListCrewModel().myCrewRankingInfo.obs;

  //개인랭킹 관련 변수들
  var _rankingListIndivList_total = <RankingUser>[].obs;
  var _rankingListIndivMy_total = RankingListIndivResponse().myRankingInfo.obs;
  var _rankingListIndivList_resort = <RankingUser>[].obs;
  var _rankingListIndivMy_resort = RankingListIndivResponse().myRankingInfo.obs;
  var _rankingListIndivList_total_daily = <RankingUser>[].obs;
  var _rankingListIndivMy_total_daily = RankingListIndivResponse().myRankingInfo.obs;
  var _rankingListIndivList_resort_daily = <RankingUser>[].obs;
  var _rankingListIndivMy_resort_daily = RankingListIndivResponse().myRankingInfo.obs;

  //크루랭킹 관련 변수들
  var _rankingListCrewList_total = <CrewRanking>[].obs;
  var _rankingListCrewMy_total = RankingListCrewModel().myCrewRankingInfo.obs;
  var _rankingListCrewList_total_daily = <CrewRanking>[].obs;
  var _rankingListCrewMy_total_daily = RankingListCrewModel().myCrewRankingInfo.obs;
  var _rankingListCrewList_resort = <CrewRanking>[].obs;
  var _rankingListCrewMy_resort = RankingListCrewModel().myCrewRankingInfo.obs;
  var _rankingListCrewList_resort_daily = <CrewRanking>[].obs;
  var _rankingListCrewMy_resort_daily = RankingListCrewModel().myCrewRankingInfo.obs;


  RxString _tapName = '개인랭킹'.obs;
  RxString _dayOrTotal = '일간'.obs;
  RxString _resortOrTotal = '전체스키장'.obs;
  RxString _selectedCategory_resort = '스키장별 랭킹'.obs;
  RxInt _selectedResortNum = 99.obs;
  var _nextPageUrl_indiv_total = ''.obs;
  var _nextPageUrl_indiv_resort = ''.obs;
  var _nextPageUrl_indiv_total_daily = ''.obs;
  var _nextPageUrl_indiv_resort_daily = ''.obs;
  var _nextPageUrl_crew_total = ''.obs;
  var _nextPageUrl_crew_resort = ''.obs;
  var _nextPageUrl_crew_total_daily = ''.obs;
  var _nextPageUrl_crew_resort_daily = ''.obs;

  //뷰에서 사용하는 변수 4개
  List<RankingUser>? get rankingListIndivList_view => _rankingListIndivList_view;
  MyRankingInfo? get rankingListIndivMy_view => _rankingListIndivMy_view.value;
  List<CrewRanking>? get rankingListCrewList_view => _rankingListCrewList_view;
  MyCrewRankingInfo? get rankingListCrewMy_view => _rankingListCrewMy_view.value;

  //개인랭킹 관련 변수들
  List<RankingUser>? get rankingListIndivList_total => _rankingListIndivList_total;
  MyRankingInfo? get rankingListIndivMy_total => _rankingListIndivMy_total.value;
  List<RankingUser>? get rankingListIndivList_resort => _rankingListIndivList_resort;
  MyRankingInfo? get rankingListIndivMy_resort => _rankingListIndivMy_resort.value;
  List<RankingUser>? get rankingListIndivList_total_daily => _rankingListIndivList_total_daily;
  MyRankingInfo? get rankingListIndivMy_total_daily => _rankingListIndivMy_total_daily.value;
  List<RankingUser>? get rankingListIndivList_resort_daily => _rankingListIndivList_resort_daily;
  MyRankingInfo? get rankingListIndivMy_resort_daily => _rankingListIndivMy_resort_daily.value;

  //크루랭킹 관련 변수들
  List<CrewRanking>? get rankingListCrewList_total => _rankingListCrewList_total;
  MyCrewRankingInfo? get rankingListCrewMy_total => _rankingListCrewMy_total.value;
  List<CrewRanking>? get rankingListCrewList_total_daily => _rankingListCrewList_total_daily;
  MyCrewRankingInfo? get rankingListCrewMy_total_daily => _rankingListCrewMy_total_daily.value;
  List<CrewRanking>? get rankingListCrewList_resort => _rankingListCrewList_resort;
  MyCrewRankingInfo? get rankingListCrewMy_resort => _rankingListCrewMy_resort.value;
  List<CrewRanking>? get rankingListCrewList_resort_daily => _rankingListCrewList_resort_daily;
  MyCrewRankingInfo? get rankingListCrewMy_resort_daily => _rankingListCrewMy_resort_daily.value;

  String get tapName => _tapName.value;
  String get dayOrTotal => _dayOrTotal.value;
  String get resortOrTotal => _resortOrTotal.value;
  String get selectedCategory_resort => _selectedCategory_resort.value;
  int get selectedResortNum => _selectedResortNum.value;
  String get nextPageUrlIndivTotal => _nextPageUrl_indiv_total.value;
  String get nextPageUrlIndivResort => _nextPageUrl_indiv_resort.value;
  String get nextPageUrlIndivTotalDaily => _nextPageUrl_indiv_total_daily.value;
  String get nextPageUrlIndivResortDaily => _nextPageUrl_indiv_resort_daily.value;
  String get nextPageUrl_crew_total => _nextPageUrl_crew_total.value;
  String get nextPageUrl_crew_resort => _nextPageUrl_crew_resort.value;
  String get nextPageUrl_crew_total_daily => _nextPageUrl_crew_total_daily.value;
  String get nextPageUrl_crew_resort_daily => _nextPageUrl_crew_resort_daily.value;

  ScrollController scrollController_indiv = ScrollController();
  ScrollController scrollController_crew = ScrollController();

  @override
  void onInit() async{
    super.onInit();

    await fetchRankingDataIndiv_total_daily(userId: _userViewModel.user.user_id,daily: true);
    _rankingListIndivList_view.value =_rankingListIndivList_total_daily;
    _rankingListIndivMy_view.value = _rankingListIndivMy_total_daily.value;
    await fetchRankingDataIndiv_resort_daily(userId: _userViewModel.user.user_id, resortId: _userViewModel.user.favorite_resort,daily: true);
    await fetchRankingDataIndiv_resort(userId: _userViewModel.user.user_id, resortId: _userViewModel.user.favorite_resort);
    await fetchRankingDataIndiv_total(userId: _userViewModel.user.user_id);

    await fetchRankingDataCrew_total_daily(userId: _userViewModel.user.user_id,daily: true);
    _rankingListCrewList_view.value =_rankingListCrewList_resort_daily;
    _rankingListCrewMy_view.value = _rankingListCrewMy_resort_daily.value;
    await fetchRankingDataCrew_resort_daily(userId: _userViewModel.user.user_id,resortId: _userViewModel.user.favorite_resort,daily: true);
    await fetchRankingDataCrew_resort(userId: _userViewModel.user.user_id,resortId: _userViewModel.user.favorite_resort);
    await fetchRankingDataCrew_total(userId: _userViewModel.user.user_id);

    scrollController_indiv = ScrollController()
      ..addListener(_scrollListener_indiv);

    scrollController_crew = ScrollController()
      ..addListener(_scrollListener_crew);

  }

  Future<void> fetchNextPage_indiv_total() async{
    if (_nextPageUrl_indiv_total.value.isNotEmpty) {
      await fetchRankingDataIndiv_total(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_total.value
      );
    }
  }

  Future<void> fetchNextPage_indiv_resort() async{
    if (_nextPageUrl_indiv_resort.value.isNotEmpty) {
      await fetchRankingDataIndiv_resort(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_resort.value
      );
    }
  }

  Future<void> fetchNextPage_indiv_total_daily() async{
      print('fetchNextPage_indiv_total_daily 시작');
    if (_nextPageUrl_indiv_total_daily.value.isNotEmpty) {
      await fetchRankingDataIndiv_total_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_total_daily.value,
        daily: true
      );
    }
  }

  Future<void> fetchNextPage_indiv_resort_daily() async{
    if (_nextPageUrl_indiv_resort_daily.value.isNotEmpty) {
      await fetchRankingDataIndiv_resort_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_resort_daily.value,
        daily: true
      );
    }
  }

  Future<void> fetchNextPage_crew_total() async{
    print('fetchNextPage_crew_total 시작');
    if (_nextPageUrl_crew_total.value.isNotEmpty) {
      await fetchRankingDataCrew_total(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_total.value
      );
    }
  }

  Future<void> fetchNextPage_crew_resort() async{
    print('fetchNextPage_crew_resort 시작');
    if (_nextPageUrl_crew_resort.value.isNotEmpty) {
      await fetchRankingDataCrew_resort(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_resort.value
      );
    }
  }

  Future<void> fetchNextPage_crew_total_daily() async{
    print('fetchNextPage_crew_total_daily 시작');
    if (_nextPageUrl_crew_total_daily.value.isNotEmpty) {
      await fetchRankingDataCrew_total_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_total_daily.value,
          daily: true
      );
    }
  }

  Future<void> fetchNextPage_crew_resort_daily() async{
    print('fetchNextPage_crew_resort_daily 시작');
    if (_nextPageUrl_crew_resort_daily.value.isNotEmpty) {
      await fetchRankingDataCrew_resort_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_resort_daily.value,
          daily: true
      );
    }
  }

  Future<void> _scrollListener_indiv() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_indiv.position.pixels == scrollController_indiv.position.maxScrollExtent) {
      print('다음 100개 불러오기 시작');
      if(tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간' && isLoading != true){
        if (_nextPageUrl_indiv_resort_daily.value.isNotEmpty) {
          isLoading.value=true;
          await fetchNextPage_indiv_resort_daily();
          _rankingListIndivList_view.value = _rankingListIndivList_resort_daily;
          _rankingListIndivMy_view.value = _rankingListIndivMy_resort_daily.value;
          isLoading.value=false;
        }
      }else if  (tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적' && isLoading != true){
        if (_nextPageUrl_indiv_resort.value.isNotEmpty) {
          isLoading.value=true;
          await fetchNextPage_indiv_resort();
          _rankingListIndivList_view.value = _rankingListIndivList_resort;
          _rankingListIndivMy_view.value = _rankingListIndivMy_resort.value;
          isLoading.value=false;
        }
      }else if  (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && isLoading != true){
        if (_nextPageUrl_indiv_total_daily.value.isNotEmpty) {
          isLoading.value=true;
          await fetchNextPage_indiv_total_daily();
          _rankingListIndivList_view.value = _rankingListIndivList_total_daily;
          _rankingListIndivMy_view.value = _rankingListIndivMy_total_daily.value;
          isLoading.value=false;
        }
      }else if  (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && isLoading != true){
        if (_nextPageUrl_indiv_total.value.isNotEmpty) {
          isLoading.value=true;
          await fetchNextPage_indiv_total();
          _rankingListIndivList_view.value = _rankingListIndivList_total_daily;
          _rankingListIndivMy_view.value = _rankingListIndivMy_total_daily.value;
          isLoading.value=false;
        }
      }
    }
  }

  Future<void> _scrollListener_crew() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_crew.position.pixels == scrollController_crew.position.maxScrollExtent) {
      print('다음 100개 불러오기 시작');
      if(tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간' && isLoading != true){
        if (_nextPageUrl_crew_resort_daily.value.isNotEmpty) {
          isLoading.value=true;
          await fetchNextPage_crew_resort_daily();
          _rankingListCrewList_view.value = _rankingListCrewList_resort_daily;
          _rankingListCrewMy_view.value = _rankingListCrewMy_resort_daily.value;
          isLoading.value=false;
        }
      }else if  (tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적' && isLoading != true){
        if (_nextPageUrl_crew_resort.value.isNotEmpty) {
          isLoading.value=true;
          await fetchNextPage_crew_resort();
          _rankingListCrewList_view.value = _rankingListCrewList_resort;
          _rankingListCrewMy_view.value = _rankingListCrewMy_resort.value;
          isLoading.value=false;
        }
      }else if  (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && isLoading != true){
        if (_nextPageUrl_crew_total_daily.value.isNotEmpty) {
          isLoading.value=true;
          await fetchNextPage_crew_total_daily();
          _rankingListCrewList_view.value = _rankingListCrewList_total_daily;
          _rankingListCrewMy_view.value = _rankingListCrewMy_total_daily.value;
          isLoading.value=false;
        }
      }else if  (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && isLoading != true){
        if (_nextPageUrl_crew_total.value.isNotEmpty) {
          isLoading.value=true;
          await fetchNextPage_crew_total();
          _rankingListCrewList_view.value = _rankingListCrewList_total_daily;
          _rankingListCrewMy_view.value = _rankingListCrewMy_total_daily.value;
          isLoading.value=false;
        }
      }
    }
  }

  void changeTap(value) {
    _tapName.value = value;
  }

  void changeResortOrTotal(value) {
    _resortOrTotal.value = value;
  }

  void changeDayOrTotal(value) {
    _dayOrTotal.value = value;
  }

  void changeResortNum(value) {
    _selectedResortNum.value = value;
  }

  Future<void> toggleDataDayOrTotal({int? resortNum}) async{
    if(tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      await fetchRankingDataIndiv_resort_daily(userId: _userViewModel.user.user_id, resortId: resortNum,daily: true);
      _rankingListIndivList_view.value = _rankingListIndivList_resort_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_resort_daily.value;
      print(_rankingListIndivList_view[0].displayName);
    } else if (tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      await fetchRankingDataIndiv_resort(userId: _userViewModel.user.user_id, resortId: resortNum);
      _rankingListIndivList_view.value = _rankingListIndivList_resort;
      _rankingListIndivMy_view.value = _rankingListIndivMy_resort.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간'){
      await fetchRankingDataIndiv_total_daily(userId: _userViewModel.user.user_id,daily: true);
      _rankingListIndivList_view.value = _rankingListIndivList_total_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_total_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적'){
      await fetchRankingDataIndiv_total(userId: _userViewModel.user.user_id);
      _rankingListIndivList_view.value = _rankingListIndivList_total;
      _rankingListIndivMy_view.value = _rankingListIndivMy_total.value;
    } else if(tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      await fetchRankingDataCrew_resort_daily(userId: _userViewModel.user.user_id, resortId: resortNum,daily: true);
      _rankingListCrewList_view.value = _rankingListCrewList_resort_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_resort_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      await fetchRankingDataCrew_resort(userId: _userViewModel.user.user_id, resortId: resortNum);
      _rankingListCrewList_view.value = _rankingListCrewList_resort;
      _rankingListCrewMy_view.value = _rankingListCrewMy_resort.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간'){
      await fetchRankingDataCrew_total_daily(userId: _userViewModel.user.user_id,daily: true);
      _rankingListCrewList_view.value = _rankingListCrewList_total_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_total_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적'){
      await fetchRankingDataCrew_total(userId: _userViewModel.user.user_id);
      _rankingListCrewList_view.value = _rankingListCrewList_total;
      _rankingListCrewMy_view.value = _rankingListCrewMy_total.value;
    }
  }

  Future<void> fetchRankingDataIndiv_total({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url,
  }) async {
    print('fetchRankingDataIndiv_total 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListIndivList_total.value = rankingListIndivResponse.results!.rankingUsers;
        } else {
          // URL이 있을 경우 리스트에 추가
            _rankingListIndivList_total.addAll(rankingListIndivResponse.results!.rankingUsers);
        }
          _rankingListIndivMy_total.value=rankingListIndivResponse.myRankingInfo;
          _nextPageUrl_indiv_total.value = rankingListIndivResponse.results!.next ?? '';
      } else {
        print('Failed to load individual ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual ranking: $e');
    } finally {
      isLoading(false);
    }
    print('fetchRankingDataIndiv_total 끝');
  }

  Future<void> fetchRankingDataIndiv_resort({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url,
  }) async {
    print('fetchRankingDataIndiv_resort 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListIndivList_resort.value = rankingListIndivResponse.results!.rankingUsers;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListIndivList_resort.addAll(rankingListIndivResponse.results!.rankingUsers );
        }
          _rankingListIndivMy_resort.value=rankingListIndivResponse.myRankingInfo;
        _nextPageUrl_indiv_resort.value = rankingListIndivResponse.results!.next ?? '';
      } else {
        print('Failed to load individual ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual ranking: $e');
    } finally {
      isLoading(false);
    }
    print('fetchRankingDataIndiv_resort 끝');
  }

  Future<void> fetchRankingDataIndiv_total_daily({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url,
  }) async {
    print('fetchRankingDataIndiv_total_daily 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListIndivList_total_daily.value = rankingListIndivResponse.results!.rankingUsers;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListIndivList_total_daily.addAll(rankingListIndivResponse.results!.rankingUsers );
        }
        _rankingListIndivMy_total_daily.value=rankingListIndivResponse.myRankingInfo;
        _nextPageUrl_indiv_total_daily.value = rankingListIndivResponse.results!.next ?? '';
      } else {
        print('Failed to load individual ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual ranking: $e');
    } finally {
      isLoading(false);
    }
    print('fetchRankingDataIndiv_total_daily 끝');
  }

  Future<void> fetchRankingDataIndiv_resort_daily({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url,
  }) async {
    print('fetchRankingDataIndiv_resort_daily 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListIndivList_resort_daily.value = rankingListIndivResponse.results!.rankingUsers;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListIndivList_resort_daily.addAll(rankingListIndivResponse.results!.rankingUsers );
        }
        _rankingListIndivMy_resort_daily.value=rankingListIndivResponse.myRankingInfo;
        _nextPageUrl_indiv_resort_daily.value = rankingListIndivResponse.results!.next ?? '';
      } else {
        print('Failed to load individual ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual ranking: $e');
    } finally {
      isLoading(false);
    }
    print('fetchRankingDataIndiv_resort_daily 끝');
  }



  Future<void> fetchRankingDataCrew_total({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url, // URL 추가
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url, // URL 전달
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListCrewList_total.value = rankingListCrewResponse.rankingResults!.results!;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListCrewList_total.addAll(rankingListCrewResponse.rankingResults!.results ?? []);
        }
          _rankingListCrewMy_total.value=rankingListCrewResponse.myCrewRankingInfo;
        _nextPageUrl_crew_total.value = rankingListCrewResponse.rankingResults!.next ?? '';
      } else {
        print('Failed to load crew ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew ranking: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRankingDataCrew_resort({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url, // URL 추가
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url, // URL 전달
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListCrewList_resort.value = rankingListCrewResponse.rankingResults!.results!;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListCrewList_resort.addAll(rankingListCrewResponse.rankingResults!.results ?? []);
        }
        _rankingListCrewMy_resort.value=rankingListCrewResponse.myCrewRankingInfo;
        _nextPageUrl_crew_resort.value = rankingListCrewResponse.rankingResults!.next ?? '';
      } else {
        print('Failed to load crew ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew ranking: $e');
    } finally {
      isLoading(false);
    }
  }


  Future<void> fetchRankingDataCrew_total_daily({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url, // URL 추가
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url, // URL 전달
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListCrewList_total_daily.value = rankingListCrewResponse.rankingResults!.results!;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListCrewList_total_daily.addAll(rankingListCrewResponse.rankingResults!.results ?? []);
        }
        _rankingListCrewMy_total_daily.value=rankingListCrewResponse.myCrewRankingInfo;
        _nextPageUrl_crew_total_daily.value = rankingListCrewResponse.rankingResults!.next ?? '';
      } else {
        print('Failed to load crew ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew ranking: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRankingDataCrew_resort_daily({
    required int userId,
    int? resortId,
    bool? daily,
    String? season,
    String? url, // URL 추가
  }) async {
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew(
        userId: userId,
        resortId: resortId,
        daily: daily,
        season: season,
        url: url, // URL 전달
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListCrewList_resort_daily.value = rankingListCrewResponse.rankingResults!.results!;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListCrewList_resort_daily.addAll(rankingListCrewResponse.rankingResults!.results ?? []);
        }
        _rankingListCrewMy_resort_daily.value=rankingListCrewResponse.myCrewRankingInfo;
        _nextPageUrl_crew_resort_daily.value = rankingListCrewResponse.rankingResults!.next ?? '';
      } else {
        print('Failed to load crew ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew ranking: $e');
    } finally {
      isLoading(false);
    }
  }

  void changeCategory_resort(value) {
    _selectedCategory_resort.value = value;
  }


}

enum RankingFilter_resort {
  total("전체 스키장 랭킹", "total"),
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
  initial("스키장별 랭킹","");

  final String korean;
  final String english;
  const RankingFilter_resort(this.korean, this.english);
}
