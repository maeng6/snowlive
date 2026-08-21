import 'package:com.snowlive/core/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/core/api/api_crew.dart';
import 'package:get/get_rx/get_rx.dart';

class CrewDailyRecordViewModel extends GetxController {
  var isLoading = false.obs;
  var isLoading_refresh = false.obs;
  var crewRidingRecords = <CrewRidingRecord>[].obs;

  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();

  // 현재 시즌 (enum 기반)
  RxBool isTodayCardExpanded = true.obs;
  RxInt expandedCardIndex = (-1).obs;
  var currentYear = DateTime.now().year.obs; // 현재 연도로 초기화

  @override
  void onInit() async{
    super.onInit();
    resetTabs();
    // crewId가 null이면 API 호출 스킵
    final crewId = _crewDetailViewModel.crewDetailInfo.crewId;
    if (crewId != null) {
      await fetchCrewRidingRecords(crewId, currentYear.value.toString());
    }
  }

  // 연도 변경
  void setYear(int year) {
    currentYear.value = year;
  }

  // 특정 카드 확장 상태 변경
  void setExpandedCardIndex(int? index) {
    expandedCardIndex.value = index ?? -1;
  }

  // 탭 및 데이터 초기화
  void resetTabs() {
    currentYear.value = DateTime.now().year; // 현재 연도로 초기화
    expandedCardIndex.value = -1; // 확장된 카드 초기화
    crewRidingRecords.clear(); // 데이터를 비움
  }

  // API 호출을 통해 크루의 라이딩 기록을 가져오는 메서드
  Future<void> fetchCrewRidingRecords(int crewId, String year) async {
    isLoading.value = true;
    try {
      final response = await CrewAPI().getCrewDailyReport(crewId, year);
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

  Future<void> fetchCrewRidingRecords_refresh(int crewId, String year) async {
    isLoading_refresh.value = true;
    try {
      final response = await CrewAPI().getCrewDailyReport(crewId, year);
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
