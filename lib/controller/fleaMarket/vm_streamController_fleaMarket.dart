import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/fleaMarket/vm_fleaMarketController.dart';
import 'package:com.snowlive/controller/public/vm_limitController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StreamController_fleaMarket extends GetxController {

  //TODO: Dependency Injection**************************************************
  limitController _seasonController = Get.find<limitController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  //TODO: Dependency Injection**************************************************

  final auth = FirebaseAuth.instance;
  var _allCategories;
  final RxString _selectedValue = ''.obs;
  final RxString _selectedValue2 = ''.obs;

  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> fleaStream_fleaMarket_List_Screen = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();
  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> fleaStream_fleaMarket_My_Screen = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();
  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> fleaStream_fleaMarket_List_Detail = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();

  @override
  void onInit() async {
    super.onInit();
    await setupStreams_fleaMarket_List_Screen();
    await setupStreams_fleaMarket_My_Screen();
    await setupStreams_fleaMarket_List_Detail();
  }

  // v_fleaMarket_List_Screen 필터 선택 값 변경하는 메소드
  void setSelectedValues(String value1, String value2) {
    _selectedValue.value = value1;
    _selectedValue2.value = value2;
    setupStreams_fleaMarket_List_Screen(); // 선택된 값이 변경되면 스트림을 다시 설정
  }

  Future<void> setupStreams_fleaMarket_List_Screen() async {

    fleaStream_fleaMarket_List_Screen.value = FirebaseFirestore.instance
        .collection('fleaMarket')
        .where('category',
        isEqualTo:
        (_selectedValue.value == '카테고리') ? _allCategories : _selectedValue.value)
        .where('location', isEqualTo: (_selectedValue2.value == '거래장소') ? _allCategories : _selectedValue2.value)
        .orderBy('timeStamp', descending: true)
        .limit(_seasonController.fleaMarketLimit != 0 ? _seasonController.fleaMarketLimit! : 500)
        .snapshots();
  }

  Future<void> setupStreams_fleaMarket_My_Screen() async {
    final uid = auth.currentUser!.uid;

    fleaStream_fleaMarket_My_Screen.value = FirebaseFirestore.instance
        .collection('fleaMarket')
        .where("uid", isEqualTo: uid)
        .orderBy('timeStamp', descending: true)
        .limit(500)
        .snapshots();
  }

  Future<void> setupStreams_fleaMarket_List_Detail() async {

    fleaStream_fleaMarket_List_Detail.value = FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: _fleaModelController.uid )
        .snapshots();
  }

}
