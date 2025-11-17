import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/model/m_slolpe_rush_recordRoom.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class SlopeRushRecordRoomViewModel extends GetxController {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final RankingAPI _api = RankingAPI();

  // ------------------------
  // UI 상태
  // ------------------------
  var isLoading = false.obs;
  final _isLoadingDetail = false.obs;

  bool get loadingDetail => _isLoadingDetail.value;
  set loadingDetail(bool v) => _isLoadingDetail.value = v;

  // ------------------------
  // 데이터 상태
  // ------------------------
  final RxInt resortId = 0.obs;
  final RxString resortFullname = ''.obs;
  final items = <SlopeRushRecordRoomItem>[].obs;
  final selectedSlope = Rxn<SlopeRushRecordRoomItem>();

  // ------------------------
  // RecordRoom 점령도 조회
  // POST /slope-rush-recordroom/
  // { resort_id, user_id, selected_season }
  // ------------------------
  Future<void> fetchSlopeRushRecordRoom({
    required int resortIdArg,
    required String selectedSeason,
  }) async {
    print('기록실 페치시작');
    try {
      isLoading(true);

      final userId = _userViewModel.user.user_id;

      final body = {
        'resort_id': resortIdArg,
        'user_id': userId,
        'selected_season': selectedSeason,
      };

      final ApiResponse res = await _api.fetchSlopeRush_recordRoom(body);

      if (res.success) {
        final parsed =
        SlopeRushRecordRoomResponse.fromJson(res.data!);

        resortId.value = parsed.resortId;
        resortFullname.value = parsed.resortFullname;
        items.value = parsed.slopeRush;
      } else {
        print('❌ fetchSlopeRushRecordRoom 실패: ${res.error}');
        items.clear();
      }
      print('기록실 페치완료');
    } catch (e) {
      print('⚠️ fetchSlopeRushRecordRoom 예외: $e');
      items.clear();
    } finally {
      isLoading(false);
    }
  }

  // ------------------------
  // 슬로프 선택
  // ------------------------
  void selectSlope(String slopeFullname) {
    final found =
    items.firstWhereOrNull((e) => e.slopeFullname == slopeFullname);
    selectedSlope.value = found;
  }

  // ------------------------
  // 특정 슬로프 상위 N개 크루
  // ------------------------
  List<SlopeRushRecordRoomCrew> topCrewsOf(
      String slopeFullname, {
        int topN = 5,
      }) {
    final it =
    items.firstWhereOrNull((e) => e.slopeFullname == slopeFullname);
    if (it == null) return const [];

    final list = [...it.crews];

    list.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      if (byCount != 0) return byCount;
      return b.ratio.compareTo(a.ratio);
    });

    if (list.length <= topN) return list;
    return list.sublist(0, topN);
  }

  // ------------------------
  // 새로고침
  // ------------------------
  Future<void> refreshRecordRoom({
    required int resortIdArg,
    required String selectedSeason,
  }) async {
    await fetchSlopeRushRecordRoom(
      resortIdArg: resortIdArg,
      selectedSeason: selectedSeason,
    );
  }
}