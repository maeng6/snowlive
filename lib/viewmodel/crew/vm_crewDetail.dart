import 'dart:convert';
import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewNotice.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/api/api_crew.dart';
import 'package:com.snowlive/model/m_crewDetail.dart';
import 'package:http/http.dart' as http;

class CrewDetailViewModel extends GetxController {

  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final CrewNoticeViewModel _crewNoticeViewModel = Get.find<CrewNoticeViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  TextEditingController textEditingController_description = TextEditingController();
  final formKey_description = GlobalKey<FormState>();

  var currentTab = '홈'.obs;


  // 탭과 관련된 Rx 변수들
  late RxString _selectedTabName;

  // 크루 디테일 모델을 옵저버블로 선언
  var crewDetailResponse = CrewDetailResponse().obs;

  // 로딩 상태
  RxBool isLoading = false.obs;

  // 그래프 토글
  RxBool isSlopeGraph = true.obs;


  // 각 크루의 ID에 대한 정보(로고, 이름, 디스크립션)를 저장할 맵
  var crewDetails = <int, Map<String, String>>{}.obs;

  RxBool _isCrewIntroExpanded = false.obs;



  CrewDetailInfo get crewDetailInfo => crewDetailResponse.value.crewDetailInfo ?? CrewDetailInfo(); // Null-safe 처리
  SeasonRankingInfo get seasonRankingInfo => crewDetailResponse.value.seasonRankingInfo ?? SeasonRankingInfo(); // Null-safe 처리

  String get crewName => crewDetailInfo.crewName ?? '';
  String get crewLogoUrl => crewDetailInfo.crewLogoUrl ?? '';
  String get description => crewDetailInfo.description ?? '';
  String get createdDate => crewDetailInfo.createdDate ?? '';
  int get crewMemberTotal => crewDetailInfo.crewMemberTotal ?? 0;
  String get color => crewDetailInfo.color ?? 'FFFFFF';
  String get notice => crewDetailInfo.notice ?? '';
  bool get permission_join => crewDetailInfo.permissionJoin ?? true;
  bool get permission_desc => crewDetailInfo.permissionDesc ?? true;
  bool get permission_notice => crewDetailInfo.permissionNotice ?? true;

  double get overallTotalScore => seasonRankingInfo.overallTotalScore ?? 0;
  int get overallRank => seasonRankingInfo.overallRank ?? 0;
  double get overallRankPercentage => seasonRankingInfo.overallRankPercentage ?? 0;
  String get overallTierIconUrl => seasonRankingInfo.overallTierIconUrl ?? '';
  int get totalSlopeCount => seasonRankingInfo.totalSlopeCount ?? 0;
  List<CountInfo> get countInfo => seasonRankingInfo.countInfo ?? [];
  Map<String, int> get timeInfo => seasonRankingInfo.timeCountInfo ?? {};

  String get selectedTabName => _selectedTabName.value;

  bool get isCrewIntroExpanded => _isCrewIntroExpanded.value;


  CrewDetailViewModel() {
    textEditingController_description.addListener(() {
      crewDetailInfo.description = textEditingController_description.text;
    });
  }

  void changeTab(String tabName) {
    currentTab.value = tabName;
  }

  // API 호출해서 데이터를 가져오는 메소드
  Future<void> fetchCrewDetail(int crewId, String season) async {
    isLoading.value = true;
    try {
      // 시즌 정보 함께 전달

      final response = await CrewAPI().getCrewDetails(crewId, season: season);

      if (response.success) {

        crewDetailResponse.value = CrewDetailResponse.fromJson(response.data!);
        await _crewNoticeViewModel.fetchCrewNotices();


      } else {
        print('Error fetching crew details: ${response.error}');
      }
    } catch (e) {
      print('Exception while fetching crew details: $e');
    } finally {
    }
    isLoading.value = false;
  }


  // 그래프 토글 함수
  void toggleGraph() {
    isSlopeGraph.value = !isSlopeGraph.value;
  }

  // 각 크루의 상세 정보를 불러와 로고 URL, 이름, 디스크립션 저장
  Future<void> findCrewDetails(int crewId, String seasonDate) async {
    await fetchCrewDetail(crewId, seasonDate);
    crewDetails[crewId] = {
      'logoUrl': crewLogoUrl,
      'name': crewName,
      'description': description,
    };
  }


