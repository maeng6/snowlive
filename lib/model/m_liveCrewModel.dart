import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    this.galleryUrlList,
    this.description,
    this.notice,
    this.resistDate,
    this.lastPassTime,
    this.sns,
    this.passCountData,
    this.slopeScores,
    this.passCountTimeData,
    this.totalPassCount,
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
  List? galleryUrlList;
  String? description;
  String? notice;
  String? sns;
  Timestamp? resistDate;
  Timestamp? lastPassTime;
  DocumentReference? reference;
  Map? passCountData;
  Map? slopeScores;
  Map? passCountTimeData;
  int? totalPassCount;

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
    galleryUrlList = json['galleryUrlList'];
    description = json['description'];
    notice = json['notice'];
    resistDate = json['resistDate'];
    lastPassTime = json['lastPassTime'];
    reference = json['reference'];
    sns = json['sns'];
    passCountData = json['passCountData'];
    slopeScores = json['slopeScores'];
    passCountTimeData = json['passCountTimeData'];
    totalPassCount = json['totalPassCount'];

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
List<Color?> crewColorList = [
  Color(0xFFFFA835),
  Color(0xFF2EB6FF),
  Color(0xFFFF54A0),
  Color(0xFF10BB88),
  Color(0xFFB173FF),
  Color(0xFFFF5F18),
  Color(0xFF326EF6),
  Color(0xFFEF0069),
  Color(0xFF019D78),
  Color(0xFF772ED3),
];


