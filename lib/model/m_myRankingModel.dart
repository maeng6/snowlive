import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../controller/vm_seasonController.dart';
import '../controller/vm_userModelController.dart';

class MyRankingModel {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  //TODO: Dependency Injection**************************************************

  MyRankingModel({
    this.lastPassTime,
    this.passCountData,
    this.passCountTimeData,
    this.slopeScores,
    this.tier,
    this.totalPassCount,
    this.totalScore,
    this.uid,
  });

  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  DocumentReference? reference;

  Timestamp? lastPassTime;
  Map? passCountData;
  Map? passCountTimeData;
  Map? slopeScores;
  String? tier;
  int? totalPassCount;
  int? totalScore;
  String? uid;

  MyRankingModel.fromJson(dynamic json, this.reference) {
    lastPassTime = json['lastPassTime'];
    passCountData = json['passCountData'];
    passCountTimeData = json['passCountTimeData'];
    slopeScores = json['slopeScores'];
    tier = json['tier'];
    totalPassCount = json['totalPassCount'];
    totalScore = json['totalScore'];
    uid = json['uid'];
    print('점수 가져오기 성공');
  }

  MyRankingModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson(snapshot.data(), snapshot.reference);

  Future<MyRankingModel?> getMyRankingModel(String uid) async {

    if (uid != null) {

      try {
        DocumentReference<Map<String, dynamic>> documentReference =
        ref.collection('Ranking')
            .doc('${_seasonController.currentSeason}')
            .collection('${_userModelController.favoriteResort}')
            .doc('$uid');
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
        if (documentSnapshot.exists) {
          MyRankingModel myRankingModel = MyRankingModel.fromSnapShot(documentSnapshot);

          return myRankingModel;
        }
      }catch(e){

      }
    }
    return null;
  }



}

