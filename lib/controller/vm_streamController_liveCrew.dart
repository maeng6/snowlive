import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_liveCrewModelController.dart';
import 'package:com.snowlive/controller/vm_rankingTierModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StreamController_liveCrew extends GetxController {

  //TODO: Dependency Injection**************************************************
  SeasonController _seasonController = Get.find<SeasonController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  RankingTierModelController _rankingTierModelController = Get.find<RankingTierModelController>();
  //TODO: Dependency Injection**************************************************


  final auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_invitedListPage() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('applyCrewList', arrayContains: _liveCrewModelController.crewID)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_inviteListPage() {
    return FirebaseFirestore.instance
        .collection('liveCrew')
        .where('applyUidList', arrayContains: _userModelController.uid!)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_setting_delegation() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('liveCrew', isEqualTo: _liveCrewModelController.crewID)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_crewDetailPage_gallery() {
    return FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewID', isEqualTo: _liveCrewModelController.crewID)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_liveCrewList_more() {
    return FirebaseFirestore.instance
        .collection('liveCrew')
        .where('baseResort', isEqualTo: _userModelController.favoriteResort!)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_crewDetailPage_screen() {
    return FirebaseFirestore.instance
        .collection('newAlarm')
        .where('uid', isEqualTo: _userModelController.uid!)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_crewDetailPage_member() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('liveCrew', isEqualTo: _liveCrewModelController.crewID)
        .orderBy('isOnLive', descending: true)
        .orderBy('displayName', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_crewDetailPage_home_currentCrew() {
    return FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewID', isEqualTo: _liveCrewModelController.crewID )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_crewDetailPage_home_currentUser(String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_crewDetailPage_home_ranking() {
    return FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_liveCrewModelController.baseResort}')
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .snapshots();
  }

  Future<void> getCrewDocs() async{
    if(_liveCrewModelController.baseResort != 12 && _liveCrewModelController.baseResort != 2 && _liveCrewModelController.baseResort != 0 ) {

      print('통합랭킹 진입');
      await _rankingTierModelController.getRankingDocs_crew_integrated();
      await _rankingTierModelController.getRankingDocs_integrated();

    }else {
      print('개별랭킹 진입');
      await _rankingTierModelController.getRankingDocs_crew(baseResort: _liveCrewModelController.baseResort!);
      await _rankingTierModelController.getRankingDocs(baseResort: _liveCrewModelController.baseResort);

    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_liveCrewHome_myCrew() {
    return FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewID', isEqualTo: _userModelController.liveCrew)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_liveCrewHome_applyCrewList() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('applyCrewList', arrayContains: _userModelController.liveCrew)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_liveCrewHome_liveOn() {
    return FirebaseFirestore.instance
        .collection('user')
        .where('isOnLive', isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_liveCrewHome_baseResortCrewList() {
    return FirebaseFirestore.instance
        .collection('liveCrew')
        .where('baseResort', isEqualTo: _userModelController.favoriteResort!)
        .orderBy('resistDate', descending: true)
        .limit(10)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_liveCrew_liveCrewHome_userInfo(String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }


}
