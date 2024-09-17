import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/login/vm_loginController.dart';
import 'package:com.snowlive/controller/login/vm_notificationController.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:com.snowlive/model_2/m_myCrewRankingModel.dart';
import 'package:com.snowlive/model_2/m_myRankingModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:com.snowlive/model_2/m_userModel.dart';
import 'package:com.snowlive/screens/login/v_loginpage.dart';
import '../../model/m_resortModel.dart';

class MyCrewRankingController extends GetxController {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Timestamp? _lastPassTime;
  RxMap? _passCountData = <String, dynamic>{}.obs;
  RxMap? _passCountTimeData = <String, dynamic>{}.obs;
  RxMap? _slopeScores = <String, dynamic>{}.obs;
  RxInt? _totalPassCount = 0.obs;
  RxInt? _totalScore = 0.obs;

  RxInt? _totalPassCount_Daily = 0.obs;
  RxInt? _totalScore_Daily = 0.obs;
  RxInt? _totalPassCount_Weekly = 0.obs;
  RxInt? _totalScore_Weekly = 0.obs;

  RxInt? _baseResort =0.obs;
  RxString? _baseResortNickName =''.obs;
  RxInt? _crewColor=0.obs;
  RxString? _crewID=''.obs;
  RxString? _crewLeader=''.obs;
  RxString? _crewName=''.obs;
  RxString? _date=''.obs;
  RxString? _description=''.obs;
  RxBool? _kusbf=false.obs;
  RxString? _leaderUid=''.obs;
  RxString? _profileImageUrl=''.obs;



  Timestamp get lastPassTime => _lastPassTime!;
  Map<String, dynamic> get passCountData => _passCountData!.value as Map<String, dynamic>;
  Map<String, dynamic> get passCountTimeData => _passCountTimeData!.value as Map<String, dynamic>;
  Map<String, dynamic> get slopeScores => _slopeScores!.value as Map<String, dynamic>;
  int get totalPassCount => _totalPassCount!.value;
  int get totalScore => _totalScore!.value;
  int get totalPassCount_Daily => _totalPassCount_Daily!.value;
  int get totalScore_Daily => _totalScore_Daily!.value;
  int get totalPassCount_Weekly => _totalPassCount_Weekly!.value;
  int get totalScore_Weekly => _totalScore_Weekly!.value;

  int get baseResort => _baseResort!.value;
  String get baseResortNickName => _baseResortNickName!.value;
  int get crewColor => _crewColor!.value;
  String get crewID => _crewID!.value;
  String get crewLeader => _crewLeader!.value;
  String get crewName => _crewName!.value;
  String get date => _date!.value;
  String get description => _description!.value;
  bool get kusbf => _kusbf!.value;
  String get leaderUid => _leaderUid!.value;
  String get profileImageUrl => _profileImageUrl!.value;

  @override
  void onInit() async {
    // TODO: implement onInit
    await getMyCrewRankingData(_userModelController.liveCrew);
    await getMyCrewRankingDataDaily(_userModelController.liveCrew);
    await getMyCrewRankingDataWeekly(_userModelController.liveCrew);
  }

  Future<void> getMyCrewRankingData(crewID) async {
    if (FirebaseAuth.instance.currentUser != null) {

      if (crewID != null) {
        MyCrewRankingModel? myCrewRankingModel = await MyCrewRankingModel().getMyCrewRankingModel(crewID);
        if (myCrewRankingModel != null) {
          this._lastPassTime = myCrewRankingModel.lastPassTime!;
          this._passCountData!.value = myCrewRankingModel.passCountData!;
          this._passCountTimeData!.value = myCrewRankingModel.passCountTimeData!;
          this._slopeScores!.value = myCrewRankingModel.slopeScores!;
          this._totalPassCount!.value = myCrewRankingModel.totalPassCount!;
          this._totalScore!.value = myCrewRankingModel.totalScore!;

        } else {}
      } else {
        Get.to(() => LoginPage());
        // handle the case where the userModel is null
      }
    } else {
      Get.to(() => LoginPage());
    }
  }

  Future<void> getMyCrewRankingDataDaily(crewID) async {
    if (FirebaseAuth.instance.currentUser != null) {

      if (crewID != null) {
        MyCrewRankingModel? myCrewRankingModelDaily = await MyCrewRankingModel().getMyCrewRankingModel_Daily(crewID);
        if (myCrewRankingModelDaily != null) {
          this._totalPassCount_Daily!.value = myCrewRankingModelDaily.totalPassCount!;
          this._totalScore_Daily!.value = myCrewRankingModelDaily.totalScore!;
          this._crewID!.value = myCrewRankingModelDaily.crewID!;
        } else {}
      } else {
        Get.to(() => LoginPage());
        // handle the case where the userModel is null
      }
    } else {
      Get.to(() => LoginPage());
    }
  }

  Future<void> getMyCrewRankingDataWeekly(crewID) async {
    if (FirebaseAuth.instance.currentUser != null) {

      if (crewID != null) {
        MyCrewRankingModel? myCrewRankingModelWeekly = await MyCrewRankingModel().getMyCrewRankingModel_Weekly(crewID);
        if (myCrewRankingModelWeekly != null) {
          this._totalPassCount_Weekly!.value = myCrewRankingModelWeekly.totalPassCountWeekly!;
          this._totalScore_Weekly!.value = myCrewRankingModelWeekly.totalScoreWeekly!;
          this._crewID!.value = myCrewRankingModelWeekly.crewID!;
        } else {}
      } else {
        Get.to(() => LoginPage());
        // handle the case where the userModel is null
      }
    } else {
      Get.to(() => LoginPage());
    }
  }

}