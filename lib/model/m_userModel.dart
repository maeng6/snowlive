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
    this.resortNickname
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
  String? profileImageUrl;
  bool? exist;
  DocumentReference? reference;
  String? resortNickname;

  UserModel.fromJson(dynamic json, this.reference) {
      uid = json['uid'];
      displayName = json['displayName'];
      userEmail = json['userEmail'];
      favoriteResort = json['favoriteResort'];
      instantResort = json['instantResort'];
      profileImageUrl = json['profileImageUrl'];
      commentCount = json['commentCount'];
      fleaCount = json['fleaCount'];
      exist = json['exist'];
      resortNickname = json['resortNickname'];


  }

  UserModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson(snapshot.data(), snapshot.reference);

  Future<UserModel> getUserModel(String uid) async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    UserModel userModel = UserModel.fromSnapShot(documentSnapshot);
    return userModel;
  }


}

