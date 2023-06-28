import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../model/m_resortModel.dart';

class LiveCrewModelController extends GetxController {

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<bool> checkDuplicateCrewName(String crewName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewName', isEqualTo: crewName)
        .get();
    return querySnapshot.docs.isEmpty;
  }//크루명 중복방지



  Future<void> createCrewDoc({
    required crewLeader,
    required crewName,
    required resortNum,
    required crewImageUrl,
    required crewColor,
    required crewID
} ) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    int colorValue = crewColor.value;
    await ref.collection('liveCrew').doc(crewID).set({
      'crewID' : crewID,
      'crewName' : crewName,
      'crewLeader': crewLeader,
      'crewColor': colorValue,
      'leaderUid': uid,
      'baseResortNickName' : nicknameList[resortNum],
      'baseResort': resortNum,
      'profileImageUrl' : crewImageUrl,
      'memberUidList' : FieldValue.arrayUnion([uid]),
      'description':'',
      'resistDate' : Timestamp.now(),
    });
  }

  Future<void> deleteCrew({required crewID}) async {
    try {
      CollectionReference crews = FirebaseFirestore.instance.collection('liveCrew');
      await crews.doc(crewID).delete();

    }catch(e){
      print('삭제 에러');
    }
  }




}