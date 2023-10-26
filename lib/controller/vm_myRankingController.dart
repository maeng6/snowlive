import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_loginController.dart';
import 'package:com.snowlive/controller/vm_notificationController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/model/m_myRankingModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.snowlive/model/m_userModel.dart';
import 'package:com.snowlive/screens/login/v_loginpage.dart';
import '../model/m_resortModel.dart';

class MyRankingController extends GetxController {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Timestamp? _lastPassTime;
  RxMap? _passCountData = <String, dynamic>{}.obs;
  RxMap? _passCountTimeData = <String, dynamic>{}.obs;
  RxMap? _slopeScores = <String, dynamic>{}.obs;
  RxString? _tier = ''.obs;
  RxInt? _totalPassCount = 0.obs;
  RxInt? _totalScore = 0.obs;
  RxString? _uid = ''.obs;
  RxBool? _exist=true.obs;

  Timestamp get lastPassTime => _lastPassTime!;
  Map<String, dynamic> get passCountData => _passCountData!.value as Map<String, dynamic>;
  Map<String, dynamic> get passCountTimeData => _passCountTimeData!.value as Map<String, dynamic>;
  Map<String, dynamic> get slopeScores => _slopeScores!.value as Map<String, dynamic>;
  String get tier => _tier!.value;
  int get totalPassCount => _totalPassCount!.value;
  int get totalScore => _totalScore!.value;
  String get uid => _uid!.value;
  bool? get exist => _exist!.value;

  @override
  void onInit() async {
    // TODO: implement onInit
    await getMyRankingData(_userModelController.uid);
  }

  Future<void> getMyRankingData(uid) async {
    if (FirebaseAuth.instance.currentUser != null) {

      if (uid != null) {
        MyRankingModel? myRankingModel = await MyRankingModel().getMyRankingModel(uid);
        if (myRankingModel != null) {
          this._lastPassTime = myRankingModel.lastPassTime!;
          this._passCountData!.value = myRankingModel.passCountData!;
          this._passCountTimeData!.value = myRankingModel.passCountTimeData!;
          this._slopeScores!.value = myRankingModel.slopeScores!;
          this._tier!.value = myRankingModel.tier!;
          this._totalPassCount!.value = myRankingModel.totalPassCount!;
          this._totalScore!.value = myRankingModel.totalScore!;
          this._uid!.value = myRankingModel.uid!;
          this._exist!.value = myRankingModel.exist!;
          print('${exist}');
        } else {}
      } else {
        Get.to(() => LoginPage());
        // handle the case where the userModel is null
      }
    } else {
      Get.to(() => LoginPage());
    }

  }

  void resetMyRankingData() async {
    this._tier!.value = '';
    this._totalScore!.value = 0;
  }

}