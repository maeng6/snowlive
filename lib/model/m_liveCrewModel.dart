import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snowlive3/model/m_timeStampModel.dart';

class LiveCrewModel {

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  LiveCrewModel({
    this.crewID,
    this.crewName,
    this.crewLeader,
    this.crewColor,
    this.leaderUid,
    this.baseResortNickName,
    this.baseResort,
    this.profileImageUrl,
    this.memberUidList,
    this.applyUidList,
    this.description,
    this.notice,
    this.resistDate,
  });

  String? crewID;
  String? crewName;
  String? crewLeader;
  int? crewColor;
  String? leaderUid;
  String? baseResortNickName;
  int? baseResort;
  String? profileImageUrl;
  List? memberUidList;
  List? applyUidList;
  String? description;
  String? notice;
  Timestamp? resistDate;
  DocumentReference? reference;

  LiveCrewModel.fromJson(dynamic json, this.reference) {
    crewID = json['crewID'];
    crewName = json['crewName'];
    crewLeader = json['crewLeader'];
    crewColor = json['crewColor'];
    leaderUid = json['leaderUid'];
    baseResortNickName = json['baseResortNickName'];
    baseResort = json['baseResort'];
    profileImageUrl = json['profileImageUrl'];
    memberUidList = json['memberUidList'];
    applyUidList = json['applyUidList'];
    description = json['description'];
    notice = json['notice'];
    resistDate = json['resistDate'];
    reference = json['reference'];

  }

  LiveCrewModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson(snapshot.data(), snapshot.reference);


  Future<LiveCrewModel?> getCrewModel(String crewID) async {
    if (crewID != null) {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('liveCrew').doc(crewID);
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
      if (documentSnapshot.exists) {
        LiveCrewModel crewModel = LiveCrewModel.fromSnapShot(documentSnapshot);
        return crewModel;
      }
    }
    return null;
  }


}

