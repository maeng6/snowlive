import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_ranking.dart';
import 'package:com.snowlive/model/m_slolpe_rush.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class SlopeRushViewModel extends GetxController {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final _api = RankingAPI();

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
  final items = <SlopeRushItem>[].obs;
  final selectedSlope = Rxn<SlopeRushItem>();

  // ------------------------
  // 점령도 조회
  // POST /ranking/slope-rush/ { resort_id, user_id }
  // ------------------------
  Future<void> fetchSlopeRush({required int resort_id}) async {
    try {
      isLoading(true);

      final userId = _userViewModel.user.user_id;
      final body = {
        'resort_id': resort_id,
        'user_id': userId,
      };

      final ApiResponse res = await _api.fetchSlopeRush(body);

      if (res.success) {
        final parsed = SlopeRushResponse.fromJson(res.data!);
        resortId.value = parsed.resortId;
        resortFullname.value = parsed.resortFullname;
        items.value = parsed.slopeRush;
      } else {
        print('❌ fetchSlopeRush 실패: ${res.error}');
        items.clear();
      }
    } catch (e) {
      print('⚠️ fetchSlopeRush 예외: $e');
      items.clear();
    } finally {
      isLoading(false);
    }
  }

  // ------------------------
  // 슬로프 선택 (UI에서 사용자가 특정 슬로프를 눌렀을 때)
  // ------------------------
  void selectSlope(String slopeFullname) {
    final found = items.firstWhereOrNull((e) => e.slopeFullname == slopeFullname);
    selectedSlope.value = found;
  }

  // ------------------------
  // 유틸: 특정 슬로프의 상위 N개 크루
  // ------------------------
  List<SlopeCrew> topCrewsOf(String slopeFullname, {int topN = 5}) {
    final it = items.firstWhereOrNull((e) => e.slopeFullname == slopeFullname);
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
  Future<void> refreshRush({required int resortIdArg}) async {
    await fetchSlopeRush(resort_id: resortIdArg);
  }
}