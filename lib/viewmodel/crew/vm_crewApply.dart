import 'package:com.snowlive/model/m_crewApplyList.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/api/api_crew.dart';

class CrewApplyViewModel extends GetxController {

  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  TextEditingController textEditingController = TextEditingController();

  // 크루 가입 신청 목록과 로딩 상태를 위한 Rx 변수
  var crewApplyList = <CrewApply>[].obs;
  var isLoading = false.obs;
  var isSubmitButtonEnabled = false.obs;

  // 크루 가입 신청
  Future<void> applyForCrew(int crewId, int userId, String title) async {
    isLoading.value = true;
    try {
      // 서버에 전송할 데이터 구성
      final response = await CrewAPI().applyForCrew({
        'crew_id': crewId,
        'applicant_user_id': userId,
        'title': title
      });

      if (response.success) {

        await fetchCrewApplyListUser(userId);
        CustomFullScreenDialog.cancelDialog();
        Get.offNamed(AppRoutes.crewApplicationUser);
      } else {
        Get.back();
        Get.snackbar('중복 신청', '이미 가입 신청 중인 크루입니다.');
      }
    } catch (e) {
      print('$e');
      Get.back();
      Get.snackbar('신청 오류', '잠시후 다시 시도해주세요.');
    } finally {
      isLoading.value = false;
    }
  }

  // 특정 크루의 신청 목록
  Future<void> fetchCrewApplyList(int crewId) async {
    isLoading.value = true;
    try {
      // API 호출
      final response = await CrewAPI().listCrewApplications(crewId);
      if (response.success) {
        CrewApplyListResponse crewApplyListResponse = CrewApplyListResponse.fromJson(response.data as List<dynamic>);
        crewApplyList.assignAll(crewApplyListResponse.crewApplyList ?? []);
      } else {
        Get.snackbar('오류', '크루 가입 신청 목록을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      Get.snackbar('오류', '에러가 발생했습니다: $e');
    } finally {
      isLoading.value = false;
    }
  }
  // 특정 유저의 신청 목록
  Future<void> fetchCrewApplyListUser(int userId) async {
    isLoading.value = true;
    try {
      // API 호출
      final response = await CrewAPI().listCrewApplicationsUser(userId);
      if (response.success) {
        CrewApplyListResponse crewApplyListResponse = CrewApplyListResponse.fromJson(response.data as List<dynamic>);
        crewApplyList.assignAll(crewApplyListResponse.crewApplyList ?? []);
      } else {
        Get.snackbar('오류', '크루 가입 신청 목록을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      Get.snackbar('오류', '에러가 발생했습니다: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 크루 가입 신청을 승인하는 함수
  Future<void> approveCrewApplication(int applicantUserId, int applyCrewId) async {
    isLoading.value = true;
    try {
      final response = await CrewAPI().approveCrewApplication({
        "applicant_user_id": applicantUserId,    //필수
        "crew_id": applyCrewId    //필수
      });
      if (response.success) {
        print('크루 가입 신청을 승인했습니다.');
        // 승인 후 목록 갱신
        fetchCrewApplyList(applyCrewId);
        _crewMemberListViewModel.fetchCrewMembers(crewId: applyCrewId);
      } else {
        print('크루 가입 신청 승인에 실패했습니다.');
      }
    } catch (e) {
      print('에러가 발생했습니다: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 크루 가입 신청을 삭제하는 함수
  Future<void> deleteCrewApplication(int applyUserId, int applyCrewId, int userId) async {
    isLoading.value = true;
    try {
      final response = await CrewAPI().deleteCrewApplication({
        "applicant_user_id": applyUserId,
        "crew_id": applyCrewId,
        "user_id": userId
      });
      if (response.success) {
        print('크루 가입 신청을 삭제했습니다.');
        // 삭제 후 목록 갱신
        crewApplyList.removeWhere((apply) => apply.applyCrewId == applyCrewId);
      } else {
        print('크루 가입 신청 삭제에 실패했습니다.');
      }
    } catch (e) {
      print('에러가 발생했습니다: $e');
    } finally {
      isLoading.value = false;
    }
  }

}
