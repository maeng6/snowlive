import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BulletinCrewModel {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;

  BulletinCrewModel(
      {this.displayName,
      this.uid,
      this.profileImageUrl,
      this.itemImagesUrls,
      this.title,
      this.category,
      this.location,
      this.description,
      this.bulletinCrewCount,
      this.bulletinCrewReplyCount,
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
  int? bulletinCrewCount;
  int? bulletinCrewReplyCount;
  String? resortNickname;
  Timestamp? timeStamp;
  bool? soldOut;
  DocumentReference? reference;

  BulletinCrewModel.fromJson(dynamic json, this.reference) {
    displayName = json['displayName'];
    uid = json['uid'];
    profileImageUrl = json['profileImageUrl'];
    itemImagesUrls = json['itemImagesUrls'];
    title = json['title'];
    category = json['category'];
    location = json['location'];
    description = json['description'];
    timeStamp = json['timeStamp'];
    bulletinCrewCount = json['bulletinCrewCount'];
    bulletinCrewReplyCount = json['bulletinCrewReplyCount'];
    resortNickname = json['resortNickname'];
    soldOut = json['soldOut'];
  }

  BulletinCrewModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<BulletinCrewModel> getBulletinCrewModel(String uid,int bulletinCrewCount) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        ref.collection('bulletinCrew').doc('$uid#$bulletinCrewCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
    BulletinCrewModel bulletinCrewModel = BulletinCrewModel.fromSnapShot(documentSnapshot);
    return bulletinCrewModel;
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
      timeStamp,
      required bulletinCrewCount,
      required resortNickname}) async {
    await ref.collection('bulletinCrew').doc('$uid#$bulletinCrewCount').set({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrls': itemImagesUrls,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'timeStamp': Timestamp.now(),
      'bulletinCrewCount': bulletinCrewCount,
      'bulletinCrewReplyCount': 0,
      'resortNickname': resortNickname,
      'soldOut': false,
      'viewerUid': [],
    });
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
        timeStamp,
        required bulletinCrewCount,
        required resortNickname}) async {
    await ref.collection('bulletinCrew').doc('$uid#$bulletinCrewCount').update({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrls': itemImagesUrls,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'bulletinCrewCount': bulletinCrewCount,
      'timeStamp': Timestamp.now(),
      'resortNickname': resortNickname,
      'soldOut': false,
      'viewerUid': [],
    });
  }

}

List<dynamic> bulletinCrewResortList = [
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
  '휘닉스평창',
];

List<dynamic> bulletinCrewCategoryList = [
  '단톡방',
  '동호회(크루)',
  '기타'
];