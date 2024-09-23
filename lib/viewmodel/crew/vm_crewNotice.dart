import 'package:com.snowlive/api/api_crew.dart';
import 'package:com.snowlive/model/m_crewNotice.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model/m_crewMemberList.dart';

class CrewNoticeViewModel extends GetxController {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();


  // 공지사항 입력 필드 관리
  TextEditingController noticeController = TextEditingController();
  TextEditingController noticeModifyController = TextEditingController();
  final formKeyNotice = GlobalKey<FormState>();

  // 로딩 상태 관리
  RxBool isLoading = false.obs;

  // 공지사항 목록을 관리하는 변수
  RxList<CrewNotice> noticeList = <CrewNotice>[].obs;

  // 공지사항을 생성하는 메소드
  Future<void> createCrewNotice() async {
    if (formKeyNotice.currentState!.validate()) {
      isLoading.value = true;
      try {
        final noticeData = {
          "user_id": _userViewModel.user.user_id,
          "crew_id": _userViewModel.user.crew_id,
          "notice": noticeController.text,
        };

        final response = await CrewAPI().createCrewNotice(noticeData);

        if (response.success) {
          print('공지사항이 생성되었습니다.');
          noticeController.clear();  // 공지사항 입력 필드 초기화
          await fetchCrewNotices();  // 공지사항 목록 새로고침
        } else {
          print('공지사항 생성에 실패했습니다.');
        }
      } catch (e) {
        print('공지사항 생성 중 오류: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // 공지사항을 업데이트하는 메소드
  Future<void> updateCrewNotice(int noticeId, String noticeText) async {
    if (formKeyNotice.currentState!.validate()) {
      isLoading.value = true;
      try {
        final noticeData = {
          "user_id": _userViewModel.user.user_id,
          "notice_id": noticeId,
          "notice": noticeText,
        };

        final response = await CrewAPI().updateCrewNotice(noticeData);

        if (response.success) {
          Get.snackbar('성공', '공지사항이 업데이트되었습니다.');
          await fetchCrewNotices();  // 공지사항 목록 새로고침
        } else {
          Get.snackbar('오류', '공지사항 업데이트에 실패했습니다.');
        }
      } catch (e) {
        print('공지사항 업데이트 중 오류: $e');
        Get.snackbar('오류', '공지사항 업데이트 중 오류가 발생했습니다.');
      } finally {
        isLoading.value = false;
      }
    }
  }


  // 공지사항 목록 조회
  Future<void> fetchCrewNotices() async {
    isLoading.value = true;
    try {
      final response = await CrewAPI().listCrewNotices(
          _userViewModel.user.user_id,
          _userViewModel.user.crew_id
      );
      if (response.success) {
        noticeList.value = response.data!
            .map((item) => CrewNotice.fromJson(item))
            .toList();
        print(noticeList);
      } else {
        print('공지사항 목록 조회 중 오류: ${response.error}');
      }
    } catch (e) {
      print('공지사항 목록 조회 중 예외 발생: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 공지사항 삭제
  Future<void> deleteCrewNotice(int userId, int noticeId) async {
    isLoading.value = true; // 로딩 상태 활성화
    try {
      // API 호출 (userId와 noticeId를 JSON body로 보냄)
      final response = await CrewAPI().deleteCrewNotice(userId, noticeId);

      if (response.success) {
        // 성공적으로 삭제된 경우 noticeList에서 해당 공지 삭제
        noticeList.removeWhere((notice) => notice.noticeCrewId == noticeId);

        // 삭제 성공 메시지 출력 (선택 사항)
        Get.snackbar('삭제 완료', '공지사항이 성공적으로 삭제되었습니다.');
      } else {
        // 오류 발생 시 처리
        Get.snackbar('삭제 실패', '공지사항 삭제 중 오류 발생');
        print('공지사항 삭제 중 오류');
      }
    } catch (e) {
      // 예외 처리
      Get.snackbar('예외 발생', '공지사항 삭제 중 예외 발생: $e');
      print('공지사항 삭제 중 예외 발생: $e');
    } finally {
      isLoading.value = false; // 로딩 상태 해제
    }
  }


  // 작성자의 이름을 찾아주는 메서드
  String getAuthorInfo(int authorUserId) {
    final member = _crewMemberListViewModel.crewMembersList.firstWhere(
          (member) => member.userInfo?.userId == authorUserId,
      orElse: () => CrewMember(userInfo: UserInfo(displayName: '알 수 없음')),
    );
    return member.userInfo?.displayName ?? '알 수 없음';
  }

  // 작성자의 역할을 찾아주는 메서드
  String getAuthorRole(int authorUserId) {
    final member = _crewMemberListViewModel.crewMembersList.firstWhere(
          (member) => member.userInfo?.userId == authorUserId,
      orElse: () => CrewMember(status: '크루원'), // 기본 값은 크루원
    );
    switch (member.status) {
      case '크루장':
        return '(크루장)';
      case '운영진':
        return '(운영진)';
      default:
        return '(크루원)';
    }
  }

  // 날짜 포맷팅 메서드 (이전 코드 중복을 제거)
  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy.MM.dd').format(dateTime);
  }
}
