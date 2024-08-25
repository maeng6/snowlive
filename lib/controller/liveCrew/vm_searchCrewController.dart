import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../model_2/m_liveCrewModel.dart';


class SearchCrewController extends GetxController{

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
  }





  Future<bool> checkDuplicateCrewName(String CrewName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewName', isEqualTo: CrewName)
        .get();
    return querySnapshot.docs.isEmpty;
  }//회원 닉네임 중복방지



}