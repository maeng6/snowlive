import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class StreamController_MoreTab extends GetxController {

  final auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_moreTab_notice() {
    return FirebaseFirestore.instance
        .collection('notice')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> setupStreams_moreTab_event() {
    return FirebaseFirestore.instance
        .collection('event')
        .orderBy('timeStamp', descending: true)
        .snapshots();
  }


}
