import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {

  UserModel({
    this.uid,
    this.displayName,
    this.userEmail,
    this.favoriteResort,
    this.instantResort,
    this.profileImageUrl,
    this.exist,
    this.commentCount,
    this.fleaCount,
    this.bulletinRoomCount,
    this.resortNickname,
    this.phoneAuth,
    this.phoneNum,
    this.likeUidList,
    this.resistDate,
    this.newChat
  });

  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  String? uid;
  String? displayName;
  String? userEmail;
  int? favoriteResort;
  int? instantResort;
  int? commentCount;
  int? fleaCount;
  int? bulletinRoomCount;
  String? profileImageUrl;
  bool? exist;
  DocumentReference? reference;
  String? resortNickname;
  bool? phoneAuth;
  bool? newChat;
  String? phoneNum;
  List? likeUidList;
  List? fleaChatUidList;
  Timestamp? resistDate;

  UserModel.fromJson(dynamic json, this.reference) {
      uid = json['uid'];
      displayName = json['displayName'];
      userEmail = json['userEmail'];
      favoriteResort = json['favoriteResort'];
      instantResort = json['instantResort'];
      profileImageUrl = json['profileImageUrl'];
      commentCount = json['commentCount'];
      fleaCount = json['fleaCount'];
      bulletinRoomCount = json['bulletinRoomCount'];
      exist = json['exist'];
      resortNickname = json['resortNickname'];
      phoneAuth = json['phoneAuth'];
      phoneNum = json['phoneNum'];
      likeUidList = json['likeUidList'];
      resistDate = json['resistDate'];
      fleaChatUidList = json['fleaChatUidList'];
      newChat = json['newChat'];

  }

  UserModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson(snapshot.data(), snapshot.reference);


  Future<UserModel?> getUserModel(String uid) async {
    if (uid != null) {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
      if (documentSnapshot.exists) {
        UserModel userModel = UserModel.fromSnapShot(documentSnapshot);
        return userModel;
      }
    }
    return null;
  }


}

