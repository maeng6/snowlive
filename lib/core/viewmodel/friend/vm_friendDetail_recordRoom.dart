import 'package:com.snowlive/core/api/ApiResponse.dart';
import 'package:com.snowlive/core/api/api_friendDetail.dart';
import 'package:com.snowlive/core/model/m_friendDetail_recordRoom.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingIndivHistory.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class FriendDetailViewModel_recordRoom extends GetxController {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final RankingIndivHistoryViewModel _rankingIndivHistoryViewModel = Get.find<RankingIndivHistoryViewModel>();

  static const ridingStatisticsTabNameListConst = [
    '누적 통계',
    '일간 통계'
  ];

  late RxList<String> ridingStatisticsTabNameList;
  late RxString _ridingStatisticsTabName;

  @override
  void onInit() async {
    super.onInit();

    ridingStatisticsTabNameList = <String>[
      '누적 통계',
      '일간 통계'
    ].obs;

    _ridingStatisticsTabName = ridingStatisticsTabNameList[0].obs;

    await fetchFriendDetailInfo_recordRoom(
      userId: _userViewModel.user.user_id,
      friendUserId: _userViewModel.user.user_id,
      selected_season: '2526',
    );

    await getCurrentSeason();
  }



  var _friendDetailModel_recordRoom = FriendDetailModel_recordRoom().obs;
  var findFriendInfo = <int, Map<String, String>>{}.obs;

  RxString _seasonDate = ''.obs;
  var isLoading = false.obs;
  RxString _seasonStartDate=''.obs;
  RxString _seasonEndDate=''.obs;
  RxInt _selectedDailyIndex=0.obs;
  RxInt _friend_id=0.obs;
  RxMap<String, dynamic> _passCountData = <String, dynamic>{}.obs;
  RxMap<String, dynamic> _passCountTimeData = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> _barData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> _barData2 = <Map<String, dynamic>>[].obs;

  ApiResponse? response;

  dynamic get friendDetailModel_recordRoom => _friendDetailModel_recordRoom.value;
  String get seasonDate => _seasonDate.value;
  String get seasonStartDate => _seasonStartDate.value;
  String get seasonEndDate => _seasonEndDate.value;
  String get ridingStatisticsTabName => _ridingStatisticsTabName.value;
  int get friend_id => _friend_id.value;
  int get selectedDailyIndex => _selectedDailyIndex.value;
  List<Map<String, dynamic>> get barData => _barData;
  List<Map<String, dynamic>> get barData2 => _barData2;
  Map<String, dynamic> get passCountData => _passCountData;
  Map<String, dynamic> get passCountTimeData => _passCountTimeData;

  Future<void> fetchFriendDetailInfo_recordRoom({required int userId, required int friendUserId, required String selected_season, bool isFromRefresh = false,}) async {
    isLoading(true);
    try {
      ApiResponse response = await FriendDetailAPI().fetchFriendDetail_recordRoom(userId, friendUserId, selected_season);
      if (response.success) {
        _friendDetailModel_recordRoom.value = response.data as FriendDetailModel_recordRoom;
      } else {
        if (!isFromRefresh) {
          Get.back();
        }
        Get.snackbar('Error', '데이터 로딩 실패');
      }
    } catch (e) {
      print('❌ fetchFriendDetailInfo_recordRoom 에러: $e');
      if (!isFromRefresh) {
        Get.back();
      }
      Get.snackbar('Error', '데이터 로딩 실패');
    } finally {
      isLoading(false);
    }
  }

  void changeRidingStaticTab(int index)  {
    _ridingStatisticsTabName.value = ridingStatisticsTabNameList[index];
  }

  void updateSelectedDailyIndex(int index) {
    _selectedDailyIndex.value = index;
  }

  Future<void> getCurrentSeason({String? season}) async {
    final target = season ?? _rankingIndivHistoryViewModel.selectedCategory_season;
    if (target == '25/26시즌') {
      _seasonStartDate.value = '2025-11-01';
      _seasonEndDate.value = '2026-03-31';
    } else if (target == '24/25시즌') {
      _seasonStartDate.value = '2024-11-01';
      _seasonEndDate.value = '2025-03-31';
    } else if (target == '23/24시즌') {
      _seasonStartDate.value = '2023-11-01';
      _seasonEndDate.value = '2024-03-31';
    }
    String seasonDate = "${_seasonStartDate.value}, ${_seasonEndDate.value}";
    _seasonDate.value = seasonDate;
    print('선택된 시즌 : $seasonDate');
  }



}

