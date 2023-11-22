import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FleaModel {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;

  FleaModel(
      {this.displayName,
      this.uid,
      this.profileImageUrl,
      this.itemImagesUrls,
      this.title,
      this.category,
      this.itemName,
      this.price,
      this.location,
      this.method,
      this.description,
      this.fleaCount,
      this.resortNickname,
      this.kakaoUrl,
      this.timeStamp});

  String? displayName;
  String? uid;
  String? profileImageUrl;
  List? itemImagesUrls;
  String? title;
  String? category;
  String? itemName;
  int? price;
  String? location;
  String? method;
  String? description;
  int? fleaCount;
  String? resortNickname;
  String? kakaoUrl;
  Timestamp? timeStamp;
  bool? soldOut;
  DocumentReference? reference;

  FleaModel.fromJson(dynamic json, this.reference) {
    displayName = json['displayName'];
    uid = json['uid'];
    profileImageUrl = json['profileImageUrl'];
    itemImagesUrls = json['itemImagesUrls'];
    title = json['title'];
    category = json['category'];
    itemName = json['itemName'];
    price = json['price'];
    location = json['location'];
    method = json['method'];
    description = json['description'];
    timeStamp = json['timeStamp'];
    fleaCount = json['fleaCount'];
    resortNickname = json['resortNickname'];
    kakaoUrl = json['kakaoUrl'];
    soldOut = json['soldOut'];
  }

  FleaModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<FleaModel> getFleaModel(String uid,int fleaCount) async {
    DocumentReference<Map<String, dynamic>> documentReference =
        ref.collection('fleaMarket').doc('$uid#$fleaCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
    FleaModel fleaModel = FleaModel.fromSnapShot(documentSnapshot);
    return fleaModel;
  }

  Future<void> uploadFleaItem(
      {required displayName,
      required uid,
      required profileImageUrl,
      required itemImagesUrls,
      required title,
      required category,
      required itemName,
      required price,
      required location,
      required method,
      required description,
      required kakaoUrl,
      timeStamp,
      required fleaCount,
      required resortNickname}) async {
    await ref.collection('fleaMarket').doc('$uid#$fleaCount').set({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrls': itemImagesUrls,
      'title': title,
      'category': category,
      'itemName': itemName,
      'price': price,
      'location': location,
      'method': method,
      'description': description,
      'timeStamp': Timestamp.now(),
      'fleaCount': fleaCount,
      'resortNickname': resortNickname,
      'kakaoUrl': kakaoUrl,
      'soldOut': false,
      'viewerUid': [],
      'lock': false,
    });
  }

  Future<void> updateFleaItem(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required itemName,
        required price,
        required location,
        required method,
        required description,
        required kakaoUrl,
        timeStamp,
        required fleaCount,
        required resortNickname}) async {
    await ref.collection('fleaMarket').doc('$uid#$fleaCount').update({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'itemImagesUrls': itemImagesUrls,
      'title': title,
      'category': category,
      'itemName': itemName,
      'price': price,
      'location': location,
      'method': method,
      'description': description,
      'timeStamp': Timestamp.now(),
      'fleaCount': fleaCount,
      'resortNickname': resortNickname,
      'soldOut': false,
      'kakaoUrl': kakaoUrl,
    });
  }

}

List<dynamic> fleaCategoryList = ['데크', '바인딩', '부츠', '의류','플레이트', '기타'];

List<dynamic> fleaLocationList = [
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
  '기타지역'
];

List<dynamic> fleaMethodList = [
  '직거래',
  '택배거래',
  '무관',
];
