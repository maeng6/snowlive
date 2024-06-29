import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NoticeController extends GetxController {

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    await getIsNewNotice();
    await getIsAndroidEmailLogIn();
  }

  RxBool? _isNewNotice = false.obs;
  RxBool? _isAndroidEmailLogIn = false.obs;

  bool? get isNewNotice => _isNewNotice!.value;
  bool? get isAndroidEmailLogIn => _isAndroidEmailLogIn!.value;

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

  Future<void> getIsAndroidEmailLogIn() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('emailLogIn').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    bool isAndroidEmailLogIn = documentSnapshot.get('visible');
    this._isAndroidEmailLogIn!.value = isAndroidEmailLogIn;
  }


}