import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../model/m_crewModel.dart';

class SearchCrewController extends GetxController{

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
  }



  Future<dynamic> searchCrewByCrewName(String crewName) async {
    var foundCrewID ;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewName', isEqualTo: crewName)
        .get();

    final List<CrewModel> users = [];
    for (final doc in querySnapshot.docs) {
      final crew = await CrewModel.fromJson(doc.data(),doc.reference);
      users.add(crew);

      foundCrewID = crew.crewID;
    }
    return foundCrewID;

  }

  Future<CrewModel?> getFoundCrew(crewID) async{
    CrewModel? foundCrewModel= CrewModel();
    if(crewID != null) {
      foundCrewModel = await CrewModel().getCrewModel(crewID);
      if (foundCrewModel != null) {
        foundCrewModel.baseResort = foundCrewModel.baseResort!;
        foundCrewModel.baseResortNickName = foundCrewModel.baseResortNickName;
        foundCrewModel.crewColor = foundCrewModel.crewColor!;
        foundCrewModel.crewName = foundCrewModel.crewName!;
        foundCrewModel.description = foundCrewModel.description;
        foundCrewModel.leaderUid = foundCrewModel.leaderUid!;
        foundCrewModel.memberUidList = foundCrewModel.memberUidList!;
        foundCrewModel.profileImageUrl = foundCrewModel.profileImageUrl!;
        foundCrewModel.resistDate = foundCrewModel.resistDate!;
      } else {
        // handle the case where the userModel is null
      }
    } else{
    }
    return foundCrewModel;
  }

  Future<bool> checkDuplicateCrewName(String CrewName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewName', isEqualTo: CrewName)
        .get();
    return querySnapshot.docs.isEmpty;
  }//회원 닉네임 중복방지



}