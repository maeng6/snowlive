import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../public/vm_limitController.dart';

class StreamController_ResortHome extends GetxController {
  final auth = FirebaseAuth.instance;

  //TODO: Dependency Injection**************************************************
  limitController _seasonController = Get.find<limitController>();
  //TODO: Dependency Injection**************************************************

  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> alarmStream = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();
  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> friendStream = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();
  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> bfStream = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();
  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> rankingGuideUrlStream = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();

  @override
  void onInit() async {
    super.onInit();
    await setupStreams();
  }

  Future<void> setupStreams() async {
    final uid = auth.currentUser!.uid;

    alarmStream.value = FirebaseFirestore.instance
        .collection('newAlarm')
        .where('uid', isEqualTo: uid)
        .snapshots();

    friendStream.value = FirebaseFirestore.instance
        .collection('user')
        .where('whoResistMeBF', arrayContains: uid)
        .orderBy('displayName', descending: false)
        .snapshots();

    bfStream.value = FirebaseFirestore.instance
        .collection('user')
        .where('whoResistMeBF', arrayContains: uid)
        .orderBy('isOnLive', descending: true)
        .snapshots();

    rankingGuideUrlStream.value = FirebaseFirestore.instance
        .collection('Ranking_guideUrl')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_resortHome_myScore(int favoriteResort, String uid) {
    return FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('$favoriteResort')
        .where('uid', isEqualTo: uid )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_resortHome_myRank(int favoriteResort) {
    return FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('$favoriteResort')
        .where('totalScore', isGreaterThan: 0)
        .orderBy('totalScore', descending: true)
        .snapshots();
  }

}
