import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_myCrewRankingController.dart';
import 'package:com.snowlive/controller/vm_myRankingController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_rankingTierModelController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';

class StreamController_ranking extends GetxController {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  MyCrewRankingController _myCrewRankingController = Get.find<MyCrewRankingController>();
  MyRankingController _myRankingController = Get.find<MyRankingController>();
  //TODO: Dependency Injection**************************************************

  final auth = FirebaseAuth.instance;


  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_ranking_crew_Screen() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_ranking_indi_Screen_user_rank1(String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_ranking_indi_Screen_user_rank2(String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_ranking_indi_Screen_user_rank3(String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }




  Future<void> refreshData_Crew({bool isDaily = false, bool isWeekly = false}) async {
    if (_userModelController.favoriteResort == 12 ||
        _userModelController.favoriteResort == 2 ||
        _userModelController.favoriteResort == 0) {
      if (isDaily == true) {
        await _rankingTierModelController.getRankingDocs_crew_Daily(baseResort: _userModelController.favoriteResort!);
        await _myCrewRankingController.getMyCrewRankingDataDaily(_userModelController.liveCrew);
      } else if (isWeekly == true) {
        await _rankingTierModelController.getRankingDocs_crew_Weekly(baseResort: _userModelController.favoriteResort!);
        await _myCrewRankingController.getMyCrewRankingDataWeekly(_userModelController.liveCrew);
      } else {
        await _rankingTierModelController.getRankingDocs_crew(baseResort: _userModelController.favoriteResort!);
        await _myCrewRankingController.getMyCrewRankingData(_userModelController.liveCrew);
      }
    } else {
      if (isDaily == true) {
        await _rankingTierModelController.getRankingDocs_crew_integrated_Daily();
        await _myCrewRankingController.getMyCrewRankingDataDaily(_userModelController.liveCrew);
      } else if (isWeekly == true) {
        await _rankingTierModelController.getRankingDocs_crew_integrated_Weekly();
        await _myCrewRankingController.getMyCrewRankingDataWeekly(_userModelController.liveCrew);
      } else {
        await _rankingTierModelController.getRankingDocs_crew_integrated();
        await _myCrewRankingController.getMyCrewRankingData(_userModelController.liveCrew);
      }
    }
  }

  Future<void> refreshData_Indi({bool isDaily = false, bool isWeekly = false}) async {
    if(_userModelController.favoriteResort == 12
        ||_userModelController.favoriteResort == 2
        ||_userModelController.favoriteResort == 0) {

      if(isDaily == true){
        await _rankingTierModelController.getRankingDocsDaily(baseResort: _userModelController.favoriteResort);
        await _myRankingController.getMyRankingDataDaily(_userModelController.uid);
      }
      else if(isWeekly == true){
        await _rankingTierModelController.getRankingDocsWeekly(baseResort: _userModelController.favoriteResort);
        await _myRankingController.getMyRankingDataWeekly(_userModelController.uid);
      }
      else{
        await _rankingTierModelController.getRankingDocs(baseResort: _userModelController.favoriteResort);
        await _myRankingController.getMyRankingData(_userModelController.uid);
      }
    }else{

      if(isDaily == true){
        await _rankingTierModelController.getRankingDocs_integrated_Daily();
        await _myRankingController.getMyRankingDataDaily(_userModelController.uid);
      }
      else if(isWeekly == true){
        await _rankingTierModelController.getRankingDocs_integrated_Weekly();
        await _myRankingController.getMyRankingDataWeekly(_userModelController.uid);
      }
      else{
        await _rankingTierModelController.getRankingDocs_integrated();
        await _myRankingController.getMyRankingData(_userModelController.uid);
      }
    }
  }



}
