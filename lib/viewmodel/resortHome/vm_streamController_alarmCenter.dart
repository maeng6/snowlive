import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StreamController_AlarmCenter extends GetxController {
  final auth = FirebaseAuth.instance;

  // 🔥 StreamSubscription 패턴으로 변경 (메모리 누수 방지)
  final RxList<Map<String, dynamic>> alarmList = <Map<String, dynamic>>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _alarmSubscription;

  @override
  void onInit() async {
    super.onInit();
    await setupStreams();
  }

  Future<void> setupStreams() async {
    final uid = auth.currentUser!.uid;

    _alarmSubscription?.cancel();
    _alarmSubscription = FirebaseFirestore.instance
        .collection('alarmCenter')
        .doc(uid)
        .collection('alarmCenter')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          alarmList.value = snapshot.docs.map((doc) {
            final data = doc.data();
            data['docId'] = doc.id;
            return data;
          }).toList();
        });
  }

  @override
  void onClose() {
    // 🛡️ 메모리 누수 방지: 스트림 구독 취소
    _alarmSubscription?.cancel();
    _alarmSubscription = null;
    super.onClose();
  }
}
