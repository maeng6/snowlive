import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:snowlive3/model/m_commentModel.dart';
import 'package:snowlive3/model/m_fleaChatModel.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

class NoticeController extends GetxController {

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    await getIsNewNotice();
  }

  RxBool? _isNewNotice = false.obs;

  bool? get isNewNotice => _isNewNotice!.value;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;


  Future<void> getIsNewNotice() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('newNotice').doc('YFaW31P1Omt53LQk3vO9');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    bool isNewNotice = documentSnapshot.get('new');
    this._isNewNotice!.value = isNewNotice;
  }

}