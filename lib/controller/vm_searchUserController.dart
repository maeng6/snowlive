import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import '../model/m_userModel.dart';

class SearchUserController extends GetxController{

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
  }

// TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  // TODO: Dependency Injection**************************************************


  Future<dynamic> searchUsersByDisplayName(String displayName) async {
    var foundUid ;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('displayName', isEqualTo: displayName)
        .get();

    final List<UserModel> users = [];
    for (final doc in querySnapshot.docs) {
      final user = await UserModel.fromJson(doc.data(),doc.reference);
      users.add(user);

      foundUid = user.uid;
    }
    return foundUid;

  }

  Future<dynamic> searchUsersTier({required uid}) async {
    var foundTier ;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Ranking')
        .doc('${_seasonController.currentSeason}')
        .collection('${_userModelController.favoriteResort}')
        .where('uid', isEqualTo: uid )
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      foundTier = querySnapshot.docs[0]['tier'];
    } else {
      foundTier = '';
    }

    return foundTier;

  }


  Future<dynamic> searchUsersCrewName({required uid}) async {
    var foundCrewName ;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('memberUidList', arrayContains: uid )
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      foundCrewName = querySnapshot.docs[0]['crewName'];
    } else {
      foundCrewName = '';
    }

    return foundCrewName;

  }



}