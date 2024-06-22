import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StreamController_Friend extends GetxController {

  //TODO: Dependency Injection**************************************************
  SeasonController _seasonController = Get.find<SeasonController>();
  //TODO: Dependency Injection**************************************************

  final auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_friendDetailPage_friendComment(String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('friendsComment')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_friendDetailPage_user(String uid) {
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_friendDetailPage_crew(String uid) {
    return FirebaseFirestore.instance
        .collection('liveCrew')
        .where('memberUidList', arrayContains: uid)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> setupStreams_friendDetailPage_rank(int favoriteResort, String uid) {
    return FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('$favoriteResort')
        .doc(uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_friendDetailPage_rank_daily(int favoriteResort, List<String> dateItems, String selectedDateName, String uid) {
    return FirebaseFirestore.instance
        .collection('Ranking_Daily')
        .doc('${_seasonController.currentSeason}')
        .collection('$favoriteResort')
        .where('date', isEqualTo: dateItems.isNotEmpty ? selectedDateName : '필터')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_friendDetailPage_rank2(int favoriteResort, String uid) {
    return FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('$favoriteResort')
        .where('uid', isEqualTo: uid )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_friendDetailPage_rank3(int favoriteResort) {
    return FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('$favoriteResort')
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .snapshots();
  }

  Future<List<String>> fetchFilteredDateItems(String uid, int favoriteResort) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Ranking_Daily')
        .doc('${_seasonController.currentSeason}')
        .collection('$favoriteResort')
        .where('uid', isEqualTo: uid)
        .get();

    List<String> dateItems = [];
    if (snapshot.docs.isNotEmpty) {
      dateItems = snapshot.docs.map((doc) => doc['date'].toString()).toList();
    }
    return dateItems;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_friendListPage_alarm () {
    final uid = auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('newAlarm')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_friendListPage_user () {
    final uid = auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_friendListPage_friend () {
    final uid = auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('user')
        .where('whoResistMe', arrayContains: uid)
        .orderBy('displayName', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_repoList () {
    final uid = auth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('user')
        .where('whoRepoMe', arrayContains: uid)
        .snapshots();
  }


}
