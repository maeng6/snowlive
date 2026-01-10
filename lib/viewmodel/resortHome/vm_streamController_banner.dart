import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:get/get.dart';

class StreamController_Banner extends GetxController {

  //TODO: Dependency Injection**************************************************
  UserViewModel _userViewModel = Get.find<UserViewModel>();
  //TODO: Dependency Injection**************************************************

  // 🛡️ 메모리 누수 방지: StreamSubscription 패턴 사용
  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> bannerDocs_resortHome =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bannerSub_resortHome;

  @override
  void onInit() async {
    super.onInit();
    await setupStreams();
  }

  Future<void> setupStreams() async {
    // 기존 구독 취소
    _bannerSub_resortHome?.cancel();

    _bannerSub_resortHome = FirebaseFirestore.instance
        .collection('discover_banner_url')
        .doc('${_userViewModel.user.instant_resort}')
        .collection('1')
        .where('visable', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
          bannerDocs_resortHome.value = snapshot.docs;
        });
  }

  @override
  void onClose() {
    // 🛡️ 메모리 누수 방지: 구독 취소
    _bannerSub_resortHome?.cancel();
    _bannerSub_resortHome = null;
    super.onClose();
  }
}
