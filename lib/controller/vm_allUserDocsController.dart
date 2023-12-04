import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

StreamSubscription? _subscription;

class AllUserDocsController extends GetxController {
  RxList<Map<String, dynamic>> _allUserDocs = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get allUserDocs => _allUserDocs;

  @override
  void onInit()  async{

    await getAllUserDocs();

  }

  Future<void> getAllUserDocs() async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('user').get();
    this._allUserDocs.value = querySnapshot.docs
        .map((doc) => doc.data())
        .where((data) => data != null)
        .map((data) => data! as Map<String, dynamic>)
        .toList();
  }

  Future<void> startListening() async {
    _subscription = await FirebaseFirestore.instance.collection('user').snapshots().listen((snapshot) async {
      await getAllUserDocs();
    });
  }


  void stopListening() {
    _subscription?.cancel();
  }

  String findProfileUrl(String chatDocUid, List<Map<String, dynamic>> userDocs) {
    // userDocs 리스트에서 uid가 chatDocUid와 일치하는 첫 번째 항목을 찾습니다.
    Map<String, dynamic>? userDoc = userDocs.firstWhere(
          (userDoc) => userDoc['uid'] == chatDocUid,
      orElse: () => {},  // 일치하는 항목이 없을 경우 빈 Map 반환
    );

    // 찾은 문서에서 profileUrl 값을 반환합니다. 값이 없으면 기본값인 ''을 반환합니다.
    return userDoc['profileImageUrl'] ?? '';
  }

  String findDisplayName(String chatDocUid, List<Map<String, dynamic>> userDocs) {
    // userDocs 리스트에서 uid가 chatDocUid와 일치하는 첫 번째 항목을 찾습니다.
    Map<String, dynamic>? userDoc = userDocs.firstWhere(
          (userDoc) => userDoc['uid'] == chatDocUid,
      orElse: () => {},  // 일치하는 항목이 없을 경우 빈 Map 반환
    );

    // 찾은 문서에서 profileUrl 값을 반환합니다. 값이 없으면 기본값인 ''을 반환합니다.
    return userDoc['displayName'] ?? '탈퇴한회원';
  }

  String findStateMsg(String chatDocUid, List<Map<String, dynamic>> userDocs) {
    // userDocs 리스트에서 uid가 chatDocUid와 일치하는 첫 번째 항목을 찾습니다.
    Map<String, dynamic>? userDoc = userDocs.firstWhere(
          (userDoc) => userDoc['uid'] == chatDocUid,
      orElse: () => {},  // 일치하는 항목이 없을 경우 빈 Map 반환
    );

    // 찾은 문서에서 profileUrl 값을 반환합니다. 값이 없으면 기본값인 ''을 반환합니다.
    return userDoc['stateMsg'] ?? '';
  }

}
