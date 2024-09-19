import 'package:get/get.dart';
import 'package:com.snowlive/model/m_crewMemberList.dart';
import 'package:com.snowlive/api/api_crew.dart';

class CrewMemberListViewModel extends GetxController {
  // 크루 멤버 리스트와 관련된 Rx 변수들
  var crewMemberListResponse = CrewMemberListResponse().obs;  // Rx로 변경

  // totalMemberCount와 liveMemberCount를 모델에서 바로 가져옴
  int get totalMemberCount => crewMemberListResponse.value.totalMemberCount ?? 0;
  int get liveMemberCount => crewMemberListResponse.value.liveMemberCount ?? 0;
  List<CrewMember> get crewMembersList => crewMemberListResponse.value.crewMembers ?? [];


  // 로딩 상태 관리
  RxBool isLoading = false.obs;


  // 크루 멤버 데이터를 불러오는 메소드
  Future<void> fetchCrewMembers({required int crewId}) async {
    isLoading.value = true; // 로딩 시작
    try {
      final response = await CrewAPI().listCrewMembers(crewId);

      if (response.success) {
        var jsonResponse = response.data as Map<String, dynamic>;
          crewMemberListResponse.value = CrewMemberListResponse.fromJson(jsonResponse);
      } else {
        print('크루 멤버를 불러오는 중 오류 발생: ${response.error}');
      }
    } catch (e) {
      print('크루 멤버 데이터를 가져오는 중 예외 발생: $e');
    } finally {
      isLoading.value = false; // 로딩 종료
    }
  }
}
