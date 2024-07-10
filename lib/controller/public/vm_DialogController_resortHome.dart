import 'package:get/get.dart';

class DialogController extends GetxController {
  var isChecked = false.obs;

  void toggleCheckbox(bool? value) {
    isChecked.value = value ?? false;
    update();
  }
}