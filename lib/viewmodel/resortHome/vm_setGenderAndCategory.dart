import 'package:com.snowlive/api/ApiResponse.dart';
import 'package:com.snowlive/api/api_user.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/view/resortHome/v_setGenderAndCategory.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class GenderCategoryViewModel extends GetxController {
  var selectedGender = ''.obs;
  var selectedCategory = ''.obs;

  UserViewModel _userViewModel = Get.find<UserViewModel>();

  // 성별 선택
  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // 종목 선택
  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  // 선택이 완료됐는지 확인하는 함수
  bool isSelectionComplete() {
    return selectedGender.isNotEmpty && selectedCategory.isNotEmpty;
  }

  // 선택된 결과를 반환
  Map<String, String> getSelectionResult() {
    return {
      'gender': selectedGender.value,
      'category': selectedCategory.value,
    };
  }

  // 팝업을 호출하는 메소드
  Future<void> showGenderAndCategoryPopup() async {
    final result = await Get.dialog(
      GenderAndCategoryPopup(),
      barrierDismissible: false, // 팝업 외부 터치 시 닫히지 않게 설정
    );
    if (result != null) {
      // 선택 결과 처리
      selectedGender.value = result['gender'];
      selectedCategory.value = result['category'];
      print("선택된 성별: ${selectedGender.value}, 선택된 종목: ${selectedCategory.value}");
      ApiResponse response = await UserAPI().updateUserInfo({
        "user_id": _userViewModel.user.user_id,
        "skiorboard": selectedCategory.value,
        "sex": selectedGender.value,
      });
      if (response.success) {
        Get.snackbar(
          "성공",
          "성별 및 주 종목 설정이 완료되었습니다",
          snackPosition: SnackPosition.TOP,
          backgroundColor: SDSColor.snowliveWhite,
          colorText: SDSColor.snowliveBlack,
        );
        print('유저 정보 수정완료');
      } else {
        print('유저 정보 수정실패');
      }
    } else {
      print("선택이 취소됨.");
    }
  }
}
