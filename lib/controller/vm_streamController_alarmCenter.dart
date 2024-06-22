import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StreamController_AlarmCenter extends GetxController {
  final auth = FirebaseAuth.instance;

  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> alarmStream = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();

  @override
  void onInit() async {
    super.onInit();
    await setupStreams();
  }

  Future<void> setupStreams() async {
    final uid = auth.currentUser!.uid;

    alarmStream.value = FirebaseFirestore.instance
        .collection('alarmCenter')
        .doc(uid)
        .collection('alarmCenter')
        .orderBy('timeStamp', descending: true)
        .snapshots();

}
}
