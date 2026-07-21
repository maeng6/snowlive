import 'package:com.snowlive/model/m_crewMemberRankingList_recordRoom.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList_recordRoom.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/api/api_crew.dart';

class CrewRankingListViewModel_recordRoom extends GetxController {
  var crewRankingResponse = CrewRankingResponse_recordRoom().obs; // 크루 랭킹 데이터를 저장
  RxBool isLoading = false.obs; // 로딩 상태 관리

  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  void onInit() async{
    // TODO: implement onInit
    super.onInit();
    await fetchCrewRankings_recordRoom(crewId: _crewDetailViewModel.crewDetailInfo.crewId!, userId: _userViewModel.user.user_id  ,selected_season:  RankingFilter_season.values.first.dbSeason );
  }

  // 크루 랭킹 리스트
  List<CrewRanking_recordRoom> get crewRankings => crewRankingResponse.value.rankingResults ?? [];

  // 크루 랭킹 데이터를 가져오는 메서드
  Future<void> fetchCrewRankings_recordRoom({
    required int crewId,
    required int userId,
    required String selected_season,
  }) async {
    isLoading.value = true; // 로딩 시작
    try {
      final response = await CrewAPI().getCrewRanking_recordRoom(
        crewId: crewId,
        userId: userId,
        selected_season: selected_season,
      );

      if (response.success && response.data is Map<String, dynamic>) {
        // JSON 데이터를 모델에 저장
        crewRankingResponse.value = CrewRankingResponse_recordRoom.fromJson(response.data as Map<String, dynamic>);
        print('크루원랭킹리스트 페치완료');
      } else {
        print('크루 랭킹 데이터를 가져오는 중 오류 발생: \${response.error}');
      }
    } catch (e) {
      print('크루 랭킹 데이터를 가져오는 중 예외 발생: \$e');
    } finally {
      isLoading.value = false; // 로딩 종료
    }
  }
}