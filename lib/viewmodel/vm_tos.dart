import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/v_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

class TermsOfServiceViewModel extends GetxController {

  RxBool? tos = false.obs;
  RxBool? tp = false.obs;

  var checkListItems = [
    {
      "id": 0,
      "value": false.obs,
      "title": "(필수) 스노우라이브 이용약관 동의",
      "url": 'https://sites.google.com/view/snowlive-termsofservice/%ED%99%88',
    },
    {
      "id": 1,
      "value": false.obs,
      "title": "(필수) 개인정보 수집 및 이용동의",
      "url": "https://sites.google.com/view/134creativelabprivacypolicy/%ED%99%88",
    },
  ].obs;

  bool isAllChecked() {
    return (checkListItems[0]["value"] as RxBool).value && (checkListItems[1]["value"] as RxBool).value;
  }

  bool isEveryItemChecked() {
    return checkListItems.every((item) => (item["value"] as RxBool).value == true);
  }

  void toggleAllCheckboxes() {
    bool newValue = !isEveryItemChecked(); // 모두 체크되어 있으면 해제하고, 그렇지 않으면 모두 체크
    for (var item in checkListItems) {
      (item["value"] as RxBool).value = newValue;
    }
  }



  void toggleCheckbox(int index) {
    (checkListItems[index]["value"] as RxBool).value = !(checkListItems[index]["value"] as RxBool).value;
  }

  Future<void> signOut_welcome() async {
    User user = FirebaseAuth.instance.currentUser!;
    await user.delete();
    await FlutterSecureStorage().delete(key: 'signInMethod');
    Get.toNamed(AppRoutes.login);
  }

  Future<void> goBack() async {
    await FlutterSecureStorage().delete(key: 'localUid');
    await FlutterSecureStorage().delete(key: 'device_id');
    await FlutterSecureStorage().delete(key: 'device_token');
    if (FirebaseAuth.instance.currentUser!.providerData[0].providerId ==
        'password') {
      Get.toNamed(AppRoutes.login);
    } else {
      signOut_welcome();
    }
  }

}