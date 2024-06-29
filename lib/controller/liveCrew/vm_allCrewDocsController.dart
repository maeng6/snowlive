import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

StreamSubscription? _subscription;

class AllCrewDocsController extends GetxController {
  RxList<Map<String, dynamic>> _allCrewDocs = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get allCrewDocs => _allCrewDocs;

  Future<void> getAllCrewDocs() async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('liveCrew').get();
    this._allCrewDocs.value = querySnapshot.docs
        .map((doc) => doc.data())
        .where((data) => data != null)
        .map((data) => data! as Map<String, dynamic>)
        .toList();
  }

  Future<void> startListening() async {
    _subscription = await FirebaseFirestore.instance.collection('liveCrew').snapshots().listen((snapshot) async {
      await getAllCrewDocs();
    });
  }


  void stopListening() {
    _subscription?.cancel();
  }


  String findCrewName(String crewID, List<Map<String, dynamic>> docs) {
    // userDocs 리스트에서 uid가 chatDocUid와 일치하는 첫 번째 항목을 찾습니다.
    Map<String, dynamic>? crewDoc = docs.firstWhere(
          (crewDoc) => crewDoc['crewID'] == crewID,
      orElse: () => {},  // 일치하는 항목이 없을 경우 빈 Map 반환
    );

    // 찾은 문서에서 profileUrl 값을 반환합니다. 값이 없으면 기본값인 ''을 반환합니다.
    return crewDoc['crewName'] ?? '';
  }

}
