import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:snowlive3/model/m_commentModel.dart';
import 'package:snowlive3/model/m_fleaMarketModel.dart';

import '../model/m_bulletinRoomModel.dart';

class BulletinRoomModelController extends GetxController {
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
  RxInt? _bulletinRoomCount = 0.obs;
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

  int? get bulletinRoomCount => _bulletinRoomCount!.value;

  String? get resortNickname => _resortNickname!.value;

  bool? get soldOut => _soldOut!.value;

  Timestamp? get timeStamp => _timeStamp;

  Future<void> getCurrentBulletinRoom({required uid, required bulletinRoomCount}) async {
    BulletinRoomModel bulletinRoomModel = await BulletinRoomModel().getBulletinRoomModel(uid,bulletinRoomCount);
    this._displayName!.value = bulletinRoomModel.displayName!;
    this._uid!.value = bulletinRoomModel.uid!;
    this._profileImageUrl!.value = bulletinRoomModel.profileImageUrl!;
    this._itemImagesUrls!.value = bulletinRoomModel.itemImagesUrls!;
    this._title!.value = bulletinRoomModel.title!;
    this._category!.value = bulletinRoomModel.category!;
    this._location!.value = bulletinRoomModel.location!;
    this._description!.value = bulletinRoomModel.description!;
    this._bulletinRoomCount!.value = bulletinRoomModel.bulletinRoomCount!;
    this._resortNickname!.value = bulletinRoomModel.resortNickname!;
    this._soldOut!.value = bulletinRoomModel.soldOut!;
    this._timeStamp = bulletinRoomModel.timeStamp!;
  }

  Future<void> updateItemImageUrls(imageUrls) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('bulletinRoom').doc('$uid#$bulletinRoomCount').update({
      'itemImagesUrls': imageUrls,
    });
    await getCurrentBulletinRoom(uid: uid, bulletinRoomCount: bulletinRoomCount);
  }

  Future<void> deleteBulletinRoomImage({required uid, required bulletinRoomCount, required imageCount}) async{
    print('$uid#$bulletinRoomCount');
    for (int i = imageCount-1; i > -1; i--) {
      print('#$i.jpg');
    await FirebaseStorage.instance.ref().child('images/bulletinRoom/$uid#$bulletinRoomCount/#$i.jpg').delete();
    }
  }

  Future<void> updateState(isSoldOut) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    if(isSoldOut == false) {
      await ref.collection('bulletinRoom').doc('$uid#$bulletinRoomCount').update({
        'soldOut': true,
      });
    }else{
      await ref.collection('bulletinRoom').doc('$uid#$bulletinRoomCount').update({
        'soldOut': false,
      });
    }
    await getCurrentBulletinRoom(uid: uid, bulletinRoomCount: bulletinRoomCount);
  }

  Future<void> uploadBulletinRoom(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required location,
        required description,
        required bulletinRoomCount,
        required resortNickname}) async {
    await BulletinRoomModel().uploadBulletinRoom(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrls: itemImagesUrls,
        title: title,
        category: category,
        location: location,
        description: description,
        bulletinRoomCount: bulletinRoomCount,
        resortNickname: resortNickname);
  }

  Future<void> updateBulletinRoom(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required location,
        required description,
        required bulletinRoomCount,
        required resortNickname}) async {
    await BulletinRoomModel().updateBulletinRoom(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrls: itemImagesUrls,
        title: title,
        category: category,
        location: location,
        description: description,
        bulletinRoomCount: bulletinRoomCount,
        resortNickname: resortNickname);
  }

  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }



}


