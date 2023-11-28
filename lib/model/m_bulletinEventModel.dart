import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BulletinEventModel {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;

  BulletinEventModel(
      {this.displayName,
        this.uid,
        this.profileImageUrl,
        this.itemImagesUrl,
        this.title,
        this.category,
        this.location,
        this.description,
        this.bulletinEventCount,
        this.bulletinEventReplyCount,
        this.resortNickname,
        this.timeStamp,
        this.snsUrl,
      });

  String? displayName;
  String? uid;
  String? profileImageUrl;
  String? itemImagesUrl;
  String? title;
  String? category;
  String? location;
  String? description;
  int? bulletinEventCount;
  int? bulletinEventReplyCount;
  String? resortNickname;
  Timestamp? timeStamp;
  bool? soldOut;
  DocumentReference? reference;
  String? snsUrl;

  BulletinEventModel.fromJson(dynamic json, this.reference) {
    displayName = json['displayName'];
    uid = json['uid'];
    profileImageUrl = json['profileImageUrl'];
    itemImagesUrl = json['itemImagesUrl'];
    title = json['title'];
    category = json['category'];
    location = json['location'];
    description = json['description'];
    timeStamp = json['timeStamp'];
    bulletinEventCount = json['bulletinEventCount'];
    bulletinEventReplyCount = json['bulletinEventReplyCount'];
    resortNickname = json['resortNickname'];
    soldOut = json['soldOut'];
    snsUrl = json['snsUrl'];
  }

  BulletinEventModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<BulletinEventModel> getBulletinEventModel(String uid,int bulletinEventCount) async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinEvent').doc('$uid#$bulletinEventCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    BulletinEventModel bulletinEventModel = BulletinEventModel.fromSnapShot(documentSnapshot);
    return bulletinEventModel;
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
        timeStamp,
        required bulletinEventCount,
        required resortNickname,
        required snsUrl,
      }) async {
    await ref.collection('bulletinEvent').doc('$uid#$bulletinEventCount').set({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrl': itemImagesUrl,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'timeStamp': Timestamp.now(),
      'bulletinEventCount': bulletinEventCount,
      'bulletinEventReplyCount': 0,
      'resortNickname': resortNickname,
      'soldOut': false,
      'viewerUid': [],
      'lock': false,
      'snsUrl': snsUrl,
    });
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
        timeStamp,
        required bulletinEventCount,
        required resortNickname,
        required snsUrl,
      }) async {
    await ref.collection('bulletinEvent').doc('$uid#$bulletinEventCount').update({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrl': itemImagesUrl,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'bulletinEventCount': bulletinEventCount,
      'timeStamp': Timestamp.now(),
      'resortNickname': resortNickname,
      'soldOut': false,
      'viewerUid': [],
      'snsUrl': snsUrl,
    });
  }

}

List<dynamic> bulletinEventResortList = [
  '전국',
  '곤지암리조트',
  '무주덕유산리조트',
  '비발디파크',
  '알펜시아',
  '에덴밸리리조트',
  '엘리시안강촌',
  '오크밸리리조트',
  '오투리조트',
  '용평리조트',
  '웰리힐리파크',
  '지산리조트',
  '하이원리조트',
  '휘닉스파크',
];

List<dynamic> bulletinEventCategoryList = [
  '클리닉(무료)',
  '클리닉(유료)',
  '시승회',
  '기타',
];