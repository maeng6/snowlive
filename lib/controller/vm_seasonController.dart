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

  String? get currentSeason => _currentSeason!.value;
  int? get liveTalkLimit => _liveTalkLimit!.value;
  int? get liveTalkReplyLimit => _liveTalkReplyLimit!.value;


  @override
  void onInit()  async{
    await getCurrentSeason();
    await getLiveTalkLimit();
    await getLiveTalkReplyLimit();
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


}

