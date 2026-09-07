import 'package:get/get.dart';

class SettingsController extends GetxController {
  var useCustomQuillToolbar = false.obs;

  void toggleCustomQuillToolbar() {
    useCustomQuillToolbar.value = !useCustomQuillToolbar.value;
  }
}