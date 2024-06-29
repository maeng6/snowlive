import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:get/get.dart';

class StreamController_Banner extends GetxController {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
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
        .doc('${_userModelController.instantResort}')
        .collection('1')
        .where('visable', isEqualTo: true)
        .snapshots();

  }
}
