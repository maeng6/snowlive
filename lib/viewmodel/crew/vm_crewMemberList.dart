import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_crewMemberList.dart';
import 'package:com.snowlive/api/api_crew.dart';

class CrewMemberListViewModel extends GetxController {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  // 크루 멤버 리스트와 관련된 Rx 변수들
  var crewMemberListResponse = CrewMemberListResponse().obs;  // Rx로 변경

  // totalMemberCount와 liveMemberCount를 모델에서 바로 가져옴
  int get totalMemberCount => crewMemberListResponse.value.totalMemberCount ?? 0;
  int get liveMemberCount => crewMemberListResponse.value.liveMemberCount ?? 0;
  List<CrewMember> get crewMembersList => crewMemberListResponse.value.crewMembers ?? [];


  // 로딩 상태 관리
  RxBool isLoading = false.obs;

  // 크루장 이름을 관리할 Rx 변수
  RxString crewLeaderName = ''.obs;

  // 크루 멤버 데이터를 불러오는 메소드
  Future<void> fetchCrewMembers({required int crewId}) async {
    isLoading.value = true; // 로딩 시작
    try {
      final response = await CrewAPI().listCrewMembers(crewId);

      if (response.success) {
        var jsonResponse = response.data as Map<String, dynamic>;
        crewMemberListResponse.value = CrewMemberListResponse.fromJson(jsonResponse);

        // 크루장 이름을 가져와 crewLeaderName에 저장
        await findCrewLeaderName();  // await으로 크루장 이름 업데이트 완료 후 진행
      } else {
        print('크루 멤버를 불러오는 중 오류 발생: ${response.error}');
      }
    } catch (e) {
      print('크루 멤버 데이터를 가져오는 중 예외 발생: $e');
    } finally {
      isLoading.value = false; // 로딩 종료
    }
  }

  // 크루장 이름을 업데이트하는 메서드
  Future<void> findCrewLeaderName() async {
    try {
      // crewMembersList에서 status가 "크루장"인 멤버를 찾음
      CrewMember? crewLeader = crewMembersList.firstWhere((member) => member.status == "크루장");
      crewLeaderName.value = crewLeader.userInfo?.displayName ?? '';
    } catch (e) {
      print('크루장을 찾는 중 오류 발생: $e');
      crewLeaderName.value = '';
    }
  }

  // 작성자의 역할을 찾아주는 메서드
  String getMemberRole(int userId) {
    final member = crewMembersList.firstWhere(
          (member) => member.userInfo?.userId == userId,
      orElse: () => CrewMember(status: '크루원'), // 기본 값은 크루원
    );
    return member.status ?? '크루원'; // 상태가 null일 경우 기본값으로 '크루원' 반환
  }

  Color getRoleColorBox(String role) {
    switch (role) {
      case '크루장':
        return SDSColor.snowliveBlue; // 크루장일 때 색상
      case '운영진':
        return SDSColor.gray800; // 운영진일 때 색상
      default:
        return SDSColor.gray100; // 크루원일 때 색상
    }
  }

  Color getRoleColorText(String role) {
    switch (role) {
      case '크루장':
        return SDSColor.snowliveWhite; // 크루장일 때 색상
      case '운영진':
        return SDSColor.snowliveWhite; // 운영진일 때 색상
      default:
        return SDSColor.snowliveBlack; // 크루원일 때 색상
    }
  }

  // 멤버 롤 업데이트 메소드
  Future<void> updateCrewMemberStatus({
    required int crewMemberUserId,
    required String newStatus,
  }) async {
    // 보낼 데이터 맵 구성
    Map<String, dynamic> statusData = {
      'user_id': _userViewModel.user.user_id,
      'crew_id': _userViewModel.user.crew_id,
      'crew_member_user_id': crewMemberUserId,
      'status': newStatus,
    };

    try {
      // API 호출
      final response = await CrewAPI().updateCrewMemberStatus(statusData);

      // 성공적으로 롤 업데이트된 경우 처리
      if (response.success) {
        print("크루 멤버 상태가 $newStatus 로 성공적으로 업데이트되었습니다.");
        // 여기서 필요한 로직 추가 (예: UI 업데이트, 리스트 갱신 등)
      } else {
        print('롤 변경 중 오류 발생: ${response.error}');
      }
    } catch (e) {
      // 예외 처리
      print('롤 변경 중 예외 발생: $e');
    }
  }

  // 크루 탈퇴/강퇴 메소드
  Future<void> withdrawCrew({
    required int crewMemberUserId,
  }) async {
    // 보낼 데이터 맵 구성
    Map<String, dynamic> withdrawData = {
      "crew_member_user_id": crewMemberUserId,    //필수
      "user_id": _userViewModel.user.user_id,    //필수
      "crew_id": _userViewModel.user.crew_id    //필수
    };

    try {
      // API 호출
      final response = await CrewAPI().withdrawCrew(withdrawData);

      // 성공적으로 롤 업데이트된 경우 처리
      if (response.success) {
        await fetchCrewMembers(crewId: _userViewModel.user.crew_id);
        await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
        CustomFullScreenDialog.cancelDialog();
        Get.offAllNamed(AppRoutes.mainHome);
        print("성공적으로 탈퇴처리 되었습니다.");
        // 여기서 필요한 로직 추가 (예: UI 업데이트, 리스트 갱신 등)
      } else {
        CustomFullScreenDialog.cancelDialog();
        Get.snackbar('탈퇴 실패', '잠시후 다시 시도해주세요.');
        print('탈퇴 중 오류 발생: ${response.error}');
      }
    } catch (e) {
      CustomFullScreenDialog.cancelDialog();
      // 예외 처리
      print('탈퇴 중 예외 발생: $e');
    }
  }

  Future<void> expelCrewMember({
    required int crewMemberUserId,
  }) async {
    // 보낼 데이터 맵 구성
    Map<String, dynamic> withdrawData = {
      "crew_member_user_id": crewMemberUserId,    //필수
      "user_id": _userViewModel.user.user_id,    //필수
      "crew_id": _userViewModel.user.crew_id    //필수
    };

    try {
      // API 호출
      final response = await CrewAPI().withdrawCrew(withdrawData);

      // 성공적으로 롤 업데이트된 경우 처리
      if (response.success) {
        await fetchCrewMembers(crewId: _userViewModel.user.crew_id);
        await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
        print("성공적으로 탈퇴처리 되었습니다.");
        // 여기서 필요한 로직 추가 (예: UI 업데이트, 리스트 갱신 등)
      } else {
        Get.snackbar('탈퇴 실패', '잠시후 다시 시도해주세요.');
        print('탈퇴 중 오류 발생: ${response.error}');
      }
    } catch (e) {
      // 예외 처리
      print('탈퇴 중 예외 발생: $e');
    }
  }


}
