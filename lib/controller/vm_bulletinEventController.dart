import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_commentModel.dart';
import '../model/m_bulletinCrewModel.dart';
import '../model/m_bulletinEventModel.dart';
class BulletinEventModelController extends GetxController {
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _displayName = ''.obs;
  RxString? _uid = ''.obs;
  RxString? _profileImageUrl = ''.obs;
  RxString? _itemImagesUrl = ''.obs;
  RxString? _title = ''.obs;
  RxString? _category = ''.obs;
  RxString? _location = ''.obs;
  RxString? _description = ''.obs;
  RxInt? _bulletinEventCount = 0.obs;
  RxInt? _bulletinEventReplyCount = 0.obs;
  RxString? _resortNickname = ''.obs;
  RxBool? _soldOut = false.obs;
  Timestamp? _timeStamp;

  String? get displayName => _displayName!.value;

  String? get uid => _uid!.value;

  String? get profileImageUrl => _profileImageUrl!.value;

  String? get itemImagesUrl => _itemImagesUrl!.value;

  String? get title => _title!.value;

  String? get category => _category!.value;

  String? get location => _location!.value;

  String? get description => _description!.value;

  int? get bulletinEventCount => _bulletinEventCount!.value;

  int? get bulletinEventReplyCount => _bulletinEventReplyCount!.value;

  String? get resortNickname => _resortNickname!.value;

  bool? get soldOut => _soldOut!.value;

  Timestamp? get timeStamp => _timeStamp;

  Future<void> getCurrentBulletinEvent({required uid, required bulletinEventCount}) async {
    BulletinEventModel bulletinEventModel = await BulletinEventModel().getBulletinEventModel(uid,bulletinEventCount);
    this._displayName!.value = bulletinEventModel.displayName!;
    this._uid!.value = bulletinEventModel.uid!;
    this._profileImageUrl!.value = bulletinEventModel.profileImageUrl!;
    this._itemImagesUrl!.value = bulletinEventModel.itemImagesUrl!;
    this._title!.value = bulletinEventModel.title!;
    this._category!.value = bulletinEventModel.category!;
    this._location!.value = bulletinEventModel.location!;
    this._description!.value = bulletinEventModel.description!;
    this._bulletinEventCount!.value = bulletinEventModel.bulletinEventCount!;
    this._bulletinEventReplyCount!.value = bulletinEventModel.bulletinEventReplyCount!;
    this._resortNickname!.value = bulletinEventModel.resortNickname!;
    this._soldOut!.value = bulletinEventModel.soldOut!;
    this._timeStamp = bulletinEventModel.timeStamp!;
  }

  Future<void> updateItemImageUrl(imageUrl) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('bulletinEvent').doc('$uid#$bulletinEventCount').update({
      'itemImagesUrl': imageUrl,
    });
    await getCurrentBulletinEvent(uid: uid, bulletinEventCount: bulletinEventCount);
  }

  Future<void> deleteBulletinEventImage({required uid, required bulletinEventCount, required imageCount}) async{
    print('$uid#$bulletinEventCount');
    for (int i = imageCount-1; i > -1; i--) {
      print('#$i.jpg');
      await FirebaseStorage.instance.ref().child('images/bulletinEvent/$uid#$bulletinEventCount/#$i.jpg').delete();
    }
  }

  Future<void> updateState(isSoldOut) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    if(isSoldOut == false) {
      await ref.collection('bulletinEvent').doc('$uid#$bulletinEventCount').update({
        'soldOut': true,
      });
    }else{
      await ref.collection('bulletinEvent').doc('$uid#$bulletinEventCount').update({
        'soldOut': false,
      });
    }
    await getCurrentBulletinEvent(uid: uid, bulletinEventCount: bulletinEventCount);
  }

  Future<void> updateViewerUid() async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('bulletinEvent').doc('$uid#$bulletinEventCount').update({
      'viewerUid': FieldValue.arrayUnion([userMe])
    });
  }

  Future<void> lock(uid) async {
    try {

      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinEvent').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      bool isLock = documentSnapshot.get('lock');

      if(isLock == false) {
        await ref.collection('bulletinEvent').doc(uid).update({
          'lock': true,
        });
      }else {
        await ref.collection('bulletinEvent').doc(uid).update({
          'lock': false,
        });
      }
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> uploadBulletinEvent(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrl,
        required title,
        required category,
        required location,
        required description,
        required bulletinEventCount,
        required resortNickname}) async {
    await BulletinEventModel().uploadBulletinEvent(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrl: itemImagesUrl,
        title: title,
        category: category,
        location: location,
        description: description,
        bulletinEventCount: bulletinEventCount,
        resortNickname: resortNickname);
  }

  Future<void> updateBulletinEvent(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrl,
        required title,
        required category,
        required location,
        required description,
        required bulletinEventCount,
        required resortNickname}) async {
    await BulletinEventModel().updateBulletinEvent(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrl: itemImagesUrl,
        title: title,
        category: category,
        location: location,
        description: description,
        bulletinEventCount: bulletinEventCount,
        resortNickname: resortNickname);
  }

  Future<void> updateBulletinEventReplyCount({required bullUid, required bullCount}) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinEvent').doc('$bullUid#$bullCount');

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinEventReplyCount = documentSnapshot.get('bulletinEventReplyCount');
      int bulletinEventReplyCountPlus = bulletinEventReplyCount + 1;

      await ref.collection('bulletinEvent').doc('$bullUid#$bullCount').update({
        'bulletinEventReplyCount': bulletinEventReplyCountPlus,
      });
    }catch(e){
      await ref.collection('bulletinEvent').doc('$bullUid#$bullCount').update({
        'bulletinEventReplyCount': 1,
      });
    }
  }

  Future<void> reduceBulletinEventReplyCount({required bullUid, required bullCount}) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinEvent').doc('$bullUid#$bullCount');

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinEventReplyCount = documentSnapshot.get('bulletinEventReplyCount');
      int bulletinEventReplyCountPlus = bulletinEventReplyCount - 1;

      await ref.collection('bulletinEvent').doc('$bullUid#$bullCount').update({
        'bulletinEventReplyCount': bulletinEventReplyCountPlus,
      });
    }catch(e){}
  }

  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }



}


