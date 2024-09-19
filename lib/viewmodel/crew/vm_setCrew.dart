import 'package:com.snowlive/api/api_crew.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/viewmodel/util/vm_imageController.dart';
import 'package:com.snowlive/model/m_resortModel.dart';

class SetCrewViewModel extends GetxController {

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  // 로딩 상태 관리
  RxBool isLoading = false.obs;

  // 크루명 입력 필드와 폼 상태 관리
  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // 상태 관리 변수
  RxString _crewName = ''.obs;
  RxInt _selectedResortIndex = 99.obs;
  RxString _selectedResortName = ''.obs;
  RxBool _isCrewNameChecked = false.obs; // 크루명 중복 체크 완료 여부
  RxBool isNextButtonEnabled = false.obs;

  // 이미지 및 색상 관련 변수
  Rx<XFile?> _imageFile = Rx<XFile?>(null);
  Rx<XFile?> _croppedFile = Rx<XFile?>(null);
  Rx<Color> currentColor = Color(0xff3D83ED).obs;
  Rx<Color> currentColorBackground = Color(0xffF1F1F3).obs;

  String? profileImageUrl;

  final ImageController imageController = Get.put(ImageController());

  // Getter
  String get crewName => _crewName.value;
  int get selectedResortIndex => _selectedResortIndex.value;
  String get selectedResortName => _selectedResortName.value;
  bool get isCrewNameChecked => _isCrewNameChecked.value;
  XFile? get imageFile => _imageFile.value;
  XFile? get croppedFile => _croppedFile.value;

  // 크루명 입력 리스너
  SetCrewViewModel() {
    textEditingController.addListener(() {
      _isCrewNameChecked.value = false; // 새로운 입력 시 중복 체크 상태 초기화
      _crewName.value = textEditingController.text;
      updateNextButtonState();
    });
  }

  // 크루명 유효성 검사
  String? validateCrewName(String? value) {
    if (value == null || value.isEmpty) {
      return '크루명을 입력해주세요.';
    } else if (value.length > 10) {
      return '최대 10자 이내로 입력해주세요.';
    }
    return null;
  }

  // 크루명 중복 체크
  Future<void> checkCrewName() async {
    if (crewName.isNotEmpty) {
      try {
        isLoading.value = true;
        var response = await CrewAPI().checkCrewName(crewName);
        if (response.success) {
          _isCrewNameChecked.value = true; // 중복 체크 성공
        } else {
          _isCrewNameChecked.value = false; // 중복 체크 실패
          Get.snackbar('오류', '이미 존재하는 크루명입니다.');
        }
      } catch (e) {
        _isCrewNameChecked.value = false;
        Get.snackbar('오류', '크루명 확인 중 오류가 발생했습니다.');
      } finally {
        isLoading.value = false;
        updateNextButtonState(); // 중복 체크 후 다음 버튼 활성화 상태 업데이트
      }
    }
  }

  // 리조트 선택
  void selectResort(int selectedIndex) {
    _selectedResortIndex.value = selectedIndex;
    _selectedResortName.value = resortNameList[selectedIndex]!;
    updateNextButtonState();
  }

  // 이미지 업로드 로직
  Future<void> uploadImage(ImageSource source) async {
    try {
      _imageFile.value = await imageController.getSingleImage(source);
      if (_imageFile.value != null) {
        _croppedFile.value = await imageController.cropImage(_imageFile.value);
        updateImagePreview();
      }
    } catch (e) {
      print('Image upload error: $e');
    }
  }

  // 이미지 미리보기 업데이트
  void updateImagePreview() {
    if (_croppedFile.value != null) {
      currentColorBackground.value = Colors.white;
    }
  }

  // 이미지 URL 생성
  Future<void> getImageUrl() async {
    if (_croppedFile.value != null) {
      try {
        profileImageUrl = await imageController.setNewImage_Crew(
          newImage: _croppedFile.value!,
          crewID: _crewName.value,
        );
      } catch (e) {
        print('Image upload error: $e');
      }
    }
  }

  // 색상 선택
  void selectColor(Color color) {
    currentColor.value = color;
    currentColorBackground.value = color.withOpacity(0.2);
  }

  // 색상을 16진수 문자열로 변환하는 함수
  String colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase(); // 0xFF를 제거하고 변환
  }

  // 다음 버튼 활성화 상태 업데이트
  void updateNextButtonState() {
    if (_crewName.isNotEmpty &&
        _selectedResortName.isNotEmpty &&
        _isCrewNameChecked.value) {
      isNextButtonEnabled.value = true;
    } else {
      isNextButtonEnabled.value = false;
    }
  }

  // 크루명, 스키장, 이미지, 색상 모두 서버로 전송하는 로직
  Future<void> createCrew() async {
    if (formKey.currentState!.validate() && _croppedFile != null) {
      isLoading.value = true; // 로딩 시작

      await getImageUrl(); // 이미지 URL 생성

      // 서버로 전송할 데이터 준비
      final crewData = {
        "user_id": _userViewModel.user.user_id, // 유저 ID
        "crew_name": _crewName.value,
        "crew_logo_url": profileImageUrl ?? '',
        "color": colorToHex(currentColor.value),
        "base_resort_id": _selectedResortIndex.value,
      };

      // 서버에 크루 생성 요청
      await CrewAPI().createCrew(crewData);
      await _userViewModel.updateUserModel_api(_userViewModel.user.user_id);
      await _crewDetailViewModel.fetchCrewDetail(
          _userViewModel.user.crew_id,
          _friendDetailViewModel.seasonDate
      );
      await _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id);

      isLoading.value = false; // 로딩 끝
    }
  }

  // 크루명과 스키장 선택 후 다음 화면으로 이동
  void goToNextStep() {
    if (formKey.currentState!.validate() && _isCrewNameChecked.value) {
      Get.toNamed(AppRoutes.setCrewImageAndColor);
    }
  }

  // 크루명과 스키장 정보 초기화
  void resetAll() {
    textEditingController.clear();
    _crewName.value = '';
    _selectedResortName.value = '';
    _selectedResortIndex.value = 99;
    _isCrewNameChecked.value = false;
    isNextButtonEnabled.value = false;
    _imageFile.value = null;
    _croppedFile.value = null;
    currentColor.value = Color(0xff3D83ED);
    currentColorBackground.value = Color(0xffF1F1F3);
  }

  // 이미지와 색상 초기화
  void resetImageAndColor() {
    _imageFile.value = null;
    _croppedFile.value = null;
    currentColor.value = Color(0xff3D83ED);
    currentColorBackground.value = Color(0xffF1F1F3);
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }
}
