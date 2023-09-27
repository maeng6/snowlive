import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_commentModel.dart';
import '../model/m_bulletinCrewModel.dart';
class BulletinCrewModelController extends GetxController {
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _displayName = ''.obs;
  RxString? _uid = ''.obs;
  RxString? _profileImageUrl = ''.obs;
  RxList? _itemImagesUrls = [].obs;
  RxString? _title = ''.obs;
  RxString? _category = ''.obs;
  RxString? _location = ''.obs;
  RxString? _description = ''.obs;
  RxInt? _bulletinCrewCount = 0.obs;
  RxInt? _bulletinCrewReplyCount = 0.obs;
  RxString? _resortNickname = ''.obs;
  RxBool? _soldOut = false.obs;
  Timestamp? _timeStamp;

  String? get displayName => _displayName!.value;

  String? get uid => _uid!.value;

  String? get profileImageUrl => _profileImageUrl!.value;

  List? get itemImagesUrls => _itemImagesUrls!.value;

  String? get title => _title!.value;

  String? get category => _category!.value;

  String? get location => _location!.value;

  String? get description => _description!.value;

  int? get bulletinCrewCount => _bulletinCrewCount!.value;

  int? get bulletinCrewReplyCount => _bulletinCrewReplyCount!.value;

  String? get resortNickname => _resortNickname!.value;

  bool? get soldOut => _soldOut!.value;

  Timestamp? get timeStamp => _timeStamp;

  Future<void> getCurrentBulletinCrew({required uid, required bulletinCrewCount}) async {
    BulletinCrewModel bulletinCrewModel = await BulletinCrewModel().getBulletinCrewModel(uid,bulletinCrewCount);
    this._displayName!.value = bulletinCrewModel.displayName!;
    this._uid!.value = bulletinCrewModel.uid!;
    this._profileImageUrl!.value = bulletinCrewModel.profileImageUrl!;
    this._itemImagesUrls!.value = bulletinCrewModel.itemImagesUrls!;
    this._title!.value = bulletinCrewModel.title!;
    this._category!.value = bulletinCrewModel.category!;
    this._location!.value = bulletinCrewModel.location!;
    this._description!.value = bulletinCrewModel.description!;
    this._bulletinCrewCount!.value = bulletinCrewModel.bulletinCrewCount!;
    this._bulletinCrewReplyCount!.value = bulletinCrewModel.bulletinCrewReplyCount!;
    this._resortNickname!.value = bulletinCrewModel.resortNickname!;
    this._soldOut!.value = bulletinCrewModel.soldOut!;
    this._timeStamp = bulletinCrewModel.timeStamp!;
  }

  Future<void> updateItemImageUrls(imageUrls) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('bulletinCrew').doc('$uid#$bulletinCrewCount').update({
      'itemImagesUrls': imageUrls,
    });
    await getCurrentBulletinCrew(uid: uid, bulletinCrewCount: bulletinCrewCount);
  }

  Future<void> deleteBulletinCrewImage({required uid, required bulletinCrewCount, required imageCount}) async{
    print('$uid#$bulletinCrewCount');
    for (int i = imageCount-1; i > -1; i--) {
      print('#$i.jpg');
    await FirebaseStorage.instance.ref().child('images/bulletinCrew/$uid#$bulletinCrewCount/#$i.jpg').delete();
    }
  }

  Future<void> updateState(isSoldOut) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    if(isSoldOut == false) {
      await ref.collection('bulletinCrew').doc('$uid#$bulletinCrewCount').update({
        'soldOut': true,
      });
    }else{
      await ref.collection('bulletinCrew').doc('$uid#$bulletinCrewCount').update({
        'soldOut': false,
      });
    }
    await getCurrentBulletinCrew(uid: uid, bulletinCrewCount: bulletinCrewCount);
  }

  Future<void> updateViewerUid() async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('bulletinCrew').doc('$uid#$bulletinCrewCount').update({
      'viewerUid': FieldValue.arrayUnion([userMe])
    });
  }

  Future<void> lock(uid) async {
    try {

      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinCrew').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      bool isLock = documentSnapshot.get('lock');

      if(isLock == false) {
        await ref.collection('bulletinCrew').doc(uid).update({
          'lock': true,
        });
      }else {
        await ref.collection('bulletinCrew').doc(uid).update({
          'lock': false,
        });
      }
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> uploadBulletinCrew(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required location,
        required description,
        required bulletinCrewCount,
        required resortNickname}) async {
    await BulletinCrewModel().uploadBulletinCrew(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrls: itemImagesUrls,
        title: title,
        category: category,
        location: location,
        description: description,
        bulletinCrewCount: bulletinCrewCount,
        resortNickname: resortNickname);
  }

  Future<void> updateBulletinCrew(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required location,
        required description,
        required bulletinCrewCount,
        required resortNickname}) async {
    await BulletinCrewModel().updateBulletinCrew(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrls: itemImagesUrls,
        title: title,
        category: category,
        location: location,
        description: description,
        bulletinCrewCount: bulletinCrewCount,
        resortNickname: resortNickname);
  }

  Future<void> updateBulletinCrewReplyCount({required bullUid, required bullCount}) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinCrew').doc('$bullUid#$bullCount');

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinCrewReplyCount = documentSnapshot.get('bulletinCrewReplyCount');
      int bulletinCrewReplyCountPlus = bulletinCrewReplyCount + 1;

      await ref.collection('bulletinCrew').doc('$bullUid#$bullCount').update({
        'bulletinCrewReplyCount': bulletinCrewReplyCountPlus,
      });
    }catch(e){
      await ref.collection('bulletinCrew').doc('$bullUid#$bullCount').update({
        'bulletinCrewReplyCount': 1,
      });
    }
  }

  Future<void> reduceBulletinCrewReplyCount({required bullUid, required bullCount}) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinCrew').doc('$bullUid#$bullCount');

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinCrewReplyCount = documentSnapshot.get('bulletinCrewReplyCount');
      int bulletinCrewReplyCountPlus = bulletinCrewReplyCount - 1;

      await ref.collection('bulletinCrew').doc('$bullUid#$bullCount').update({
        'bulletinCrewReplyCount': bulletinCrewReplyCountPlus,
      });
    }catch(e){}
  }

  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }



}


