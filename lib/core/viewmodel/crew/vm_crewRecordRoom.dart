import 'package:com.snowlive/core/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/core/api/api_crew.dart';
import 'package:get/get_rx/get_rx.dart';

class CrewRecordRoomViewModel extends GetxController {
  var isLoading = false.obs;
  var isLoading_refresh = false.obs;
  var crewRidingRecords = <CrewRidingRecord>[].obs;

  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();

  // 현재 시즌 (enum 기반)
  RxString currentSeason = '${RankingFilter_season.values.first.dbSeason}'.obs;
  RxBool isTodayCardExpanded = true.obs;
  RxInt expandedCardIndex = (-1).obs;

  @override
  void onInit() async{
    // TODO: implement onInit
    super.onInit();
    resetTabs();
    await fetchCrewRidingRecords(_crewDetailViewModel.crewDetailInfo.crewId!, RankingFilter_season.values.first.dbSeason);
  }

  void setSeason(RankingFilter_season season) {
    final dbSeason = season.dbSeason;
    currentSeason.value = dbSeason;
  }

  // 특정 카드 확장 상태 변경
  void setExpandedCardIndex(int? index) {
    expandedCardIndex.value = index ?? -1;
  }

  // 탭 및 데이터 초기화
  void resetTabs() {
    currentSeason.value = '${RankingFilter_season.values.first.dbSeason}';
    expandedCardIndex.value = -1;
    crewRidingRecords.clear();
  }

  // API 호출을 통해 크루의 라이딩 기록을 가져오는 메서드
  Future<void> fetchCrewRidingRecords(int crewId, String selected_season) async {
    isLoading.value = true;
    try {
      final response = await CrewAPI().getCrewDailyReport_recordRoom(crewId, selected_season);
      if (response.success) {
        var ridingRecordResponse = CrewRecordRoomResponse.fromJson(response.data);
        crewRidingRecords.value = ridingRecordResponse.records;
        print('크루 일일 랭킹 페치완료');
      } else {
        print('Error fetching riding records: \${response.error}');
      }
    } catch (e) {
      print('Exception while fetching riding records: \$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCrewRidingRecords_refresh(int crewId, String selected_season) async {
    isLoading_refresh.value = true;
    try {
      final response = await CrewAPI().getCrewDailyReport_recordRoom(crewId, selected_season);
      if (response.success) {
        var ridingRecordResponse = CrewRecordRoomResponse.fromJson(response.data);
        crewRidingRecords.value = ridingRecordResponse.records;
      } else {
        print('Error fetching riding records: \${response.error}');
      }
    } catch (e) {
      print('Exception while fetching riding records: \$e');
    } finally {
      isLoading_refresh.value = false;
    }
  }

  int getMaxTimeInfoCount(CrewRidingRecord record) {
    return record.timeInfo?.reduce((a, b) => a > b ? a : b) ?? 0;
  }
}
