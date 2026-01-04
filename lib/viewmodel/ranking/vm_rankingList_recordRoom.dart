import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/model/m_rankingListCrew_recordRoom.dart';
import 'package:com.snowlive/model/m_rankingListIndiv_recordRoom.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class RankingListViewModel_recordRoom extends GetxController {
  var isLoading = false.obs;

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  //뷰에서 사용하는 변수 4개
  var _rankingListIndivList_view = <RankingUser_recordRoom>[].obs;
  var _rankingListIndivMy_view = RankingListIndivResponse_recordRoom().myRankingInfo.obs;
  var _rankingListCrewList_view = <CrewRanking_recordRoom>[].obs;
  var _rankingListCrewMy_view = RankingListCrewModel_recordRoom().myCrewRankingInfo.obs;

  //개인랭킹 관련 변수들
  var _rankingListIndivList_total = <RankingUser_recordRoom>[].obs;
  var _rankingListIndivMy_total = RankingListIndivResponse_recordRoom().myRankingInfo.obs;
  var _rankingListIndivList_resort = <RankingUser_recordRoom>[].obs;
  var _rankingListIndivMy_resort = RankingListIndivResponse_recordRoom().myRankingInfo.obs;
  var _rankingListIndivList_total_daily = <RankingUser_recordRoom>[].obs;
  var _rankingListIndivMy_total_daily = RankingListIndivResponse_recordRoom().myRankingInfo.obs;
  var _rankingListIndivList_resort_daily = <RankingUser_recordRoom>[].obs;
  var _rankingListIndivMy_resort_daily = RankingListIndivResponse_recordRoom().myRankingInfo.obs;

  var _rankingListIndivList_fed = <RankingUser_recordRoom>[].obs;
  var _rankingListIndivMy_fed = RankingListIndivResponse_recordRoom().myRankingInfo.obs;
  var _rankingListIndivList_fed_daily = <RankingUser_recordRoom>[].obs;
  var _rankingListIndivMy_fed_daily = RankingListIndivResponse_recordRoom().myRankingInfo.obs;

  //크루랭킹 관련 변수들
  var _rankingListCrewList_total = <CrewRanking_recordRoom>[].obs;
  var _rankingListCrewMy_total = RankingListCrewModel_recordRoom().myCrewRankingInfo.obs;
  var _rankingListCrewList_total_daily = <CrewRanking_recordRoom>[].obs;
  var _rankingListCrewMy_total_daily = RankingListCrewModel_recordRoom().myCrewRankingInfo.obs;
  var _rankingListCrewList_resort = <CrewRanking_recordRoom>[].obs;
  var _rankingListCrewMy_resort = RankingListCrewModel_recordRoom().myCrewRankingInfo.obs;
  var _rankingListCrewList_resort_daily = <CrewRanking_recordRoom>[].obs;
  var _rankingListCrewMy_resort_daily = RankingListCrewModel_recordRoom().myCrewRankingInfo.obs;

  var _rankingListCrewList_fed = <CrewRanking_recordRoom>[].obs;
  var _rankingListCrewMy_fed = RankingListCrewModel_recordRoom().myCrewRankingInfo.obs;
  var _rankingListCrewList_fed_daily = <CrewRanking_recordRoom>[].obs;
  var _rankingListCrewMy_fed_daily = RankingListCrewModel_recordRoom().myCrewRankingInfo.obs;

  RxBool _isLoadingRankingListCrewList_total = false.obs;
  RxBool _isLoadingRankingListIndiv_total = false.obs;
  RxBool _isLoadingRankingListCrewList_total_daily = false.obs;
  RxBool _isLoadingRankingListIndiv_total_daily = false.obs;
  RxBool _isLoadingRankingListCrewList_resort = false.obs;
  RxBool _isLoadingRankingListIndiv_resort = false.obs;
  RxBool _isLoadingRankingListCrewList_resort_daily = false.obs;
  RxBool _isLoadingRankingListIndiv_resort_daily = false.obs;

  RxBool _isLoadingRankingListCrewList_fed = false.obs;
  RxBool _isLoadingRankingListCrewList_fed_daily = false.obs;
  RxBool _isLoadingRankingListIndiv_fed = false.obs;
  RxBool _isLoadingRankingListIndiv_fed_daily = false.obs;

  RxBool _isLoadingRankingListCrewList_next = false.obs;
  RxBool _isLoadingRankingListIndiv_next = false.obs;

  RxString _tapName = '크루랭킹'.obs;
  RxString _dayOrTotal = '누적'.obs;
  RxString _resortOrTotal = '전체스키장'.obs;
  RxString _selectedCategory_resort = '스키장별 랭킹'.obs;
  RxString _selectedCategory_season = '24/25시즌'.obs;
  RxString _selectedCategory_season_db = '2425'.obs;
  RxString _selectedCategory_fed = '리그별 랭킹'.obs;
  RxString _myBox_title = '누적 전체 스키장'.obs;
  RxString _myBox_score = '크루 점수'.obs;
  RxString _myBox_ranking = '크루 랭킹'.obs;
  RxInt _selectedResortNum = 99.obs;
  var _nextPageUrl_indiv_total = ''.obs;
  var _nextPageUrl_indiv_resort = ''.obs;
  var _nextPageUrl_indiv_fed = ''.obs;
  var _nextPageUrl_indiv_total_daily = ''.obs;
  var _nextPageUrl_indiv_resort_daily = ''.obs;
  var _nextPageUrl_indiv_fed_daily = ''.obs;
  var _nextPageUrl_crew_total = ''.obs;
  var _nextPageUrl_crew_resort = ''.obs;
  var _nextPageUrl_crew_fed = ''.obs;
  var _nextPageUrl_crew_total_daily = ''.obs;
  var _nextPageUrl_crew_resort_daily = ''.obs;
  var _nextPageUrl_crew_fed_daily = ''.obs;

  //뷰에서 사용하는 변수 4개
  List<RankingUser_recordRoom>? get rankingListIndivList_view => _rankingListIndivList_view;
  MyRankingInfo_recordRoom? get rankingListIndivMy_view => _rankingListIndivMy_view.value;
  List<CrewRanking_recordRoom>? get rankingListCrewList_view => _rankingListCrewList_view;
  MyCrewRankingInfo_recordRoom? get rankingListCrewMy_view => _rankingListCrewMy_view.value;

  //개인랭킹 관련 변수들
  List<RankingUser_recordRoom>? get rankingListIndivList_total => _rankingListIndivList_total;
  MyRankingInfo_recordRoom? get rankingListIndivMy_total => _rankingListIndivMy_total.value;
  List<RankingUser_recordRoom>? get rankingListIndivList_resort => _rankingListIndivList_resort;
  MyRankingInfo_recordRoom? get rankingListIndivMy_resort => _rankingListIndivMy_resort.value;
  List<RankingUser_recordRoom>? get rankingListIndivList_total_daily => _rankingListIndivList_total_daily;
  MyRankingInfo_recordRoom? get rankingListIndivMy_total_daily => _rankingListIndivMy_total_daily.value;
  List<RankingUser_recordRoom>? get rankingListIndivList_resort_daily => _rankingListIndivList_resort_daily;
  MyRankingInfo_recordRoom? get rankingListIndivMy_resort_daily => _rankingListIndivMy_resort_daily.value;

  List<RankingUser_recordRoom>? get rankingListIndivList_fed => _rankingListIndivList_fed;
  MyRankingInfo_recordRoom?     get rankingListIndivMy_fed => _rankingListIndivMy_fed.value;
  List<RankingUser_recordRoom>? get rankingListIndivList_fed_daily => _rankingListIndivList_fed_daily;
  MyRankingInfo_recordRoom?     get rankingListIndivMy_fed_daily => _rankingListIndivMy_fed_daily.value;

  //크루랭킹 관련 변수들
  List<CrewRanking_recordRoom>? get rankingListCrewList_total => _rankingListCrewList_total;
  MyCrewRankingInfo_recordRoom? get rankingListCrewMy_total => _rankingListCrewMy_total.value;
  List<CrewRanking_recordRoom>? get rankingListCrewList_total_daily => _rankingListCrewList_total_daily;
  MyCrewRankingInfo_recordRoom? get rankingListCrewMy_total_daily => _rankingListCrewMy_total_daily.value;
  List<CrewRanking_recordRoom>? get rankingListCrewList_resort => _rankingListCrewList_resort;
  MyCrewRankingInfo_recordRoom? get rankingListCrewMy_resort => _rankingListCrewMy_resort.value;
  List<CrewRanking_recordRoom>? get rankingListCrewList_resort_daily => _rankingListCrewList_resort_daily;
  MyCrewRankingInfo_recordRoom? get rankingListCrewMy_resort_daily => _rankingListCrewMy_resort_daily.value;

  List<CrewRanking_recordRoom>? get rankingListCrewList_fed => _rankingListCrewList_fed;
  MyCrewRankingInfo_recordRoom? get rankingListCrewMy_fed => _rankingListCrewMy_fed.value;
  List<CrewRanking_recordRoom>? get rankingListCrewList_fed_daily => _rankingListCrewList_fed_daily;
  MyCrewRankingInfo_recordRoom? get rankingListCrewMy_fed_daily => _rankingListCrewMy_fed_daily.value;

  String get tapName => _tapName.value;
  String get dayOrTotal => _dayOrTotal.value;
  String get resortOrTotal => _resortOrTotal.value;
  String get selectedCategory_resort => _selectedCategory_resort.value;
  String get selectedCategory_season => _selectedCategory_season.value;
  String get selectedCategory_season_db => _selectedCategory_season_db.value;
  String get selectedCategory_fed => _selectedCategory_fed.value;
  String get myBox_score => _myBox_score.value;
  String get myBox_title => _myBox_title.value;
  String get myBox_ranking => _myBox_ranking.value;
  int get selectedResortNum => _selectedResortNum.value;

  String get nextPageUrlIndivTotal => _nextPageUrl_indiv_total.value;
  String get nextPageUrlIndivResort => _nextPageUrl_indiv_resort.value;
  String get nextPageUrlIndivTotalDaily => _nextPageUrl_indiv_total_daily.value;
  String get nextPageUrlIndivResortDaily => _nextPageUrl_indiv_resort_daily.value;
  String get nextPageUrl_crew_total => _nextPageUrl_crew_total.value;
  String get nextPageUrl_crew_resort => _nextPageUrl_crew_resort.value;
  String get nextPageUrl_crew_total_daily => _nextPageUrl_crew_total_daily.value;
  String get nextPageUrl_crew_resort_daily => _nextPageUrl_crew_resort_daily.value;

  String get nextPageUrlIndivFed => _nextPageUrl_indiv_fed.value;
  String get nextPageUrlIndivFedDaily => _nextPageUrl_indiv_fed_daily.value;
  String get nextPageUrl_crew_fed => _nextPageUrl_crew_fed.value;
  String get nextPageUrl_crew_fed_daily => _nextPageUrl_crew_fed_daily.value;

  bool get isLoadingRankingListCrewList_total => _isLoadingRankingListCrewList_total.value;
  bool get isLoadingRankingListIndiv_total => _isLoadingRankingListIndiv_total.value;
  bool get isLoadingRankingListCrewList_total_daily => _isLoadingRankingListCrewList_total_daily.value;
  bool get isLoadingRankingListIndiv_total_daily => _isLoadingRankingListIndiv_total_daily.value;
  bool get isLoadingRankingListCrewList_resort => _isLoadingRankingListCrewList_resort.value;
  bool get isLoadingRankingListIndiv_resort => _isLoadingRankingListIndiv_resort.value;
  bool get isLoadingRankingListCrewList_resort_daily => _isLoadingRankingListCrewList_resort_daily.value;
  bool get isLoadingRankingListIndiv_resort_daily => _isLoadingRankingListIndiv_resort_daily.value;

  bool get isLoadingRankingListCrewList_fed => _isLoadingRankingListCrewList_fed.value;
  bool get isLoadingRankingListIndiv_fed => _isLoadingRankingListIndiv_fed.value;
  bool get isLoadingRankingListCrewList_fed_daily => _isLoadingRankingListCrewList_fed_daily.value;
  bool get isLoadingRankingListIndiv_fed_daily => _isLoadingRankingListIndiv_fed_daily.value;

  bool get isLoadingRankingListCrewList_next => _isLoadingRankingListCrewList_next.value;
  bool get isLoadingRankingListIndiv_next => _isLoadingRankingListIndiv_next.value;

  ScrollController scrollController_indiv = ScrollController();
  ScrollController scrollController_crew = ScrollController();

  @override
  void onInit() async{
    super.onInit();

    await fetchAllRanking();

    scrollController_indiv = ScrollController()
      ..addListener(_scrollListener_indiv);

    scrollController_crew = ScrollController()
      ..addListener(_scrollListener_crew);

  }

  Future<void> fetchAllRanking() async{
    _isLoadingRankingListCrewList_total.value = true;
    _isLoadingRankingListCrewList_total_daily.value = true;
    _isLoadingRankingListIndiv_total.value = true;
    _isLoadingRankingListIndiv_total_daily.value = true;
    _isLoadingRankingListCrewList_resort.value = true;
    _isLoadingRankingListCrewList_resort_daily.value = true;
    _isLoadingRankingListIndiv_resort.value = true;
    _isLoadingRankingListIndiv_resort_daily.value = true;
    _isLoadingRankingListCrewList_fed.value = true;
    _isLoadingRankingListCrewList_fed_daily.value = true;
    _isLoadingRankingListIndiv_fed.value = true;
    _isLoadingRankingListIndiv_fed_daily.value = true;

    await fetchRankingDataCrew_total(userId: _userViewModel.user.user_id,selected_season:  _selectedCategory_season_db.value);
    _rankingListCrewList_view.value =_rankingListCrewList_total;
    _rankingListCrewMy_view.value = _rankingListCrewMy_total.value;
    _isLoadingRankingListCrewList_total.value = false;
    await fetchRankingDataCrew_total_daily(userId: _userViewModel.user.user_id,daily: true,selected_season:  _selectedCategory_season_db.value);
    _isLoadingRankingListCrewList_total_daily.value = false;

    await fetchRankingDataIndiv_total(userId: _userViewModel.user.user_id,selected_season:  _selectedCategory_season_db.value);
    _rankingListIndivList_view.value =_rankingListIndivList_total;
    _rankingListIndivMy_view.value = _rankingListIndivMy_total.value;
    _isLoadingRankingListIndiv_total.value = false;

    await fetchRankingDataIndiv_total_daily(userId: _userViewModel.user.user_id,daily: true,selected_season:  _selectedCategory_season_db.value);
    _isLoadingRankingListIndiv_total_daily.value = false;

  }

  Future<void> fetchNextPage_indiv_total() async{
    if (_nextPageUrl_indiv_total.value.isNotEmpty) {
      await fetchRankingDataIndiv_total(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_total.value
          ,selected_season:  _selectedCategory_season_db.value
      );
    }
  }

  Future<void> fetchNextPage_indiv_resort() async{
    if (_nextPageUrl_indiv_resort.value.isNotEmpty) {
      await fetchRankingDataIndiv_resort(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_resort.value,selected_season:  _selectedCategory_season_db.value
      );
    }
  }

  Future<void> fetchNextPage_indiv_total_daily() async{
    print('fetchNextPage_indiv_total_daily 시작');
    if (_nextPageUrl_indiv_total_daily.value.isNotEmpty) {
      await fetchRankingDataIndiv_total_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_total_daily.value,
          daily: true,selected_season: _selectedCategory_season_db.value
      );
    }
  }

  Future<void> fetchNextPage_indiv_resort_daily() async{
    if (_nextPageUrl_indiv_resort_daily.value.isNotEmpty) {
      await fetchRankingDataIndiv_resort_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_resort_daily.value,
          daily: true,selected_season:  _selectedCategory_season_db.value
      );
    }
  }

  Future<void> fetchNextPage_crew_total() async{
    print('fetchNextPage_crew_total 시작');
    if (_nextPageUrl_crew_total.value.isNotEmpty) {
      await fetchRankingDataCrew_total(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_total.value,selected_season:  _selectedCategory_season_db.value
      );
    }
  }

  Future<void> fetchNextPage_crew_resort() async{
    print('fetchNextPage_crew_resort 시작');
    if (_nextPageUrl_crew_resort.value.isNotEmpty) {
      await fetchRankingDataCrew_resort(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_resort.value,selected_season:  _selectedCategory_season_db.value
      );
    }
  }

  Future<void> fetchNextPage_crew_total_daily() async{
    print('fetchNextPage_crew_total_daily 시작');
    if (_nextPageUrl_crew_total_daily.value.isNotEmpty) {
      await fetchRankingDataCrew_total_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_total_daily.value,
          daily: true,selected_season:  _selectedCategory_season_db.value
      );
    }
  }

  Future<void> fetchNextPage_crew_resort_daily() async{
    print('fetchNextPage_crew_resort_daily 시작');
    if (_nextPageUrl_crew_resort_daily.value.isNotEmpty) {
      await fetchRankingDataCrew_resort_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_resort_daily.value,
          daily: true,selected_season:  _selectedCategory_season_db.value
      );
    }
  }

  Future<void> fetchNextPage_indiv_fed() async{
    if (_nextPageUrl_indiv_fed.value.isNotEmpty) {
      await fetchRankingDataIndiv_fed(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_fed.value,
          selected_season:  _selectedCategory_season_db.value,
        federation: _selectedCategory_fed.value
      );
    }
  }

  Future<void> fetchNextPage_indiv_fed_daily() async{
    print('fetchNextPage_indiv_fed_daily 시작');
    if (_nextPageUrl_indiv_fed_daily.value.isNotEmpty) {
      await fetchRankingDataIndiv_fed_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_indiv_fed_daily.value,
          daily: true,
          selected_season:  _selectedCategory_season_db.value,
          federation: _selectedCategory_fed.value
      );
    }
  }

  Future<void> fetchNextPage_crew_fed() async{
    print('fetchNextPage_crew_fed 시작');
    if (_nextPageUrl_crew_fed.value.isNotEmpty) {
      await fetchRankingDataCrew_fed(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_total.value,selected_season:  _selectedCategory_season_db.value,
          federation: _selectedCategory_fed.value
      );
    }
  }

  Future<void> fetchNextPage_crew_fed_daily() async{
    print('fetchNextPage_crew_fed_daily 시작');
    if (_nextPageUrl_crew_fed_daily.value.isNotEmpty) {
      await fetchRankingDataCrew_fed_daily(
          userId: _userViewModel.user.user_id,
          url: _nextPageUrl_crew_total_daily.value,
          daily: true,selected_season:  _selectedCategory_season_db.value,
          federation: _selectedCategory_fed.value
      );
    }
  }

  Future<void> _scrollListener_indiv() async {
    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_indiv.position.pixels == scrollController_indiv.position.maxScrollExtent) {
      // 로딩 중이라면 추가 호출 방지
      if (_isLoadingRankingListIndiv_next.value) {
        print("이미 로딩 중입니다.");
        return;
      }

      _isLoadingRankingListIndiv_next.value = true;
      print('다음 100개 불러오기 시작');

      try {
        if (tapName == '개인랭킹') {
          if (resortOrTotal == '개별스키장' && dayOrTotal == '일간') {
            if (_nextPageUrl_indiv_resort_daily.value.isNotEmpty) {
              await fetchNextPage_indiv_resort_daily();
              _rankingListIndivList_view.value = _rankingListIndivList_resort_daily;
              _rankingListIndivMy_view.value = _rankingListIndivMy_resort_daily.value;
            }
          } else if (resortOrTotal == '개별스키장' && dayOrTotal == '누적') {
            if (_nextPageUrl_indiv_resort.value.isNotEmpty) {
              await fetchNextPage_indiv_resort();
              _rankingListIndivList_view.value = _rankingListIndivList_resort;
              _rankingListIndivMy_view.value = _rankingListIndivMy_resort.value;
            }
          } else if (resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed == '리그별 랭킹') {
            if (_nextPageUrl_indiv_total_daily.value.isNotEmpty) {
              await fetchNextPage_indiv_total_daily();
              _rankingListIndivList_view.value = _rankingListIndivList_total_daily;
              _rankingListIndivMy_view.value = _rankingListIndivMy_total_daily.value;
            }
          } else if (resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed == '리그별 랭킹') {
            if (_nextPageUrl_indiv_total.value.isNotEmpty) {
              print('개인 전체 누적 다음 시작');
              await fetchNextPage_indiv_total();
              print('개인 전체 누적 다음 끝');
              _rankingListIndivList_view.value = _rankingListIndivList_total;
              _rankingListIndivMy_view.value = _rankingListIndivMy_total.value;
            }
          } else if (resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed != '리그별 랭킹') {
            if (_nextPageUrl_indiv_fed_daily.value.isNotEmpty) {
              await fetchNextPage_indiv_fed_daily();
              _rankingListIndivList_view.value = _rankingListIndivList_fed_daily;
              _rankingListIndivMy_view.value = _rankingListIndivMy_fed_daily.value;
            }
          } else if (resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed != '리그별 랭킹') {
            if (_nextPageUrl_indiv_fed.value.isNotEmpty) {
              print('개인 전체 누적 다음 시작');
              await fetchNextPage_indiv_fed();
              print('개인 전체 누적 다음 끝');
              _rankingListIndivList_view.value = _rankingListIndivList_fed;
              _rankingListIndivMy_view.value = _rankingListIndivMy_fed.value;
            }
          }
        }
      } catch (e) {
        print("에러 발생: $e");
      } finally {
        _isLoadingRankingListIndiv_next.value = false;
        print('로딩 상태 해제');
      }
    }
  }


  Future<void> _scrollListener_crew() async {

    // 스크롤이 리스트의 끝에 도달했을 때
    if (scrollController_crew.position.pixels == scrollController_crew.position.maxScrollExtent) {
      _isLoadingRankingListCrewList_next.value = true;
      print('다음 100개 불러오기 시작');
      if(tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간' ){

        if (_nextPageUrl_crew_resort_daily.value.isNotEmpty) {
          await fetchNextPage_crew_resort_daily();
          _rankingListCrewList_view.value = _rankingListCrewList_resort_daily;
          _rankingListCrewMy_view.value = _rankingListCrewMy_resort_daily.value;
        }
      }else if  (tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적' ){
        if (_nextPageUrl_crew_resort.value.isNotEmpty) {
          await fetchNextPage_crew_resort();
          _rankingListCrewList_view.value = _rankingListCrewList_resort;
          _rankingListCrewMy_view.value = _rankingListCrewMy_resort.value;
        }
      }else if  (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed == '리그별 랭킹'){
        if (_nextPageUrl_crew_total_daily.value.isNotEmpty) {
          await fetchNextPage_crew_total_daily();
          _rankingListCrewList_view.value = _rankingListCrewList_total_daily;
          _rankingListCrewMy_view.value = _rankingListCrewMy_total_daily.value;
        }
      }else if  (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed == '리그별 랭킹'){
        if (_nextPageUrl_crew_total.value.isNotEmpty) {
          await fetchNextPage_crew_total();
          _rankingListCrewList_view.value = _rankingListCrewList_total;
          _rankingListCrewMy_view.value = _rankingListCrewMy_total.value;
        }
      }else if  (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed != '리그별 랭킹'){
        if (_nextPageUrl_crew_fed_daily.value.isNotEmpty) {
          await fetchNextPage_crew_fed_daily();
          _rankingListCrewList_view.value = _rankingListCrewList_fed_daily;
          _rankingListCrewMy_view.value = _rankingListCrewMy_fed_daily.value;
        }
      }else if  (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed != '리그별 랭킹'){
        if (_nextPageUrl_crew_fed.value.isNotEmpty) {
          await fetchNextPage_crew_fed();
          _rankingListCrewList_view.value = _rankingListCrewList_fed;
          _rankingListCrewMy_view.value = _rankingListCrewMy_fed.value;
        }
      }
    }
    _isLoadingRankingListCrewList_next.value = false;
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

  void changeMyBoxText(){
    _isLoadingRankingListCrewList_next.value=false;
    _isLoadingRankingListIndiv_next.value=false;
    if(tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      _myBox_title.value = '${resortFullNameList[selectedResortNum-1]} 일간통계';
      _myBox_score.value = '개인 점수';
      _myBox_ranking.value = '개인 랭킹';
    } else if (tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      _myBox_title.value = '${resortFullNameList[selectedResortNum-1]} 누적통계';
      _myBox_score.value = '개인 점수';
      _myBox_ranking.value = '개인 랭킹';
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간'){
      _myBox_title.value = '일간 전체 스키장';
      _myBox_score.value = '개인 점수';
      _myBox_ranking.value = '개인 랭킹';
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적'){
      _myBox_title.value = '누적 전체 스키장';
      _myBox_score.value = '개인 점수';
      _myBox_ranking.value = '개인 랭킹';
    } else if(tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      _myBox_title.value = '일간 ${nicknameList[selectedResortNum-1]}';
      _myBox_score.value = '크루 점수';
      _myBox_ranking.value = '크루 랭킹';
    } else if (tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      _myBox_title.value = '누적 ${nicknameList[selectedResortNum-1]}';
      _myBox_score.value = '크루 점수';
      _myBox_ranking.value = '크루 랭킹';
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간'){
      _myBox_title.value = '일간 전체 스키장';
      _myBox_score.value = '크루 점수';
      _myBox_ranking.value = '크루 랭킹';
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적'){
      _myBox_title.value = '누적 전체 스키장';
      _myBox_score.value = '크루 점수';
      _myBox_ranking.value = '크루 랭킹';
    }
  }

  Future<void> toggleDataDayOrTotal({int? resortNum}) async{
    if(tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      await fetchRankingDataIndiv_resort_daily(userId: _userViewModel.user.user_id, resortId: resortNum,daily: true,selected_season:  _selectedCategory_season_db.value);
      _rankingListIndivList_view.value = _rankingListIndivList_resort_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_resort_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      await fetchRankingDataIndiv_resort(userId: _userViewModel.user.user_id, resortId: resortNum,selected_season:  _selectedCategory_season_db.value);
      _rankingListIndivList_view.value = _rankingListIndivList_resort;
      _rankingListIndivMy_view.value = _rankingListIndivMy_resort.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed == '리그별 랭킹'){
      //await fetchRankingDataIndiv_total_daily(userId: _userViewModel.user.user_id,daily: true);
      _rankingListIndivList_view.value = _rankingListIndivList_total_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_total_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed == '리그별 랭킹'){
      //await fetchRankingDataIndiv_total(userId: _userViewModel.user.user_id);
      _rankingListIndivList_view.value = _rankingListIndivList_total;
      _rankingListIndivMy_view.value = _rankingListIndivMy_total.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed != '리그별 랭킹'){
      //await fetchRankingDataIndiv_total_daily(userId: _userViewModel.user.user_id,daily: true);
      _rankingListIndivList_view.value = _rankingListIndivList_fed_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_fed_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed != '리그별 랭킹'){
      //await fetchRankingDataIndiv_total(userId: _userViewModel.user.user_id);
      _rankingListIndivList_view.value = _rankingListIndivList_fed;
      _rankingListIndivMy_view.value = _rankingListIndivMy_fed.value;
    } else if(tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      await fetchRankingDataCrew_resort_daily(userId: _userViewModel.user.user_id, resortId: resortNum,daily: true,selected_season:  _selectedCategory_season_db.value);
      _rankingListCrewList_view.value = _rankingListCrewList_resort_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_resort_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      await fetchRankingDataCrew_resort(userId: _userViewModel.user.user_id, resortId: resortNum,selected_season:  _selectedCategory_season_db.value);
      _rankingListCrewList_view.value = _rankingListCrewList_resort;
      _rankingListCrewMy_view.value = _rankingListCrewMy_resort.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed == '리그별 랭킹'){
      //await fetchRankingDataCrew_total_daily(userId: _userViewModel.user.user_id,daily: true);
      _rankingListCrewList_view.value = _rankingListCrewList_total_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_total_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed == '리그별 랭킹'){
      //await fetchRankingDataCrew_total(userId: _userViewModel.user.user_id);
      _rankingListCrewList_view.value = _rankingListCrewList_total;
      _rankingListCrewMy_view.value = _rankingListCrewMy_total.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed != '리그별 랭킹'){
      //await fetchRankingDataCrew_total_daily(userId: _userViewModel.user.user_id,daily: true);
      _rankingListCrewList_view.value = _rankingListCrewList_fed_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_fed_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed != '리그별 랭킹'){
      //await fetchRankingDataCrew_total(userId: _userViewModel.user.user_id);
      _rankingListCrewList_view.value = _rankingListCrewList_fed;
      _rankingListCrewMy_view.value = _rankingListCrewMy_fed.value;
    }
  }

  Future<void> toggleDataDayOrTotal_refresh({int? resortNum}) async{
    if(tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      //_isLoadingRankingListIndiv_resort_daily.value = true;
      await fetchRankingDataIndiv_resort_daily(userId: _userViewModel.user.user_id, resortId: resortNum,daily: true,selected_season:  _selectedCategory_season_db.value);
      //_isLoadingRankingListIndiv_resort_daily.value = false;
      _rankingListIndivList_view.value = _rankingListIndivList_resort_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_resort_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      //_isLoadingRankingListIndiv_resort.value = true;
      await fetchRankingDataIndiv_resort(userId: _userViewModel.user.user_id, resortId: resortNum,selected_season:  _selectedCategory_season_db.value);
      //_isLoadingRankingListIndiv_resort.value = false;
      _rankingListIndivList_view.value = _rankingListIndivList_resort;
      _rankingListIndivMy_view.value = _rankingListIndivMy_resort.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed == '리그별 랭킹'){
      //_isLoadingRankingListIndiv_total_daily.value = true;
      await fetchRankingDataIndiv_total_daily(userId: _userViewModel.user.user_id,daily: true,selected_season:  _selectedCategory_season_db.value);
      //_isLoadingRankingListIndiv_total_daily.value = false;
      _rankingListIndivList_view.value = _rankingListIndivList_total_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_total_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed == '리그별 랭킹'){
      //_isLoadingRankingListIndiv_total.value = true;
      await fetchRankingDataIndiv_total(userId: _userViewModel.user.user_id,selected_season:  _selectedCategory_season_db.value);
      //_isLoadingRankingListIndiv_total.value = false;
      _rankingListIndivList_view.value = _rankingListIndivList_total;
      _rankingListIndivMy_view.value = _rankingListIndivMy_total.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed != '리그별 랭킹'){
      //_isLoadingRankingListIndiv_total_daily.value = true;
      await fetchRankingDataIndiv_fed_daily(userId: _userViewModel.user.user_id,daily: true,selected_season:  _selectedCategory_season_db.value, federation: selectedCategory_fed);
      //_isLoadingRankingListIndiv_total_daily.value = false;
      _rankingListIndivList_view.value = _rankingListIndivList_fed_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_fed_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed != '리그별 랭킹'){
      //_isLoadingRankingListIndiv_total.value = true;
      await fetchRankingDataIndiv_fed(userId: _userViewModel.user.user_id,selected_season:  _selectedCategory_season_db.value,federation: selectedCategory_fed);
      //_isLoadingRankingListIndiv_total.value = false;
      _rankingListIndivList_view.value = _rankingListIndivList_fed;
      _rankingListIndivMy_view.value = _rankingListIndivMy_fed.value;
    } else if(tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      //_isLoadingRankingListCrewList_resort_daily.value = true;
      await fetchRankingDataCrew_resort_daily(userId: _userViewModel.user.user_id, resortId: resortNum,daily: true,selected_season:  _selectedCategory_season_db.value);
      //_isLoadingRankingListCrewList_resort_daily.value = false;
      _rankingListCrewList_view.value = _rankingListCrewList_resort_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_resort_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      //_isLoadingRankingListCrewList_resort.value = true;
      await fetchRankingDataCrew_resort(userId: _userViewModel.user.user_id, resortId: resortNum,selected_season:  _selectedCategory_season_db.value);
      //_isLoadingRankingListCrewList_resort.value = false;
      _rankingListCrewList_view.value = _rankingListCrewList_resort;
      _rankingListCrewMy_view.value = _rankingListCrewMy_resort.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed == '리그별 랭킹'){
      //_isLoadingRankingListCrewList_total_daily.value = true;
      await fetchRankingDataCrew_total_daily(userId: _userViewModel.user.user_id,daily: true,selected_season:  _selectedCategory_season_db.value);
      //_isLoadingRankingListCrewList_total_daily.value = false;
      _rankingListCrewList_view.value = _rankingListCrewList_total_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_total_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed == '리그별 랭킹'){
      //_isLoadingRankingListCrewList_total.value = true;
      await fetchRankingDataCrew_total(userId: _userViewModel.user.user_id,selected_season:  _selectedCategory_season_db.value);
      //_isLoadingRankingListCrewList_total.value = false;
      _rankingListCrewList_view.value = _rankingListCrewList_total;
      _rankingListCrewMy_view.value = _rankingListCrewMy_total.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed != '리그별 랭킹'){
      //_isLoadingRankingListCrewList_total_daily.value = true;
      await fetchRankingDataCrew_fed_daily(userId: _userViewModel.user.user_id,daily: true,selected_season:  _selectedCategory_season_db.value,federation: selectedCategory_fed);
      //_isLoadingRankingListCrewList_total_daily.value = false;
      _rankingListCrewList_view.value = _rankingListCrewList_fed_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_fed_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed != '리그별 랭킹'){
      //_isLoadingRankingListCrewList_total.value = true;
      await fetchRankingDataCrew_fed(userId: _userViewModel.user.user_id,selected_season:  _selectedCategory_season_db.value,federation: selectedCategory_fed);
      //_isLoadingRankingListCrewList_total.value = false;
      _rankingListCrewList_view.value = _rankingListCrewList_fed;
      _rankingListCrewMy_view.value = _rankingListCrewMy_fed.value;
    }
  }

  Future<void> toggleDataDayOrTotal_tapFilter({int? resortNum}) async{
    if(tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      _isLoadingRankingListIndiv_total.value=true;
      _isLoadingRankingListIndiv_total_daily.value=true;
      await fetchRankingDataIndiv_resort_daily(userId: _userViewModel.user.user_id, resortId: resortNum,daily: true,selected_season:  _selectedCategory_season_db.value);
      _isLoadingRankingListIndiv_total.value=false;
      _isLoadingRankingListIndiv_total_daily.value=false;
      _rankingListIndivList_view.value = _rankingListIndivList_resort_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_resort_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      _isLoadingRankingListIndiv_total.value=true;
      _isLoadingRankingListIndiv_total_daily.value=true;
      await fetchRankingDataIndiv_resort(userId: _userViewModel.user.user_id, resortId: resortNum,selected_season:  _selectedCategory_season_db.value);
      _isLoadingRankingListIndiv_total.value=false;
      _isLoadingRankingListIndiv_total_daily.value=false;
      _rankingListIndivList_view.value = _rankingListIndivList_resort;
      _rankingListIndivMy_view.value = _rankingListIndivMy_resort.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed == '리그별 랭킹'){
      // _isLoadingRankingListIndiv_total.value=true;
      // _isLoadingRankingListIndiv_total_daily.value=true;
      // await fetchRankingDataIndiv_total_daily(userId: _userViewModel.user.user_id,daily: true);
      _isLoadingRankingListIndiv_total.value=false;
      _isLoadingRankingListIndiv_total_daily.value=false;
      _rankingListIndivList_view.value = _rankingListIndivList_total_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_total_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed == '리그별 랭킹'){
      // _isLoadingRankingListIndiv_total.value=true;
      // _isLoadingRankingListIndiv_total_daily.value=true;
      // await fetchRankingDataIndiv_total(userId: _userViewModel.user.user_id);
      _isLoadingRankingListIndiv_total.value=false;
      _isLoadingRankingListIndiv_total_daily.value=false;
      _rankingListIndivList_view.value = _rankingListIndivList_total;
      _rankingListIndivMy_view.value = _rankingListIndivMy_total.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed != '리그별 랭킹'){
      _isLoadingRankingListIndiv_total.value=true;
      _isLoadingRankingListIndiv_total_daily.value=true;
      await fetchRankingDataIndiv_fed_daily(userId: _userViewModel.user.user_id,daily: true,federation: selectedCategory_fed);
      _isLoadingRankingListIndiv_total.value=false;
      _isLoadingRankingListIndiv_total_daily.value=false;
      _rankingListIndivList_view.value = _rankingListIndivList_fed_daily;
      _rankingListIndivMy_view.value = _rankingListIndivMy_fed_daily.value;
    } else if (tapName == '개인랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed != '리그별 랭킹'){
      _isLoadingRankingListIndiv_total.value=true;
      _isLoadingRankingListIndiv_total_daily.value=true;
      await fetchRankingDataIndiv_fed(userId: _userViewModel.user.user_id,selected_season:  _selectedCategory_season_db.value, federation: selectedCategory_fed);
      _isLoadingRankingListIndiv_total.value=false;
      _isLoadingRankingListIndiv_total_daily.value=false;
      _rankingListIndivList_view.value = _rankingListIndivList_fed;
      _rankingListIndivMy_view.value = _rankingListIndivMy_fed.value;
    } else if(tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '일간'){
      _isLoadingRankingListCrewList_total.value=true;
      _isLoadingRankingListCrewList_total_daily.value=true;
      await fetchRankingDataCrew_resort_daily(userId: _userViewModel.user.user_id, resortId: resortNum,daily: true,selected_season:  _selectedCategory_season_db.value);
      _isLoadingRankingListCrewList_total.value=false;
      _isLoadingRankingListCrewList_total_daily.value=false;
      _rankingListCrewList_view.value = _rankingListCrewList_resort_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_resort_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '개별스키장' && dayOrTotal == '누적'){
      _isLoadingRankingListCrewList_total.value=true;
      _isLoadingRankingListCrewList_total_daily.value=true;
      await fetchRankingDataCrew_resort(userId: _userViewModel.user.user_id, resortId: resortNum,selected_season:  _selectedCategory_season_db.value);
      _isLoadingRankingListCrewList_total.value=false;
      _isLoadingRankingListCrewList_total_daily.value=false;
      _rankingListCrewList_view.value = _rankingListCrewList_resort;
      _rankingListCrewMy_view.value = _rankingListCrewMy_resort.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed == '리그별 랭킹'){
      _isLoadingRankingListCrewList_total.value=false;
      _isLoadingRankingListCrewList_total_daily.value=false;
      _rankingListCrewList_view.value = _rankingListCrewList_total_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_total_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed == '리그별 랭킹'){
      _isLoadingRankingListCrewList_total.value=false;
      _isLoadingRankingListCrewList_total_daily.value=false;
      _rankingListCrewList_view.value = _rankingListCrewList_total;
      _rankingListCrewMy_view.value = _rankingListCrewMy_total.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '일간' && selectedCategory_fed != '리그별 랭킹'){
      _isLoadingRankingListCrewList_total.value=true;
      _isLoadingRankingListCrewList_total_daily.value=true;
      await fetchRankingDataCrew_fed_daily(userId: _userViewModel.user.user_id,daily: true,federation: selectedCategory_fed);
      _isLoadingRankingListCrewList_total.value=false;
      _isLoadingRankingListCrewList_total_daily.value=false;
      _rankingListCrewList_view.value = _rankingListCrewList_fed_daily;
      _rankingListCrewMy_view.value = _rankingListCrewMy_fed_daily.value;
    } else if (tapName == '크루랭킹' && resortOrTotal == '전체스키장' && dayOrTotal == '누적' && selectedCategory_fed != '리그별 랭킹'){
      _isLoadingRankingListCrewList_total.value=true;
      _isLoadingRankingListCrewList_total_daily.value=true;
      await fetchRankingDataCrew_fed(userId: _userViewModel.user.user_id,selected_season:  _selectedCategory_season_db.value, federation: selectedCategory_fed);
      _isLoadingRankingListCrewList_total.value=false;
      _isLoadingRankingListCrewList_total_daily.value=false;
      _rankingListCrewList_view.value = _rankingListCrewList_fed;
      _rankingListCrewMy_view.value = _rankingListCrewMy_fed.value;
    }
  }

  Future<void> fetchRankingDataCrew_fed({
    required int userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url, // URL 추가
    String? federation
  }) async {
    print('fetchRankingDataCrew_fed 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
          selected_season: selected_season,
        url: url, // URL 전달
        federation: federation
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel_recordRoom.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListCrewList_fed.value = rankingListCrewResponse.rankingResults!.results!;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListCrewList_fed.addAll(rankingListCrewResponse.rankingResults!.results ?? []);
        }
        _rankingListCrewMy_fed.value=rankingListCrewResponse.myCrewRankingInfo;
        _nextPageUrl_crew_fed.value = rankingListCrewResponse.rankingResults!.next ?? '';
      } else {
        print('Failed to load crew ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew ranking: $e');
    } finally {
      isLoading(false);
    }
    print('fetchRankingDataCrew_fed 끝');
  }

  Future<void> fetchRankingDataCrew_fed_daily({
    required int userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url, // URL 추가
    String? federation
  }) async {
    print('fetchRankingDataCrew_fed_daily 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
          selected_season: selected_season,
        url: url, // URL 전달
        federation: federation
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel_recordRoom.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListCrewList_fed_daily.value = rankingListCrewResponse.rankingResults!.results!;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListCrewList_fed_daily.addAll(rankingListCrewResponse.rankingResults!.results ?? []);
        }
        _rankingListCrewMy_fed_daily.value=rankingListCrewResponse.myCrewRankingInfo;
        _nextPageUrl_crew_fed_daily.value = rankingListCrewResponse.rankingResults!.next ?? '';
      } else {
        print('Failed to load crew ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching crew ranking: $e');
    } finally {
      isLoading(false);
    }
    print('fetchRankingDataCrew_fed_daily 끝');
  }

  Future<void> fetchRankingDataIndiv_fed({
    required int userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url,
    String? federation
  }) async {
    print('fetchRankingDataIndiv_fed 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url,
        federation: federation,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse_recordRoom.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListIndivList_fed.value = rankingListIndivResponse.results!.rankingUsers;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListIndivList_fed.addAll(rankingListIndivResponse.results!.rankingUsers);
        }
        _rankingListIndivMy_fed.value=rankingListIndivResponse.myRankingInfo;
        _nextPageUrl_indiv_fed.value = rankingListIndivResponse.results!.next ?? '';
      } else {
        print('Failed to load individual ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual ranking: $e');
    } finally {
      isLoading(false);
    }
    print('fetchRankingDataIndiv_fed 끝');
  }

  Future<void> fetchRankingDataIndiv_fed_daily({
    required int userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url,
    String? federation
  }) async {
    print('fetchRankingDataIndiv_fed_daily 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url,
        federation: federation
      );


      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse_recordRoom.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          _rankingListIndivList_fed_daily.value = rankingListIndivResponse.results!.rankingUsers;
        } else {
          // URL이 있을 경우 리스트에 추가
          _rankingListIndivList_fed_daily.addAll(rankingListIndivResponse.results!.rankingUsers );
        }
        _rankingListIndivMy_fed_daily.value=rankingListIndivResponse.myRankingInfo;
        _nextPageUrl_indiv_fed_daily.value = rankingListIndivResponse.results!.next ?? '';
      } else {
        print('Failed to load individual ranking: ${response.error}');
      }
    } catch (e) {
      print('Error fetching individual ranking: $e');
    } finally {
      isLoading(false);
    }
    print('fetchRankingDataIndiv_fed_daily 끝');
  }

  Future<void> fetchRankingDataIndiv_total({
    required int userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url,
  }) async {
    print('fetchRankingDataIndiv_total 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse_recordRoom.fromJson(response.data!);

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
    String? selected_season,
    String? url,
  }) async {
    print('fetchRankingDataIndiv_resort 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse_recordRoom.fromJson(response.data!);

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
    String? selected_season,
    String? url,
  }) async {
    print('fetchRankingDataIndiv_total_daily 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url,
      );


      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse_recordRoom.fromJson(response.data!);

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
    String? selected_season,
    String? url,
  }) async {
    print('fetchRankingDataIndiv_resort_daily 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_indiv_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url,
      );

      if (response.success) {
        final rankingListIndivResponse = RankingListIndivResponse_recordRoom.fromJson(response.data!);

        if (url == null) {
          // URL이 null일 경우 데이터 설정
          print('결과 프린트 ${rankingListIndivResponse.results}');
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
    String? selected_season,
    String? url, // URL 추가
  }) async {
    print('fetchRankingDataCrew_total 시작');
    try {
      isLoading(true);
      print('크루전체 패치시작');
      print(selected_season);
      final response = await RankingAPI().fetchRankingData_crew_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url, // URL 전달
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel_recordRoom.fromJson(response.data!);

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
    print('fetchRankingDataCrew_total 끝');
  }

  Future<void> fetchRankingDataCrew_resort({
    required int userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url, // URL 추가
  }) async {
    print('fetchRankingDataCrew_resort 시작');

    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url, // URL 전달
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel_recordRoom.fromJson(response.data!);

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
    print('fetchRankingDataCrew_resort 끝');
  }


  Future<void> fetchRankingDataCrew_total_daily({
    required int userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url, // URL 추가
  }) async {
    print('fetchRankingDataCrew_total_daily 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url, // URL 전달
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel_recordRoom.fromJson(response.data!);

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
    print('fetchRankingDataCrew_total_daily 끝');
  }

  Future<void> fetchRankingDataCrew_resort_daily({
    required int userId,
    int? resortId,
    bool? daily,
    String? selected_season,
    String? url, // URL 추가
  }) async {
    print('fetchRankingDataCrew_resort_daily 시작');
    try {
      isLoading(true);
      final response = await RankingAPI().fetchRankingData_crew_recordRoom(
        userId: userId,
        resortId: resortId,
        daily: daily,
        selected_season: selected_season,
        url: url, // URL 전달
      );

      if (response.success) {
        final rankingListCrewResponse = RankingListCrewModel_recordRoom.fromJson(response.data!);

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
    print('fetchRankingDataCrew_resort_daily 끝');
  }

  void changeCategory_resort(value) {
    _selectedCategory_resort.value = value;
  }

  void changeCategory_season(value) {
    _selectedCategory_season.value = value;
    if(value=='24/25시즌')
    _selectedCategory_season_db.value = '2425';
    if(value=='23/24시즌')
      _selectedCategory_season_db.value = '2324';

  }

  void changeCategory_fed(value) {
    _selectedCategory_fed.value = value;
  }

  @override
  void onClose() {
    // 메모리 누수 방지: ScrollController 리스너 해제 및 dispose
    scrollController_indiv.removeListener(_scrollListener_indiv);
    scrollController_crew.removeListener(_scrollListener_crew);
    scrollController_indiv.dispose();
    scrollController_crew.dispose();
    super.onClose();
  }
}

enum RankingFilter_season {
  season2425("24/25시즌", "2425"),
  season2324("23/24시즌", "2324");

  final String korean;
  final String dbSeason;
  const RankingFilter_season(this.korean, this.dbSeason);
}

