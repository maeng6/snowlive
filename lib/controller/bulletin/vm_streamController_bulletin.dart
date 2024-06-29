import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/bulletin/vm_bulletinEventController.dart';
import 'package:com.snowlive/controller/bulletin/vm_bulletinFreeController.dart';
import 'package:com.snowlive/controller/public/vm_limitController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StreamController_Bulletin extends GetxController {

  //TODO: Dependency Injection**************************************************
  limitController _seasonController = Get.find<limitController>();
  BulletinFreeModelController _bulletinFreeModelController = Get.find<BulletinFreeModelController>();
  BulletinEventModelController _bulletinEventModelController = Get.find<BulletinEventModelController>();
  //TODO: Dependency Injection**************************************************

  final auth = FirebaseAuth.instance;
  var _allCategories;
  final RxString _selectedValueBulletinFree = ''.obs;
  final RxString _selectedValueBulletinEvent1 = ''.obs;
  final RxString _selectedValueBulletinEvent2 = ''.obs;



  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> bulletinStream_bulletinFree_List_Screen = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();
  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> bulletinStream_bulletinEvent_List_Screen = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();


  @override
  void onInit() async {
    super.onInit();
    await setupStreams_bulletinFree_List_Screen();
    await setupStreams_bulletinEvent_List_Screen();
  }

  // v_fleaMarket_List_Screen 필터 선택 값 변경하는 메소드
  void setSelectedValues_bulletinFree(String value) {
    _selectedValueBulletinFree.value = value;
    setupStreams_bulletinFree_List_Screen(); // 선택된 값이 변경되면 스트림을 다시 설정
  }

  void setSelectedValues_bulletinEvent(String value1, String value2) {
    _selectedValueBulletinEvent1.value = value1;
    _selectedValueBulletinEvent2.value = value2;
    setupStreams_bulletinEvent_List_Screen(); // 선택된 값이 변경되면 스트림을 다시 설정
  }


  Future<void> setupStreams_bulletinFree_List_Screen() async {

    bulletinStream_bulletinFree_List_Screen.value = FirebaseFirestore.instance
        .collection('bulletinFree')
        .where('category',
        isEqualTo:
        (_selectedValueBulletinFree == '카테고리') ? _allCategories : '$_selectedValueBulletinFree')
        .orderBy('timeStamp', descending: true)
        .limit(_seasonController.bulletinFreeLimit!)
        .snapshots();
  }
  Future<void> setupStreams_bulletinEvent_List_Screen() async {

    bulletinStream_bulletinEvent_List_Screen.value = FirebaseFirestore.instance
        .collection('bulletinEvent')
        .where('category',
        isEqualTo:
        (_selectedValueBulletinEvent1 == '카테고리') ? _allCategories : '$_selectedValueBulletinEvent1')
        .where('location', isEqualTo: (_selectedValueBulletinEvent2 == '지역') ? _allCategories : '$_selectedValueBulletinEvent2')
        .orderBy('timeStamp', descending: true)
        .limit(_seasonController.bulletinEventLimit!)
        .snapshots();
  }



  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_bulletinFree_detail_reply() {
    return FirebaseFirestore.instance
        .collection('bulletinFree')
        .doc('${_bulletinFreeModelController.uid}#${_bulletinFreeModelController.bulletinFreeCount}')
        .collection('reply')
        .orderBy('timeStamp', descending: true)
        .limit(_seasonController.bulletinFreeReplyLimit!)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_bulletinFree_detail_user () {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: _bulletinFreeModelController.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_bulletinFree_detail_user_reply (String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }


  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_bulletinEvent_detail_reply() {
    return FirebaseFirestore.instance
        .collection('bulletinEvent')
        .doc('${_bulletinEventModelController.uid}#${_bulletinEventModelController.bulletinEventCount}')
        .collection('reply')
        .orderBy('timeStamp', descending: true)
        .limit(_seasonController.bulletinEventReplyLimit!)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_bulletinEvent_detail_user () {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: _bulletinEventModelController.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_bulletinEvent_detail_user_reply (String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_bulletinEvent_home () {
    return FirebaseFirestore.instance
        .collection('bulletinEvent')
        .orderBy('timeStamp', descending: true)
        .limit(5)
        .snapshots();
  }


}
