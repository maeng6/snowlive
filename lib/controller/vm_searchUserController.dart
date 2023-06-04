import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/m_userModel.dart';

class SearchUserController extends GetxController{

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
  }



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



}