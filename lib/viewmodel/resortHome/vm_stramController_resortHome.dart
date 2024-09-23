import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StreamController_ResortHome extends GetxController {
  final auth = FirebaseAuth.instance;

  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> alarmStream = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();
  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> friendStream = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();
  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> bfStream = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();
  final Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>> rankingGuideUrlStream = Rxn<Stream<QuerySnapshot<Map<String, dynamic>>>>();

  Future<void> sendMessage(String message, String uid) async {
    if (message.isNotEmpty) {
      await FirebaseFirestore.instance.collection('chat').add({
        'text': message,
        'createdAt': Timestamp.now(),
        'uid' : uid
      });
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_resortHome_chat() {
    return FirebaseFirestore.instance
        .collection('chat')
        .orderBy('createdAt', descending: true)
        .limit(500)
        .snapshots();
  }

}