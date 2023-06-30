import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowlive3/model/m_userModel.dart';
import 'package:snowlive3/screens/login/v_loginpage.dart';
import '../model/m_resortModel.dart';

class SeasonController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _currentSeason = ''.obs;

  String? get currentSeason => _currentSeason!.value;


  @override
  void onInit()  async{
    getCurrentSeason();
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
}

