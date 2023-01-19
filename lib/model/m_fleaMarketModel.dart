import 'package:cloud_firestore/cloud_firestore.dart';

class FleaModel {

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  Future<void> uploadFleaItem(
      {
        required displayName,
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
        timeStamp,
       required fleaCount,
       required resortNickname
      }) async{

    await ref
        .collection('fleaMarket')
        .doc('$uid#$fleaCount')
        .set({
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
      'fleaCount' : fleaCount,
      'resortNickname' : resortNickname,
      'soldOut' : false,

    });
  }

}

List<dynamic> fleaCategoryList = [
  '데크',
  '바인딩',
  '부츠',
  '의류',
  '기타'
];

List<dynamic> fleaLocationList = [
  '곤지암리조트',
  '무주덕유산리조트',
  '비발디파크',
  '알펜시아',
  '에덴벨리리조트',
  '엘리시안강촌',
  '오크밸리리조트',
  '오투리조트',
  '용평리조트',
  '웰리힐리파크',
  '지산리조트',
  '하이원리조트',
  '휘닉스평창',
  '기타지역'
];

List<dynamic> fleaMethodList = [
  '직거래',
  '택배거래',
  '무관',
  ];