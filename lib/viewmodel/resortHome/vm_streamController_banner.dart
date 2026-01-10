import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class StreamController_Banner extends GetxController {

  //TODO: Dependency Injection**************************************************
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  //TODO: Dependency Injection**************************************************


  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> bannerStream_resortHome = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();

  @override
  void onInit() async {
    super.onInit();
    await setupStreams();
  }

  Future<void> setupStreams() async {

    bannerStream_resortHome.value = FirebaseFirestore.instance
        .collection('discover_banner_url')
        .doc('${_userViewModel.user.instant_resort}')
        .collection('1')
        .where('visable', isEqualTo: true)
        .snapshots();

  }

  @override
  void onClose() {
    // 🛡️ 메모리 누수 방지: 스트림 정리
    bannerStream_resortHome.value = null;
    super.onClose();
  }
}
