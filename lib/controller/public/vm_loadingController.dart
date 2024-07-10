import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LoadingController extends GetxController {
  var progress = 0.obs;

  void updateProgress(int value) {
    progress.value = value;
  }
}
