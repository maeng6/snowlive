import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrewModel {

  CrewModel({
    this.baseResort,
    this.baseResortNickName,
    this.crewColor,
    this.crewName,
    this.description,
    this.leaderUid,
    this.memberUidList,
    this.profileImageUrl,
    this.resistDate,
    this.crewID,
  });

  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;

  int? baseResort;
  String? baseResortNickName;
  int? crewColor;
  String? crewName;
  String? description;
  String? leaderUid;
  List? memberUidList;
  String? profileImageUrl;
  Timestamp? resistDate;
  String? crewID;
  DocumentReference? reference;

  CrewModel.fromJson(dynamic json, this.reference) {

    baseResort = json['baseResort'];
    baseResortNickName = json['baseResortNickName'];
    crewColor = json['crewColor'];
    crewName = json['crewName'];
    description = json['description'];
    leaderUid = json['leaderUid'];
    memberUidList = json['memberUidList'];
    profileImageUrl = json['profileImageUrl'];
    resistDate = json['resistDate'];
    crewID = json['crewID'];


  }

  CrewModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson(snapshot.data(), snapshot.reference);


  Future<CrewModel?> getCrewModel(String crewName) async {
    if (crewName != null) {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('liveCrew').doc(crewName);
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
      if (documentSnapshot.exists) {
        CrewModel crewModel = CrewModel.fromSnapShot(documentSnapshot);
        return crewModel;
      }
    }
    return null;
  }


}