  // 크루 가입 신청 허가 권한 토글
  Future<void> togglePermissionJoin(bool value) async{
    crewDetailInfo.permissionJoin = value;
    isLoading.value = true;  // 로딩 시작
    try {
      final updateCrewData = {
        "user_id": _userViewModel.user.user_id,
        "crew_name": crewName,
        "permission_join": value,
      };

      // 서버에 크루 세부사항 업데이트 요청
      var response = await CrewAPI().updateCrewDetails(crewDetailInfo.crewId!, updateCrewData);

      if (response.success) {
        // 업데이트 성공 후 필요한 추가 작업 (예: 로컬 모델 업데이트)
        await fetchCrewDetail(
            _userViewModel.user.crew_id,
            _friendDetailViewModel.seasonDate
        );
        print("운영진 권한이 성공적으로 변경되었습니다");
      } else {
        // 오류 메시지 출력
        print("크루 세부사항 업데이트 실패: ${response.error}");
      }
    } catch (e) {
      print("크루 세부사항 업데이트 중 예외 발생: $e");
    } finally {
      isLoading.value = false;  // 로딩 종료
    }


  }

  // 크루 소개글 변경 권한 토글
  Future<void> togglePermissionDesc(bool value) async{
    crewDetailInfo.permissionDesc = value;
    isLoading.value = true;  // 로딩 시작
    try {
      final updateCrewData = {
        "user_id": _userViewModel.user.user_id,
        "crew_name": crewName,
        "permission_desc": crewDetailInfo.permissionDesc,
      };

      // 서버에 크루 세부사항 업데이트 요청
      var response = await CrewAPI().updateCrewDetails(crewDetailInfo.crewId!, updateCrewData);

      if (response.success) {
        // 업데이트 성공 후 필요한 추가 작업 (예: 로컬 모델 업데이트)
        await fetchCrewDetail(
            _userViewModel.user.crew_id,
            _friendDetailViewModel.seasonDate
        );
        print("운영진 권한이 성공적으로 변경되었습니다");
      } else {
        // 오류 메시지 출력
        print("크루 세부사항 업데이트 실패: ${response.error}");
      }
    } catch (e) {
      print("크루 세부사항 업데이트 중 예외 발생: $e");
    } finally {
      isLoading.value = false;  // 로딩 종료
    }

  }

  // 공지사항 추가 권한 토글
  Future<void> togglePermissionNotice(bool value) async{
    crewDetailInfo.permissionNotice = value;
    isLoading.value = true;  // 로딩 시작
    try {
      final updateCrewData = {
        "user_id": _userViewModel.user.user_id,
        "crew_name": crewName,
        "permission_notice": crewDetailInfo.permissionNotice,
      };

      // 서버에 크루 세부사항 업데이트 요청
      var response = await CrewAPI().updateCrewDetails(crewDetailInfo.crewId!, updateCrewData);

      if (response.success) {
        // 업데이트 성공 후 필요한 추가 작업 (예: 로컬 모델 업데이트)
        await fetchCrewDetail(
            _userViewModel.user.crew_id,
            _friendDetailViewModel.seasonDate
        );
        print("운영진 권한이 성공적으로 변경되었습니다");
      } else {
        // 오류 메시지 출력
        print("크루 세부사항 업데이트 실패: ${response.error}");
      }
    } catch (e) {
      print("크루 세부사항 업데이트 중 예외 발생: $e");
    } finally {
      isLoading.value = false;  // 로딩 종료
    }
  }

  // 크루 삭제
  Future<ApiResponse> deleteCrew(int crewId, String userId) async {
    final uri = Uri.parse('https://snowlive-api-0eab29705c9f.herokuapp.com/api/crew/$crewId/')
        .replace(queryParameters: {'user_id': userId.toString()});

    final response = await http.delete(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 204) {
      await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
      CustomFullScreenDialog.cancelDialog();
      Get.offAllNamed(AppRoutes.mainHome);
      return ApiResponse.success(null);
    } else {
      CustomFullScreenDialog.cancelDialog();
      return ApiResponse.error(json.decode(utf8.decode(response.bodyBytes)));
    }
  }

  void toggleExpandCrewIntro() async {
    _isCrewIntroExpanded.value = !_isCrewIntroExpanded.value;
  }




}
