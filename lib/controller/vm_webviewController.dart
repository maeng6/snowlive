import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class WebviewController extends GetxController{


  Future<void> visitCountUpdate({required brandName}) async{

    DocumentReference<Map<String, dynamic>> documentReference =
    FirebaseFirestore.instance.collection('brandList').doc(brandName);

    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();

    int visitCount = documentSnapshot.get('visitCount');
    int visitCountPlus = visitCount + 1;

    await FirebaseFirestore.instance.collection('brandList').doc(brandName).update({
      'visitCount': visitCountPlus,
    });
  }


}