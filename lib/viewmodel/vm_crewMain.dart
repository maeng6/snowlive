import 'package:get/get.dart';

class CrewMainViewModel extends GetxController {
  // 탭 상태 관리 (홈, 멤버, 갤러리)
  var currentTab = '홈'.obs;

  // 탭 변경 메서드
  void changeTab(String tabName) {
    currentTab.value = tabName;
  }
}
