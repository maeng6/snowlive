import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {

  UserModel({
    this.uid,
    this.userEmail,
    this.favoriteResort,
    this.instantResort
});

  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  String? uid;
  String? userEmail;
  int? favoriteResort;
  int? instantResort;
  DocumentReference? reference;

  UserModel.fromJson(dynamic json, this.reference){
    uid = json['uid'];
    userEmail = json['userEmail'];
    favoriteResort = json['favoriteResort'];
    instantResort = json['instantResort'];
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

