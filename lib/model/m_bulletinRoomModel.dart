import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BulletinRoomModel {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;

  BulletinRoomModel(
      {this.displayName,
        this.uid,
        this.profileImageUrl,
        this.itemImagesUrls,
        this.title,
        this.category,
        this.location,
        this.description,
        this.bulletinRoomCount,
        this.resortNickname,
        this.timeStamp});

  String? displayName;
  String? uid;
  String? profileImageUrl;
  List? itemImagesUrls;
  String? title;
  String? category;
  String? location;
  String? description;
  int? bulletinRoomCount;
  int? bulletinRoomReplyCount;
  String? resortNickname;
  Timestamp? timeStamp;
  bool? soldOut;
  DocumentReference? reference;

  BulletinRoomModel.fromJson(dynamic json, this.reference) {
    displayName = json['displayName'];
    uid = json['uid'];
    profileImageUrl = json['profileImageUrl'];
    itemImagesUrls = json['itemImagesUrls'];
    title = json['title'];
    category = json['category'];
    location = json['location'];
    description = json['description'];
    timeStamp = json['timeStamp'];
    bulletinRoomCount = json['bulletinRoomCount'];
    bulletinRoomReplyCount = json['bulletinRoomReplyCount'];
    resortNickname = json['resortNickname'];
    soldOut = json['soldOut'];
  }

  BulletinRoomModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<BulletinRoomModel> getBulletinRoomModel(String uid,int bulletinRoomCount) async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinRoom').doc('$uid#$bulletinRoomCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    BulletinRoomModel bulletinRoomModel = BulletinRoomModel.fromSnapShot(documentSnapshot);
    return bulletinRoomModel;
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
        timeStamp,
        required bulletinRoomCount,
        required resortNickname}) async {
    await ref.collection('bulletinRoom').doc('$uid#$bulletinRoomCount').set({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrls': itemImagesUrls,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'timeStamp': Timestamp.now(),
      'bulletinRoomCount': bulletinRoomCount,
      'bulletinRoomReplyCount': 0,
      'resortNickname': resortNickname,
      'soldOut': false,
      'viewerUid': [],
      'lock': false,
    });
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
        timeStamp,
        required bulletinRoomCount,
        required resortNickname}) async {
    await ref.collection('bulletinRoom').doc('$uid#$bulletinRoomCount').update({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrls': itemImagesUrls,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'bulletinRoomCount': bulletinRoomCount,
      'timeStamp': Timestamp.now(),
      'resortNickname': resortNickname,
      'soldOut': false,
    });
  }

}

List<dynamic> bulletinRoomResortList = [
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
  '휘닉스파크'
];

List<dynamic> bulletinRoomCategoryList = [
  '방 임대',
  '방 구해요',
  '주주모집'
];