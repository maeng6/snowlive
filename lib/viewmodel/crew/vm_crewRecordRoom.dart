import 'package:get/get.dart';
import 'package:com.snowlive/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/api/api_crew.dart';

class CrewRecordRoomViewModel extends GetxController {
  var isLoading = false.obs;
  var crewRidingRecords = <CrewRidingRecord>[].obs;

  // 현재 연도와 카드 확장 상태
  var currentYear = DateTime.now().year.obs; // 현재 연도로 초기화
  RxBool isTodayCardExpanded = true.obs;
  RxInt expandedCardIndex = (-1).obs;

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
        // 응답 데이터를 CrewRidingRecord 리스트로 변환
        var ridingRecordResponse = CrewRecordRoomResponse.fromJson(response.data);
        crewRidingRecords.value = ridingRecordResponse.records;
      } else {
        print('Error fetching riding records: ${response.error}');
      }
    } catch (e) {
      print('Exception while fetching riding records: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 시간대별 횟수에서 가장 큰 값 계산
  int getMaxTimeInfoCount(CrewRidingRecord record) {
    return record.timeInfo?.reduce((a, b) => a > b ? a : b) ?? 0;
  }
}
