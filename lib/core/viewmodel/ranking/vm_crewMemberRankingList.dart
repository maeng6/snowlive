import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/core/api/api_crew.dart';

class CrewRankingListViewModel extends GetxController {
  var crewRankingResponse = CrewRankingResponse().obs; // 크루 랭킹 데이터를 저장
  RxBool isLoading = false.obs; // 로딩 상태 관리

  // 크루 랭킹 리스트
  List<CrewRanking> get crewRankings => crewRankingResponse.value.rankingResults ?? [];

  // 크루 랭킹 데이터를 가져오는 메서드
  Future<void> fetchCrewRankings({
    required int crewId,
    required int userId,
    required String season, // 추가된 season 파라미터
  }) async {
    isLoading.value = true; // 로딩 시작
    try {
      final response = await CrewAPI().getCrewRanking(
        crewId: crewId,
        userId: userId,
        season: season, // season 전달
      );

      if (response.success && response.data is Map<String, dynamic>) {
        // JSON 데이터를 모델에 저장
        crewRankingResponse.value = CrewRankingResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        print('크루 랭킹 데이터를 가져오는 중 오류 발생: ${response.error}');
      }
    } catch (e) {
      print('크루 랭킹 데이터를 가져오는 중 예외 발생: $e');
    } finally {
      isLoading.value = false; // 로딩 종료
    }
  }


}
