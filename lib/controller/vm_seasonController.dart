import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.snowlive/model/m_userModel.dart';
import 'package:com.snowlive/screens/login/v_loginpage.dart';
import '../model/m_resortModel.dart';

class SeasonController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _currentSeason = ''.obs;
  RxInt? _liveTalkLimit = 0.obs;
  RxInt? _liveTalkReplyLimit = 0.obs;
  RxInt? _fleaMarketLimit = 0.obs;
  RxInt? _bulletinRoomLimit = 0.obs;
  RxInt? _bulletinCrewLimit = 0.obs;
  RxInt? _bulletinCrewReplyLimit = 0.obs;
  RxInt? _bulletinRoomReplyLimit = 0.obs;

  String? get currentSeason => _currentSeason!.value;
  int? get liveTalkLimit => _liveTalkLimit!.value;
  int? get liveTalkReplyLimit => _liveTalkReplyLimit!.value;
  int? get fleaMarketLimit => _fleaMarketLimit!.value;
  int? get bulletinRoomLimit => _bulletinRoomLimit!.value;
  int? get bulletinCrewLimit => _bulletinCrewLimit!.value;
  int? get bulletinCrewReplyLimit => _bulletinCrewReplyLimit!.value;
  int? get bulletinRoomReplyLimit => _bulletinRoomReplyLimit!.value;


  @override
  void onInit()  async{
    await getCurrentSeason();
    await getLiveTalkLimit();
    await getLiveTalkReplyLimit();
    await getFleaMarketLimit();
    await getBulletinRoomLimit();
    await getBulletinCrewLimit();
    await getBulletinCrewReplyLimit();
    await getBulletinRoomReplyLimit();
    // TODO: implement onInit
    super.onInit();
  }


  Future<void> getCurrentSeason() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('season').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    String currentSeason = documentSnapshot.get('season');
    this._currentSeason!.value = currentSeason;
    print(currentSeason);
  }

  Future<void> getLiveTalkLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('liveTalkLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int liveTalkLimit = documentSnapshot.get('limit');
    this._liveTalkLimit!.value = liveTalkLimit;
    print(liveTalkLimit);
  }

  Future<void> getLiveTalkReplyLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('liveTalkReplyLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int liveTalkReplyLimit = documentSnapshot.get('limit');
    this._liveTalkReplyLimit!.value = liveTalkReplyLimit;
    print(liveTalkReplyLimit);
  }

  Future<void> getFleaMarketLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('fleaMarketLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int fleaMarketLimit = documentSnapshot.get('limit');
    this._fleaMarketLimit!.value = fleaMarketLimit;
    print(fleaMarketLimit);
  }

  Future<void> getBulletinRoomLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinRoomLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinRoomLimit = documentSnapshot.get('limit');
    this._bulletinRoomLimit!.value = bulletinRoomLimit;
    print(bulletinRoomLimit);
  }

  Future<void> getBulletinCrewLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinCrewLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinCrewLimit = documentSnapshot.get('limit');
    this._bulletinCrewLimit!.value = bulletinCrewLimit;
    print(bulletinCrewLimit);
  }

  Future<void> getBulletinCrewReplyLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinCrewReplyLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinCrewReplyLimit = documentSnapshot.get('limit');
    this._bulletinCrewReplyLimit!.value = bulletinCrewReplyLimit;
    print(bulletinCrewReplyLimit);
  }

  Future<void> getBulletinRoomReplyLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinRoomReplyLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinRoomReplyLimit = documentSnapshot.get('limit');
    this._bulletinRoomReplyLimit!.value = bulletinRoomReplyLimit;
    print(bulletinRoomReplyLimit);
  }


}

