import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BulletinLostModel {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;

  BulletinLostModel(
      {this.displayName,
        this.uid,
        this.profileImageUrl,
        this.itemImagesUrls,
        this.title,
        this.category,
        this.description,
        this.bulletinLostCount,
        this.resortNickname,
        this.likeCount,
        this.timeStamp,
        this.score,
        this.hot,
        this.viewerUid
      });

  String? displayName;
  String? uid;
  String? profileImageUrl;
  List? itemImagesUrls;
  String? title;
  String? category;
  String? description;
  int? bulletinLostCount;
  int? bulletinLostReplyCount;
  String? resortNickname;
  Timestamp? timeStamp;
  int? likeCount;
  bool? soldOut;
  DocumentReference? reference;
  double? score;
  bool? hot;
  List? viewerUid;

  BulletinLostModel.fromJson(dynamic json, this.reference) {
    displayName = json['displayName'];
    uid = json['uid'];
    profileImageUrl = json['profileImageUrl'];
    itemImagesUrls = json['itemImagesUrls'];
    title = json['title'];
    category = json['category'];
    description = json['description'];
    timeStamp = json['timeStamp'];
    bulletinLostCount = json['bulletinLostCount'];
    bulletinLostReplyCount = json['bulletinLostReplyCount'];
    resortNickname = json['resortNickname'];
    soldOut = json['soldOut'];
    likeCount = json['likeCount'];
    score =  json['score']?.toDouble() ?? 0.0;
    hot = json['hot'];
    viewerUid = json['viewerUid'];
  }

  BulletinLostModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<BulletinLostModel> getBulletinLostModel(String uid,int bulletinLostCount) async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinLost').doc('$uid#$bulletinLostCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    BulletinLostModel bulletinLostModel = BulletinLostModel.fromSnapShot(documentSnapshot);
    return bulletinLostModel;
  }

  Future<void> uploadBulletinLost(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required description,
        timeStamp,
        required bulletinLostCount,
        required resortNickname}) async {
    await ref.collection('bulletinLost').doc('$uid#$bulletinLostCount').set({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrls': itemImagesUrls,
      'title': title,
      'category': category,
      'description': description,
      'timeStamp': Timestamp.now(),
      'bulletinLostCount': bulletinLostCount,
      'bulletinLostReplyCount': 0,
      'resortNickname': resortNickname,
      'soldOut': false,
      'viewerUid': [],
      'lock': false,
      'hot': false,
      'score': 0,
      'likeCount':0
    });
  }

  Future<void> updateBulletinLost(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required description,
        required likeCount,
        required timeStamp,
        required bulletinLostCount,
        required resortNickname,
        required score,
        required hot,
        required viewerUid,
      }) async {
    await ref.collection('bulletinLost').doc('$uid#$bulletinLostCount').update({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrls': itemImagesUrls,
      'title': title,
      'category': category,
      'description': description,
      'bulletinLostCount': bulletinLostCount,
      'timeStamp': timeStamp,
      'resortNickname': resortNickname,
      'soldOut': false,
      'likeCount':likeCount,
      'score':score,
      'hot':hot,
      'viewerUid':viewerUid,
    });
  }

}

List<dynamic> bulletinLostResortList = [
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

List<dynamic> bulletinLostCategoryList = [
  '분실물',
  '습득물',
  '기타',
];